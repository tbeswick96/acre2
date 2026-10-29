#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the number of mesh hops between two MPU-5 radios. The function caches the hop counts from each transmitter for a short time.
 *
 * Arguments:
 * 0: Transmitting radio ID <STRING>
 * 1: Receiving radio ID <STRING>
 *
 * Return Value:
 * Hop count, -1 if no path exists <NUMBER>
 *
 * Example:
 * ["acre_mpu5_id_1", "acre_mpu5_id_2"] call acre_sys_mpu5_fnc_meshHops
 *
 * Public: No
 */

params ["_txRadioId", "_rxRadioId"];

_txRadioId = toLower _txRadioId;
private _entry = GVAR(reachCache) getOrDefault [_txRadioId, [-1, createHashMap]];

if (diag_tickTime - (_entry select 0) > MPU5_REACH_CACHE) then {
    private _hops = createHashMap;
    if (_txRadioId in GVAR(links)) then {
        _hops set [_txRadioId, 0];
        private _frontier = [_txRadioId];
        private _depth = 0;
        while {_frontier isNotEqualTo []} do {
            _depth = _depth + 1;
            private _next = [];
            {
                {
                    if !(_x in _hops) then {
                        _hops set [_x, _depth];
                        _next pushBack _x;
                    };
                } forEach (GVAR(links) getOrDefault [_x, []]);
            } forEach _frontier;
            _frontier = _next;
        };
    };
    _entry = [diag_tickTime, _hops];
    GVAR(reachCache) set [_txRadioId, _entry];
};

(_entry select 1) getOrDefault [toLower _rxRadioId, -1]
