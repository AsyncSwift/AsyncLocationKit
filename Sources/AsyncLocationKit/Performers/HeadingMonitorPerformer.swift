import Foundation
import CoreLocation.CLHeading

public enum HeadingMonitorEvent {
    case didUpdate(heading: CLHeading)
    case didFailWith(error: Error)
}

class HeadingMonitorPerformer: AnyLocationPerformer {
    
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var cancellabel: Cancellabel?
    var eventsSupport: [CoreLocationEventSupport] = [.didUpdateHeading, .didFailWithError]
    var stream: HeadingMonitorStream.Continuation?
    
    func linkContinuation(_ continuation: HeadingMonitorStream.Continuation) {
        stream = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didUpdateHeading(let heading):
            stream?.yield(.didUpdate(heading: heading))
        case .didFailWithError(let error):
            stream?.yield(.didFailWith(error: error))
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }
    
    func cancelation() { }
    
}
