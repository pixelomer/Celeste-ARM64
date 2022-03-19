#!/usr/bin/env bash

set -e

if [ "$(uname -m)" != "aarch64" -a "$(uname -m)" != "arm64" ]; then
	echo "Host is not arm64. Aborting."
	exit 1
fi

if [ "$(uname)" != "Linux" ]; then
	echo "Host is not Linux, will attempt to compile with Docker."
	type docker 2>/dev/null >&2 || {
		echo "Docker is missing, cannot cross compile."
		exit 1
	}
	docker build -t celeste-arm64/build docker
	docker run --rm -t -v "$(pwd)":"/work" celeste-arm64/build bash -c "cd /work; ./build.sh"
	exit 0
fi

type sudo 2>/dev/null >&2 || { sudo() { "${@}"; }; }

echo "Ensuring dependencies..."
sudo apt-get update
sudo apt install -y cmake make libsdl2-dev sudo gcc git curl jq sed

cd fmod
make

cd ../otherlibs
make