#include "script_component.hpp"
/*
 * Author: UKSF
 * Handles PTT down on an MPU-5. An ordinary PTT press clears a TX slot talk group that is still set, so the radio transmits on its active talk group. Then the standard single-channel PTT handling runs.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event (unused) <STRING>
 * 2: Event data (unused) <ARRAY>
 * 3: Radio data (unused) <HASH>
 * 4: Remote (unused) <BOOL>
 *
 * Return Value:
 * Transmission can start <BOOL>
 *
 * Example:
 * ["acre_mpu5_id_1", "handlePTTDown", [], _radioData, false] call acre_sys_mpu5_fnc_handlePTTDown
 *
 * Public: No
 */

params ["_radioId"];

if (!GVAR(txSlotKeying)) then {
    private _talkgroup = [_radioId, "getState", MPU5_TX_TALKGROUP_STATE] call EFUNC(sys_data,dataEvent);
    if (!isNil "_talkgroup" && {_talkgroup > 0}) then {
        [_radioId, "setState", [MPU5_TX_TALKGROUP_STATE, 0]] call EFUNC(sys_data,dataEvent);
    };
};

_this call EFUNC(sys_bf888s,handlePTTDown)
