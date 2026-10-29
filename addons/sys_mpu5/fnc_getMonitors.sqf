#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the listen-only talk groups of an MPU-5.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 *
 * Return Value:
 * Talk groups, 1 to 16 <ARRAY>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_getMonitors
 *
 * Public: Yes
 */

params ["_radioId"];

private _monitors = [_radioId, "getState", MPU5_MONITORS_STATE] call EFUNC(sys_data,dataEvent);
if (isNil "_monitors") exitWith {[]};

_monitors
