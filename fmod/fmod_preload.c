#define _GNU_SOURCE
#include <stdbool.h>
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

static void *fmodstudio;
static void *fmod;

static int FMOD_Studio_EventInstance_SetParameterValue(void *system, const char *name, float value) {
	static int (*SetParameterByName)(void *, const char *, float, int ignoreseekspeed /* ?? */);
	if (SetParameterByName == NULL) {
		SetParameterByName = dlsym(fmodstudio, "FMOD_Studio_System_SetParameterByName");
	}
	return SetParameterByName(system, name, value, 0);
}

extern void *_dl_sym(void *, const char *, void *);
void *dlsym(void *handle, const char *name) {
	static void *(*dlsym_real)(void *, const char *);
	if (dlsym_real == NULL) {
		dlsym_real = _dl_sym(RTLD_NEXT, "dlsym", dlsym);
	}
	//printf("dlsym(%p, \"%s\")\n", handle, name);
	fflush(stdout);
	if (name != NULL) {
		if (strcmp(name, "FMOD_Studio_System_GetLowLevelSystem") == 0) {
			return dlsym_real(handle, "FMOD_Studio_System_GetCoreSystem");
		}
		else if (strcmp(name, "FMOD_Studio_EventInstance_SetParameterValue") == 0) {
			return FMOD_Studio_EventInstance_SetParameterValue;
		}
		else if (strcmp(name, "dlsym") == 0) {
			return dlsym;
		}
	}
	return dlsym_real(handle, name);
}

void *dlopen(const char *filename, int flags) {
	static void *(*dlopen_real)(const char *, int);
	if (dlopen_real == NULL) {
		dlopen_real = dlsym(RTLD_NEXT, "dlopen");
	}
	//printf("dlopen(\"%s\", %d)", filename, flags);
	void *result = dlopen_real(filename, flags);
	if (((fmodstudio == NULL) || (fmod == NULL)) && (result != NULL) && (filename != NULL)) {
		char filename_copy[strlen(filename)+1];
		strcpy(filename_copy, filename);
		char *name = basename(filename_copy);
		if (strcmp(name, "libfmodstudio.so.10") == 0) {
			fmodstudio = result;
		}
		else if (strcmp(name, "libfmod.so.10") == 0) {
			fmod = result;
		}
	}
	return result;
}