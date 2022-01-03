import Foundation
import CoreLocation.CLLocation

class SingleLocationUpdatePerformer: AnyLocationPerformer {
    
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var eventsSupport: [CoreLocationEventSupport] = [.didUpdateLocations, .didFailWithError]
    
    var cancellabel: Cancellabel?
    var continuation: LocationOnceContinuation?
    
    func linkContinuation(_ continuation: LocationOnceContinuation) {
        self.continuation = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didUpdate(let locations):
            continuation?.resume(returning: .didUpdateLocations(locations: locations))
            continuation = nil
            cancellabel?.cancel(for: self)
        case .didFailWithError(let error):
            continuation?.resume(throwing: error)
            continuation = nil
            cancellabel?.cancel(for: self)
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self))")
        }
    }
    
    func cancelation() { }

}
