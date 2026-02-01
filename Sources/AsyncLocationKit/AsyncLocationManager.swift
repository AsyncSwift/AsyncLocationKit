//  MIT License
//
//  Copyright (c) 2022 AsyncSwift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
@preconcurrency import CoreLocation

public typealias AuthorizationContinuation = CheckedContinuation<CLAuthorizationStatus, Never>
public typealias AccuracyAuthorizationContinuation = CheckedContinuation<CLAccuracyAuthorization?, Error>
public typealias LocationOnceContinuation = CheckedContinuation<LocationUpdateEvent?, Error>
public typealias LocationEnabledStream = AsyncStream<LocationEnabledEvent>
public typealias LocationStream = AsyncStream<LocationUpdateEvent>
public typealias RegionMonitoringStream = AsyncStream<RegionMonitoringEvent>
public typealias VisitMonitoringStream = AsyncStream<VisitMonitoringEvent>
public typealias SignificantLocationChangeMonitoringStream = AsyncStream<SignificantLocationChangeEvent>
public typealias HeadingMonitorStream = AsyncStream<HeadingMonitorEvent>
public typealias AuthorizationStream = AsyncStream<AuthorizationEvent>
public typealias AccuracyAuthorizationStream = AsyncStream<AccuracyAuthorizationEvent>
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public typealias BeaconsRangingStream = AsyncStream<BeaconRangeEvent>

/// Modern async/await wrapper for CoreLocation framework.
///
/// `AsyncLocationManager` provides a Swift concurrency-friendly interface to CoreLocation,
/// replacing delegate patterns with async/await and AsyncStream APIs.
///
/// - Important: Always initialize `AsyncLocationManager` synchronously on the main thread.
///
/// ## Example
/// ```swift
/// let manager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)
/// let status = await manager.requestPermission(with: .whenInUsage)
/// ```
///
/// ## Thread Safety
/// This class is thread-safe. All internal operations are synchronized via a serial dispatch queue.
public final class AsyncLocationManager: @unchecked Sendable {
    private var locationManager: CLLocationManager
    private var proxyDelegate: AsyncDelegateProxyInterface
    private var locationDelegate: CLLocationManagerDelegate

    /// Creates a new location manager with specified settings.
    ///
    /// This is the recommended initializer for most use cases.
    ///
    /// - Parameters:
    ///   - desiredAccuracy: The accuracy of location data. Default is `.bestAccuracy`.
    ///   - allowsBackgroundLocationUpdates: Whether to allow location updates in background. Default is `false`.
    ///
    /// - Important: Must be called on the main thread.
    public convenience init(desiredAccuracy: LocationAccuracy = .bestAccuracy, allowsBackgroundLocationUpdates: Bool = false) {
        self.init(locationManager: CLLocationManager(), desiredAccuracy: desiredAccuracy, allowsBackgroundLocationUpdates: allowsBackgroundLocationUpdates)
    }

    /// Creates a new location manager with a custom CLLocationManager instance.
    ///
    /// Use this initializer when you need to provide your own configured CLLocationManager.
    ///
    /// - Parameters:
    ///   - locationManager: A configured CLLocationManager instance.
    ///   - desiredAccuracy: The accuracy of location data. Default is `.bestAccuracy`.
    ///   - allowsBackgroundLocationUpdates: Whether to allow location updates in background. Default is `false`.
    ///
    /// - Important: Must be called on the main thread.
    public init(locationManager: CLLocationManager, desiredAccuracy: LocationAccuracy = .bestAccuracy, allowsBackgroundLocationUpdates: Bool = false) {
        self.locationManager = locationManager
        proxyDelegate = AsyncDelegateProxy()
        locationDelegate = LocationDelegate(delegateProxy: proxyDelegate)
        self.locationManager.delegate = locationDelegate
        self.locationManager.desiredAccuracy = desiredAccuracy.convertingAccuracy
        #if !os(tvOS)
        self.locationManager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
        #endif
    }
    

    /// Returns whether location services are enabled on the device.
    ///
    /// This method checks the system-wide location services setting.
    ///
    /// - Returns: `true` if location services are enabled, `false` otherwise.
    ///
    /// - Note: This method automatically runs off the main thread to avoid UI unresponsiveness.
    public func getLocationEnabled() async -> Bool {
        // Though undocumented, `locationServicesEnabled()` must not be called from the main thread. Otherwise,
        // we get a runtime warning "This method can cause UI unresponsiveness if invoked on the main thread"
        // Therefore, we use `Task.detached` to ensure we're off the main thread.
        await Task.detached { CLLocationManager.locationServicesEnabled() }.value
    }

