//fnc_isExternalAudio.sqf
#include "script_component.hpp"

params ["_radioId", "_event", "_eventData", "_radioData"];

(HASH_GET(_radioData, "audioPath") == "INTAUDIO")
