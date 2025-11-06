#!/usr/bin/env bash

set -e

[[ -d Implib.so ]] || git clone https://github.com/yugr/Implib.so
cd Implib.so
./implib-gen.py --library-load-name libfmodstudio_real.so ../../otherlibs/fmodstudioapi/api/studio/lib/arm64/libfmodstudio.so.13

uname_m="$(uname -m)"
if [[ "${uname_m}" == "x86_64" ]]; then
    sed -i \
        -e 's/\(FMOD_Studio_System_Create\):/\1:\n  movl $0x20222, %esi/g' \
        -e 's/\(FMOD_Studio_EventInstance_SetParameterByName\):/\1:\n  movl $0x0, %edx/g' \
        -e 's/\(FMOD_Studio_System_SetListenerAttributes_2\):/\1:\n  movl $0x0, %ecx/g' \
        libfmodstudio.so.13.tramp.S
cat >> libfmodstudio.so.13.tramp.S <<'EOF'

  .globl FMOD_Studio_EventDescription_GetParameter
  .p2align 4
  .type FMOD_Studio_EventDescription_GetParameter, %function
FMOD_Studio_EventDescription_GetParameter:
  jmp FMOD_Studio_EventDescription_GetParameterByName
EOF
elif [[ "${uname_m}" == "aarch64" || "${uname_m}" == "arm64" ]]; then
    sed -i \
        -e 's/\(FMOD_Studio_System_Create\):/\1:\n  movz x1, #0x0222\n  movk x1, #0x2, lsl #16/g' \
        -e 's/\(FMOD_Studio_EventInstance_SetParameterByName\):/\1:\n  movz x2, #0x0/g' \
        -e 's/\(FMOD_Studio_System_SetListenerAttributes_2\):/\1:\n  movz x3, #0x0/g' \
        libfmodstudio.so.13.tramp.S
cat >> libfmodstudio.so.13.tramp.S <<'EOF'

  .globl FMOD_Studio_EventDescription_GetParameter
  .p2align 4
  .type FMOD_Studio_EventDescription_GetParameter, %function
FMOD_Studio_EventDescription_GetParameter:
  b FMOD_Studio_EventDescription_GetParameterByName
EOF
else
    echo "ERROR: unsupported architecture: ${uname_m}" >&2
    exit 1
fi

sed -i \
    -e 's/FMOD_Studio_System_GetCoreSystem/FMOD_Studio_System_GetLowLevelSystem/g' \
    -e 's/FMOD_Studio_EventInstance_GetParameterByName/FMOD_Studio_EventInstance_GetParameterValue/g' \
    -e 's/FMOD_Studio_EventInstance_SetParameterByName/FMOD_Studio_EventInstance_SetParameterValue/g' \
    -e 's/FMOD_Studio_EventDescription_GetParameterDescriptionCount/FMOD_Studio_EventDescription_GetParameterCount/g' \
    -e 's/FMOD_Studio_EventDescription_GetParameterDescriptionByIndex/FMOD_Studio_EventDescription_GetParameterByIndex/g' \
    -e 's/FMOD_Studio_EventDescription_GetParameterDescriptionByName/FMOD_Studio_EventDescription_GetParameterByName/g' \
    -e 's/FMOD_Studio_EventDescription_HasSustainPoint/FMOD_Studio_EventDescription_HasCue/g' \
    -e 's/FMOD_Studio_EventInstance_KeyOff/FMOD_Studio_EventInstance_TriggerCue/g' \
    libfmodstudio.so.13.tramp.S

gcc -o ../sound/libfmodstudio.so -shared -fPIC -DIMPLIB_EXPORT_SHIMS \
    libfmodstudio.so.13.init.c libfmodstudio.so.13.tramp.S -ldl -pthread