    /// Returns the current authorization status for location services.
    ///
    /// Use this method to check the current authorization state without requesting permission.
    ///
    /// - Returns: The current `CLAuthorizationStatus`.
    @available(watchOS 6.0, *)
    public func getAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14, tvOS 14, watchOS 7, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    /// Starts monitoring changes to location services availability.
    ///
    /// Returns an `AsyncStream` that yields events when location services are enabled or disabled.
    ///
    /// - Returns: An `AsyncStream` of `LocationEnabledEvent`.
    ///
    /// ## Example
    /// ```swift
    /// for await event in await manager.startMonitoringLocationEnabled() {
    ///     switch event {
    ///     case .didUpdate(let enabled):
    ///         print("Location services enabled: \(enabled)")
    ///     }
    /// }
    /// ```
    public func startMonitoringLocationEnabled() async -> LocationEnabledStream {
        let performer = LocationEnabledMonitoringPerformer()
        return LocationEnabledStream { stream in
            performer.linkContinuation(stream)
            proxyDelegate.addPerformer(performer)
            stream.onTermination = { @Sendable _ in
                self.stopMonitoringLocationEnabled()
            }
        }
    }

    /// Stops monitoring location services availability changes.
    public func stopMonitoringLocationEnabled() {
        proxyDelegate.cancel(for: LocationEnabledMonitoringPerformer.self)
    }

    /// Starts monitoring changes to location authorization status.
    ///
    /// Returns an `AsyncStream` that yields events when the authorization status changes.
    ///
    /// - Returns: An `AsyncStream` of `AuthorizationEvent`.
    ///
    /// ## Example
    /// ```swift
    /// for await event in await manager.startMonitoringAuthorization() {
    ///     switch event {
    ///     case .didUpdate(let authorization):
    ///         print("Authorization: \(authorization)")
    ///     }
    /// }
    /// ```
    public func startMonitoringAuthorization() async -> AuthorizationStream {
        let performer = AuthorizationMonitoringPerformer()
        return AuthorizationStream { stream in
            performer.linkContinuation(stream)
            proxyDelegate.addPerformer(performer)
            stream.onTermination = { @Sendable _ in
                self.stopMonitoringAuthorization()
            }
        }
    }

    /// Stops monitoring authorization status changes.
    public func stopMonitoringAuthorization() {
        proxyDelegate.cancel(for: AuthorizationMonitoringPerformer.self)
    }

    /// Starts monitoring changes to location accuracy authorization.
    ///
    /// Available on iOS 14+ where users can choose between full and reduced accuracy.
    ///
    /// - Returns: An `AsyncStream` of `AccuracyAuthorizationEvent`.
    public func startMonitoringAccuracyAuthorization() async -> AccuracyAuthorizationStream {
        let performer = AccuracyAuthorizationMonitoringPerformer()
        return AccuracyAuthorizationStream { stream in
            performer.linkContinuation(stream)
            proxyDelegate.addPerformer(performer)
            stream.onTermination = { @Sendable _ in
                self.stopMonitoringAccuracyAuthorization()
            }
        }
    }

    /// Stops monitoring accuracy authorization changes.
    public func stopMonitoringAccuracyAuthorization() {
        proxyDelegate.cancel(for: AccuracyAuthorizationMonitoringPerformer.self)
    }

    /// Returns the current accuracy authorization level.
    ///
    /// - Returns: The current `CLAccuracyAuthorization` (`.fullAccuracy` or `.reducedAccuracy`).
    @available(iOS 14, tvOS 14, watchOS 7, *)
    public func getAccuracyAuthorization() -> CLAccuracyAuthorization {
        locationManager.accuracyAuthorization
    }

    /// Updates the desired accuracy for location data.
    ///
    /// - Parameter newAccuracy: The new accuracy level to use.
    public func updateAccuracy(with newAccuracy: LocationAccuracy) {
        locationManager.desiredAccuracy = newAccuracy.convertingAccuracy
    }

    /// Updates whether background location updates are allowed.
    ///
    /// - Parameter newAllows: `true` to allow background updates, `false` to disable.
    ///
    /// - Important: Requires appropriate background modes in your app's capabilities.
    @available(tvOS, unavailable)
    public func updateAllowsBackgroundLocationUpdates(with newAllows: Bool) {
        locationManager.allowsBackgroundLocationUpdates = newAllows
    }

