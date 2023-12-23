#define _GNU_SOURCE
#include <stdbool.h>
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

static void *fmodstudio = NULL;
static void *fmod = NULL;

static int FMOD_Studio_EventInstance_SetParameterValue(void *system, const char *name, float value) {
	static int (*SetParameterByName)(void *, const char *, float, int ignoreseekspeed /* ?? */);
	if (SetParameterByName == NULL) {
		SetParameterByName = dlsym(fmodstudio, "FMOD_Studio_EventInstance_SetParameterByName");
	}
	return SetParameterByName(system, name, value, 0);
}

void *dlsym(void *handle, const char *name) {
	static void *(*dlsym_real)(void *, const char *);
	if (dlsym_real == NULL) {
		dlsym_real = dlvsym(handle, "dlsym", "GLIBC_2.17" /* aarch64 only! */);
		dlsym_real = dlsym_real(RTLD_NEXT, "dlsym"); // play nice with other hooks
	}
	if (name != NULL) {
		if (strcmp(name, "FMOD_Studio_System_GetLowLevelSystem") == 0) {
			return dlsym_real(handle, "FMOD_Studio_System_GetCoreSystem");
		}
		else if (strcmp(name, "FMOD_Studio_EventInstance_TriggerCue") == 0) {
			return dlsym_real(handle, "FMOD_Studio_EventInstance_KeyOff");
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
	if (filename != NULL) {
		void **target_pt = NULL;
		char filename_copy[strlen(filename)+1];
		strcpy(filename_copy, filename);
		char *name = basename(filename_copy);
		if (strncmp(name, "libfmodstudio.so.10", 19) == 0) {
			filename = "libfmodstudio.so.13";
			target_pt = &fmodstudio;
		}
		else if (strncmp(name, "libfmod.so.10", 13) == 0) {
			filename = "libfmod.so.13";
			target_pt = &fmod;
		}
		void *result = dlopen_real(filename, flags);
		if ((target_pt != NULL) && (*target_pt == NULL) && (result != NULL)) {
			*target_pt = result;
		}
		return result;
	}
	else {
		return dlopen_real(filename, flags);
	}
}
