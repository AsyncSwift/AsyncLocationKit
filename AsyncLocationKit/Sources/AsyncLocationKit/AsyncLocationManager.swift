import Foundation
import CoreLocation

public typealias AuthotizationContinuation = CheckedContinuation<CLAuthorizationStatus, Never>
public typealias LocationOnceContinuation = CheckedContinuation<LocationUpdateEvent?, Error>
public typealias LocationStream = AsyncStream<LocationUpdateEvent>

public final class AsyncLocationManager: NSObject {
    
    public private(set) var locationManager: CLLocationManager
    private var proxyDelegate: AsyncDelegateProxyInterface
    private var locationDelegate: CLLocationManagerDelegate
    
    public override init() {
        locationManager = CLLocationManager()
        proxyDelegate = AsyncDelegateProxy()
        locationDelegate = LocationDelegate(delegateProxy: proxyDelegate)
        locationManager.delegate = locationDelegate
        super.init()
    }
    
    public func requestAuthorizationWhenInUse() async -> CLAuthorizationStatus {
        let authorizationPerformer = RequestAuthorizationPerformer()
        return await withTaskCancellationHandler {
            proxyDelegate.cancel(for: authorizationPerformer.uniqueIdentifier)
        } operation: {
            await withCheckedContinuation { continuation in
                authorizationPerformer.linkContinuation(continuation)
                proxyDelegate.addPerformer(authorizationPerformer)
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    public func requestAuthorizationAlways() async -> CLAuthorizationStatus {
        let authorizationPerformer = RequestAuthorizationPerformer()
        return await withTaskCancellationHandler {
            proxyDelegate.cancel(for: authorizationPerformer.uniqueIdentifier)
        } operation: {
            await withCheckedContinuation { continuation in
                authorizationPerformer.linkContinuation(continuation)
                proxyDelegate.addPerformer(authorizationPerformer)
                locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
    public func startUpdatingLocation() async -> LocationStream {
        let monitoringPerformer = MonitoringUpdateLocationPerformer()
        return LocationStream { streamContinuation in
            proxyDelegate.addPerformer(monitoringPerformer)
            locationManager.startUpdatingLocation()
            streamContinuation.onTermination = { @Sendable _ in
                self.proxyDelegate.cancel(for: monitoringPerformer.uniqueIdentifier)
            }
        }
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        proxyDelegate.cancel(for: MonitoringUpdateLocationPerformer.self)
    }
    
    public func requestLocation() async throws -> LocationUpdateEvent? {
        let performer = SingleLocationUpdatePerformer()
        return try await withTaskCancellationHandler(handler: {
            proxyDelegate.cancel(for: performer.uniqueIdentifier)
        }, operation: {
            return try await withCheckedThrowingContinuation({ continuation in
                performer.linkContinuation(continuation)
                self.proxyDelegate.addPerformer(performer)
                self.locationManager.requestLocation()
            })
        })
    }
    
    public func startMonitoring(for region: CLRegion) {
        locationManager.startMonitoring(for: region)
    }
    
    public func stopMonitoring(for region: CLRegion) {
        locationManager.stopMonitoring(for: region)
    }
    
    public func startMonitoringVisit() {
        locationManager.startMonitoringVisits()
    }
    
    public func stopMonitoringVisit() {
        locationManager.stopMonitoringVisits()
    }
    
    public func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }
    
    public func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    public func startRangingBeacons(satisfying: CLBeaconIdentityConstraint) {
        locationManager.startRangingBeacons(satisfying: satisfying)
    }
    
    public func stopRangingBeacons(satisfying: CLBeaconIdentityConstraint) {
        locationManager.stopRangingBeacons(satisfying: satisfying)
    }
    
}
