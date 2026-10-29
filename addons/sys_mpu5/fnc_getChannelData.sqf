#include "script_component.hpp"
/*
 * Author: UKSF
 * Returns the channel data of one talk group.
 *
 * Arguments:
 * 0: Radio ID <STRING>
 * 1: Event (unused) <STRING>
 * 2: Event data <ANY>
 * 3: Radio data <HASH>
 *
 * Return Value:
 * Channel data <HASH>
 *
 * Example:
 * ["acre_mpu5_id_1", "getChannelData", 0, _radioData] call acre_sys_mpu5_fnc_getChannelData
 *
 * Public: No
 */

params ["", "", "_eventData"];

GVAR(channelData) select ((0 max _eventData) min (MPU5_TALKGROUPS - 1))
