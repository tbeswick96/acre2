#include "script_component.hpp"
/*
 * Author: UKSF
 * Sets the current channel of an MPU-5. Channels 0 to 15 are talk groups 1 to 16. Channel 16 is the bridge channel and is available only while the radio has a bridge.
 *
 * Arguments:
 * 0: Radio ID <STRING> (Unused)
 * 1: Event <STRING> (Unused)
 * 2: Channel <NUMBER>
 * 3: Radio data <HASH>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["acre_mpu5_id_1", "setCurrentChannel", 3, _radioData] call acre_sys_mpu5_fnc_setCurrentChannel
 *
 * Public: No
 */

params ["", "", "_channel", "_radioData"];

if (_channel != MPU5_BRIDGE_CHANNEL || {((_radioData getVariable [MPU5_BRIDGE_STATE, []]) param [1, []]) isEqualTo []}) then {
    _channel = (0 max _channel) min (MPU5_TALKGROUPS - 1);
};

HASH_SET(_radioData,"currentChannel",_channel);
