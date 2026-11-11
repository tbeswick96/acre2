#include "script_component.hpp"
/*
 * Author: ACRE2Team
 * Decides how the local player hears a remote unit's direct speech. ACE unconscious speakers are heard only by ACE unconscious listeners, at full volume at any distance.
 *
 * Arguments:
 * 0: Speaking unit <OBJECT>
 * 1: Units already sent radio speaking data this frame <ARRAY>
 *
 * Return Value:
 * updateSpeakingData parameters, empty when nothing needs sending <ARRAY>
 *
 * Example:
 * [unit, []] call acre_sys_core_fnc_getDirectSpeakingData
 *
 * Public: No
 */

params ["_unit", "_sentMicRadios"];

if (isNull _unit || {_unit == acre_player}) exitWith { [] };

private _unconsciousSpeaker = IS_UNCONSCIOUS_VOICE(_unit);
if (IS_MUTED(_unit) || {_unconsciousSpeaker && {!IS_UNCONSCIOUS_VOICE(acre_player)}}) exitWith {
    ["m", GET_TS3ID(_unit), 0]
};

if (_unconsciousSpeaker || {_unit call FUNC(inRange)}) exitWith {
    TRACE_1("Calling processDirectSpeaker",_unit);
    [_unit] call FUNC(processDirectSpeaker)
};

[["m", GET_TS3ID(_unit), 0], []] select (_unit in _sentMicRadios)
