enum ConstellationFileError : Error {
	case NoSuchConstellationFile
	case UnableToLoad
	case InvalidData(hint: String)
}
