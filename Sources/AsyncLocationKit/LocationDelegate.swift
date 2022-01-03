import CoreLocation
import Foundation

internal class LocationDelegate: NSObject, CLLocationManagerDelegate {
    
    weak var proxy: AsyncDelegateProxyInterface?
    
    init(delegateProxy: AsyncDelegateProxyInterface) {
        proxy = delegateProxy
        super.init()
    }
    
//    MARK: - Authorize
    @available(iOS 14, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        proxy?.eventForMethodInvoked(.didChangeAuthorization(status: manager.authorizationStatus))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        proxy?.eventForMethodInvoked(.didChangeAuthorization(status: status))
    }
    
//    MARK: - Stream new event with locations/heading/region
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        proxy?.eventForMethodInvoked(.didUpdate(locations: locations))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        proxy?.eventForMethodInvoked(.didUpdateHeading(heading: newHeading))
    }
    
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
    
    
//    MARK: - Fails methods
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        proxy?.eventForMethodInvoked(.didFailWithError(error: error))
    }
    
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
    
}