    /// Requests "When In Use" location authorization.
    ///
    /// - Returns: The resulting authorization status.
    ///
    /// - Deprecated: Use `requestPermission(with: .whenInUsage)` instead.
    @available(*, deprecated, message: "Use requestPermission(with: .whenInUsage) instead")
    @available(watchOS 7.0, *)
    public func requestAuthorizationWhenInUse() async -> CLAuthorizationStatus {
        await requestPermission(with: .whenInUsage)
    }

#if !APPCLIP && !os(tvOS)
    /// Requests "Always" location authorization.
    ///
    /// - Returns: The resulting authorization status.
    ///
    /// - Deprecated: Use `requestPermission(with: .always)` instead.
    @available(*, deprecated, message: "Use requestPermission(with: .always) instead")
    @available(watchOS 7.0, *)
    @available(iOS 14, *)
    public func requestAuthorizationAlways() async -> CLAuthorizationStatus {
        await requestPermission(with: .always)
    }
#endif
    
    /// Requests location authorization from the user.
    ///
    /// This method displays a permission dialog requesting access to the user's location.
    /// The dialog only appears if authorization has not yet been determined.
    ///
    /// - Parameter permissionType: The type of permission to request (`.whenInUsage` or `.always`).
    /// - Returns: The resulting `CLAuthorizationStatus` after the request.
    ///
    /// - Important: Must add appropriate usage description keys to Info.plist:
    ///   - `NSLocationWhenInUseUsageDescription` for when-in-use authorization
    ///   - `NSLocationAlwaysAndWhenInUseUsageDescription` for always authorization
    ///
    /// ## Example
    /// ```swift
    /// let status = await manager.requestPermission(with: .whenInUsage)
    /// if status == .authorizedWhenInUse {
    ///     // Start using location services
    /// }
    /// ```
    @available(watchOS 7.0, *)
    public func requestPermission(with permissionType: LocationPermission) async -> CLAuthorizationStatus {
        switch permissionType {
        case .always:
            #if APPCLIP
            return await locationPermissionWhenInUse()
            #else
            return await locationPermissionAlways()
            #endif
        case .whenInUsage:
            return await locationPermissionWhenInUse()
        }
    }

    /// Requests temporary access to full location accuracy.
    ///
    /// On iOS 14+, users can choose to provide approximate location. Use this method
    /// to request temporary access to precise location for a specific purpose.
    ///
    /// - Parameter purposeKey: A key from your Info.plist's `NSLocationTemporaryUsageDescriptionDictionary`
    ///   that describes why you need full accuracy.
    /// - Returns: The resulting `CLAccuracyAuthorization`, or `nil` if authorization is not determined.
    /// - Throws: An error if the request fails.
    ///
    /// - Important: Must add `NSLocationTemporaryUsageDescriptionDictionary` to Info.plist with your purpose keys.
    @available(iOS 14, tvOS 14, watchOS 7, *)
    public func requestTemporaryFullAccuracyAuthorization(purposeKey: String) async throws -> CLAccuracyAuthorization? {
        try await locationPermissionTemporaryFullAccuracy(purposeKey: purposeKey)
    }

    /// Starts continuous location updates.
    ///
    /// Returns an `AsyncStream` that yields location update events. The stream continues
    /// until the task is cancelled or `stopUpdatingLocation()` is called.
    ///
    /// - Returns: An `AsyncStream` of `LocationUpdateEvent`.
    ///
    /// ## Example
    /// ```swift
    /// for await event in await manager.startUpdatingLocation() {
    ///     switch event {
    ///     case .didUpdateLocations(let locations):
    ///         print("New location: \(locations.last?.coordinate)")
    ///     case .didFailWith(let error):
    ///         print("Error: \(error)")
    ///     case .didPaused:
    ///         print("Updates paused")
    ///     case .didResume:
    ///         print("Updates resumed")
    ///     }
    /// }
    /// ```
    @available(tvOS, unavailable)
    public func startUpdatingLocation() async -> LocationStream {
        let monitoringPerformer = MonitoringUpdateLocationPerformer()
        return LocationStream { streamContinuation in
            monitoringPerformer.linkContinuation(streamContinuation)
            proxyDelegate.addPerformer(monitoringPerformer)
            locationManager.startUpdatingLocation()
            streamContinuation.onTermination = { @Sendable _ in
                self.proxyDelegate.cancel(for: monitoringPerformer.uniqueIdentifier)
            }
        }
    }

