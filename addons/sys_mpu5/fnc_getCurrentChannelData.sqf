#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the channel data of the active talk group.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event (unused) <STRING>
 * 2: Event data <ANY>
 * 3: Radio data <HASH>
 *
 * Return Value:
 * Channel data <HASH>
 *
 * Example:
 * ["acre_mpu5_id_1", "getCurrentChannelData", [], _radioData] call acre_sys_mpu5_fnc_getCurrentChannelData
 *
 * Public: No
 */

params ["_radioId", "", "", "_radioData"];

private _channel = HASH_GET(_radioData,"currentChannel");
if (isNil "_channel") then {
    _channel = 0;
};

if (_channel == MPU5_BRIDGE_CHANNEL) exitWith {
    [_radioId, _radioData] call FUNC(bridgeChannelData)
};

GVAR(channelData) select _channel
