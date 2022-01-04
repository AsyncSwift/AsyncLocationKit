import Foundation

extension Array where Element == AnyLocationPerformer {
    func allWith(identifier: ObjectIdentifier) -> [Element] {
        return self.filter({ $0.typeIdentifier == identifier })
    }
}
