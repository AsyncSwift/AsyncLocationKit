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

/// Represents the type of location permission to request from the user.
///
/// ## Usage Descriptions Required
/// Add the appropriate keys to your Info.plist:
/// - For `whenInUsage`: `NSLocationWhenInUseUsageDescription`
/// - For `always`: `NSLocationAlwaysAndWhenInUseUsageDescription`
///
/// ## Example
/// ```swift
/// let status = await manager.requestPermission(with: .whenInUsage)
/// ```
public enum LocationPermission: Sendable {
    /// Request "Always" authorization.
    ///
    /// Allows the app to access location even when in the background or suspended.
    /// Required for features like geofencing, significant location changes, or visit monitoring.
    ///
    /// - Important: On iOS 13+, users first see "When In Use" authorization, then must separately
    ///   grant "Always" authorization. App Clips always receive "When In Use" regardless of what's requested.
    case always

    /// Request "When In Use" authorization.
    ///
    /// Allows the app to access location only when the app is in use (foreground or using
    /// background location with the blue status bar indicator).
    ///
    /// This is the recommended default for most apps.
    case whenInUsage
}
