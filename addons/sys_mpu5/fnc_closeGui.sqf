#include "script_component.hpp"
/*
 * Author: UKSF
 * Closes the MPU-5 interface. The radio has no ACRE dialog, so nothing changes.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event (unused) <STRING>
 * 2: Event data <ANY>
 * 3: Radio data <HASH>
 *
 * Return Value:
 * Closed <BOOL>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_closeGui
 *
 * Public: No
 */

true
