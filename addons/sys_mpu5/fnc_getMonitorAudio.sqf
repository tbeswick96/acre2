#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the volume and ear an MPU-5 uses for one talk group that is not its active talk group.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Talk group <NUMBER>
 *
 * Return Value:
 * 0: Volume, 0 to 1 <NUMBER>
 * 1: Ear, -1 left, 0 both, 1 right, -2 the radio's own ear setting <NUMBER>
 *
 * Example:
 * ["acre_mpu5_id_1", 3] call acre_sys_mpu5_fnc_getMonitorAudio
 *
 * Public: Yes
 */

params ["_radioId", "_talkgroup"];

private _audio = [_radioId, "getState", MPU5_MONITOR_AUDIO_STATE] call EFUNC(sys_data,dataEvent);
if (isNil "_audio") exitWith {[1, MPU5_EAR_DEFAULT]};

private _index = _audio findIf {(_x select 0) == _talkgroup};
if (_index < 0) exitWith {[1, MPU5_EAR_DEFAULT]};
(_audio select _index) params ["", "_volume", "_ear"];
[_volume, _ear]
