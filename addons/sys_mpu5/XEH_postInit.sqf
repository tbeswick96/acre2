#include "script_component.hpp"

[FUNC(updateNodes), MPU5_NODE_REFRESH] call CBA_fnc_addPerFrameHandler;
[FUNC(updateLinks), 0] call CBA_fnc_addPerFrameHandler;
