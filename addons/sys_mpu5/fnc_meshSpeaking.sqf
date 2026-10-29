#include "script_component.hpp"
/*
 * Author: UKSF
 * Calculates the signal of an MPU-5 transmission on the receiving client from the mesh path between the two radios.
 *
 * Arguments:
 * 0: Transmitter <OBJECT>
 * 1: Transmitter Radio ID <STRING>
 * 2: Receiver <OBJECT>
 * 3: Receiver Radio ID <STRING>
 *
 * Return Value:
 * Signal calculation parameters <ARRAY>
 *
 * Example:
 * [unit1, "acre_mpu5_id_1", acre_player, "acre_mpu5_id_2"] call acre_sys_mpu5_fnc_meshSpeaking
 *
 * Public: No
 */

params ["", "_txRadioId", "", "_rxRadioId"];

private _signal = [0, -993];

if (_rxRadioId != _txRadioId) then {
    private _hops = [_txRadioId, _rxRadioId] call FUNC(meshHops);
    if (_hops > 0) then {
        _signal = [(1 - 0.02 * (_hops - 1)) max 0.8, -60];
    };
} else {
    if ((toLower _txRadioId) in ACRE_SPECTATOR_RADIOS) then {
        _signal = [1, 0];
    };
};

[_txRadioId, _rxRadioId, _signal select 0, _signal select 1, 0]
