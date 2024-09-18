// swift-tools-version: 5.10

import PackageDescription

let package = Package(
	name: "Starfall",
	products: [],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
		.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
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
