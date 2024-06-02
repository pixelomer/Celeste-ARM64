#include "../otherlibs/fmodstudioapi/api/core/inc/fmod_common.h"
#include "../otherlibs/fmodstudioapi/api/studio/inc/fmod_studio.h"

#define DECLSPEC __attribute__ ((visibility("default")))

DECLSPEC int _FMOD_Studio_EventInstance_SetParameterValue(FMOD_STUDIO_EVENTINSTANCE *system, const char *name, float value)
{
	return FMOD_Studio_EventInstance_SetParameterByName(system, name, value, 0);
}

DECLSPEC int _FMOD_Studio_System_Create(FMOD_STUDIO_SYSTEM **system, unsigned int headerversion)
{
	// Override the FMOD_VERSION header.
	return FMOD_Studio_System_Create(system, FMOD_VERSION);
}