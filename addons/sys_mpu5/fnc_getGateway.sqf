#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the radio over IP link of an MPU-5.
 *
 * Arguments:
 * 0: MPU-5 radio ID <STRING>
 *
 * Return Value:
 * Ordinary radio ID and talk group, or an empty array when there is no link <ARRAY>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_getGateway
 *
 * Public: Yes
 */

params ["_radioId"];

private _gateway = [_radioId, "getState", MPU5_GATEWAY_STATE] call EFUNC(sys_data,dataEvent);
if (isNil "_gateway") exitWith {[]};
_gateway
