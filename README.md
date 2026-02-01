# AsyncLocationKit

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.5+-orange.svg" alt="Swift 5.5+"/>
  <img src="https://img.shields.io/badge/iOS-13.0+-blue.svg" alt="iOS 13.0+"/>
  <img src="https://img.shields.io/badge/macOS-12.0+-blue.svg" alt="macOS 12.0+"/>
  <img src="https://img.shields.io/badge/watchOS-6.0+-blue.svg" alt="watchOS 6.0+"/>
  <img src="https://img.shields.io/badge/tvOS-13.0+-blue.svg" alt="tvOS 13.0+"/>
  <img src="https://img.shields.io/badge/license-MIT-black.svg" alt="License: MIT"/>
  <img src="https://img.shields.io/badge/SPM-compatible-green.svg" alt="SPM Compatible"/>
  <img src="https://img.shields.io/badge/CocoaPods-compatible-green.svg" alt="CocoaPods Compatible"/>
</p>

<p align="center">
  <b>Modern, async/await wrapper for Apple's CoreLocation framework</b><br/>
  No more delegate patterns or completion blocks. Embrace Swift's structured concurrency.
</p>

---

## Features

- **Async/Await Native**: Built from the ground up for Swift's modern concurrency model
- **AsyncStream Support**: Monitor continuous location updates with `for await` loops
- **Type-Safe**: Comprehensive event types for all CoreLocation scenarios
- **Zero Dependencies**: Pure Swift, no external frameworks
- **Multi-Platform**: iOS, macOS, watchOS, and tvOS support
- **Thread-Safe**: Concurrent access protected with serial dispatch queues
- **Swift 6 Ready**: Full Sendable conformance for strict concurrency checking

---

## Installation

### Swift Package Manager

Add AsyncLocationKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AsyncSwift/AsyncLocationKit.git", from: "1.6.4")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/AsyncSwift/AsyncLocationKit.git`
3. Select version `1.6.4` or later

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'AsyncLocationKit', :git => 'https://github.com/AsyncSwift/AsyncLocationKit.git', :tag => '1.6.4'
```

Then run:
```bash
pod install
```

---

## Quick Start

### Initialization

> **Important**: Always initialize `AsyncLocationManager` synchronously on the main thread.

```swift
import AsyncLocationKit

let locationManager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)
```

### Request Authorization

```swift
// Request "When In Use" authorization
let status = await locationManager.requestPermission(with: .whenInUsage)

// Or request "Always" authorization
let status = await locationManager.requestPermission(with: .always)

// Handle the authorization status
switch status {
case .authorizedWhenInUse, .authorizedAlways:
    print("Location authorized!")
case .denied:
    print("Location access denied")
case .restricted:
    print("Location access restricted")
case .notDetermined:
    print("Authorization not determined")
@unknown default:
    print("Unknown authorization status")
}
```

### Single Location Request

Get the user's location once:

```swift
do {
    if let event = try await locationManager.requestLocation() {
        switch event {
        case .didUpdateLocations(let locations):
            print("Current location: \(locations.first?.coordinate)")
        case .didFailWith(let error):
            print("Location error: \(error)")
        default:
            break
        }
    }
} catch {
    print("Failed to get location: \(error)")
}
```

### Continuous Location Updates

Monitor location changes using AsyncStream:

```swift
Task {
    for await event in await locationManager.startUpdatingLocation() {
        switch event {
        case .didUpdateLocations(let locations):
            print("New location: \(locations.last?.coordinate)")
        case .didFailWith(let error):
            print("Error: \(error)")
        case .didPaused:
            print("Location updates paused")
        case .didResume:
            print("Location updates resumed")
        }
    }
}
```

The stream automatically stops when the Task is cancelled:

```swift
let task = Task {
    for await event in await locationManager.startUpdatingLocation() {
        // Handle location updates
    }
}

// Later, cancel the task to stop location updates
task.cancel()
```

---

## Usage Examples

### Monitor Authorization Changes

```swift
Task {
    for await event in await locationManager.startMonitoringAuthorization() {
        switch event {
        case .didUpdate(let authorization):
            print("Authorization changed to: \(authorization)")
        }
    }
}
```

### Monitor Location Services Availability

```swift
Task {
    for await event in await locationManager.startMonitoringLocationEnabled() {
        switch event {
        case .didUpdate(let enabled):
            print("Location services enabled: \(enabled)")
        }
    }
}
```

### Region Monitoring (iOS/macOS only)

```swift
let region = CLCircularRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    radius: 100,
    identifier: "San Francisco"
)

