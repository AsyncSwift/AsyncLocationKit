//  MIT License
//
//  Copyright (c) 2022 AsyncSwift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

typealias CancelationCondition = ((AnyLocationPerformer) -> Bool)

protocol Cancellable: AnyObject {
    /// # Performer can use CheckecContinuation
    /// # who can return value only **once**, and next attempt will lead to **crash** application
    /// ```swift
    /// class SomePerformer: AnyLocationPerformer {
    ///     weak var cancellabel: Cancellabel?
    ///
    ///    func invokedMethod(event: **SomeEvent**) {
    ///         switch event {
    ///         case .didChangeAuthorization(let status):
    ///             if status != .notDetermined {
    ///                 guard let continuation = continuation else { cancellabel?.cancel(for: self); return }
    ///                 continuation.resume(returning: status)
    ///                 self.continuation = nil
    ///                 cancellabel?.cancel(for: self)
    ///             }
    ///         /* other cases c*/
    ///    }
    ///     // implementation other protocol methods
    /// }
    /// ```
    ///
    func cancel(for performer: AnyLocationPerformer)
}

protocol AsyncDelegateProxyInterface: AnyObject {
    func eventForMethodInvoked(_ event: CoreLocationDelegateEvent)
    func addPerformer(_ performer: AnyLocationPerformer)
    
    func cancel(for type: AnyLocationPerformer.Type)
    func cancel(for uniqueIdentifier: UUID)
    func cancel(for type: AnyLocationPerformer.Type, with condition: @escaping CancelationCondition)
}

final class AsyncDelegateProxy: AsyncDelegateProxyInterface {
    /// Array of performers, who handle events from normal delegate
    var performers: [AnyLocationPerformer] = []
    
    /// Handle method from delegate converted to **enum** case
    /// - Parameter event: case converting from method of normal delegate
    func eventForMethodInvoked(_ event: CoreLocationDelegateEvent) {
        for performer in performers {
            if performer.eventSupported(event) {
                performer.invokedMethod(event: event)
            }
        }
    }
    
    func addPerformer(_ performer: AnyLocationPerformer) {
        performer.cancellable = self
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
    
    func cancel(for type: AnyLocationPerformer.Type, with condition: @escaping (AnyLocationPerformer) -> Bool) {
        var filteredPerformer = performers.allWith(identifier: ObjectIdentifier(type))
        filteredPerformer.removeAll(where: { condition($0) })
        filteredPerformer.forEach { _performer in
            performers.removeAll(where: { $0.uniqueIdentifier == _performer.uniqueIdentifier })
        }
    }
}

extension AsyncDelegateProxy: Cancellable {
    func cancel(for performer: AnyLocationPerformer) {
        performers.removeAll(where: { $0.uniqueIdentifier == performer.uniqueIdentifier })
    }
}
