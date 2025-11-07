# Celeste FMOD2 Utilities

This repository contains utilities for getting Celeste to work with FMOD 2 on ARM64 and x86_64 Linux. These utilities were tested on a Nintendo Switch running Ubuntu Noble 24.04.

![Photo of Glyph running on the Nintendo Switch](photo.png)

## Installation

> Read all of the instructions at least once before starting.

These steps are meant to be followed directly on the Switch. You don't need a separate Linux system. (For your convenience, you may also choose to perform these operations over SSH. If you do, make sure to set `DISPLAY=:0` and `WAYLAND_DISPLAY=wayland-0` before attempting to start Celeste.)

1. Download Celeste from either [itch.io](https://mattmakesgames.itch.io/celeste) or [Epic Games Store](https://www.epicgames.com/store/en-US/p/celeste). Download the Linux build if possible (but Windows FNA builds may also work). Builds on Steam will **not** work because the Steam version of the game contains DRM.
2. Download the latest release of Celeste-FMOD2 and extract it somewhere other than the Celeste folder.
3. Run the following commands in the terminal.
```bash
cd /path/to/Celeste-FMOD2
./patch.sh /path/to/celeste-linux/Celeste.exe
```
4. If the patcher was successful, run the following commands. You may be required to enter your password. After running these command, the installation will be complete and Celeste will start.
```bash
cd /path/to/celeste-linux
./Celeste-fmod2
```
5. You should now be able to launch Celeste using the app launcher.

Note that if you decide to move the Celeste folder somewhere else in the future, you'll have to run `/path/to/celeste-linux/Celeste-fmod2` again to fix the app launcher shortcuts.

## Installing Mods

Celeste-FMOD2 will also install Everest automatically. However, Olympus isn't available on the Switch, so you'll have to manually download mods and copy them into the Celeste folder.

## Files

### patch.sh

Use this script to apply the necessary changes for FMOD 2 compatibility.

### fmod/

Contains instructions (for developers) on how to get the FMOD library working. The FMOD library is used in Celeste for sound.

### otherlibs/

Contains a Makefile for building FNA3D, SDL and fmod_SDL.