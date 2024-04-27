import Foundation
import ArgumentParser

@main
struct Starfall: ParsableCommand {
	@Option(name: .shortAndLong, help: "Loads a specific constellation file")
	var file: String? = nil
	@Option(name: .shortAndLong, help: "Path to search for constellation files")
	var searchPath: String? = nil
	@Option(name: .shortAndLong, help: "Hex color for stars and highlights")
	var color: String = "#ffffff"
	@Option(name: .shortAndLong, help: "Short form for info box labels", completion: .list(["normal", "symbol", "short"]))
	var labelFormat: LabelFormatType = .normal
	@Flag(name: .long, help: "Debug print all constellations")
	var debugConstellations: Bool = false
	@Flag(name: .shortAndLong, help: "Print version info and exit")
	var version: Bool = false

	mutating func run() throws {
		if(version) {
			print("starfall", "v" + ((Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1.0.0"))
			return;	
		}

		let constellations = Constellation.get_constellations(additionalPaths: searchPath)

		if debugConstellations {
			for constellation in constellations {
				print(try! ConstellationFile(path: constellation))
			}
		} else {
			print(try! ConstellationFile(path: constellations.randomElement()!))
		}

	}
}
