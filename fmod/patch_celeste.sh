#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
	echo "Usage: patch_celeste.sh Celeste.exe"
	exit 1
fi

set -e

if [ ! -f "$1.bak" ]; then
	cp "$1" "$1.bak"
fi
xxd -p < "$1.bak" | tr -d '\n' | LC_ALL=C sed 's/03000616fe012a0013300200210000000a000011160a02145112012014100100/03000616fe012a0013300200210000000a000011160a02145112012006020200/g' | xxd -r -p > "$1.new"
mv "$1.new" "$1"