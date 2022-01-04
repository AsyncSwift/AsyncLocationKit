import Foundation

//MARK: - Array extension equal to filter, but shortly 🙂
extension Array where Element == AnyLocationPerformer {
    func allWith(identifier: ObjectIdentifier) -> [Element] {
        return self.filter({ $0.typeIdentifier == identifier })
    }
}
