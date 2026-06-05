#include "script_component.hpp"
/*
 * Author: UKSF
 * Enable or disable teeing the local player's captured direct-speech mic audio
 * to the STT named pipe. The actual capture is additionally gated on
 * Speaking::direct inside the plugin, so this only opens the door.
 *
 * Arguments:
 * 0: Enabled <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call acre_sys_core_fnc_setMicCaptureGate
 *
 * Public: No
 */
params [["_enabled", false, [false]]];

["setMicCaptureGate", [_enabled]] call EFUNC(sys_rpc,callRemoteProcedure);
