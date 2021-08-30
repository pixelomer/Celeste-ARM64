# FMOD patches

Celeste uses FMOD for playing audio. This folder contains patches that make FMOD 2.02 work with Celeste. These patches are necessary because FMOD 2.02 is the oldest version of FMOD that supports ARM64 but Celeste expects FMOD 1.10.

## Compatibility Patches (Enables Sound)

1. Build `fmod_preload.so`.
```bash
make sound
```

2. Patch `Celeste.exe` to change the expected header version. This fixes the ERR_HEADER_MISMATCH error. `Celeste.exe` will be backed up as `Celeste.exe.bak` if it wasn't backed up before and then patched.
```
./patch_celeste.sh /path/to/Celeste.exe
```

3. Start Celeste with this library preloaded.
```bash
LD_PRELOAD=/path/to/fmod_preload.so mono /path/to/Celeste.exe
```

## Stub Libraries (No Sound)

1. Build `libfmod.so.10` and `libfmodstudio.so.10` stubs.
```bash
make nosound
```

2. Replace the default Celeste FMOD libraries with these libraries.
```bash
cp nosound/libfmod.so.10 /path/to/Celeste/lib64/
cp nosound/libfmodstudio.so.10 /path/to/Celeste/lib64/
```

3. Start Celeste.
```bash
mono /path/to/Celeste.exe
```