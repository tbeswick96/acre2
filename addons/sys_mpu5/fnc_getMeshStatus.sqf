#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the direct links and the reachable nodes of an MPU-5 in the local mesh picture.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 *
 * Return Value:
 * [direct links, reachable nodes] <ARRAY>
 *
 * Example:
 * ["acre_mpu5_id_1"] call acre_sys_mpu5_fnc_getMeshStatus
 *
 * Public: Yes
 */

params ["_radioId"];

_radioId = toLower _radioId;
[_radioId, _radioId] call FUNC(meshHops);
private _reachable = (GVAR(reachCache) get _radioId) select 1;

[count (GVAR(links) getOrDefault [_radioId, []]), (count _reachable - 1) max 0]
