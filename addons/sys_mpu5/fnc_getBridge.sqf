#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the ordinary radio whose channel is copied into the bridge channel of an MPU-5.
 *
 * Arguments:
 * 0: MPU-5 radio ID <STRING>
 *
 * Return Value:
 * Ordinary radio ID, or an empty string when there is no bridge channel <STRING>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_getBridge
 *
 * Public: Yes
 */

params ["_radioId"];

private _bridge = [_radioId, "getState", MPU5_BRIDGE_STATE] call EFUNC(sys_data,dataEvent);
if (isNil "_bridge") exitWith {""};
_bridge param [0, ""]