    /// Stops continuous location updates.
    ///
    /// Call this method to stop location updates started with `startUpdatingLocation()`.
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        proxyDelegate.cancel(for: MonitoringUpdateLocationPerformer.self)
    }

    /// Requests a single location update.
    ///
    /// This method is more efficient than `startUpdatingLocation()` when you only need
    /// the user's location once.
    ///
    /// - Returns: A `LocationUpdateEvent` containing the location, or `nil` if unsuccessful.
    /// - Throws: An error if the location request fails.
    ///
    /// ## Example
    /// ```swift
    /// do {
    ///     if let event = try await manager.requestLocation(),
    ///        case .didUpdateLocations(let locations) = event {
    ///         print("Current location: \(locations.first?.coordinate)")
    ///     }
    /// } catch {
    ///     print("Failed to get location: \(error)")
    /// }
    /// ```
    public func requestLocation() async throws -> LocationUpdateEvent? {
        let performer = SingleLocationUpdatePerformer()
        return try await withTaskCancellationHandler(operation: {
            return try await withCheckedThrowingContinuation({ continuation in
                performer.linkContinuation(continuation)
                self.proxyDelegate.addPerformer(performer)
                self.locationManager.requestLocation()
            })
        }, onCancel: {
            proxyDelegate.cancel(for: performer.uniqueIdentifier)
        })
    }
    
    /// Starts monitoring a geographic region.
    ///
    /// Monitors entry and exit events for the specified region. The region can be circular
    /// (`CLCircularRegion`) or beacon-based (`CLBeaconRegion`).
    ///
    /// - Parameter region: The region to monitor.
    /// - Returns: An `AsyncStream` of `RegionMonitoringEvent`.
    ///
    /// ## Example
    /// ```swift
    /// let region = CLCircularRegion(
    ///     center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    ///     radius: 100,
    ///     identifier: "San Francisco"
    /// )
    ///
    /// for await event in await manager.startMonitoring(for: region) {
    ///     switch event {
    ///     case .didEnterTo(let region):
    ///         print("Entered \(region.identifier)")
    ///     case .didExitTo(let region):
    ///         print("Exited \(region.identifier)")
    ///     case .didStartMonitoringFor:
    ///         print("Monitoring started")
    ///     case .monitoringDidFailFor(_, let error):
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func startMonitoring(for region: CLRegion) async -> RegionMonitoringStream {
        let performer = RegionMonitoringPerformer(region: region)
        return RegionMonitoringStream { streamContinuation in
            performer.linkContinuation(streamContinuation)
            proxyDelegate.addPerformer(performer)
            locationManager.startMonitoring(for: region)
            streamContinuation.onTermination = { @Sendable _ in
                self.proxyDelegate.cancel(for: performer.uniqueIdentifier)
            }
        }
    }

    /// Stops monitoring the specified region.
    ///
    /// - Parameter region: The region to stop monitoring.
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func stopMonitoring(for region: CLRegion) {
        proxyDelegate.cancel(for: RegionMonitoringPerformer.self) { regionMonitoring in
            guard let regionPerformer = regionMonitoring as? RegionMonitoringPerformer else { return false }
            return regionPerformer.region ==  region
        }
        locationManager.stopMonitoring(for: region)
    }

    /// Starts monitoring significant visit events.
    ///
    /// A visit represents the user staying in one location for a period of time.
    /// This is more battery-efficient than continuous location updates.
    ///
    /// - Returns: An `AsyncStream` of `VisitMonitoringEvent`.
    ///
    /// ## Example
    /// ```swift
    /// for await event in await manager.startMonitoringVisit() {
    ///     switch event {
    ///     case .didVisit(let visit):
    ///         print("Visit at \(visit.coordinate)")
    ///         print("Arrived: \(visit.arrivalDate)")
    ///     case .didFailWithError(let error):
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func startMonitoringVisit() async -> VisitMonitoringStream {
        let performer = VisitMonitoringPerformer()
        return VisitMonitoringStream { stream in
            performer.linkContinuation(stream)
            proxyDelegate.addPerformer(performer)
            locationManager.startMonitoringVisits()
            stream.onTermination = { @Sendable _ in
                self.stopMonitoringVisit()
            }
        }
    }

    /// Stops monitoring visit events.
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func stopMonitoringVisit() {
        proxyDelegate.cancel(for: VisitMonitoringPerformer.self)
        locationManager.stopMonitoringVisits()
    }

    /// Starts monitoring significant location changes.
    ///
    /// Significant location changes are more battery-efficient than continuous updates
    /// and work even when the app is in the background or suspended. This is ideal for
    /// apps that don't need frequent location updates.
    ///
    /// - Returns: An `AsyncStream` of `SignificantLocationChangeEvent`.
    ///
    /// - Note: Significant changes are typically triggered when the device moves more than 500 meters.
    ///
    /// ## Example
    /// ```swift
    /// for await event in await manager.startMonitoringSignificantLocationChanges() {
    ///     switch event {
    ///     case .didUpdateLocations(let locations):
    ///         print("Significant change: \(locations.last?.coordinate)")
    ///     case .didFailWith(let error):
    ///         print("Error: \(error)")
    ///     case .didPaused, .didResume:
    ///         break
    ///     }
    /// }
    /// ```
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func startMonitoringSignificantLocationChanges() async -> SignificantLocationChangeMonitoringStream {
        let monitoringPerformer = SignificantLocationChangeMonitoringPerformer()
        return SignificantLocationChangeMonitoringStream { streamContinuation in
            monitoringPerformer.linkContinuation(streamContinuation)
            proxyDelegate.addPerformer(monitoringPerformer)
            locationManager.startMonitoringSignificantLocationChanges()
            streamContinuation.onTermination = { @Sendable _ in
                self.proxyDelegate.cancel(for: monitoringPerformer.uniqueIdentifier)
            }
        }
    }

    /// Stops monitoring significant location changes.
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
        proxyDelegate.cancel(for: SignificantLocationChangeMonitoringPerformer.self)
    }

