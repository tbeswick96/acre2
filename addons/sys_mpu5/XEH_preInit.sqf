#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

[] call FUNC(presetInformation);

GVAR(nodes) = createHashMap;
GVAR(nodeIds) = [];
GVAR(links) = createHashMap;
GVAR(linkCursor) = 0;
GVAR(reachCache) = createHashMap;

ADDON = true;
