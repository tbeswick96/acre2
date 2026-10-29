#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the active talk group and the monitored talk groups as text.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event (unused) <STRING>
 * 2: Event data <ANY>
 * 3: Radio data <HASH>
 *
 * Return Value:
 * Description <STRING>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_getChannelDescription
 *
 * Public: No
 */

params ["_radioId"];

private _talkgroup = ([_radioId, "getCurrentChannel"] call EFUNC(sys_data,dataEvent)) + 1;
private _monitors = [_radioId] call FUNC(getMonitors);

if (_monitors isEqualTo []) exitWith {
    format ["TG %1", _talkgroup]
};

format ["TG %1 MON %2", _talkgroup, _monitors joinString ","]
