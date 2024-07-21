#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/util/functions.bash"

install_bin
install_config_component alacritty
install_config_component oh-my-posh.json
# install_config_component hypr
# install_font Mononoki
# install_font ShureTech
