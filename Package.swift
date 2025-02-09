// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "Starfall",
	products: [
		.executable(name: "starfall", targets: ["starfall"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
		.package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
	],
	targets: [
		.executableTarget(
			name: "starfall",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			resources: [.copy("Resources/.")]
		),
		.testTarget(
			name: "StarfallTests",
			dependencies: ["starfall"]),
	]
)
