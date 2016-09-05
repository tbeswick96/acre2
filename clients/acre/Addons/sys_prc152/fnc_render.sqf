#include "script_component.hpp"
private["_display"];
if((count _this) > 0) then {
	_display = _this select 0;
	uiNamespace setVariable [QUOTE(GVAR(currentDisplay)), _display];
} else {
	_display = uiNamespace getVariable [QUOTE(GVAR(currentDisplay)), nil];
};

_knobPosition = GET_STATE_DEF("knobPosition", 1);
_knobImageStr = [_knobPosition, 1, 0] call CBA_fnc_formatNumber;
_knobImageStr = format["\idi\clients\acre\addons\sys_prc152\Data\knobs\channelknob\prc152c_ui_knob_%1.paa", _knobImageStr];
TRACE_1("Setting knob image", _knobImageStr);

(_display displayCtrl ICON_KNOB) ctrlSetText _knobImageStr;
(_display displayCtrl ICON_KNOB) ctrlCommit 0;

true