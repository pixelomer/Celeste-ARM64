# Celeste ARM64 Utilities

This repository contains utilities for getting Celeste to work on ARM64 Linux. These utilities were tested on a Nintendo Switch running Ubuntu Bionic 18.04.

## Easy installation

```sh
# Example installation
# - Celeste at ~/Celeste
# - FMOD libraries at ~/fmodstudioapi20202linux
# - Mono is installed (see https://www.mono-project.com/download/stable/#download-lin)

# Install required packages
sudo apt update
sudo apt install libsdl2-dev mono-complete

# Download prebuilt Celeste patcher
wget https://github.com/pixelomer/Celeste-ARM64/releases/download/2021.08.31/Celeste-ARM64-prebuilt.zip
unzip Celeste-ARM64-prebuilt.zip

# Patch Celeste and add arm64 libraries
cd Celeste-ARM64-prebuilt
./patch.sh ~/Celeste/Celeste.exe

# Copy FMOD libraries
cp ~/fmodstudioapi20202linux/api/studio/lib/arm64/libfmodstudio.so.13.2 ~/Celeste/lib64/libfmodstudio.so.13
cp ~/fmodstudioapi20202linux/api/core/lib/arm64/libfmod.so.13.2 ~/Celeste/lib64/libfmod.so.13

# Start Celeste
cd ~/Celeste
./Celeste
```

## Files

### patch.sh

Use this script to make Celeste work on ARM64.

### fmod/

Contains instructions on how to get the FMOD library working. The FMOD library is used in Celeste for playing audio.

### otherlibs/

Contains a Makefile for building FNA3D, SDL and fmod_SDL.