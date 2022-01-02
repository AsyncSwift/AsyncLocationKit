import CoreLocation
import Foundation

internal class LocationDelegate: NSObject, CLLocationManagerDelegate {
    
//    MARK: - Authorize
    @available(iOS 14, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
//    MARK: - Stream new event with locations/heading/region
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    }
    
//    MARK: - Beacons
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
    }
    
    
//    MARK: - Region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    }
    
    
//    MARK: - Fails methods
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    }
    
    
//    MARK: - Visit methods
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    }
    
    
//    MARK: - Pause and resume
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    }
    
}
