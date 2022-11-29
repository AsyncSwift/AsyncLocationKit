import XCTest
import CoreLocation
@testable import AsyncLocationKit

final class AsyncLocationKitTests: XCTestCase {
    static let mockLocationManager = MockLocationManager()
    
    func testDesiredAccuracy() {
        let firstAccuracy: LocationAccuracy = .nearestTenMetersAccuracy
        let locationManager = AsyncLocationManager(locationManager: AsyncLocationKitTests.mockLocationManager, desiredAccuracy: firstAccuracy)
        XCTAssertTrue(AsyncLocationKitTests.mockLocationManager.desiredAccuracy == firstAccuracy.convertingAccuracy)

        let secondAccuracy: LocationAccuracy = .bestForNavigationAccuracy
        locationManager.updateAccuracy(with: secondAccuracy)
        XCTAssertTrue(AsyncLocationKitTests.mockLocationManager.desiredAccuracy == secondAccuracy.convertingAccuracy)
    }

    func testAllowsBackgroundLocationUpdates() {
        let firstAllows = true
        let locationManager = AsyncLocationManager(locationManager: AsyncLocationKitTests.mockLocationManager, allowsBackgroundLocationUpdates: firstAllows)
        XCTAssertTrue(AsyncLocationKitTests.mockLocationManager.allowsBackgroundLocationUpdates == firstAllows)

        let secondAllows = false
        locationManager.updateAllowsBackgroundLocationUpdates(with: secondAllows)
        XCTAssertTrue(AsyncLocationKitTests.mockLocationManager.allowsBackgroundLocationUpdates == secondAllows)
    }

    func testRequestLocation() async {
        do {
            let locationManager = AsyncLocationManager(locationManager: AsyncLocationKitTests.mockLocationManager)
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
