#include "script_component.hpp"
/*
 * Author: UKSF
 * Checks if an MPU-5 receives a talk group. The radio receives its active talk group, the emergency talk group, its monitored talk groups, and the talk groups in its TX slots.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Talk group <NUMBER>
 *
 * Return Value:
 * Radio receives the talk group <BOOL>
 *
 * Example:
 * ["acre_mpu5_id_1", 3] call acre_sys_mpu5_fnc_receivesTalkgroup
 *
 * Public: No
 */

params ["_radioId", "_talkgroup"];

_talkgroup == MPU5_EMERGENCY_TALKGROUP
|| {_talkgroup == ([_radioId, "getCurrentChannel"] call EFUNC(sys_data,dataEvent)) + 1}
|| {_talkgroup in ([_radioId] call FUNC(getMonitors))}
|| {_talkgroup in ([_radioId] call FUNC(getTxSlots))}
