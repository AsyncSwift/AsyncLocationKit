import CoreLocation.CLLocationManagerDelegate

extension Selector {
    
    /// `locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)`
    ///     was deprecated in `iOS 14`, now we must use `locationManagerDidChangeAuthorization(_ manager: CLLocationManager)`
    static var authorizationStatusDidChange: Selector {
        if #available(iOS 14, *) {
            return #selector(CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:))
        } else {
            return #selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:))
        }
    }
    
//    MARK: - Selectors for update locations/heading/region
    static let didUpdateLocation = #selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))
    static let didUpdateHeading = #selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:))
    static let didDetermineState = #selector(CLLocationManagerDelegate.locationManager(_:didDetermineState:for:))
    
    
//    MARK: - Beacons
    static let didRangeBeacons = #selector(CLLocationManagerDelegate.locationManager(_:didRange:satisfying:))
    static let didFailRangingFor = #selector(CLLocationManagerDelegate.locationManager(_:didFailRangingFor:error:))
    
//    MARK: - Region
    static let didEnterRegion = #selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:))
    static let didExitRegion = #selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:))
    static let didStartMonitoringForRegion = #selector(CLLocationManagerDelegate.locationManager(_:didStartMonitoringFor:))
    
//    MARK: - Fails selectors
    static let didFailWithError = #selector(CLLocationManagerDelegate.locationManager(_:didFailWithError:))
    static let monitoringDidFailFor = #selector(CLLocationManagerDelegate.locationManager(_:monitoringDidFailFor:withError:))
    
//    MARK: - Visit selector
    static let didVisit = #selector(CLLocationManagerDelegate.locationManager(_:didVisit:))
    
//    MARK: - Pause and resume
    static let didPauseLocationUpdates = #selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:))
    static let didResumeLocationUpdates = #selector(CLLocationManagerDelegate.locationManagerDidResumeLocationUpdates(_:))
}