#if os(iOS)
    /// Starts monitoring device heading updates.
    ///
    /// Returns the device's current heading (direction) relative to magnetic or true north.
    ///
    /// - Returns: An `AsyncStream` of `HeadingMonitorEvent`.
    ///
    /// - Note: Only available on iOS devices with a magnetometer (compass).
    ///
    /// ## Example
    /// ```swift
    /// for await event in await manager.startUpdatingHeading() {
    ///     switch event {
    ///     case .didUpdate(let heading):
    ///         print("Heading: \(heading.trueHeading)°")
    ///     case .didFailWith(let error):
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    @available(iOS 13, *)
    public func startUpdatingHeading() async -> HeadingMonitorStream {
        let performer = HeadingMonitorPerformer()
        return HeadingMonitorStream { stream in
            performer.linkContinuation(stream)
            proxyDelegate.addPerformer(performer)
            locationManager.startUpdatingHeading()
            stream.onTermination = { @Sendable _ in
                self.stopUpdatingHeading()
            }
        }
    }

    /// Stops monitoring heading updates.
    public func stopUpdatingHeading() {
        proxyDelegate.cancel(for: HeadingMonitorPerformer.self)
        locationManager.stopUpdatingHeading()
    }
#endif

    /// Starts ranging for beacons that satisfy the specified constraint.
    ///
    /// Beacon ranging provides the relative distance to nearby beacons. This is useful
    /// for indoor positioning and proximity detection.
    ///
    /// - Parameter satisfying: A `CLBeaconIdentityConstraint` specifying which beacons to range.
    /// - Returns: An `AsyncStream` of `BeaconRangeEvent`.
    ///
    /// ## Example
    /// ```swift
    /// let constraint = CLBeaconIdentityConstraint(
    ///     uuid: UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
    /// )
    ///
    /// for await event in await manager.startRangingBeacons(satisfying: constraint) {
    ///     switch event {
    ///     case .didRange(let beacons, _):
    ///         for beacon in beacons {
    ///             print("Beacon: \(beacon.uuid), proximity: \(beacon.proximity)")
    ///         }
    ///     case .didFailRanginFor(_, let error):
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func startRangingBeacons(satisfying: CLBeaconIdentityConstraint) async -> BeaconsRangingStream {
        let performer = BeaconsRangePerformer(satisfying: satisfying)
        return BeaconsRangingStream { stream in
            performer.linkContinuation(stream)
            proxyDelegate.addPerformer(performer)
            locationManager.startRangingBeacons(satisfying: satisfying)
            stream.onTermination = { @Sendable _ in
                self.stopRangingBeacons(satisfying: satisfying)
            }
        }
    }

    /// Stops ranging for the specified beacons.
    ///
    /// - Parameter satisfying: The `CLBeaconIdentityConstraint` to stop ranging.
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func stopRangingBeacons(satisfying: CLBeaconIdentityConstraint) {
        proxyDelegate.cancel(for: BeaconsRangePerformer.self) { beaconsMonitoring in
            guard let beaconsPerformer = beaconsMonitoring as? BeaconsRangePerformer else { return false }
            return beaconsPerformer.satisfying == satisfying
        }
        locationManager.stopRangingBeacons(satisfying: satisfying)
    }
}

