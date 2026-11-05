#include "script_component.hpp"
/*
 * Author: UKSF
 * Checks if a receiving radio channel can decode a transmitting radio channel. Matching PRR modes are compatible. For single-channel modes, modulation must match, encrypted traffic needs the same key and traffic rate, clear FM and NB traffic needs a matching CTCSS tone unless the receiver has none, and clear AM traffic always decodes. Frequency matching is handled separately.
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

private _mode = _rxData getVariable ["mode", ""];
if (_mode != (_txData getVariable ["mode", ""])) exitWith {false};
if (_mode == "singleChannelPRR") exitWith {true};
if (_mode != "singleChannel") exitWith {false};

private _modulation = _rxData getVariable ["modulation", ""];
private _rxEncryption = _rxData getVariable ["encryption", 0];
private _txEncryption = _txData getVariable ["encryption", 0];
private _ctcss = _rxData getVariable ["CTCSSRx", 0];

if (_modulation != (_txData getVariable ["modulation", ""])) exitWith {false};
if (_rxEncryption == 1 && {_txEncryption == 1}) exitWith {
    (_rxData getVariable ["TEK", 0]) isEqualTo (_txData getVariable ["TEK", 0])
    && {(_rxData getVariable ["trafficRate", 0]) isEqualTo (_txData getVariable ["trafficRate", 0])}
};
if (_rxEncryption != 0 || {_txEncryption != 0}) exitWith {false};
if (_modulation in ["FM", "NB"]) exitWith {_ctcss == 0 || {_ctcss == (_txData getVariable ["CTCSSTx", 0])}};
_modulation == "AM"