Task {
    for await event in await locationManager.startMonitoring(for: region) {
        switch event {
        case .didEnterTo(let region):
            print("Entered region: \(region.identifier)")
        case .didExitTo(let region):
            print("Exited region: \(region.identifier)")
        case .didStartMonitoringFor(let region):
            print("Started monitoring: \(region.identifier)")
        case .monitoringDidFailFor(let region, let error):
            print("Monitoring failed: \(error)")
        }
    }
}
```

### Heading Updates (iOS only)

```swift
#if os(iOS)
Task {
    for await event in await locationManager.startUpdatingHeading() {
        switch event {
        case .didUpdate(let heading):
            print("Heading: \(heading.trueHeading)°")
        case .didFailWith(let error):
            print("Heading error: \(error)")
        }
    }
}
#endif
```

### Visit Monitoring (iOS only)

```swift
#if os(iOS)
Task {
    for await event in await locationManager.startMonitoringVisit() {
        switch event {
        case .didVisit(let visit):
            print("Visit: \(visit.coordinate)")
            print("Arrival: \(visit.arrivalDate)")
            print("Departure: \(visit.departureDate)")
        case .didFailWithError(let error):
            print("Visit monitoring error: \(error)")
        }
    }
}
#endif
```

### Beacon Ranging (iOS/macOS only)

```swift
#if !os(watchOS) && !os(tvOS)
let beaconConstraint = CLBeaconIdentityConstraint(
    uuid: UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
)

Task {
    for await event in await locationManager.startRangingBeacons(satisfying: beaconConstraint) {
        switch event {
        case .didRange(let beacons, _):
            print("Found \(beacons.count) beacons")
        case .didFailRanginFor(_, let error):
            print("Beacon ranging failed: \(error)")
        }
    }
}
#endif
```

### Significant Location Changes (iOS/macOS only)

```swift
#if !os(watchOS) && !os(tvOS)
Task {
    for await event in await locationManager.startMonitoringSignificantLocationChanges() {
        switch event {
        case .didUpdateLocations(let locations):
            print("Significant location change: \(locations)")
        case .didFailWith(let error):
            print("Error: \(error)")
        case .didPaused, .didResume:
            break
        }
    }
}
#endif
```

### Request Temporary Full Accuracy (iOS 14+)

```swift
#if os(iOS)
if #available(iOS 14.0, *) {
    do {
        let accuracy = try await locationManager.requestTemporaryFullAccuracyAuthorization(
            purposeKey: "YourPurposeKeyFromInfoPlist"
        )
        print("Accuracy authorization: \(accuracy)")
    } catch {
        print("Failed to request full accuracy: \(error)")
    }
}
#endif
```

---

## Architecture

AsyncLocationKit uses a **Performer Pattern** to elegantly manage the complex delegate-based CoreLocation API:

```
┌─────────────────────────┐
│  AsyncLocationManager   │
│  (Public API)           │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  AsyncDelegateProxy     │
│  (Event Dispatcher)     │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  AnyLocationPerformer   │
│  (Protocol)             │
└───────────┬─────────────┘
            │
            ├──► SingleLocationUpdatePerformer
            ├──► MonitoringUpdateLocationPerformer
            ├──► AuthorizationPerformer
            ├──► RegionMonitoringPerformer
            └──► ...and more
```

**Key Components:**

- **AsyncLocationManager**: Main entry point providing async/await methods
- **AsyncDelegateProxy**: Thread-safe dispatcher routing events to performers
- **Performers**: Individual handlers for specific CoreLocation delegate methods
- **Events**: Strongly-typed enums representing CoreLocation callbacks

This architecture provides:
- Thread-safe concurrent access
- Clean separation of concerns
- Easy testability
- Type safety throughout

---

## Configuration Options

### Location Accuracy

```swift
let manager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)

// Available accuracy levels:
// .bestAccuracy
// .nearestTenMetersAccuracy
// .hundredMetersAccuracy
// .kilometerAccuracy
// .threeKilometersAccuracy
// .bestForNavigationAccuracy

// Update accuracy dynamically:
manager.updateAccuracy(with: .hundredMetersAccuracy)
```

### Background Location Updates

```swift
let manager = AsyncLocationManager(
    desiredAccuracy: .bestAccuracy,
    allowsBackgroundLocationUpdates: true
)

