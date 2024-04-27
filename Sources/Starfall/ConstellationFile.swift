import Foundation

struct ConstellationFile {
	let name: String;
	let quadrant: String?;
	let ascension: String?;
	let declination: String?;
	let area: String?;
	let mainStars: Int;
	let subStars: Int;
	let stars: [Star];

	init(data: String) throws {
		if(!data.starts(with: "name ")) {
			throw ConstellationFileError.InvalidData(hint: "not a constellation file")
		}

		var name: String.SubSequence? = nil;
		var quadrant: String.SubSequence? = nil;
		var ascension: String.SubSequence? = nil;
		var declination: String.SubSequence? = nil;
		var area: String.SubSequence? = nil;
		var mainStars: Int = 0;
		var subStars: Int = 0;
		var stars: [Star] = [];

		for rawLine in data.split(separator: "\n", omittingEmptySubsequences: true) {
			if (rawLine.isEmpty) {
				continue;
			}

			let line = rawLine.split(separator: "#", maxSplits: 1)[0].trimmingCharacters(in: .whitespacesAndNewlines)
			let parts: [Substring.SubSequence] = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true);
			if(parts.count < 2 || parts[1].isEmpty) {
				continue;
			}

			switch(parts[0]) {
				case "name":
					name = parts[1];
					break;
				case "quadrant":
					quadrant = parts[1];
					break;
				case "ascension":
					ascension = parts[1];
					break;
				case "declination":
					declination = parts[1];
					break;
				case "area":
					area = parts[1];
					break;
				case "seq", "n_stars":
					let nParts = parts[1].split(separator: ",", maxSplits: 1)
					if let val = Int.init(argument: String(nParts[0])) {
						mainStars = val;
					} else {
						throw ConstellationFileError.InvalidData(hint: "main stars value is bad");
					}

					if nParts.count > 1 {
						if let val = Int.init(argument: String(nParts[1])) {
							subStars = val;
						}
					}
					break;
				case "star", "bright_star":
					let starParts = parts[1].split(separator: " ", maxSplits: 1)
					if starParts.count < 2 {
						throw ConstellationFileError.InvalidData(hint: "not enough components to make a star");
					}
					
					let x = Int.init(argument: String(starParts[0]));
					if x == nil || x! < 0 || x! > 40 {
						throw ConstellationFileError.InvalidData(hint: "star x coordinate is bad");
					}

					let y = Int.init(argument: String(starParts[1]));
					if y == nil || y! < 0 || y! > 40 {
						throw ConstellationFileError.InvalidData(hint: "star x coordinate is bad");
					}
					
					stars.append(Star(x: x!, y: y!, minor: parts[0] == "bright_star"))
					break;
				default:
					continue
			}
		}

		if name == nil {
			throw ConstellationFileError.InvalidData(hint: "no name");
		}

		if stars.isEmpty {
			throw ConstellationFileError.InvalidData(hint: "no stars");
		}

		self.name = String(name!);
		self.quadrant = quadrant == nil ? nil : String(quadrant!);
		self.ascension = ascension == nil ? nil : String(ascension!);
		self.declination = declination == nil ? nil : String(declination!);
		self.area = area == nil ? nil : String(area!);
		self.mainStars = mainStars;
		self.subStars = subStars;
		self.stars = stars;
	}

	init(path: String) throws {
		if let file = FileManager.default.contents(atPath: path) {
			if let str = String(data: file, encoding: .utf8) {
				try self.init(data: str)
				return
			}

			throw ConstellationFileError.UnableToLoad;
		}

		throw ConstellationFileError.NoSuchConstellationFile;
	}
}