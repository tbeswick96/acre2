#include "script_component.hpp"
/*
 * Author: UKSF
 * Rebuilds the list of powered MPU-5 mesh nodes, drops the links of nodes that left the mesh, and rebuilds the list of radio over IP links whose ordinary radio is powered and next to its MPU-5.
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

private _gateways = [];
{
    ([_x] call FUNC(getGateway)) params [["_legacyId", ""], ["_talkgroup", 0]];
    if (_legacyId != "" && {[_legacyId] call EFUNC(sys_data,isRadioInitialized)} && {([_legacyId, "getOnOffState"] call EFUNC(sys_data,dataEvent)) isEqualTo 1}) then {
        private _legacyObject = (EGVAR(sys_server,objectIdRelationTable) getVariable [_legacyId, []]) param [0, objNull];
        if (!isNull _legacyObject && {_legacyObject distance _y <= MPU5_GATEWAY_RANGE}) then {
            _gateways pushBack [_x, _legacyId, _talkgroup];
        };
    };
} forEach _nodes;
GVAR(gateways) = _gateways;
