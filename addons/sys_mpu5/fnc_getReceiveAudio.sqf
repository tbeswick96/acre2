#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the volume scale and ear for one transmission an MPU-5 receives. A transmission on the active talk group uses the radio's own settings.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event <STRING> (Unused)
 * 2: Transmitting radio ID <STRING>
 * 3: Radio data <HASH>
 *
 * Return Value:
 * Volume scale and ear, or nil for the radio's own settings <ARRAY>
 *
 * Example:
 * ["acre_mpu5_id_1", "getReceiveAudio", "acre_mpu5_id_2", _radioData] call acre_sys_mpu5_fnc_getReceiveAudio
 *
 * Public: No
 */

params ["_radioId", "", "_txRadioId", "_radioData"];

private _channel = HASH_GET(_radioData,"currentChannel");
if (isNil "_channel") then {
    _channel = 0;
};
if (_channel == MPU5_BRIDGE_CHANNEL) exitWith {nil};

private _txData = [_txRadioId, "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
private _talkgroup = if (HASH_GET(_txData,"mode") == "mpu5Mesh") then {
    [_txRadioId] call FUNC(txTalkgroup)
} else {
    (([_txRadioId, _radioId] call FUNC(gatewayMatches)) param [0, [0, 0, 0]]) select 2
};
if (_talkgroup == _channel + 1) exitWith {nil};

private _audio = [_radioId, _talkgroup] call FUNC(getMonitorAudio);
if (_audio isEqualTo [1, MPU5_EAR_DEFAULT]) exitWith {nil};
_audio
