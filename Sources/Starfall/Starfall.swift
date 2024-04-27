import Foundation
import ArgumentParser

extension String.SubSequence {
	func fullwidth() -> String {
		let utf32 = self.unicodeScalars.map { $0.isASCII ? $0.value + 0xfee0 : $0.value }
		let data = Data(bytes: utf32, count: utf32.count * MemoryLayout<UInt32>.stride)
		return String(data: data, encoding: .utf32LittleEndian) ?? String(self)
	}
}

@main
struct Starfall: ParsableCommand {
	@Option(name: .shortAndLong, help: "Loads a specific constellation file")
	var file: String? = nil
	@Option(name: .shortAndLong, help: "Path to search for constellation files")
	var searchPath: String? = nil
	@Option(name: .shortAndLong, help: "Hex color for stars and highlights")
	var color: String = "ffffff"
	@Option(name: .shortAndLong, help: "Label format for attributes", completion: .list(["normal", "symbol", "short"]))
	var labelFormat: LabelFormat = .normal
	@Option(name: .shortAndLong, help: "Text transformation for window headings", completion: .list(["normal", "uppercase", "lowercase"]))
	var textTransform: TextTransform = .lowercase
	@Flag(name: .long, help: "Debug print all constellations")
	var debugConstellations: Bool = false
	@Flag(name: .shortAndLong, help: "Print version info and exit")
	var version: Bool = false

