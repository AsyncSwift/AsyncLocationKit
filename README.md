# AsyncLocationKit

[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5.5-orange?style=flat)](https://img.shields.io/badge/Swift-5.5-Orange?style=flat)
[![Platforms](https://img.shields.io/badge/platforms-iOS--13%20|%20macOS(beta)%20|%20watchOS--6(beta)%20|%20tvOS(beta)-orange?style=flat)](https://img.shields.io/badge/platforms-iOS--13%20|%20macOS(beta)%20|%20watchOS--6(beta)%20|%20tvOS(beta)-orange?style=flat)

Wrapper for Apple `CoreLocation` framework with new Concurency Model. No more `delegate` pattern or `completion blocks`.

### Install
---
##### SPM
```swift
dependencies: [
    .package(url: "https://github.com/AsyncSwift/AsyncLocationKit.git", .upToNextMinor(from: "1.6.4"))
]
```

#### Cocoapods
```
pod 'AsyncLocationKit', :git => 'https://github.com/AsyncSwift/AsyncLocationKit.git', :tag => '1.6.4'
```


:warning: **Initialize AsyncLocationManager only synchronously on MainThread**

```swift
import AsyncLocationKit

let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)

let permission = await self.asyncLocationManager.requestAuthorizationWhenInUse() //returns CLAuthorizationStatus
```

You can use all methods from Apple `CLLocationManager`.

```swift
let coordinate = try await asyncLocationManager.requestLocation() //Request user location once
```

Start monitoring update of user location with `AsyncStream`.

```swift
for await locationUpdateEvent in await asyncLocationManager.startUpdatingLocation() {
    switch locationUpdateEvent {
    case .didUpdateLocations(let locations):
        // do something
    case .didFailWith(let error):
        // do something
    case .didPaused, .didResume: 
        break
    }
}
```

If `Task` was canceled, Stream finished automaticaly.
