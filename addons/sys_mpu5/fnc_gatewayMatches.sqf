#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the radio over IP links that can carry a transmission between an MPU-5 and an ordinary radio. Mesh traffic goes out on the ordinary radio of a link, and ordinary traffic the link radio can decode goes into the talk group of the link.
 *
 * Arguments:
 * 0: Transmitting radio ID <STRING>
 * 1: Receiving radio ID <STRING>
 *
 * Return Value:
 * Links as MPU-5 radio ID, ordinary radio ID, and talk group <ARRAY>
 *
 * Example:
 * ["acre_mpu5_id_1", "acre_prc152_id_1"] call acre_sys_mpu5_fnc_gatewayMatches
 *
 * Public: No
 */

params ["_txRadioId", "_rxRadioId"];

if (GVAR(gateways) isEqualTo []) exitWith {[]};

private _txData = [_txRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
private _rxData = [_rxRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);

if (HASH_GET(_txData,"mode") == "mpu5Mesh") exitWith {
    if !(HASH_GET(_rxData,"mode") in MPU5_LEGACY_MODES) exitWith {[]};
    private _talkgroup = [_txRadioId] call FUNC(txTalkgroup);
    private _frequency = HASH_GET(_rxData,"frequencyRX");
    GVAR(gateways) select {
        _x params ["_gatewayId", "_legacyId", "_gatewayTalkgroup"];
        private _legacyData = [_legacyId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
        _gatewayTalkgroup == _talkgroup
        && {_legacyId != _rxRadioId}
        && {HASH_GET(_legacyData,"mode") in MPU5_LEGACY_MODES}
        && {HASH_GET(_legacyData,"frequencyTX") == _frequency}
        && {[_legacyData, _rxData] call FUNC(channelsCompatible)}
        && {([_txRadioId, _gatewayId] call FUNC(meshHops)) >= 0}
    }
};

if (HASH_GET(_rxData,"mode") != "mpu5Mesh" || {!(HASH_GET(_txData,"mode") in MPU5_LEGACY_MODES)}) exitWith {[]};
private _frequency = HASH_GET(_txData,"frequencyTX");
GVAR(gateways) select {
    _x params ["_gatewayId", "_legacyId", "_gatewayTalkgroup"];
    private _legacyData = [_legacyId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
    _legacyId != _txRadioId
    && {_gatewayId != _rxRadioId}
    && {HASH_GET(_legacyData,"mode") in MPU5_LEGACY_MODES}
    && {HASH_GET(_legacyData,"frequencyRX") == _frequency}
    && {[_txData, _legacyData] call FUNC(channelsCompatible)}
    && {[_rxRadioId, _gatewayTalkgroup] call FUNC(receivesTalkgroup)}
    && {([_gatewayId, _rxRadioId] call FUNC(meshHops)) > 0}
}
