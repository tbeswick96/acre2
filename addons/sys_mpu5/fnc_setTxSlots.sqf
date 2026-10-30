#include "script_component.hpp"
/*
 * Author: UKSF
 * Sets the talk groups in the four TX slots of an MPU-5. A talk group can be in one slot only, so a repeated talk group empties the later slot.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Talk group for each slot, 0 for an empty slot <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["acre_mpu5_id_1", [1, 3, 0, 16]] call acre_sys_mpu5_fnc_setTxSlots
 *
 * Public: Yes
 */

params ["_radioId", "_talkgroups"];

private _slots = [];
for "_slot" from 0 to MPU5_TX_SLOTS - 1 do {
    private _talkgroup = _talkgroups param [_slot, 0];
    if !(_talkgroup isEqualType 0 && {_talkgroup >= 1} && {_talkgroup <= MPU5_TALKGROUPS} && {!(_talkgroup in _slots)}) then {
        _talkgroup = 0;
    };
    _slots pushBack _talkgroup;
};

[_radioId, "setState", [MPU5_TX_SLOTS_STATE, _slots]] call EFUNC(sys_data,dataEvent);