	func run() {
		if version {
			print("starfall", "v" + ((Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1.0.0"))
			return	
		}

#if os(Windows)
		// Enable VT100 interpretation
		let hOut = GetStdHandle(STD_OUTPUT_HANDLE)
		var dwMode: DWORD = 0

		guard hOut != INVALID_HANDLE_VALUE else { return }
		guard GetConsoleMode(hOut, &dwMode) else { return }

		dwMode |= DWORD(ENABLE_VIRTUAL_TERMINAL_PROCESSING)
		guard SetConsoleMode(hOut, dwMode) else { return }
#endif

		let constellations = Constellation.get_constellations(additionalPaths: searchPath)

		if debugConstellations {
			for constellation in constellations {
				render(path: constellation)
			}
		} else {
			render(path: constellations.randomElement())
		}
	}

	static let WindowWidth: Int = 24
	static let WindowHeight: Int = 12

	func render(path: String?) {
		if path == nil {
			return
		}

		do {
			let constellation: ConstellationFile = try ConstellationFile(path: path!)

			if Terminal.terminalWidth > 40 {
				render_window(constellation)
			} else {
				render_info(constellation)
			}
		} catch {
			print(error)
		}
	}

	private static let star: Character = "✦"
	private static let bright_star: Character = "✧"

	private static let resetString = "\u{001B}[0m"
	private static let boldString = "\u{001B}[1m"

	// this code is gigantically ugly.
	func render_window(_ constellation: ConstellationFile) {
		var lines: [String] = []
		let name = switch self.textTransform {
			case .lowercase:
				constellation.name.lowercased()
			case .uppercase:
				constellation.name.uppercased()
			default:
				constellation.name
		}

		// rgb to xterm-24-bit, but only if COLORTERM is set
		let supportsColor = ProcessInfo.processInfo.environment["COLORTERM"] == "truecolor"
		let colorRgb = Int(color, radix: 16) ?? 0xFFFFFF
		let colorString = supportsColor ? ("\u{001B}[38;2;" + String((colorRgb >> 16) & 0xFF) + ";" + String((colorRgb >> 8) & 0xFF) + ";" + String(colorRgb & 0xFF) + "m") : ""
		
		// preprocess first part
		let nameParts = name.split(separator: " ", omittingEmptySubsequences: true)
		let pre = nameParts[0].fullwidth()
		let preRemain = (Starfall.WindowWidth / 2) - pre.count

		if preRemain > 0 {
			lines.append("┌" + String(repeating: "─", count: preRemain) + Starfall.boldString + colorString + pre + Starfall.resetString + String(repeating: "─", count: preRemain) + "┐")
		} else {
			lines.append("┌" + pre + "┐")
		}

		for _ in 0..<Starfall.WindowHeight {
			lines.append("│" + String(repeating: " ", count: Starfall.WindowWidth) + "│")
		}
		
		// add stars
		for star in constellation.stars {
			var line = Array(lines[star.y + 1])
			line[star.x + 1] = star.bright ? Starfall.bright_star : Starfall.star
			lines[star.y + 1] = String(line)
		}
		
		for i in 0..<Starfall.WindowHeight {
			lines[i] = lines[i].replacingOccurrences(of: String(Starfall.bright_star), with: colorString + String(Starfall.bright_star) + Starfall.resetString, options: .literal, range: nil).replacingOccurrences(of: String(Starfall.star), with: colorString + String(Starfall.star) + Starfall.resetString, options: .literal, range: nil)
		}

		// preprocess last part, if necessary
		if nameParts.count > 1 {
			let post = nameParts[1].fullwidth()
			let postRemain = (Starfall.WindowWidth / 2) - post.count

			if postRemain > 0 {
				lines.append("└" + String(repeating: "─", count: postRemain) + Starfall.boldString + colorString + post + Starfall.resetString + String(repeating: "─", count: postRemain) + "┘")
			} else {
				lines.append("└" + post + "┘")
			}
		} else {
			lines.append("└" + String(repeating: "─", count: Starfall.WindowWidth) + "┘")
		}

		let prefix = "\t" + Starfall.boldString + colorString
		let separator = (labelFormat == .symbol ? "" : ":") + " " + Starfall.resetString

		lines[2] += prefix + constellation.name + Starfall.resetString

		let attributes = labelFormat.labels
		var currentLine = 4
		if constellation.quadrant != nil {
			lines[currentLine] += prefix + attributes[0] + separator + constellation.quadrant!
			currentLine += 1
		}
		
		if constellation.ascension != nil {
			lines[currentLine] += prefix + attributes[1] + separator + constellation.ascension!
			currentLine += 1
		}
		
		if constellation.declination != nil {
			lines[currentLine] += prefix + attributes[2] + separator + constellation.declination!
			currentLine += 1
		}
		
		if constellation.area != nil {
			lines[currentLine] += prefix + attributes[3] + separator + constellation.area!
			currentLine += 1
		}
		
		if !constellation.groups.isEmpty {
			lines[currentLine] += prefix + attributes[4] + separator + constellation.groups.map { String($0) }.joined(separator: ", ")
			currentLine += 1
		}

		for line in lines {
			print(line)
		}
	}

	func render_info(_ constellation: ConstellationFile) {
		let supportsColor = ProcessInfo.processInfo.environment["COLORTERM"] == "truecolor"
		let colorRgb = Int(color, radix: 16) ?? 0xFFFFFF
		let colorString = supportsColor ? ("\u{001B}[38;2;" + String((colorRgb >> 16) & 0xFF) + ";" + String((colorRgb >> 8) & 0xFF) + ";" + String(colorRgb & 0xFF) + "m") : ""
		let prefix = Starfall.boldString + colorString
		let separator = (labelFormat == .symbol ? "" : ":") + " " + Starfall.resetString
		let attributes = labelFormat.labels

		print(prefix + constellation.name + Starfall.resetString)
		print("")
		if constellation.quadrant != nil {
			print(prefix + attributes[0] + separator + constellation.quadrant!)
		}
		
		if constellation.ascension != nil {
			print(prefix + attributes[1] + separator + constellation.ascension!)
		}
		
		if constellation.declination != nil {
			print(prefix + attributes[2] + separator + constellation.declination!)
		}
		
		if constellation.area != nil {
			print(prefix + attributes[3] + separator + constellation.area!)
		}
		
		if !constellation.groups.isEmpty {
			print(prefix + attributes[4] + separator + constellation.groups.map { String($0) }.joined(separator: ", "))
		}
	}
}
