import ArgumentParser

enum TextTransform: ExpressibleByArgument {
	init?(argument: String) {
		switch argument.lowercased() {
			case "uppercase":
				self = .uppercase
				break
			case "lowercase":
				self = .lowercase
				break
			default:
				self = .normal
				break
		}
	}

	case normal
	case uppercase
	case lowercase

}