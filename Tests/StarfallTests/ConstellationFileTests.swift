import XCTest
@testable import starfall

final class ConstellationFileTests: XCTestCase {
	let testConstellation = """
name Neptue # Comment
quadrant Here
ascension 19h 57m 20s
declination 42.950°
area 7.6187x10^9 km2
seq 4
star 1 5
bright_star 8 2
""";

	func testInit() {
		do {
			let constellation = try ConstellationFile(data: testConstellation)
			XCTAssertEqual(constellation.name, "Neptue")
			XCTAssertEqual(constellation.quadrant, "Here")
			XCTAssertEqual(constellation.ascension, "19h 57m 20s")
			XCTAssertEqual(constellation.declination, "42.950°")
			XCTAssertEqual(constellation.area, "7.6187x10^9 km2")
			XCTAssertEqual(constellation.mainStars, 4)
			XCTAssertEqual(constellation.stars.count, 2)
			XCTAssertEqual(constellation.stars[0].x, 1)
			XCTAssertEqual(constellation.stars[0].y, 5)
			XCTAssertFalse(constellation.stars[0].bright)
			XCTAssertEqual(constellation.stars[1].x, 8)
			XCTAssertEqual(constellation.stars[1].y, 2)
			XCTAssertTrue(constellation.stars[1].bright)
		} catch ConstellationFileError.InvalidData(let hint) {
			XCTFail(hint);
		} catch {
			XCTFail();
		}
	}

	func testProvided() {
		let constellations = Constellation.get_constellations()
		for constellation in constellations {
			do {
				let value = try ConstellationFile(path: constellation)
				XCTAssertFalse(value.stars.isEmpty)
			} catch ConstellationFileError.InvalidData(let hint) {
				XCTFail(constellation + " errored with " + hint);
			} catch {
				XCTFail(constellation + " errored");
			}
		}
	}
}