//
//  File.swift
//  
//
//  Created by Pavel Grechikhin on 29.10.2022.
//

import Foundation
import CoreLocation

class MockLocationManager: CLLocationManager {
    private var mockAllowsBackgroundLocationUpdates: Bool = false
    private var _authStatus: CLAuthorizationStatus = .notDetermined
    
    override var authorizationStatus: CLAuthorizationStatus {
        return _authStatus
    }
    
    #if !os(tvOS)
    override var allowsBackgroundLocationUpdates: Bool {
        get {
            return mockAllowsBackgroundLocationUpdates
        }
        set {
            mockAllowsBackgroundLocationUpdates = newValue
        }
    }
    #endif
    
    override var location: CLLocation? {
        return CLLocation(latitude: 100, longitude: 200)
    }
    
    override func requestLocation() {
        delegate?.locationManager?(self, didUpdateLocations: [location!])
    }
    
    override func requestAlwaysAuthorization() {
        _authStatus = .authorizedAlways
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.delegate?.locationManagerDidChangeAuthorization?(self)
        }
    }
    
    override func requestWhenInUseAuthorization() {
        _authStatus = .authorized
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.delegate?.locationManagerDidChangeAuthorization?(self)
        }
    }
}
