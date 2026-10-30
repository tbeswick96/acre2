#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the talk groups in the four TX slots of an MPU-5.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 *
 * Return Value:
 * Talk group for each slot, 0 for an empty slot <ARRAY>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_getTxSlots
 *
 * Public: Yes
 */

params ["_radioId"];

private _slots = [_radioId, "getState", MPU5_TX_SLOTS_STATE] call EFUNC(sys_data,dataEvent);
if (isNil "_slots") exitWith {[0, 0, 0, 0]};
_slots
