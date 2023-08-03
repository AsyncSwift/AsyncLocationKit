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

@available(watchOS, unavailable)
@available(tvOS, unavailable)
public enum BeaconRangeEvent {
    case didRange(beacons: [CLBeacon], beaconConstraint: CLBeaconIdentityConstraint)
    case didFailRanginFor(beaconConstraint: CLBeaconIdentityConstraint, error: Error)
}

@available(watchOS, unavailable)
class BeaconsRangePerformer: AnyLocationPerformer {
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var cancellable: Cancellable?
    
    var eventssupported: [CoreLocationEventSupport] = [.didRangeBeacons, .didFailRanginForBeaconConstraint]
    
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    var satisfying: CLBeaconIdentityConstraint
    
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    var stream: BeaconsRangingStream.Continuation?
    
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    init(satisfying: CLBeaconIdentityConstraint) {
        self.satisfying = satisfying
    }
    
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    func linkContinuation(_ continuation: BeaconsRangingStream.Continuation) {
        self.stream = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventssupported.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        #if !os(tvOS)
        case .didRange(let beacons, let beaconConstraint):
            stream?.yield(.didRange(beacons: beacons, beaconConstraint: beaconConstraint))
        case .didFailRanginFor(let beaconConstraint, let error):
            stream?.yield(.didFailRanginFor(beaconConstraint: beaconConstraint, error: error))
        #endif
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }
    
    func cancelation() { }   
}
