//
//  File.swift
//  
//
//  Created by p.grechikhin on 03.01.2022.
//

import Foundation
import CoreLocation.CLLocationManagerDelegate
import CoreLocation

enum CoreLocationDelegateEvent {
//    MARK: - Authorization event
    case didChangeAuthorization(status: CLAuthorizationStatus)
//    MARK: - Location events
    case didUpdate(locations: [CLLocation])
    case didUpdateHeading(heading: CLHeading)
    case didDetermine(state: CLRegionState, forRegion: CLRegion)
//    MARK: - Beacons events
    case didRange(beacons: [CLBeacon], beaconConstraint: CLBeaconIdentityConstraint)
    case didFailRanginFor(beaconConstraint: CLBeaconIdentityConstraint, error: Error)
//    MARK: - Region events
    case didEnterRegion(region: CLRegion)
    case didExitRegion(region: CLRegion)
    case didStartMonitoringFor(region: CLRegion)
//    MARK: - Fails events
    case didFailWithError(error: Error)
    case monitoringDidFailFor(region: CLRegion?, error: Error)
//    MARK: - Visit event
    case didVisit(visit: CLVisit)
//    MARK: - Pause and resume events
    case locationUpdatesPaused
    case locationUpdatesResume
    
    func rawEvent() -> CoreLocationEventSupport {
        switch self {
        case .didChangeAuthorization(_):
            return .didChangeAuthorization
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
    case didChangeAuthorization
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
