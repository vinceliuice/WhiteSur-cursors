#! /usr/bin/env bash

# from where the command was run
ROOT=$(pwd)

# check command avalibility
has_command() {
	command -v "$1" >/dev/null 2>&1
}

if [ ! "$(which xcursorgen 2> /dev/null)" ]; then
	echo xorg-xcursorgen needs to be installed to generate the cursors.
	if has_command zypper; then
		sudo zypper install -y xcursorgen
	elif has_command apt-get; then
		sudo apt-get install -y xorg-xcursorgen || sudo apt-get install -y x11-apps
	elif has_command dnf; then
		sudo dnf install -y xcursorgen
	elif has_command yum; then
		sudo dnf install -y xcursorgen
	elif has_command pacman; then
		sudo pacman -S --noconfirm xorg-xcursorgen
	fi
fi

if [ ! "$(which rsvg-convert 2> /dev/null)" ]; then
	echo rsvg-convert needs to be installed to generate the cursors.
	if has_command zypper; then
		sudo zypper install -y rsvg-convert
	elif has_command apt-get; then
		sudo apt-get install -y librsvg2-bin
	elif has_command dnf; then
		sudo dnf install -y librsvg2 librsvg2-tools
	elif has_command yum; then
		sudo dnf install -y librsvg2 librsvg2-tools
	elif has_command pacman; then
		sudo pacman -S --noconfirm librsvg
	fi
fi

if [ ! "$(which python3 2> /dev/null)" ]; then
	echo python3 needs to be installed to generate svg cursors.
	if has_command zypper; then
		sudo zypper install -y python3
	elif has_command apt-get; then
		sudo apt-get install -y python3
	elif has_command dnf; then
		sudo dnf install -y python3
	elif has_command yum; then
		sudo dnf install -y python3
	elif has_command pacman; then
		sudo pacman -S --noconfirm python
	fi
fi

function create {
	cd "$SRC"
	mkdir -p x1 x1_25 x1_5 x2
	cd "$SRC"/$1
	find . -name "*.svg" -exec sh -c 'rsvg-convert -w 32 -h 32 "$0" -o "../x1/$(basename "$0" .svg).png"' {} \;
	find . -name "*.svg" -exec sh -c 'rsvg-convert -w 40 -h 40 "$0" -o "../x1_25/$(basename "$0" .svg).png"' {} \;
	find . -name "*.svg" -exec sh -c 'rsvg-convert -w 48 -h 48 "$0" -o "../x1_5/$(basename "$0" .svg).png"' {} \;
	find . -name "*.svg" -exec sh -c 'rsvg-convert -w 64 -h 64 "$0" -o "../x2/$(basename "$0" .svg).png"' {} \;

	cd $SRC

	# generate cursors
	BUILD="$SRC"/../dist
	OUTPUT="$BUILD"/cursors
	ALIASES="$SRC"/cursorList

	if [ ! -d "$BUILD" ]; then
		mkdir "$BUILD"
	fi
	if [ ! -d "$OUTPUT" ]; then
		mkdir "$OUTPUT"
	fi

	echo -ne "Generating cursor theme...\\r"
	for CUR in config/*.cursor; do
		BASENAME="$CUR"
		BASENAME="${BASENAME##*/}"
		BASENAME="${BASENAME%.*}"
		
		xcursorgen "$CUR" "$OUTPUT/$BASENAME"
	done
	echo -e "Generating cursor theme... DONE"

	cd "$OUTPUT"	

	#generate aliases
	echo -ne "Generating shortcuts...\\r"
	while read ALIAS; do
		FROM="${ALIAS#* }"
		TO="${ALIAS% *}"

		if [ -e $TO ]; then
			continue
		fi
		ln -sr "$FROM" "$TO"
	done < "$ALIASES"
	echo -e "Generating shortcuts... DONE"

	cd "$PWD"

	echo -ne "Generating Theme Index...\\r"
	INDEX="$OUTPUT/../index.theme"
	if [ ! -e "$OUTPUT/../$INDEX" ]; then
		touch "$INDEX"
		echo -e "[Icon Theme]\nName=$THEME\n" > "$INDEX"
	fi
	echo -e "Generating Theme Index... DONE"
}

# generate pixmaps from svg source
SRC=$ROOT/src
THEME="WhiteSur Cursors"

function svg-cursors {
	cd $ROOT
	rm -rf ./svg-cursor/
	rm -rf ./dist/cursors_scalable/
	git clone https://github.com/jinliu/svg-cursor.git

	echo -e "Generating SVG cursors...\\r"
	./svg-cursor/build-svg-theme/build-svg-theme.py --output-dir=$ROOT/dist/cursors_scalable --svg-dir=$SRC/svg --config-dir=$SRC/config --alias-file=$SRC/cursorList --nominal-size=24 >/dev/null 2>&1
	echo -e "Generating SVG cursors... DONE"
}

create svg
svg-cursors
