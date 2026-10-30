#include "script_component.hpp"

[FUNC(updateNodes), MPU5_NODE_REFRESH] call CBA_fnc_addPerFrameHandler;
[FUNC(updateLinks), 0] call CBA_fnc_addPerFrameHandler;

if (!hasInterface) exitWith {};

["acre_remoteStoppedSpeaking", {
    params ["_unit"];
    {
        _x params ["_rxRadioId", "_legacyRadioId"];
        if ([_rxRadioId] call EFUNC(sys_data,isRadioInitialized)) then {
            [_rxRadioId, "handleEndTransmission", [_legacyRadioId]] call EFUNC(sys_data,transEvent);
        };
    } forEach (GVAR(gatewayHeard) getOrDefault [netId _unit, []]);
    GVAR(gatewayHeard) deleteAt netId _unit;
}] call CBA_fnc_addEventHandler;

for "_slot" from 1 to MPU5_TX_SLOTS do {
    [
        "ACRE2",
        format [QGVAR(txSlot%1), _slot],
        [format ["MPU-5 TX slot %1", _slot], format ["Transmit on the MPU-5 talk group in TX slot %1 without changing the active talk group.", _slot]],
        compile format ["[%1, true] call %2", _slot, QFUNC(txSlotKey)],
        compile format ["[%1, false] call %2", _slot, QFUNC(txSlotKey)],
        [0, [false, false, false]]
    ] call CBA_fnc_addKeybind;
};
