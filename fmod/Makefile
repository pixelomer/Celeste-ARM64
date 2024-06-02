all: sound nosound
clean:
	rm -rf nosound sound
nosound: nosound/libfmod.so.10 nosound/libfmodstudio.so.10
sound: sound/fmod_fix.so

sound/fmod_fix.so: fmod_fix.c ../otherlibs/fmodstudioapi/.timestamp
	@mkdir -p sound
	$(CC) -fPIC -lfmod -lfmodstudio -I../otherlibs/fmodstudioapi/api/studio/inc -I../otherlibs/fmodstudioapi/api/core/inc -L../otherlibs/fmodstudioapi/api/studio/lib/arm64 -L../otherlibs/fmodstudioapi/api/core/lib/arm64 -shared fmod_fix.c -o sound/fmod_fix.so

nosound/libfmodstudio.so.10: fmodstudio_stub.c
	@mkdir -p nosound
	$(CC) -fPIC -shared fmodstudio_stub.c -o nosound/libfmodstudio.so.10

nosound/libfmod.so.10: fmod_stub.c
	@mkdir -p nosound
	$(CC) -fPIC -shared fmod_stub.c -o nosound/libfmod.so.10