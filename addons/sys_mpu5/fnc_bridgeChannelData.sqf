#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the channel data of the bridge channel of an MPU-5. The function keeps one channel hash per radio and rebuilds it only when the copied channel changes.
 *
 * Arguments:
 * 0: MPU-5 radio ID <STRING>
 * 1: Radio data <HASH>
 *
 * Return Value:
 * Channel data, or the first talk group when there is no bridge channel <HASH>
 *
 * Example:
 * ["acre_mpu5_id_1", _radioData] call acre_sys_mpu5_fnc_bridgeChannelData
 *
 * Public: No
 */

params ["_radioId", "_radioData"];

private _pairs = (_radioData getVariable [MPU5_BRIDGE_STATE, []]) param [1, []];
if (_pairs isEqualTo []) exitWith {GVAR(channelData) select 0};

(GVAR(bridgeData) getOrDefault [_radioId, [[], locationNull]]) params ["_cachedPairs", "_hash"];
if (_cachedPairs isNotEqualTo _pairs) then {
    deleteLocation _hash;
    _hash = HASH_CREATE_NAMESPACE;
    {
        _hash setVariable _x;
    } forEach _pairs;
    GVAR(bridgeData) set [_radioId, [+_pairs, _hash]];
};
_hash
