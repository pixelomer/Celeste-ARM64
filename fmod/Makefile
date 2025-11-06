all: sound nosound
clean:
	rm -rf nosound sound
nosound: nosound/libfmod.so.10 nosound/libfmodstudio.so.10
sound: sound/libfmodstudio.so

sound/libfmodstudio.so: ../otherlibs/fmodstudioapi/.timestamp
	mkdir -p sound
	./make-fmodstudio-shim.sh

nosound/libfmodstudio.so.10: fmodstudio_stub.c
	mkdir -p nosound
	$(CC) -fPIC -shared fmodstudio_stub.c -o nosound/libfmodstudio.so.10

nosound/libfmod.so.10: fmod_stub.c
	mkdir -p nosound
	$(CC) -fPIC -shared fmod_stub.c -o nosound/libfmod.so.10