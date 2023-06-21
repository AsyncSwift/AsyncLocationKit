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

import CoreLocation
import Foundation

internal class LocationDelegate: NSObject, CLLocationManagerDelegate {
    weak var proxy: AsyncDelegateProxyInterface?
    
    init(delegateProxy: AsyncDelegateProxyInterface) {
        proxy = delegateProxy
        super.init()
    }
    
//    MARK: - Authorize
    @available(watchOS 7.0, *)
    @available(iOS 14, tvOS 14, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        proxy?.eventForMethodInvoked(.didChangeAuthorization(status: manager.authorizationStatus))
        proxy?.eventForMethodInvoked(.didChangeAccuracyAuthorization(authorization: manager.accuracyAuthorization))
        locationServicesEnabledDidChange()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        proxy?.eventForMethodInvoked(.didChangeAuthorization(status: status))
        locationServicesEnabledDidChange()
    }

    private func locationServicesEnabledDidChange() {
        Task {
            let enabled = CLLocationManager.locationServicesEnabled()
            await MainActor.run {
                proxy?.eventForMethodInvoked(.didChangeLocationEnabled(enabled: enabled))
            }
        }
    }

//    MARK: - Stream new event with locations/heading/region
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        proxy?.eventForMethodInvoked(.didUpdate(locations: locations))
    }
    
    #if !os(tvOS)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        proxy?.eventForMethodInvoked(.didUpdateHeading(heading: newHeading))
    }
    #endif
    
    #if os(iOS)
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        proxy?.eventForMethodInvoked(.didDetermine(state: state, forRegion: region))
    }
    
//    MARK: - Beacons
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        proxy?.eventForMethodInvoked(.didRange(beacons: beacons, beaconConstraint: beaconConstraint))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        proxy?.eventForMethodInvoked(.didFailRanginFor(beaconConstraint: beaconConstraint, error: error))
    }
    
//    MARK: - Region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        proxy?.eventForMethodInvoked(.didEnterRegion(region: region))
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        proxy?.eventForMethodInvoked(.didExitRegion(region: region))
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        proxy?.eventForMethodInvoked(.didStartMonitoringFor(region: region))
    }
    #endif
    
//    MARK: - Fails methods
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        proxy?.eventForMethodInvoked(.didFailWithError(error: error))
    }
    
    #if os(iOS)
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        proxy?.eventForMethodInvoked(.monitoringDidFailFor(region: region, error: error))
    }
    
//    MARK: - Visit methods
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        proxy?.eventForMethodInvoked(.didVisit(visit: visit))
    }
    
//    MARK: - Pause and resume
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        proxy?.eventForMethodInvoked(.locationUpdatesPaused)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        proxy?.eventForMethodInvoked(.locationUpdatesResume)
    }
    #endif
}
