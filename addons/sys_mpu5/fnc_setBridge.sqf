#include "script_component.hpp"
/*
 * Author: UKSF
 * Copies the current channel of an ordinary radio into the bridge channel of an MPU-5 and selects that channel. The MPU-5 then transmits and receives on the ordinary net with its own antenna and power. An empty radio ID removes the bridge channel and returns the MPU-5 to its previous talk group.
 *
 * Arguments:
 * 0: MPU-5 radio ID <STRING>
 * 1: Ordinary radio ID <STRING>
 *
 * Return Value:
 * Bridge set <BOOL>
 *
 * Example:
 * ["acre_mpu5_id_1", "acre_prc152_id_1"] call acre_sys_mpu5_fnc_setBridge
 *
 * Public: Yes
 */

params ["_radioId", "_legacyRadioId"];

private _channel = [_radioId, "getCurrentChannel"] call EFUNC(sys_data,dataEvent);

if (_legacyRadioId == "") exitWith {
    private _return = [_radioId, "getState", MPU5_BRIDGE_RETURN_STATE] call EFUNC(sys_data,dataEvent);
    [_radioId, "setState", [MPU5_BRIDGE_STATE, []]] call EFUNC(sys_data,dataEvent);
    if (_channel == MPU5_BRIDGE_CHANNEL) then {
        [_radioId, "setCurrentChannel", [0, _return] select !isNil "_return"] call EFUNC(sys_data,dataEvent);
    };
    true
};

if (_legacyRadioId find MPU5_ID_PREFIX == 0) exitWith {false};
private _legacyData = [_legacyRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
if (isNil "_legacyData") exitWith {false};
private _mode = HASH_GET(_legacyData,"mode");
if !(_mode in MPU5_LEGACY_MODES) exitWith {false};

private _pairs = [];
{
    private _value = _legacyData getVariable _x;
    if (!isNil "_value" && {_x != "power"}) then {
        _pairs pushBack [_x, _value];
    };
} forEach getArray (configFile >> "CfgAcreRadioModes" >> _mode >> "channelHash");
_pairs pushBack ["power", MPU5_POWER];

if (_channel != MPU5_BRIDGE_CHANNEL) then {
    [_radioId, "setState", [MPU5_BRIDGE_RETURN_STATE, _channel]] call EFUNC(sys_data,dataEvent);
};
[_radioId, "setState", [MPU5_BRIDGE_STATE, [_legacyRadioId, _pairs]]] call EFUNC(sys_data,dataEvent);
[_radioId, "setCurrentChannel", MPU5_BRIDGE_CHANNEL] call EFUNC(sys_data,dataEvent);
true
