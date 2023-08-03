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
import CoreLocation.CLLocation

class RequestAuthorizationPerformer: AnyLocationPerformer {
    private let currentStatus: CLAuthorizationStatus
    private var applicationStateMonitor: ApplicationStateMonitor!

    init(currentStatus: CLAuthorizationStatus) {
        self.currentStatus = currentStatus
    }

    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var eventsSupport: [CoreLocationEventSupport] = [.didChangeAuthorization]
    
    var continuation: AuthotizationContinuation?
    
    weak var cancellable: Cancellable?
    
    func linkContinuation(_ continuation: AuthotizationContinuation) {
        self.continuation = continuation
        Task { await start() }
    }

    func start() async {
        applicationStateMonitor = await ApplicationStateMonitor()
        await applicationStateMonitor.startMonitoringApplicationState()

        // Wait a brief amount of time for the permission dialog to appear.
        Task { [applicationStateMonitor, currentStatus] in
            guard let applicationStateMonitor else { return }
            try await Task.sleep(nanoseconds: UInt64(Double(NSEC_PER_SEC) * 0.3))

            if await !applicationStateMonitor.hasResignedActive {
                // We timed out waiting for the dialog to appear, so we can assume that the permission request
                // silently failed. We then emit the `currentStatus` to be returned to the caller.
                await applicationStateMonitor.stopMonitoringApplicationState()
                await MainActor.run {
                    self.invokedMethod(event:.didChangeAuthorization(status: currentStatus))
                }
            }
        }
    }

    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didChangeAuthorization(let status):
            if status != .notDetermined {
                Task {
                    if await applicationStateMonitor.hasResignedActive {
                        _ = await applicationStateMonitor.hasBecomeActive()
                    }

                    guard let continuation = continuation else { cancellable?.cancel(for: self); return }
                    continuation.resume(returning: status)
                    self.continuation = nil
                    cancellable?.cancel(for: self)
                }
            }
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }

    func cancelation() {
        Task {
            await applicationStateMonitor.stopMonitoringApplicationState()
        }
    }
}
