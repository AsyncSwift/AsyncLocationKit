import Foundation
import CoreLocation

public enum BeaconRangeEvent {
    case didRange(beacons: [CLBeacon], beaconConstraint: CLBeaconIdentityConstraint)
    case didFailRanginFor(beaconConstraint: CLBeaconIdentityConstraint, error: Error)
}

class BeaconsRangePerformer: AnyLocationPerformer {
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var cancellabel: Cancellabel?
    
    var eventssupported: [CoreLocationEventSupport] = [.didRangeBeacons, .didFailRanginForBeaconConstraint]
    
    var satisfying: CLBeaconIdentityConstraint
    
    var stream: BeaconsRangingStream.Continuation?
    
    init(satisfying: CLBeaconIdentityConstraint) {
        self.satisfying = satisfying
    }
    
    func linkContinuation(_ continuation: BeaconsRangingStream.Continuation) {
        self.stream = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventssupported.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didRange(let beacons, let beaconConstraint):
            stream?.yield(.didRange(beacons: beacons, beaconConstraint: beaconConstraint))
        case .didFailRanginFor(let beaconConstraint, let error):
            stream?.yield(.didFailRanginFor(beaconConstraint: beaconConstraint, error: error))
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }
    
    func cancelation() { }
    
}
