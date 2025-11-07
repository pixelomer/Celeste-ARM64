#!/usr/bin/env bash

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
	echo "[+] Building FMOD fix"
	make sound
else
	echo "[i] Missing fmod/Makefile, skipping"
fi

cd ..

celeste_dir="$(dirname "$1")"

echo "[+] Creating launch script"
backup "${celeste_dir}/Celeste-fmod2"
cat Celeste > "${celeste_dir}/Celeste-fmod2"
chmod +x "${celeste_dir}/Celeste-fmod2"

echo "[+] Downloading FMOD"
./download-fmod.sh

echo "[+] Copying libraries to Celeste directory"
backup "${celeste_dir}/lib-fmod2"
mkdir -p "${celeste_dir}/lib-fmod2"
arch="$(uname -m)"
[ "$arch" == "aarch64" ] && arch="arm64"
cp -H otherlibs/fmodstudioapi/api/studio/lib/$arch/libfmodstudio.so.13 "${celeste_dir}/lib-fmod2/libfmodstudio_real.so"
cp -H otherlibs/fmodstudioapi/api/core/lib/$arch/libfmod.so.13 "${celeste_dir}/lib-fmod2/libfmod.so.13"
cp -H otherlibs/*.so* "${celeste_dir}/lib-fmod2/"
cp -H fmod/sound/libfmodstudio.so "${celeste_dir}/lib-fmod2/"
ln -s libfmod.so.13 "${celeste_dir}/lib-fmod2/libfmod.so"
ln -s libfmod.so.13 "${celeste_dir}/lib-fmod2/libfmod.so.10"
ln -s libfmodstudio_real.so "${celeste_dir}/lib-fmod2/libfmodstudio.so.13"
ln -s libfmodstudio.so "${celeste_dir}/lib-fmod2/libfmodstudio.so.10"

echo "[+] Successfully patched Celeste"
