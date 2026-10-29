#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {RADIO_WEAPON_LIST_STR(ACRE_MPU5)};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"acre_sys_radio", "acre_sys_modes", "acre_sys_bf888s"};
        author = ECSTRING(main,Author);
        authors[] = {"UKSF"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

PRELOAD_ADDONS;

#include "CfgWeapons.hpp"
#include "CfgAcreRadios.hpp"
#include "CfgAcreRadioModes.hpp"
#include "CfgEventHandlers.hpp"
