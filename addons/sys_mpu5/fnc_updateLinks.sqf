#include "script_component.hpp"
/*
 * Author: UKSF
 * Recalculates the mesh links of one MPU-5 node per frame. A link exists inside the short link range, or inside the line-of-sight range when terrain does not block the path.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call acre_sys_mpu5_fnc_updateLinks
 *
 * Public: No
 */

private _count = count GVAR(nodeIds);
if (_count < 2) exitWith {};

GVAR(linkCursor) = (GVAR(linkCursor) + 1) % _count;
private _id = GVAR(nodeIds) select GVAR(linkCursor);
private _object = GVAR(nodes) get _id;
if (isNull _object) exitWith {};

private _position = (getPosASL _object) vectorAdd [0, 0, MPU5_ANTENNA_HEIGHT];
private _neighbours = [];

{
    if (_x != _id && {!isNull _y}) then {
        private _otherPosition = (getPosASL _y) vectorAdd [0, 0, MPU5_ANTENNA_HEIGHT];
        private _distance = _position distance _otherPosition;
        private _linked = _distance <= GVAR(nlosRange) || {_distance <= GVAR(losRange) && {!terrainIntersectASL [_position, _otherPosition]}};
        private _list = GVAR(links) getOrDefault [_x, []];
        private _index = _list find _id;
        if (_linked) then {
            _neighbours pushBack _x;
            if (_index < 0) then {_list pushBack _id};
        } else {
            if (_index >= 0) then {_list deleteAt _index};
        };
        GVAR(links) set [_x, _list];
    };
} forEach GVAR(nodes);

GVAR(links) set [_id, _neighbours];
