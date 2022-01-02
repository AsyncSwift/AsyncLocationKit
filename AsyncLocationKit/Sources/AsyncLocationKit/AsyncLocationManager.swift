import Foundation
import CoreLocation

#if swift(>=5.5)

public typealias AuthotizationContinuation = CheckedContinuation<CLAuthorizationStatus, Never>
public typealias LocationOnceContinuation = CheckedContinuation<CLLocation, Error>
public typealias LocationStream = AsyncStream<[CLLocation]>

public final class AsyncLocationManager {
    public init() { }
}

#endif
