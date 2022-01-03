import Foundation
import CoreLocation.CLRegion

public enum RegionMonitoringEvent {
    case didEnterTo(region: CLRegion)
    case didExitTo(region: CLRegion)
    case didStartMonitoringFor(region: CLRegion)
    case monitoringDidFailFor(region: CLRegion?, error: Error)
}

class RegionMonitoringPerformer: AnyLocationPerformer {
    
    var typeIdentifier: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
    
    var uniqueIdentifier: UUID = UUID()
    
    var cancellabel: Cancellabel?
    var eventsSupport: [CoreLocationEventSupport] = [.didEnterRegion, .didExitRegion, .monitoringDidFailForRegion, .didStartMonitoringForRegion]
    var stream: RegionMonitoringStream.Continuation?
    var region: CLRegion
    
    init(region: CLRegion) {
        self.region = region
    }
    
    func linkContinuation(_ continuation: RegionMonitoringStream.Continuation) {
        stream = continuation
    }
    
    func eventSupported(_ event: CoreLocationDelegateEvent) -> Bool {
        return eventsSupport.contains(event.rawEvent())
    }
    
    func invokedMethod(event: CoreLocationDelegateEvent) {
        switch event {
        case .didEnterRegion(let region):
            stream?.yield(.didEnterTo(region: region))
        case .didExitRegion(let region):
            stream?.yield(.didExitTo(region: region))
        case .didStartMonitoringFor(let region):
            stream?.yield(.didStartMonitoringFor(region: region))
        case .monitoringDidFailFor(let region, let error):
            stream?.yield(.monitoringDidFailFor(region: region, error: error))
        default:
            fatalError("Method can't be execute by this performer: \(String(describing: self)) for event: \(type(of: event))")
        }
    }
    
    func cancelation() { }
    
}
