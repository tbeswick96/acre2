#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns every MPU-5 transmission that the radio can hear. Wave Relay voice is digital, so simultaneous transmissions do not interfere.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event (unused) <STRING>
 * 2: Transmissions <ARRAY>
 *
 * Return Value:
 * Hearable transmissions <ARRAY>
 *
 * Example:
 * ["acre_mpu5_id_1", "handleMultipleTransmissions", _radios] call acre_sys_mpu5_fnc_handleMultipleTransmissions
 *
 * Public: No
 */

params ["_radioId", "", "_radios"];

if !([_radioId] call EFUNC(sys_radio,canUnitReceive)) exitWith {[]};
if (SCRATCH_GET_DEF(_radioId,"PTTDown",false) && {!EGVAR(sys_core,fullDuplex)}) exitWith {[]};

private _hearable = _radios select {((_x select 2) select 0) > 0};
SCRATCH_SET(_radioId,"currentTransmissions",_hearable apply {_x select 1});

private _beeped = SCRATCH_GET_DEF(_radioId,"hasBeeped",false);
if ((_hearable isNotEqualTo []) isNotEqualTo _beeped) then {
    SCRATCH_SET(_radioId,"hasBeeped",!_beeped);
    private _volume = [_radioId, "getVolume"] call EFUNC(sys_data,dataEvent);
    private _sound = ["Acre_GenericClickOn", "Acre_GenericClickOff"] select _beeped;
    [_radioId, _sound, [0, 0, 0], [0, 1, 0], _volume] call EFUNC(sys_radio,playRadioSound);
};

_hearable
