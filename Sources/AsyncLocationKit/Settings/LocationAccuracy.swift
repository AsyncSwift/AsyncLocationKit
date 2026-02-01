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
@preconcurrency import CoreLocation

/// Represents the desired accuracy of location data.
///
/// Use this enum to specify how accurate you need location data to be.
/// Higher accuracy consumes more battery power.
///
/// ## Examples
/// ```swift
/// // For navigation apps
/// let manager = AsyncLocationManager(desiredAccuracy: .bestForNavigationAccuracy)
///
/// // For general location (saves battery)
/// let manager = AsyncLocationManager(desiredAccuracy: .hundredMetersAccuracy)
/// ```
public enum LocationAccuracy: Sendable {
    /// The highest level of accuracy available.
    ///
    /// Uses all available positioning methods (GPS, WiFi, cellular) for maximum precision.
    /// Consumes the most battery power.
    case bestAccuracy

    /// Accurate to within ten meters.
    ///
    /// Good balance between accuracy and battery usage for most apps.
    case nearestTenMetersAccuracy

    /// Accurate to within one hundred meters.
    ///
    /// Suitable for apps that don't need precise location. Uses less battery.
    case hundredMetersAccuracy

    /// Accurate to within one kilometer.
    ///
    /// Suitable for weather apps or other apps with low precision requirements.
    case kilometerAccuracy

    /// Accurate to within three kilometers.
    ///
    /// The lowest accuracy level. Minimal battery impact.
    case threeKilometersAccuracy

    /// The highest accuracy available, optimized for navigation.
    ///
    /// Similar to `bestAccuracy` but may use additional sensor data for navigation.
    case bestForNavigationAccuracy
    
    internal var convertingAccuracy: CLLocationAccuracy {
        switch self {
        case .bestAccuracy:
            return kCLLocationAccuracyBest
        case .nearestTenMetersAccuracy:
            return kCLLocationAccuracyNearestTenMeters
        case .hundredMetersAccuracy:
            return kCLLocationAccuracyHundredMeters
        case .kilometerAccuracy:
            return kCLLocationAccuracyKilometer
        case .threeKilometersAccuracy:
            return kCLLocationAccuracyThreeKilometers
        case .bestForNavigationAccuracy:
            return kCLLocationAccuracyBestForNavigation
        }
    }
}
