import Foundation

protocol AnyLocationPerformer: AnyObject {
    
    var typeIdentifier: ObjectIdentifier { get }
    var uniqueIdentifier: UUID { get }
    var cancellabel: Cancellabel? { get set }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool
    
    func invokedMethod(event: CoreLocationDelegateEvent)
    
    func cancelation()
    
}
