#!/usr/bin/env bash

set -e
cd "${0%/*}"

echo "[+] Removing existing release"
rm -rf Celeste-FMOD2-prebuilt
rm -f Celeste-FMOD2-prebuilt.zip
mkdir Celeste-FMOD2-prebuilt

echo "[+] Building everything"
./build.sh

echo "[+] Copying binaries"
cd Celeste-FMOD2-prebuilt
mkdir -p fmod
cp -vr ../fmod/sound ../fmod/nosound fmod/
mkdir -p otherlibs
cp -v ../otherlibs/libFNA3D.so ../otherlibs/libSDL2.so ../otherlibs/libfmod_SDL.so otherlibs/

echo "[+] Copying scripts"
cp -v ../Celeste ../make-release.sh ../patch.sh ../download-fmod.sh ./

echo "[+] Creating zip"
cd ..
zip -r Celeste-FMOD2-prebuilt.zip Celeste-FMOD2-prebuilt
