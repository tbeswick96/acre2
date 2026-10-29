#include "script_component.hpp"
/*
 * Author: UKSF
 * Rebuilds the list of powered MPU-5 mesh nodes and drops the links of nodes that left the mesh.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call acre_sys_mpu5_fnc_updateNodes
 *
 * Public: No
 */

private _nodes = createHashMap;
{
    if (_x find MPU5_ID_PREFIX == 0 && {[_x] call EFUNC(sys_data,isRadioInitialized)} && {([_x, "getOnOffState"] call EFUNC(sys_data,dataEvent)) isEqualTo 1}) then {
        private _object = (HASH_GET(EGVAR(sys_server,objectIdRelationTable),_x)) select 0;
        if (!isNull _object) then {
            _nodes set [_x, _object];
        };
    };
} forEach HASH_KEYS(EGVAR(sys_server,objectIdRelationTable));

private _links = createHashMap;
{
    _links set [_x, (GVAR(links) getOrDefault [_x, []]) select {_x in _nodes}];
} forEach _nodes;

GVAR(nodes) = _nodes;
GVAR(nodeIds) = keys _nodes;
GVAR(links) = _links;
