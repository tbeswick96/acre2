#include "script_component.hpp"
/*
 * Author: UKSF
 * Checks if a receiving radio listens to the talk group of a transmitting MPU-5. The receiver hears its active talk group, its monitored talk groups, and the emergency talk group.
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
if (HASH_GET(_rxData,"mode") != "mpu5Mesh") exitWith {false};

private _txData = [_txRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
private _talkgroup = HASH_GET(_txData,"talkgroup");

_talkgroup == HASH_GET(_rxData,"talkgroup")
|| {_talkgroup == MPU5_EMERGENCY_TALKGROUP}
|| {_talkgroup in ([_rxRadioId] call FUNC(getMonitors))}
