import Foundation

enum Constellation {
	static func get_constellations(path: String) -> [String] {
		do {
			return try FileManager.default.contentsOfDirectory(atPath: path).filter({ NSString(string: $0).pathExtension == "constellation" })
		} catch {
			return []
		}
	}
	
	private static func get_constellations_bundled() -> [String] {
		return Bundle.module.paths(forResourcesOfType: "constellation", inDirectory: nil)
	}

	private static func get_constellations_system_xdg() -> [String] {
		if let xdgDataDirs: String = ProcessInfo.processInfo.environment["XDG_DATA_DIRS"] {
			var paths : [String] = []
			let dirs: [String.SubSequence] = xdgDataDirs.split(separator: ":", omittingEmptySubsequences: true)
			for dir: String.SubSequence in dirs {
 				paths.append(contentsOf: get_constellations(path: NSString.path(withComponents: [String(dir), "starfall"])))
			}

			return paths
		} else {
			return get_constellations(path: "/usr/share/starfall")
		}
	}
	
	private static func get_constellations_user_xdg() -> [String] {
		if let xdgHome: String = ProcessInfo.processInfo.environment["XDG_DATA_HOME"] {
			return get_constellations(path: NSString.path(withComponents: [xdgHome, "starfall"]))
		} else if let home: String = ProcessInfo.processInfo.environment["HOME"] {
			return get_constellations(path: NSString.path(withComponents: [home, ".local/share/starfall"]))
		} else if let user: String = ProcessInfo.processInfo.environment["USER"] {
			#if os(macOS)
				return get_constellations(path: NSString.path(withComponents: ["/Users", user, ".local/share/starfall"]))
			#else
				return get_constellations(path: NSString.path(withComponents: ["/home", user, ".local/share/starfall"]))
			#endif
		}

		return []
	}
	
	private static func get_constellations_macos() -> [String] {
		var paths : [String] = []
        if let user: String = ProcessInfo.processInfo.environment["USER"] {
			paths.append(contentsOf: get_constellations(path: NSString.path(withComponents: ["/Users", user, "Library/Application Support/aq.chronovore.Starfall"])))
		}
		
        paths.append(contentsOf: get_constellations(path: NSString.path(withComponents: ["/Library/Application Support/aq.chronovore.Starfall"])))
        return paths
	}
	
	private static func get_constellations_windows() -> [String] {
		var paths : [String] = []
		if let appdata: String = ProcessInfo.processInfo.environment["APPDATA"] {
			paths.append(contentsOf: get_constellations(path: NSString.path(withComponents: [appdata, "aq.chronovore.starfall"])))
		} 

		if let localAppdata: String = ProcessInfo.processInfo.environment["LOCALAPPDATA"] {
			paths.append(contentsOf: get_constellations(path: NSString.path(withComponents: [localAppdata, "aq.chronovore.starfall"])))
		}

		if let programData: String = ProcessInfo.processInfo.environment["PROGRAMDATA"] {
			paths.append(contentsOf: get_constellations(path: NSString.path(withComponents: [programData, "aq.chronovore.starfall"])))
		}
        
        return paths
	}

	static func get_constellations(additionalPaths: String?...) -> Set<String> {
		var paths : [String] = []
		for dir: String? in additionalPaths {
			if dir == nil {
				continue
			}

			paths.append(contentsOf: get_constellations(path: dir!))
		}
		
		paths.append(contentsOf: get_constellations_bundled())

		#if !os(Windows)
			paths.append(contentsOf: get_constellations_system_xdg())
			paths.append(contentsOf: get_constellations_user_xdg())
		#endif

		#if os(macOS)
			paths.append(contentsOf: get_constellations_macos())
		#endif

		#if os(Windows) || os(Cygwin)
			paths.append(contentsOf: get_constellations_windows())
		#endif

		return Set(paths)
	}
}