import XCTest
import CoreLocation
@testable import AsyncLocationKit

final class AsyncLocationKitTests: XCTestCase {
    let locationManager = AsyncLocationManager(locationManager: MockLocationManager(), desiredAccuracy: .bestAccuracy)
    
    func testRequestLocation() async {
        do {
            let location = try await locationManager.requestLocation()
            
            switch location {
            case .didUpdateLocations(let locations):
                print(locations)
                XCTAssert(true)
            default:
                XCTAssert(false, "Something went wrong")
            }
            
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
}
