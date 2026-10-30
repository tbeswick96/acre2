#include "script_component.hpp"
/*
 * Author: UKSF
 * Calculates the signal of a transmission that crosses a radio over IP link. For mesh traffic sent out on an ordinary radio, the ordinary radio of the link becomes the transmitter, so the receiver checks its own channel against that radio. For ordinary traffic sent into the mesh, the signal is the weaker of the ordinary radio path to the link and the mesh path to the receiver.
 *
 * Arguments:
 * 0: Transmitting unit <OBJECT>
 * 1: Transmitting radio ID <STRING>
 * 2: Receiving unit <OBJECT> (Unused)
 * 3: Receiving radio ID <STRING>
 *
 * Return Value:
 * Transmitting radio ID, receiving radio ID, signal quality, signal dBm, signal model <ARRAY>
 *
 * Example:
 * [unit1, "acre_mpu5_id_1", acre_player, "acre_prc152_id_1"] call acre_sys_mpu5_fnc_gatewaySpeaking
 *
 * Public: No
 */

params ["_unit", "_txRadioId", "", "_rxRadioId"];

private _best = [_txRadioId, 0, -993];
private _txData = [_txRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
private _toLegacy = HASH_GET(_txData,"mode") == "mpu5Mesh";

{
    _x params ["_gatewayId", "_legacyId"];
    private _result = if (_toLegacy) then {
        private _legacyData = [_legacyId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
        private _signal = [HASH_GET(_legacyData,"frequencyTX"), HASH_GET(_legacyData,"power"), _rxRadioId, _legacyId] call EFUNC(sys_signal,getSignal);
        [_legacyId, (_signal select 0) min MPU5_HOP_QUALITY([ARR_2(_txRadioId,_gatewayId)] call FUNC(meshHops)), _signal select 1]
    } else {
        private _signal = [HASH_GET(_txData,"frequencyTX"), HASH_GET(_txData,"power"), _legacyId, _txRadioId] call EFUNC(sys_signal,getSignal);
        private _quality = (_signal select 0) min MPU5_HOP_QUALITY([ARR_2(_gatewayId,_rxRadioId)] call FUNC(meshHops));
        [_txRadioId, _quality, [-60, _signal select 1] select ((_signal select 1) <= -992 || {_quality <= 0})]
    };
    if ((_result select 2) == -992 && {(_best select 2) != -992} && {(_best select 1) <= 0}) then {
        _best = _result;
    };
    if ((_result select 1) > (_best select 1)) then {
        _best = _result;
    };
} forEach ([_txRadioId, _rxRadioId] call FUNC(gatewayMatches));

_best params ["_bestTxRadioId", "_quality", "_dbm"];
if (_toLegacy && {_quality > 0}) then {
    private _key = netId _unit;
    private _heard = GVAR(gatewayHeard) getOrDefault [_key, [], true];
    _heard pushBackUnique [_rxRadioId, _bestTxRadioId];
};

[_bestTxRadioId, _rxRadioId, _quality, _dbm, 0]
