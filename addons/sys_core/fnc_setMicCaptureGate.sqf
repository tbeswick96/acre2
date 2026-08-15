#include "script_component.hpp"
/*
 * Author: UKSF
 * Enable or disable teeing the local player's captured direct-speech mic audio
 * to the STT named pipe. The actual capture is additionally gated on
 * Speaking::direct inside the plugin, so this only opens the door.
 *
 * Desired state is stored in SQF. The TeamSpeak plugin resets CSelf to closed
 * on every init, so this function only sends the RPC while the ACRE pipe is
 * up. Pipe-up reapplies the stored state.
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

GVAR(micCaptureGate) = _enabled;

if (EGVAR(sys_io,pipeCode) isNotEqualTo "1") exitWith {};

["setMicCaptureGate", [_enabled]] call EFUNC(sys_rpc,callRemoteProcedure);
