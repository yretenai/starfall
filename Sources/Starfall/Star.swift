struct Star {
	let x : Int
	let y : Int
	let bright : Bool

	init(x: Int, y : Int, minor: Bool) {
		self.x = x
		self.y = y
		self.bright = minor
	}
}
