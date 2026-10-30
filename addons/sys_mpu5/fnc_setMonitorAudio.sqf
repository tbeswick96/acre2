#include "script_component.hpp"
/*
 * Author: UKSF
 * Sets the volume and ear an MPU-5 uses for one talk group that is not its active talk group. Volume 1 with ear -2 removes the setting.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Talk group <NUMBER>
 * 2: Volume, 0 to 1 <NUMBER>
 * 3: Ear, -1 left, 0 both, 1 right, -2 the radio's own ear setting <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["acre_mpu5_id_1", 3, 0.5, -1] call acre_sys_mpu5_fnc_setMonitorAudio
 *
 * Public: Yes
 */

params ["_radioId", "_talkgroup", "_volume", "_ear"];

private _audio = [_radioId, "getState", MPU5_MONITOR_AUDIO_STATE] call EFUNC(sys_data,dataEvent);
_audio = if (isNil "_audio") then {[]} else {_audio select {(_x select 0) != _talkgroup}};

if (_volume != 1 || {_ear != MPU5_EAR_DEFAULT}) then {
    _audio pushBack [_talkgroup, (_volume max 0) min 1, [MPU5_EAR_DEFAULT, _ear] select (_ear in [-1, 0, 1])];
    _audio sort true;
};

[_radioId, "setState", [MPU5_MONITOR_AUDIO_STATE, _audio]] call EFUNC(sys_data,dataEvent);
