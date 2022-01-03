import Foundation

protocol AnyLocationPerformer: AnyObject {
    
    var identifier: ObjectIdentifier { get }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool
    
    func invokedMethod(event: CoreLocationDelegateEvent)
    
}

protocol AsyncDelegateProxyInterface: AnyObject {
    func eventForMethodInvoked(_ event: CoreLocationDelegateEvent)
    func addPerformer(_ performer: AnyLocationPerformer)
    
    func cancel(for type: AnyLocationPerformer.Type)
}

final class AsyncDelegateProxy: AsyncDelegateProxyInterface {
    
    var performers: [AnyLocationPerformer] = []
    
    func eventForMethodInvoked(_ event: CoreLocationDelegateEvent) {
        for performer in performers {
            if performer.eventSupported(event) {
                performer.invokedMethod(event: event)
            }
        }
    }
    
    func addPerformer(_ performer: AnyLocationPerformer) {
        if performers.contains(where: { $0.identifier == performer.identifier }) {
            let actualPerformer = performers.with(identifier: performer.identifier)
        }
    }
    
    func cancel(for type: AnyLocationPerformer.Type) {
        performers.removeAll(where: { $0.identifier == ObjectIdentifier(type) })
    }
    
}

class RequestAuthorizationPerformer: AnyLocationPerformer {
    
    var identifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var eventsSupport: [CoreLocationEventSupport] = [.didChangeAuthorization]
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didChangeAuthorization(let status):
            if status != .notDetermined {
                
            }
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self))")
        }
    }
    
}

extension Array where Element == AnyLocationPerformer {
    func with(identifier: ObjectIdentifier) -> Element {
        guard let element = self.first(where: { $0.identifier == identifier }) else { fatalError("non elements in array with identifier: \(identifier)") }
        return element
    }
}
