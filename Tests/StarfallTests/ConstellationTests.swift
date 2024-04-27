import XCTest
@testable import starfall

final class ConstellationTests: XCTestCase {
	func test_get_constellations_path() {
		XCTAssertTrue(Constellation.get_constellations(path: Bundle.module.resourcePath ?? "./").count > 0)
	}

	func test_get_constellations() {
		XCTAssertFalse(Constellation.get_constellations().isEmpty)
	}
}