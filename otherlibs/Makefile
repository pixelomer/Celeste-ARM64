all: libfmod_SDL.so libFNA3D.so.0 libSDL2-2.0.so.0
clean: rm -rf FMOD_SDL FNA3D SDL libFNA3D.so.0 libSDL2-2.0.so.0 libfmod_SDL.so

FMOD_SDL:
	[ -d FMOD_SDL ] || git clone https://github.com/flibitijibibo/FMOD_SDL FMOD_SDL
	cd FMOD_SDL && git checkout tags/21.03.05

libfmod_SDL.so: FMOD_SDL
	@[ -d fmodstudioapi20202linux ] || { echo -e "\nERROR: fmodstudioapi20202linux is missing. See README.md for details.\n"; exit 1; }
	cp fmodstudioapi20202linux/api/core/inc/* FMOD_SDL/
	cp fmodstudioapi20202linux/api/core/lib/arm64/* FMOD_SDL/
	cp fmodstudioapi20202linux/api/studio/inc/* FMOD_SDL/
	cp fmodstudioapi20202linux/api/studio/lib/arm64/* FMOD_SDL/
	cd FMOD_SDL && sed 's/FMOD_VERSION = 11/FMOD_VERSION = 13/g' < Makefile > Makefile.new
	cd FMOD_SDL && mv Makefile.new Makefile
	cd FMOD_SDL && make -j4
	cp FMOD_SDL/libfmod_SDL.so ./

FNA3D:
	[ -d FNA3D ] || git clone https://github.com/FNA-XNA/FNA3D FNA3D
	cd FNA3D && git checkout tags/21.08
	cd FNA3D && git submodule update --init --recursive

libFNA3D.so.0: FNA3D
	cd FNA3D && mkdir build && cd build && cmake .. && make -j4
	cp -H FNA3D/build/libFNA3D.so ./libFNA3D.so.0

SDL:
	[ -d SDL ] || git clone https://github.com/libsdl-org/SDL SDL
	cd SDL && git checkout tags/release-2.0.16
	cd SDL && git submodule update --init --recursive

libSDL2-2.0.so.0: SDL
	cd SDL && ./configure && make -j4
	cp -H SDL/build/.libs/libSDL2.so ./libSDL2-2.0.so.0