#!/usr/bin/env bash

set -e
cd "${0%/*}"

echo "[+] Removing existing release"
rm -rf Celeste-ARM64-prebuilt
rm -f Celeste-ARM64-prebuilt.zip
mkdir Celeste-ARM64-prebuilt

echo "[+] Building everything"
./build.sh

echo "[+] Copying binaries"
cd Celeste-ARM64-prebuilt
mkdir -p fmod
cp -vr ../fmod/sound ../fmod/nosound fmod/
mkdir -p otherlibs
cp -v ../otherlibs/libFNA3D.so.0 ../otherlibs/libSDL2-2.0.so.0 ../otherlibs/libfmod_SDL.so otherlibs/

echo "[+] Copying scripts"
cp -v ../Celeste ../make-release.sh ../patch.sh ../download-fmod.sh ./

echo "[+] Creating zip"
cd ..
zip -r Celeste-ARM64-prebuilt.zip Celeste-ARM64-prebuilt