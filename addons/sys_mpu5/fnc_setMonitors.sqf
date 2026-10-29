#include "script_component.hpp"
/*
 * Author: UKSF
 * Sets the listen-only talk groups of an MPU-5. The radio hears these talk groups in addition to its active talk group and the emergency talk group.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Talk groups, 1 to 16 <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["acre_mpu5_id_1", [2, 5]] call acre_sys_mpu5_fnc_setMonitors
 *
 * Public: Yes
 */

params ["_radioId", "_talkgroups"];

private _monitors = (_talkgroups arrayIntersect _talkgroups) select {
    _x isEqualType 0 && {_x >= 1} && {_x <= MPU5_TALKGROUPS}
};
_monitors sort true;

[_radioId, "setState", [MPU5_MONITORS_STATE, _monitors]] call EFUNC(sys_data,dataEvent);
