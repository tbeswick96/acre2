#include "script_component.hpp"
/*
 * Author: UKSF
 * Handles a TX slot key of the player's MPU-5. Key down transmits on the talk group in the slot without changing the active talk group. When the talk group changes, the radio waits a short time before it keys so that other clients receive the new talk group first.
 *
 * Arguments:
 * 0: TX slot, 1 to 4 <NUMBER>
 * 1: Key down <BOOL>
 *
 * Return Value:
 * Key handled <BOOL>
 *
 * Example:
 * [1, true] call acre_sys_mpu5_fnc_txSlotKey
 *
 * Public: Yes
 */

params ["_slot", "_down"];

if (!_down) exitWith {
    if (GVAR(txSlotActive) != _slot) exitWith {false};
    GVAR(txSlotActive) = 0;
    [] call EFUNC(sys_core,handleMultiPttKeyPressUp);
    [{!EGVAR(sys_core,pttKeyDown)}, {
        [{
            params ["_radioId"];
            if (GVAR(txSlotActive) == 0) then {
                [_radioId, "setState", [MPU5_TX_TALKGROUP_STATE, 0]] call EFUNC(sys_data,dataEvent);
            };
        }, _this, MPU5_TX_RESET_DELAY] call CBA_fnc_waitAndExecute;
    }, [GVAR(txSlotRadio)]] call CBA_fnc_waitUntilAndExecute;
    true
};

if (GVAR(txSlotActive) != 0 || {EGVAR(sys_core,pttKeyDown)}) exitWith {false};

private _radios = [] call EFUNC(sys_data,getPlayerRadioList);
private _index = _radios findIf {
    _x find MPU5_ID_PREFIX == 0 && {([_x, "getOnOffState"] call EFUNC(sys_data,dataEvent)) isEqualTo 1}
};
if (_index < 0) exitWith {false};
private _radioId = _radios select _index;
if (([_radioId, "getCurrentChannel"] call EFUNC(sys_data,dataEvent)) == MPU5_BRIDGE_CHANNEL) exitWith {false};

private _talkgroup = ([_radioId] call FUNC(getTxSlots)) select (_slot - 1);
if (_talkgroup < 1) exitWith {false};

GVAR(txSlotActive) = _slot;
GVAR(txSlotRadio) = _radioId;

private _delay = 0;
if (([_radioId] call FUNC(txTalkgroup)) != _talkgroup) then {
    [_radioId, "setState", [MPU5_TX_TALKGROUP_STATE, _talkgroup]] call EFUNC(sys_data,dataEvent);
    _delay = MPU5_TX_SWITCH_DELAY;
};

[{
    params ["_radioId", "_slot"];
    if (GVAR(txSlotActive) != _slot) exitWith {};
    private _activeRadio = ACRE_ACTIVE_RADIO;
    ACRE_ACTIVE_RADIO = _radioId;
    [-1] call EFUNC(sys_core,handleMultiPttKeyPress);
    ACRE_ACTIVE_RADIO = _activeRadio;
}, [_radioId, _slot], _delay] call CBA_fnc_waitAndExecute;

true
