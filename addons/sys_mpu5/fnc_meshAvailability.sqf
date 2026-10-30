#include "script_component.hpp"
/*
 * Author: UKSF
 * Checks if a receiving radio listens to the talk group of a transmitting MPU-5. An MPU-5 hears its active talk group, its monitored talk groups, its TX slot talk groups, and the emergency talk group. An ordinary radio hears the talk group through a radio over IP link.
 *
 * Arguments:
 * 0: Transmitting radio ID <STRING>
 * 1: Receiving radio ID <STRING>
 *
 * Return Value:
 * Receiver listens <BOOL>
 *
 * Example:
 * ["acre_mpu5_id_1", "acre_mpu5_id_2"] call acre_sys_mpu5_fnc_meshAvailability
 *
 * Public: No
 */

params ["_txRadioId", "_rxRadioId"];

private _rxData = [_rxRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
if (HASH_GET(_rxData,"mode") != "mpu5Mesh") exitWith {
    ([_txRadioId, _rxRadioId] call FUNC(gatewayMatches)) isNotEqualTo []
};

[_rxRadioId, [_txRadioId] call FUNC(txTalkgroup)] call FUNC(receivesTalkgroup)
