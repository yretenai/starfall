# starfall<br/>gaze upon the falling stars


starfetch/stargaze rewitten in swift

## constellation file (starfile) format

following stargaze format, constellation files are made out of attribute names and data.

the following names are supported:

- `name` (required): the name of the constellation
- `quadrant`, `ascension`, `declination` and `area`: trivial text attributes
- `seq` (legacy: `n_stars`): number of main/sub stars in the constellation (`seq main,sub`)
- `star` and `bright_star`: a star position, minor stars will be a hollow icon (`star x y`, `bright_star x y`)

any other keyword is ignored, any data after `#` is ignored

## storage

constellation files are bundled with starfall, however starfall looks in the following paths for *.constellation files.

- (UNIX) `${XDG_DATA_DIRS}/starfall` or `/usr/share/starfall`
- (UNIX) `${XDG_DATA_HOME}/starfall` or `${HOME}/.local/share/starfall` or `/home/${USER}/.local/share/starfall` (if Linux/BSD) or `/Users/${USER}/.local/share/starfall `(if macOS)
- (macOS) `/Users/${USER}/Library/Application Support/aq.chronovore.starfall`
- (macOS) `/Library/Application Support/aq.chronovore.starfall`
- (Windows) `${APPDATA}/aq.chronovore.starfall`
- (Windows) `${LOCALAPPDATA}/aq.chronovore.starfall`
- (Windows) `${PROGRAMDATA}/aq.chronovore.starfall`
