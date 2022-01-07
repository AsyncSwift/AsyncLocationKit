# AsyncLocationKit

[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat)
[![Swift](https://img.shields.io/badge/Swift-5.5-orange?style=flat)](https://img.shields.io/badge/Swift-5.3_5.4_5.5-Orange?style=flat)

Wrapper for Apple `CoreLocation` framework with new Concurency Model. No more `delegate` patter or `completion blocks`.

```swift
import AsyncLocationKit

let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)

Task {
    let permission = await self.asyncLocationManager.requestAuthorizationWhenInUse() //returns CLAuthorizationStatus
}
```

You can use all methods from Apple `CLLocationManager`.

```swift
Task {
    let coordinate = try await asyncLocationManager.requestLocation() //Request user location once
}
```

Start monitoring update of user location with `AsyncStream`.

```swift
Task {
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
}
```

If `Task` was canceled, Stream finished automaticaly.
