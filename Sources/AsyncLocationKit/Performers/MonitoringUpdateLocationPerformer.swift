import Foundation
import CoreLocation.CLLocation

public enum LocationUpdateEvent {
    case didPaused
    case didResume
    case didUpdateLocations(locations: [CLLocation])
}

class MonitoringUpdateLocationPerformer: AnyLocationPerformer {
    
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var eventsSupport: [CoreLocationEventSupport] = [.didUpdateLocations, .locationUpdatesPaused, .locationUpdatesResume]
    
    var cancellabel: Cancellabel?
    var stream: LocationStream.Continuation?
    
    func linkContinuation(_ continuation: LocationStream.Continuation) {
        stream = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didUpdate(let locations):
            stream?.yield(.didUpdateLocations(locations: locations))
        case .locationUpdatesPaused:
            stream?.yield(.didPaused)
        case .locationUpdatesResume:
            stream?.yield(.didResume)
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }
    
    func cancelation() {
        guard let stream = stream else { return }
        stream.finish()
        self.stream = nil
    }

}
