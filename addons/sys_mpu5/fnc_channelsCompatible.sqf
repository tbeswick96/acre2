#include "script_component.hpp"
/*
 * Author: UKSF
 * Checks if a receiving radio channel can decode a transmitting radio channel. The check compares modulation, encryption key, and CTCSS tone in the same way as the ACRE single-channel radios.
 *
 * Arguments:
 * 0: Transmitting channel data <HASH>
 * 1: Receiving channel data <HASH>
 *
 * Return Value:
 * Channels are compatible <BOOL>
 *
 * Example:
 * [_txData, _rxData] call acre_sys_mpu5_fnc_channelsCompatible
 *
 * Public: No
 */

params ["_txData", "_rxData"];

private _encryption = _txData getVariable ["encryption", 0];
private _ctcss = _rxData getVariable ["CTCSSRx", 0];

(_txData getVariable ["modulation", ""]) == (_rxData getVariable ["modulation", ""])
&& {_encryption == (_rxData getVariable ["encryption", 0])}
&& {_encryption == 0 || {(_txData getVariable ["TEK", 0]) isEqualTo (_rxData getVariable ["TEK", 0])}}
&& {_ctcss == 0 || {_ctcss == (_txData getVariable ["CTCSSTx", 0])}}
