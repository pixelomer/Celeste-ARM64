#!/usr/bin/env bash

# Only tested with unmodded 1.4.0.0-fna

if [ "$#" -le 1 ]; then
	echo "Usage: patch_celeste.sh Celeste.exe"
	exit 1
fi

set -e

cd otherlibs
echo "[+] Building libraries"
make

cd ../fmod
echo "[+] Building FMOD preload"
make sound

echo "[+] Patching Celeste.exe"
./patch_celeste.sh "$1"

celeste_dir="$(dirname "$1")"

echo "[+] Creating start.sh"
cp fmod/fmod_preload.so "${celeste_dir}/"
cat > "${celeste_dir}/start.sh" <<'EOF'
#!/usr/bin/env bash
cd "${0%/*}"
LD_PRELOAD="$(pwd)/fmod_preload.so" LD_LIBRARY_PATH="$(pwd)/lib64" mono Celeste.exe
EOF
chmod +x "${celeste_dir}/start.sh"

echo "[+] Copying libraries to Celeste directory"
mkdir -p "${celeste_dir}/lib64"
cp -H otherlibs/*.so* otherlibs/FMOD_SDL/libfmod.so.13 otherlibs/FMOD_SDL/libfmodstudio.so.13 "${celeste_dir}/lib64/"
cd "${celeste_dir}/lib64/"
ln -s libfmod.so.10 libfmod.so.13
ln -s libfmodstudio.so.10 libfmodstudio.so.13