#!/bin/bash
###################################################
#  Miking is licensed under the MIT license.
#  Copyright (C) David Broman. See file LICENSE.txt
#
#  To make the build system platform independent,
#  building is done using Dune and called from
#  this bash script (on UNIX platforms) or
#  using make.bat (on Windows).
###################################################

# Forces the script to exit on error
set -e

# Setup environment variable to find ipm folder
export MCORE_STDLIB=`pwd`;

# Compile the project
build(){
    mkdir -p build
    dune build src/ocaml-server/main.exe
    cp -f _build/default/src/ocaml-server/main.exe build/ipm-server
}

# Install the server
install() {
    bin_path=$HOME/.local/bin
    mkdir -p $bin_path
    cp -f build/ipm-server $bin_path/ipm-server; chmod +x $bin_path/ipm-server
}


case $1 in
    install)
	build
	install
	;;
esac
