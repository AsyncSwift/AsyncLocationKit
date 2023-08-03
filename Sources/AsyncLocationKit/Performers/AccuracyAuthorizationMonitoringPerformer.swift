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
import CoreLocation

public enum AccuracyAuthorizationEvent {
    case didUpdate(accuracyAuthorization: CLAccuracyAuthorization)
}

class AccuracyAuthorizationMonitoringPerformer: AnyLocationPerformer {
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }

    var uniqueIdentifier: UUID = UUID()

    var cancellable: Cancellable?
    var eventsSupport: [CoreLocationEventSupport] = [.didChangeAccuracyAuthorization]
    var stream: AccuracyAuthorizationStream.Continuation?

    func linkContinuation(_ continuation: AccuracyAuthorizationStream.Continuation) {
        stream = continuation
    }

    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }

    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didChangeAccuracyAuthorization(let accuracyAuthorization):
            stream?.yield(.didUpdate(accuracyAuthorization: accuracyAuthorization))
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }

    func cancelation() { }
}
