import Foundation

protocol Cancellabel: AnyObject {
    func cancel(for performer: AnyLocationPerformer)
}

protocol AsyncDelegateProxyInterface: AnyObject {
    func eventForMethodInvoked(_ event: CoreLocationDelegateEvent)
    func addPerformer(_ performer: AnyLocationPerformer)
    
    func cancel(for type: AnyLocationPerformer.Type)
    func cancel(for uniqueIdentifier: UUID)
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
        performer.cancellabel = self
        performers.append(performer)
    }
    
    func cancel(for type: AnyLocationPerformer.Type) {
        performers.removeAll(where: { $0.typeIdentifier == ObjectIdentifier(type) })
    }
    
    func cancel(for uniqueIdentifier: UUID) {
        performers.removeAll { performer in
            if performer.uniqueIdentifier == uniqueIdentifier {
                performer.cancelation()
                return true
            } else {
                return false
            }
        }
    }
    
}

extension AsyncDelegateProxy: Cancellabel {
    func cancel(for performer: AnyLocationPerformer) {
        performers.removeAll(where: { $0.uniqueIdentifier == performer.uniqueIdentifier })
    }
}
