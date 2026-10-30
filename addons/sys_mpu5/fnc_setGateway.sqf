#include "script_component.hpp"
/*
 * Author: UKSF
 * Links an ordinary radio carried with an MPU-5 to one talk group (radio over IP). Mesh traffic on the talk group is sent out on the ordinary radio's channel, and traffic the ordinary radio receives is sent into the talk group. An empty radio ID removes the link.
 *
 * Arguments:
 * 0: MPU-5 radio ID <STRING>
 * 1: Ordinary radio ID <STRING>
 * 2: Talk group <NUMBER>
 *
 * Return Value:
 * Link set <BOOL>
 *
 * Example:
 * ["acre_mpu5_id_1", "acre_prc152_id_1", 3] call acre_sys_mpu5_fnc_setGateway
 *
 * Public: Yes
 */

params ["_radioId", "_legacyRadioId", "_talkgroup"];

if (_legacyRadioId == "") exitWith {
    [_radioId, "setState", [MPU5_GATEWAY_STATE, []]] call EFUNC(sys_data,dataEvent);
    true
};

if (_legacyRadioId find MPU5_ID_PREFIX == 0 || {_talkgroup < 1} || {_talkgroup > MPU5_TALKGROUPS}) exitWith {false};
private _legacyData = [_legacyRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
if (isNil "_legacyData" || {!(HASH_GET(_legacyData,"mode") in MPU5_LEGACY_MODES)}) exitWith {false};

[_radioId, "setState", [MPU5_GATEWAY_STATE, [_legacyRadioId, _talkgroup]]] call EFUNC(sys_data,dataEvent);
true
