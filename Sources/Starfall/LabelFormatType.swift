import ArgumentParser

enum LabelFormatType: ExpressibleByArgument {
	init?(argument: String) {
		switch(argument.lowercased()) {
			case "normal":
				self = .normal
				break;
			case "symbol":
				self = .symbol
				break;
			case "short":
				self = .short
				break;
			default:
				self = .normal
				break
		}
	}

	case normal
	case symbol
	case short

}
