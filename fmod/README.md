# FMOD patches

Celeste uses FMOD for audio. This folder contains patches that make FMOD 2.02 work with Celeste. These patches are necessary because FMOD 2.02 is the oldest version of FMOD that supports ARM64 but Celeste expects FMOD 1.10.

## Stub Libraries (No Sound)

1. Build `libfmod.so.10` and `libfmodstudio.so.10` stubs.
```bash
make nosound
```

2. Replace the default Celeste FMOD libraries with these libraries.

3. Start Celeste.
```bash
mono /path/to/Celeste.exe
```

## Compatibility Patches (Enables Sound)

> **Notice:** These instructions are now deprecated. Follow the instructions in the parent directory to patch Celeste.

1. Build `fmod_preload.so`.
```bash
make sound
```

2. Patch `Celeste.exe` to change the expected header version. This fixes the ERR_HEADER_MISMATCH error. `Celeste.exe` will be backed up as `Celeste.exe.bak` if it wasn't backed up before and then patched.
```
./patch_celeste.sh /path/to/Celeste.exe
```

3. Make sure libfmodstudio.13.6 and libfmod.13.6 are in your LD_LIBRARY_PATH.

4. Start Celeste with this library preloaded.
```bash
LD_PRELOAD=/path/to/fmod_preload.so mono /path/to/Celeste.exe
```