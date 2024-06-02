all: libSDL2-2.0.so.0 libfmod_SDL.so libFNA3D.so.0
clean:
	@echo "==> Cleaning..."
	rm -rf FMOD_SDL FNA3D SDL libFNA3D.so.0 libSDL2-2.0.so.0 libfmod_SDL.so

FMOD_SDL:
	@echo "==> Downloading FMOD_SDL..."
	[ -d FMOD_SDL ] || git clone https://github.com/flibitijibibo/FMOD_SDL FMOD_SDL
	cd FMOD_SDL && git checkout tags/22.06.16

fmodstudioapi/.timestamp:
	@echo "==> Downloading FMOD Engine..."
	@cd ..; ./download-fmod.sh

libfmod_SDL.so: fmodstudioapi/.timestamp FMOD_SDL libSDL2-2.0.so.0
	@echo "==> Building libfmod_SDL..."
	cp fmodstudioapi/api/core/inc/* FMOD_SDL/
	cp fmodstudioapi/api/core/lib/arm64/* FMOD_SDL/
	cp fmodstudioapi/api/studio/inc/* FMOD_SDL/
	cp fmodstudioapi/api/studio/lib/arm64/* FMOD_SDL/
	sed 's/sdl2-config --cflags/\$$\$$\(pwd\)\/\.\.\/SDL\/sdl2-config --prefix="\$$\$$\(pwd\)\/\.\.\/SDL\/out" --cflags/g' < FMOD_SDL/Makefile > FMOD_SDL/Makefile.1
	mv FMOD_SDL/Makefile.1 FMOD_SDL/Makefile
	cd FMOD_SDL && make -j4
	cp FMOD_SDL/libfmod_SDL.so ./

FNA3D:
	@echo "==> Downloading FNA3D..."
	[ -d FNA3D ] || git clone https://github.com/FNA-XNA/FNA3D FNA3D
	cd FNA3D && git checkout tags/24.06
	cd FNA3D && git submodule update --init --recursive

libFNA3D.so.0: FNA3D libSDL2-2.0.so.0
	@echo "==> Building libFNA3D..."
	rm -rf FNA3D/build
	cd FNA3D && mkdir build && cd build && cmake -DSDL2_LIBRARIES="$$(pwd)/../../SDL/out/lib/libSDL2-2.0.so.0" -DSDL2_INCLUDE_DIRS="$$(pwd)/../../SDL/out/include/SDL2" .. && make -j4
	cp -H FNA3D/build/libFNA3D.so ./libFNA3D.so.0

SDL:
	@echo "==> Downloading SDL2..."
	[ -d SDL ] || git clone https://github.com/libsdl-org/SDL SDL
	cd SDL && git checkout tags/release-2.30.3
	cd SDL && git submodule update --init --recursive

libSDL2-2.0.so.0: SDL
	@echo "==> Building libSDL2..."
	mkdir -p SDL/out
	cd SDL && ./configure --host=aarch64-linux-gnu --prefix="$$(pwd)/out" && make -j4 && make install
	cp -H SDL/build/.libs/libSDL2.so ./libSDL2-2.0.so.0