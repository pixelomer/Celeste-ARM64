#!/usr/bin/env bash

# Only tested with unmodded 1.4.0.0-fna

if [ "$#" -lt 1 ]; then
	echo "Usage: patch_celeste.sh Celeste.exe"
	exit 1
fi

set -e

backup() {
	if [ -e "$1" ] && [ ! -e "$1.bak" ]; then
		mv "$1" "$1.bak"
	fi
	rm -rf "$1"
}

cd otherlibs
echo "[+] Building libraries"
make

cd ../fmod
echo "[+] Building FMOD preload"
make sound

cd ..
echo "[+] Patching Celeste.exe"
./fmod/patch_celeste.sh "$1"

celeste_dir="$(dirname "$1")"

echo "[+] Creating launch script"
backup "${celeste_dir}/Celeste"
cp fmod/sound/fmod_preload.so "${celeste_dir}/fmod_preload.so"
cat > "${celeste_dir}/Celeste" <<'EOF'
#!/usr/bin/env bash
cd "${0%/*}"
LD_PRELOAD="$(pwd)/fmod_preload.so" LD_LIBRARY_PATH="$(pwd)/lib64" mono Celeste.exe
EOF
chmod +x "${celeste_dir}/Celeste"

echo "[+] Copying libraries to Celeste directory"
backup "${celeste_dir}/lib64"
mkdir -p "${celeste_dir}/lib64"
cp -H otherlibs/*.so* otherlibs/FMOD_SDL/libfmod.so.13 otherlibs/FMOD_SDL/libfmodstudio.so.13 "${celeste_dir}/lib64/"
cd "${celeste_dir}/lib64/"
ln -s libfmod.so.13 libfmod.so.10
ln -s libfmodstudio.so.13 libfmodstudio.so.10