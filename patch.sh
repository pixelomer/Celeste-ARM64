#!/usr/bin/env bash

# Only tested with unmodded 1.4.0.0-fna

if [ "$#" -lt 1 ]; then
	echo "Usage: patch_celeste.sh Celeste.exe"
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
skipped_fmod=0
if [ -f Makefile ]; then
	echo "[+] Building FMOD preload"
	make sound
else
	skipped_fmod=1
	echo "[i] Missing fmod/Makefile, skipping"
fi

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
if [ "${skipped_fmod}" -ne 1 ]; then
	cp -H otherlibs/FMOD_SDL/libfmod.so.13 otherlibs/FMOD_SDL/libfmodstudio.so.13 "${celeste_dir}/lib64/"
else
	cat <<'EOF'

This release does not contain fmod libraries.

Download these libraries from https://fmod.com/download and copy
the arm64 libraries libfmod.so.13 and libfmodstudio.so.13 to the
lib64 folder in the Celeste folder.

EOF
fi
cp -H otherlibs/*.so* "${celeste_dir}/lib64/"
cd "${celeste_dir}/lib64/"
ln -s libfmod.so.13 libfmod.so.10
ln -s libfmodstudio.so.13 libfmodstudio.so.10

echo "[+] Successfully patched Celeste"