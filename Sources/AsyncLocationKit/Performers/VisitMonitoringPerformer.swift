import Foundation
import CoreLocation.CLVisit

public enum VisitMonitoringEvent {
    case didVisit(visit: CLVisit)
    case didFailWithError(error: Error)
}

class VisitMonitoringPerformer: AnyLocationPerformer {
    
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var cancellabel: Cancellabel?
    var eventssupported: [CoreLocationEventSupport] = [.didVisit, .didFailWithError]
    var stream: VisitMonitoringStream.Continuation?
    
    func linkContinuation(_ continuation: VisitMonitoringStream.Continuation) {
        stream = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventssupported.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didFailWithError(let error):
            stream?.yield(.didFailWithError(error: error))
        case .didVisit(let visit):
            stream?.yield(.didVisit(visit: visit))
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }
    
    func cancelation() {
    }
    
    
}