// Update background setting dynamically (iOS/macOS/watchOS only):
#if !os(tvOS)
manager.updateAllowsBackgroundLocationUpdates(with: true)
#endif
```

---

## API Reference

### Location Authorization

| Method | Description | Return Type |
|--------|-------------|-------------|
| `requestPermission(with:)` | Request location permission | `CLAuthorizationStatus` |
| `getAuthorizationStatus()` | Get current authorization status | `CLAuthorizationStatus` |
| `startMonitoringAuthorization()` | Monitor authorization changes | `AuthorizationStream` |

### Location Updates

| Method | Description | Return Type |
|--------|-------------|-------------|
| `requestLocation()` | Request single location update | `LocationUpdateEvent?` |
| `startUpdatingLocation()` | Start continuous updates | `LocationStream` |
| `stopUpdatingLocation()` | Stop location updates | `Void` |

### Monitoring

| Method | Description | Return Type |
|--------|-------------|-------------|
| `startMonitoring(for:)` | Monitor region entry/exit | `RegionMonitoringStream` |
| `startMonitoringVisit()` | Monitor significant visits | `VisitMonitoringStream` |
| `startMonitoringSignificantLocationChanges()` | Monitor significant changes | `SignificantLocationChangeMonitoringStream` |

### Utilities

| Method | Description | Return Type |
|--------|-------------|-------------|
| `getLocationEnabled()` | Check if location services enabled | `Bool` |
| `startMonitoringLocationEnabled()` | Monitor location services status | `LocationEnabledStream` |

---

## Platform Availability

| Feature | iOS | macOS | watchOS | tvOS |
|---------|-----|-------|---------|------|
| Basic Location | ✅ | ✅ | ✅ | ✅ |
| Authorization | ✅ | ✅ | ✅ | ✅ |
| Region Monitoring | ✅ | ✅ | ❌ | ❌ |
| Visit Monitoring | ✅ | ❌ | ❌ | ❌ |
| Heading Updates | ✅ | ❌ | ❌ | ❌ |
| Beacon Ranging | ✅ | ✅ | ❌ | ❌ |
| Significant Changes | ✅ | ✅ | ❌ | ❌ |
| Background Updates | ✅ | ✅ | ✅ | ❌ |

---

## Requirements

- **Swift**: 5.5 or later
- **iOS**: 13.0 or later
- **macOS**: 12.0 or later
- **watchOS**: 6.0 or later
- **tvOS**: 13.0 or later
- **Xcode**: 13.0 or later

---

## Migration Guide

### From Delegate-Based CoreLocation

**Before** (delegate pattern):
```swift
class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var completion: ((CLLocation?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager,
                        didUpdateLocations locations: [CLLocation]) {
        completion?(locations.first)
    }
}
```

**After** (async/await):
```swift
let locationManager = AsyncLocationManager()

do {
    if let event = try await locationManager.requestLocation() {
        if case .didUpdateLocations(let locations) = event {
            print(locations.first)
        }
    }
} catch {
    print("Error: \(error)")
}
```

---

## Best Practices

1. **Always initialize on the main thread**: CoreLocation requires main thread initialization
   ```swift
   let manager = AsyncLocationManager() // ✅ On main thread
   ```

2. **Handle authorization properly**: Always check authorization before requesting location
   ```swift
   let status = await manager.requestPermission(with: .whenInUsage)
   guard status == .authorizedWhenInUse || status == .authorizedAlways else {
       return
   }
   ```

3. **Cancel tasks to stop monitoring**: Streams automatically clean up when tasks are cancelled
   ```swift
   let task = Task {
       for await event in await manager.startUpdatingLocation() { ... }
   }
   // Later:
   task.cancel() // Stops location updates
   ```

4. **Choose appropriate accuracy**: Use lower accuracy when possible to save battery
   ```swift
   let manager = AsyncLocationManager(desiredAccuracy: .hundredMetersAccuracy)
   ```

5. **Add required Info.plist keys**: Don't forget to add location usage descriptions
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to show nearby places</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>We need your location to provide location-based features</string>
   ```

---

## Troubleshooting

<details>
<summary><b>Location updates not working</b></summary>

- Ensure you've added the required Info.plist keys
- Check that authorization has been granted
- Verify location services are enabled on the device
- Make sure you initialized on the main thread
</details>

<details>
<summary><b>Task cancelled warning</b></summary>

This is expected behavior when you cancel a Task that's monitoring location updates. The library properly cleans up resources.
</details>

<details>
<summary><b>Background location not working</b></summary>

- Add "Location updates" to Background Modes in Xcode capabilities
- Set `allowsBackgroundLocationUpdates` to `true`
- Request "Always" authorization, not just "When In Use"
</details>

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Guidelines

- Follow Swift API design guidelines
- Add tests for new features
- Update documentation for public API changes
- Ensure code compiles on all supported platforms

---

## License

AsyncLocationKit is released under the MIT License. See [LICENSE](LICENSE) for details.

```
MIT License

Copyright (c) 2022 AsyncSwift

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

- Built by the AsyncSwift team
- Inspired by the Swift concurrency revolution
- Thanks to all contributors and users

---

## Links

- [GitHub Repository](https://github.com/AsyncSwift/AsyncLocationKit)
- [Issue Tracker](https://github.com/AsyncSwift/AsyncLocationKit/issues)
- [Apple CoreLocation Documentation](https://developer.apple.com/documentation/corelocation)
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

---

<p align="center">
  Made with ❤️ by the AsyncSwift team
</p>
