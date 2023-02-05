# Celeste ARM64 Utilities

This repository contains utilities for getting Celeste to work on ARM64 Linux. These utilities were tested on a Nintendo Switch running Ubuntu Bionic 18.04.

![Photo of Glyph running on the Nintendo Switch](photo.png)

## Installation

> Read all of the instructions at least once before starting.

1. Download Celeste from either [itch.io](https://mattmakesgames.itch.io/celeste) or [Epic Games Store](https://www.epicgames.com/store/en-US/p/celeste). Both Linux and Windows builds will work. The builds on Steam will **not** work because the Steam version of the game contains DRM.
2. Extract Celeste.
3. Download the latest release of Celeste-ARM64 and extract it somewhere other than the Celeste folder.
4. Run the following commands in the terminal.
```bash
cd /path/to/Celeste-ARM64
./patch.sh /path/to/celeste-linux/Celeste.exe
```
5. \(optional\) Install Everest on this copy of Celeste with Olympus. Do this on your computer before copying the game to your Switch since the arm64 build of Olympus is not able to to install Everest.
6. Copy the Celeste folder to your Switch.
7. Run the following commands in a terminal on your Switch. You may be required to enter your password. After running this command, the installation will be complete and Celeste will start.
```bash
cd /path/to/celeste-linux
./Celeste
```
8. You should now be able to launch Olympus and Celeste using the app launcher.

## Files

### patch.sh

Use this script to make Celeste work on ARM64.

### fmod/

Contains instructions on how to get the FMOD library working. The FMOD library is used in Celeste for sound.

### otherlibs/

Contains a Makefile for building FNA3D, SDL and fmod_SDL.