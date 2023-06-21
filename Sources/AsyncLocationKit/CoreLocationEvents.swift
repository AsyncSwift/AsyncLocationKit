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
import CoreLocation.CLLocationManagerDelegate
import CoreLocation

enum CoreLocationDelegateEvent {
//    MARK: - Authorization event
    case didChangeLocationEnabled(enabled: Bool)
    case didChangeAuthorization(status: CLAuthorizationStatus)
    case didChangeAccuracyAuthorization(authorization: CLAccuracyAuthorization)
//    MARK: - Location events
    case didUpdate(locations: [CLLocation])
    @available(tvOS, unavailable)
    case didUpdateHeading(heading: CLHeading)
    
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    case didDetermine(state: CLRegionState, forRegion: CLRegion)
    
//    MARK: - Beacons events
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    case didRange(beacons: [CLBeacon], beaconConstraint: CLBeaconIdentityConstraint)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    case didFailRanginFor(beaconConstraint: CLBeaconIdentityConstraint, error: Error)
//    MARK: - Region events
    case didEnterRegion(region: CLRegion)
    case didExitRegion(region: CLRegion)
    case didStartMonitoringFor(region: CLRegion)
//    MARK: - Fails events
    case didFailWithError(error: Error)
    case monitoringDidFailFor(region: CLRegion?, error: Error)
//    MARK: - Visit event
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    case didVisit(visit: CLVisit)
//    MARK: - Pause and resume events
    case locationUpdatesPaused
    case locationUpdatesResume
    
    func rawEvent() -> CoreLocationEventSupport {
        switch self {
        case .didChangeLocationEnabled(_):
            return .didChangeLocationEnabled
        case .didChangeAuthorization(_):
            return .didChangeAuthorization
        case .didChangeAccuracyAuthorization(_):
            return .didChangeAccuracyAuthorization
        case .didUpdate(_):
            return .didUpdateLocations
        case .didUpdateHeading(_):
            return .didUpdateHeading
        case .didDetermine(_, _):
            return .didDetermineState
        case .didRange(_, _):
            return .didRangeBeacons
        case .didFailRanginFor(_,_):
            return .didFailRanginForBeaconConstraint
        case .didEnterRegion(_):
            return .didEnterRegion
        case .didExitRegion(_):
            return .didExitRegion
        case .didStartMonitoringFor(_):
            return .didStartMonitoringForRegion
        case .didFailWithError(_):
            return .didFailWithError
        case .monitoringDidFailFor(_, _):
            return .monitoringDidFailForRegion
        case .didVisit(_):
            return .didVisit
        case .locationUpdatesPaused:
            return .locationUpdatesPaused
        case .locationUpdatesResume:
            return .locationUpdatesResume
        }
    }
}

/// Event for mark what support current delegate
enum CoreLocationEventSupport {
    case didChangeLocationEnabled
    case didChangeAuthorization
    case didChangeAccuracyAuthorization
    case didUpdateLocations
    case didUpdateHeading
    case didDetermineState
    case didRangeBeacons
    case didFailRanginForBeaconConstraint
    case didEnterRegion
    case didExitRegion
    case didStartMonitoringForRegion
    case didFailWithError
    case monitoringDidFailForRegion
    case didVisit
    case locationUpdatesPaused
    case locationUpdatesResume
}
