#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the talk group an MPU-5 transmits on. A TX slot key sets a temporary talk group, otherwise the radio transmits on its active talk group.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 *
 * Return Value:
 * Talk group, 1 to 16 <NUMBER>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_txTalkgroup
 *
 * Public: No
 */

params ["_radioId"];

private _talkgroup = [_radioId, "getState", MPU5_TX_TALKGROUP_STATE] call EFUNC(sys_data,dataEvent);
if (!isNil "_talkgroup" && {_talkgroup > 0}) exitWith {_talkgroup};

([_radioId, "getCurrentChannel"] call EFUNC(sys_data,dataEvent)) + 1
