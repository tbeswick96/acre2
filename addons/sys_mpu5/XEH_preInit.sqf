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
GVAR(gateways) = [];
GVAR(gatewayHeard) = createHashMap;
GVAR(bridgeData) = createHashMap;
GVAR(txSlotActive) = 0;
GVAR(txSlotRadio) = "";
GVAR(txSession) = 0;
GVAR(txSlotKeyed) = false;
GVAR(txSlotKeying) = false;
GVAR(txSwitchTime) = -1;

ADDON = true;
