import ArgumentParser

enum LabelFormat: ExpressibleByArgument {
	init?(argument: String) {
		switch argument.lowercased() {
			case "symbol":
				self = .symbol
				break
			case "short":
				self = .short
				break
			default:
				self = .normal
				break
		}
	}

	case normal
	case symbol
	case short

	var labels: [String] {
		switch self {
			case .symbol:
				return ["Q", "α", "δ", "A", "✦"]
			case .short:
				return ["Quad", "Asc", "Decl", "Area", "Stars"]
			default: // unreachable
				return ["Quadrant", "Ascension", "Declination", "Area", "Star Groups"]
		}
	}
}
