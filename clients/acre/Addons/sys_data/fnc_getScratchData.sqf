//fnc_getScratchData.sqf
#include "script_component.hpp"

params["_radioId", "_id", ["_default",nil]];

if(!HASH_HASKEY(GVAR(radioScratchData), _radioId)) exitWith {
	HASH_SET(GVAR(radioScratchData), _radioId, HASH_CREATE);
	private _data = HASH_GET(GVAR(radioScratchData), _radioId);
	HASH_SET(_data, _id, _default);
	_default
};

private _data = HASH_GET(GVAR(radioScratchData), _radioId);
if(!HASH_HASKEY(_data, _id)) exitWith {
	HASH_SET(_data, _id, _default);
	_default
};
HASH_GET(_data, _id);