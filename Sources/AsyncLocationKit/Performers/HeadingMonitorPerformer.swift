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
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didUpdateHeading(let heading):
            break
        case .didFailWithError(let error):
            break
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }
    
    func cancelation() {
        
    }
    
    
}
