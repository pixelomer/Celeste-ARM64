all: fmod_preload.so libfmodstudio.so.10 libfmod.so.10
nosound: nosound/libfmod.so.10 nosound/libfmodstudio.so.10
sound: fmod_preload.so

sound/fmod_preload.so: fmod_preload.c
	@mkdir -p sound
	cc -fPIC -ldl -shared fmod_preload.c -o sound/fmod_preload.so

nosound/libfmodstudio.so.10: fmodstudio_stub.c
	@mkdir -p nosound
	cc -fPIC -shared fmodstudio_stub.c -o nosound/libfmodstudio.so.10

nosound/libfmod.so.10: fmod_stub.c
	@mkdir -p nosound
	cc -fPIC -shared fmod_stub.c -o nosound/libfmod.so.10