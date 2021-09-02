# Celeste ARM64 Utilities

This repository contains utilities for getting Celeste to work on ARM64 Linux. These utilities were tested on a Nintendo Switch running Ubuntu Bionic 18.04.

## Easy installation

This example assumes that
- FMOD libraries are downloaded to `~/fmodstudioapi20202linux`.
- Mono is installed (see https://www.mono-project.com/download/stable/#download-lin)

### Instructions

1. Install required packages.
```sh
sudo apt update
sudo apt install libsdl2-dev mono-complete
```

2. Download the Celeste patcher with prebuilt binaries.
```sh
cd ~
wget https://github.com/pixelomer/Celeste-ARM64/releases/download/2021.09.02/Celeste-ARM64-prebuilt.zip
unzip Celeste-ARM64-prebuilt.zip
```

3. Patch Celeste and add arm64 libraries.
```sh
cd Celeste-ARM64-prebuilt
./patch.sh /path/to/Celeste/Celeste.exe
```

4. Copy FMOD libraries.
```sh
cp ~/fmodstudioapi20202linux/api/studio/lib/arm64/libfmodstudio.so.13.2 /path/to/Celeste/lib64/libfmodstudio.so.13
cp ~/fmodstudioapi20202linux/api/core/lib/arm64/libfmod.so.13.2 /path/to/Celeste/lib64/libfmod.so.13
```

5. Install [Olympus](https://github.com/EverestAPI/Olympus). You can skip this step if you aren't going to use Olympus.
```sh
cd ~
sudo apt install libcurl3 liblua5.3
ln -s /usr/lib/aarch64-linux-gnu/liblua5.3.so /path/to/Celeste/lib64/liblua53.so
wget https://github.com/pixelomer/Celeste-ARM64/releases/download/2021.09.02/Olympus.zip
unzip Olympus.zip
cd Olympus
mkdir -p ~/.config/Olympus
cat > ~/.config/Olympus/config.json <<'EOF'
{
	"installs":[{
		"type":"manual",
		"name":"Celeste",
		"path":"/path/to/Celeste"
	}]
}
EOF
./install.sh
```

6. You can now start Celeste by running the `Celeste` script in the Celeste folder.
```sh
cd /path/to/Celeste
./Celeste
```

## Files

### patch.sh

Use this script to make Celeste work on ARM64.

### fmod/

Contains instructions on how to get the FMOD library working. The FMOD library is used in Celeste for playing audio.

### otherlibs/

Contains a Makefile for building FNA3D, SDL and fmod_SDL.