import Foundation

extension Array where Element == AnyLocationPerformer {
    func with(identifier: ObjectIdentifier) -> Element {
        guard let element = self.first(where: { $0.typeIdentifier == identifier }) else { fatalError("No elements in array with identifier: \(identifier)") }
        return element
    }
}
