#!/usr/bin/env bash
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

# RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

function prompt {
	local MSG=$1
	local QUERY=$2
	echo -e "${YELLOW}WARN:${NC} $MSG"
	echo -n "Currently: "
	ls "$DEST"
	while true; do
		read -r -p "$QUERY (Y/n) " yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		*) echo "Please answer yes or no." ;;
		esac
	done
}

install_bin() {
	echo Linking scripts.
	mkdir -p "$HOME/bin"
	shopt -s nullglob
	local filename
	for script in "$SCRIPT_DIR/../bin"/*; do
		filename=$(basename "$script")
		if ! [ -L "$HOME/bin/$filename" ]; then
			ln -s "$(realpath "$script")" "$HOME/bin/$filename"
		fi
	done
}

# Install a `~/.config/{COMPONENT}`.
#
# Links the `COMPONENT` to this repos directory.
install_config_component() {
	# Check function arguments.
	if [[ "$#" != "1" ]]; then
		echo "Error: Expected 1 argument, got $#."
	fi

	local COMPONENT="$1"
	local FROM="$SCRIPT_DIR/../.config/"
	local TO="$HOME/.config/"

	link_directory "$COMPONENT" "$FROM" "$TO"
}


install_font() {
	# Check function arguments.
	if [[ "$#" != "1" ]]; then
		echo "Error: Expected 1 argument, got $#."
	fi

	local COMPONENT="$1"
	local FROM="$SCRIPT_DIR/../.local/share/fonts/"
	local TO="$HOME/.local/share/fonts/"

	mkdir -p "$TO"

	link_directory "$COMPONENT" "$FROM" "$TO"
}

# link a COMPONENT from FROM to TO
link_directory() {
	# Check function arguments.
	if [[ "$#" != "3" ]]; then
		echo "Error: Expected 3 argument, got $#."
	fi

	local COMPONENT="$1"
	local SRC="$FROM/$COMPONENT"
	local DEST="$TO/$COMPONENT"

	function make_link {
		local TARGET
		local LINKNAME
		TARGET="$(realpath "$SRC")"
		LINKNAME="$(realpath "$DEST")"
		ln -s "$TARGET" "$LINKNAME"
	}

	# Make a backup if a directory exists.
	#
	# Cases:
	# 1. There is no dir or link. Nothing to check.
	# 2. There is an existing dir. Prompt and back it up.
	# 3. There is an existing link and it is different. Prompt to change.
	# 4. There is an existing link and it is already installed.
	#
	# Only need to worry about case 2 & 3

	# Case 1.
	# Also make sure it isn't a broken link
	if [ ! -f "$DEST" ] && [ ! -d "$DEST" ] && [ ! -e "$DEST" ] && [ ! -h "$DEST" ]; then
		echo "Linking $COMPONENT"
		make_link
		return
	fi

	# Case 2.
	if [ -d "$DEST" ] && ! [ -L "$DEST" ]; then
		if prompt "Found existing directry at $DEST" "Make backup and install component link?"; then
			mv "$DEST" "${DEST}_backup"
			make_link
		else
			echo Skipping installing "$COMPONENT"
		fi
		return
	fi

	# Case 3.
	if [ -L "$DEST" ] && [[ "$(readlink -f "$DEST")" != "$(realpath "$SRC")" ]]; then
		if prompt "Found existing link at $DEST -> $(readlink "$DEST")" "Relink to $SRC?"; then
			unlink "$DEST"
			make_link
		else
			echo Skipping installing "$COMPONENT"
		fi
		return
	fi

	# Case 4.
	if [ -L "$DEST" ] && test "$(readlink -f "$DEST")" == "$(realpath "$SRC")"; then
		echo "$COMPONENT already installed."
		return
	fi

	# Unhandled case.
	# Debug information to understand the missing case.
	echo -n "Is file ($DEST): "
	if [ -f "$DEST" ]; then echo YES; else echo NO; fi
	echo -n "Is directory ($DEST): "
	if [ -d "$DEST" ]; then echo YES; else echo NO; fi
	echo -n "Is link ($DEST): "
	if [ -L "$DEST" ]; then echo YES; else echo NO; fi
	echo "readlink: $(readlink -f "$DEST")"
}

