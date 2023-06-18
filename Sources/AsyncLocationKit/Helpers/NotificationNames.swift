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
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#elseif os(watchOS)
import WatchKit
#endif

@available(macOS 12, iOS 13, tvOS 13, watchOS 8, *)
struct NotificationNamesConstants {
#if os(iOS) || os(tvOS)
    static let willResignActiveName = UIApplication.willResignActiveNotification
#elseif os(macOS)
    static let willResignActiveName = NSApplication.willResignActiveNotification
#elseif os(watchOS)
    static let willResignActiveName = WKExtension.applicationWillResignActiveNotification
#endif
    
#if os(iOS) || os(tvOS)
    static let didBecomeActiveName = UIApplication.didBecomeActiveNotification
#elseif os(macOS)
    static let didBecomeActiveName = NSApplication.didBecomeActiveNotification
#elseif os(watchOS)
    static let didBecomeActiveName = WKExtension.applicationDidBecomeActiveNotification
#endif
}
