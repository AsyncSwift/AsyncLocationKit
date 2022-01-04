import Foundation
import CoreLocation

/// Wrapper for CLLocationAccuracy
public enum LocationAccuracy {
    case bestAccuracy
    case nearestTenMetersAccuracy
    case hundredMetersAccuracy
    case kilometerAccuracy
    case threeKilometersAccuracy
    case bestForNavigationAccuracy
    
    internal var convertingAccuracy: CLLocationAccuracy {
        switch self {
        case .bestAccuracy:
            return kCLLocationAccuracyBest
        case .nearestTenMetersAccuracy:
            return kCLLocationAccuracyNearestTenMeters
        case .hundredMetersAccuracy:
            return kCLLocationAccuracyHundredMeters
        case .kilometerAccuracy:
            return kCLLocationAccuracyKilometer
        case .threeKilometersAccuracy:
            return kCLLocationAccuracyThreeKilometers
        case .bestForNavigationAccuracy:
            return kCLLocationAccuracyBestForNavigation
        }
    }
    
}
