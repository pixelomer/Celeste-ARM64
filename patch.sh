#!/usr/bin/env bash

# Only tested with unmodded 1.4.0.0-fna

if [ "$#" -lt 1 ]; then
	echo "Usage: patch_celeste.sh Celeste.exe"
	exit 1
fi

if [ "$(basename "$1")" != "Celeste.exe" ]; then
	echo "Specified file is not Celeste.exe."
	exit 1
fi

set -e
cd "${0%/*}"

backup() {
	if [ -e "$1" ] && [ ! -e "$1.bak" ]; then
		mv "$1" "$1.bak"
	fi
	rm -rf "$1"
}

cd otherlibs
if [ -f Makefile ]; then
	echo "[+] Building libraries"
	make
else
	echo "[i] Missing otherlibs/Makefile, skipping"
fi

cd ../fmod
if [ -f Makefile ]; then
	echo "[+] Building FMOD preload"
	make sound
else
	echo "[i] Missing fmod/Makefile, skipping"
fi

cd ..
echo "[+] Patching Celeste.exe"
./fmod/patch_celeste.sh "$1"

celeste_dir="$(dirname "$1")"

echo "[+] Creating launch script"
backup "${celeste_dir}/Celeste"
cp fmod/sound/fmod_preload.so "${celeste_dir}/fmod_preload.so"
cat Celeste > "${celeste_dir}/Celeste"
chmod +x "${celeste_dir}/Celeste"

echo "[+] Downloading libfmod"
./download-fmod.sh

echo "[+] Copying libraries to Celeste directory"
backup "${celeste_dir}/lib-arm64"
mkdir -p "${celeste_dir}/lib-arm64"
cp -H otherlibs/fmodstudioapi20206linux/api/studio/lib/arm64/libfmodstudio.so.13.6 "${celeste_dir}/lib-arm64/libfmodstudio.so.13.6"
cp -H otherlibs/fmodstudioapi20206linux/api/core/lib/arm64/libfmod.so.13.6 "${celeste_dir}/lib-arm64/libfmod.so.13.6"
cp -H otherlibs/*.so* "${celeste_dir}/lib-arm64/"
cd "${celeste_dir}/lib-arm64/"

echo "[+] Successfully patched Celeste"