extension AsyncLocationManager {
    private func locationPermissionWhenInUse() async -> CLAuthorizationStatus {
        let authorizationPerformer = RequestAuthorizationPerformer(currentStatus: getAuthorizationStatus())
        return await withTaskCancellationHandler(operation: {
            await withCheckedContinuation { continuation in
                let authorizationStatus = getAuthorizationStatus()
                if authorizationStatus != .notDetermined {
                    continuation.resume(with: .success(authorizationStatus))
                } else {
                    authorizationPerformer.linkContinuation(continuation)
                    proxyDelegate.addPerformer(authorizationPerformer)
                    locationManager.requestWhenInUseAuthorization()
                }
            }
        }, onCancel: {
            proxyDelegate.cancel(for: authorizationPerformer.uniqueIdentifier)
        })
    }
    
    private func locationPermissionAlways() async -> CLAuthorizationStatus {
        let authorizationPerformer = RequestAuthorizationPerformer(currentStatus: getAuthorizationStatus())
        return await withTaskCancellationHandler(operation: {
            await withCheckedContinuation { continuation in
#if os(macOS)
                if #available(iOS 14, watchOS 7, *), locationManager.authorizationStatus != .notDetermined {
                    continuation.resume(with: .success(locationManager.authorizationStatus))
                } else {
                    authorizationPerformer.linkContinuation(continuation)
                    proxyDelegate.addPerformer(authorizationPerformer)
                    locationManager.requestAlwaysAuthorization()
                }
#else
                if #available(iOS 14, tvOS 14, watchOS 7, *), locationManager.authorizationStatus != .notDetermined && locationManager.authorizationStatus != .authorizedWhenInUse {
                    continuation.resume(with: .success(locationManager.authorizationStatus))
                } else {
                    #if !os(tvOS)
                    authorizationPerformer.linkContinuation(continuation)
                    proxyDelegate.addPerformer(authorizationPerformer)
                    locationManager.requestAlwaysAuthorization()
                    #endif
                }
#endif
            }
        }, onCancel: {
            proxyDelegate.cancel(for: authorizationPerformer.uniqueIdentifier)
        })
    }

    @available(iOS 14, tvOS 14, watchOS 7, *)
    private func locationPermissionTemporaryFullAccuracy(purposeKey: String) async throws -> CLAccuracyAuthorization? {
        let authorizationPerformer = RequestAccuracyAuthorizationPerformer()
        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLAccuracyAuthorization?, Error>) in
                if locationManager.authorizationStatus == .notDetermined {
                    continuation.resume(with: .success(nil))
                } else if locationManager.accuracyAuthorization == .fullAccuracy {
                    continuation.resume(with: .success(locationManager.accuracyAuthorization))
                } else if !CLLocationManager.locationServicesEnabled() {
                    continuation.resume(with: .success(nil))
                } else {
                    authorizationPerformer.linkContinuation(continuation)
                    proxyDelegate.addPerformer(authorizationPerformer)
                    locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey) { [weak self] error in
                        guard let self = self else { return }

                        if let error {
                            continuation.resume(with: .failure(error))
                            return
                        }

                        // If the user chooses reduced accuracy, the didChangeAuthorization delegate method
                        // will not called. So we must emulate that here.
                        if self.locationManager.accuracyAuthorization == .reducedAccuracy {
                            self.proxyDelegate.eventForMethodInvoked(
                                .didChangeAccuracyAuthorization(authorization: self.locationManager.accuracyAuthorization)
                            )
                        }
                    }
                }
            }
        }, onCancel: {
            proxyDelegate.cancel(for: authorizationPerformer.uniqueIdentifier)
        })
    }
}

extension CLAuthorizationStatus: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined: return ".notDetermined"
        case .restricted: return ".restricted"
        case .denied: return ".denied"
        case .authorizedWhenInUse: return ".authorizedWhenInUse"
        case .authorizedAlways: return ".authorizedAlways"
        @unknown default: return "unknown \(rawValue)"
        }
    }
}

extension CLAccuracyAuthorization: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .fullAccuracy: return ".fullAccuracy"
        case .reducedAccuracy: return ".reducedAccuracy"
        @unknown default: return "unknown \(rawValue)"
        }
    }
}

