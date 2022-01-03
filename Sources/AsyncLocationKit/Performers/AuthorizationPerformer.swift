import Foundation
import CoreLocation.CLLocation

public enum LocationUpdateEvent {
    case didPaused
    case didResume
    case didUpdateLocations(locations: [CLLocation])
}

class RequestAuthorizationPerformer: AnyLocationPerformer {
    
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var eventsSupport: [CoreLocationEventSupport] = [.didChangeAuthorization]
    
    var continuation: AuthotizationContinuation?
    
    weak var cancellabel: Cancellabel?
    
    func linkContinuation(_ continuation: AuthotizationContinuation) {
        self.continuation = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didChangeAuthorization(let status):
            if status != .notDetermined {
                guard let continuation = continuation else { cancellabel?.cancel(for: self); return }
                continuation.resume(returning: status)
                self.continuation = nil
                cancellabel?.cancel(for: self)
            }
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self))")
        }
    }
    
    func cancelation() { }
    
}
