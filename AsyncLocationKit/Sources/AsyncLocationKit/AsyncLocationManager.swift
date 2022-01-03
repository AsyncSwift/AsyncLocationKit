import Foundation
import CoreLocation

#if swift(>=5.5)

public typealias AuthotizationContinuation = CheckedContinuation<CLAuthorizationStatus, Never>
public typealias LocationOnceContinuation = CheckedContinuation<CLLocation, Error>
public typealias LocationStream = AsyncStream<[CLLocation]>

public final class AsyncLocationManager {
    
    public private(set) var locationManager: CLLocationManager
    private var proxyDelegate: AsyncDelegateProxyInterface
    private var locationDelegate: CLLocationManagerDelegate
    
    public init() {
        locationManager = CLLocationManager()
        proxyDelegate = AsyncDelegateProxy()
        locationDelegate = LocationDelegate(delegateProxy: proxyDelegate)
        locationManager.delegate = locationDelegate
    }
    
    public func requestAuthorizationWhenInUse() async -> CLAuthorizationStatus {
        let authorizationPerformer = RequestAuthorizationPerformer()
        return await withTaskCancellationHandler {
            proxyDelegate.cancel(for: authorizationPerformer.uniqueIdentifier)
        } operation: {
            await withCheckedContinuation { continuation in
                authorizationPerformer.linkContinuation(continuation)
                proxyDelegate.addPerformer(authorizationPerformer)
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    public func requestAuthorizationAlways() async -> CLAuthorizationStatus {
        let authorizationPerformer = RequestAuthorizationPerformer()
        return await withTaskCancellationHandler {
            proxyDelegate.cancel(for: authorizationPerformer.uniqueIdentifier)
        } operation: {
            await withCheckedContinuation { continuation in
                authorizationPerformer.linkContinuation(continuation)
                proxyDelegate.addPerformer(authorizationPerformer)
                locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
    public func startMonitoring() async -> LocationStream {
        return LocationStream { stream in
            
        }
    }
    
}

#endif
