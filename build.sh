#!/usr/bin/env bash

set -e

if [ "$(uname -m)" != "aarch64" -a "$(uname -m)" != "arm64" ]; then
	echo "Host is not arm64. Aborting."
	exit 1
fi

if [ "$(uname)" != "Linux" -o "${CELESTE_ARM64_USE_DOCKER}" == 1 ]; then
	echo "Host is not Linux, will attempt to compile with Docker."
	type docker 2>/dev/null >&2 || {
		echo "Docker is missing, cannot cross compile."
		exit 1
	}
	sudo docker build -t celeste-arm64/build docker
	sudo docker run --rm -t --user "$(id -u):$(id -g)" -v "$(pwd)":"/work" celeste-arm64/build bash -c "cd /work; CELESTE_ARM64_SKIP_DEPS=1 ./build.sh"
	exit 0
fi

type sudo 2>/dev/null >&2 || { sudo() { "${@}"; }; }

if [ "${CELESTE_ARM64_SKIP_DEPS}" == 1 ]; then
	echo "Skipped dependency checks."
	installed=1
else
	echo "Ensuring dependencies..."
	installed=0
	type apt-get 2>/dev/null >&2 && {
		sudo apt-get update
		sudo apt-get install -y cmake make libsdl2-dev sudo gcc git curl jq sed
		installed=1
	}
	[ $installed -eq 0 ] && type dnf 2>/dev/null >&2 && {
		sudo dnf install -y libXext-devel cmake make SDL2-devel sudo gcc git curl jq sed
		installed=1
	}
fi
[ $installed -eq 0 ] && {
	echo "Could not find a supported package manager"
	exit 1
}

./download-fmod.sh

cd fmod
make

cd ../otherlibs
make