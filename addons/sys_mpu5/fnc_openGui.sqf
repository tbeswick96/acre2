#include "script_component.hpp"
/*
 * Author: UKSF
 * Raises the local open event of an MPU-5. The radio has no ACRE dialog. A device application, such as a cTab app, handles the event.
 * The ACRE open-dialog marker is cleared at once, because no dialog unload clears it and it blocks every other radio GUI.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event (unused) <STRING>
 * 2: Event data <ANY>
 * 3: Radio data <HASH>
 *
 * Return Value:
 * Opened <BOOL>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_openGui
 *
 * Public: No
 */

params ["_radioId"];

[_radioId, "closeGui"] call EFUNC(sys_data,interactEvent);
if !([_radioId] call EFUNC(sys_radio,canOpenRadio)) exitWith {false};

[QGVAR(openGui), [_radioId]] call CBA_fnc_localEvent;

true
