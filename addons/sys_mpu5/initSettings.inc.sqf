[
    QGVAR(losRange),
    "SLIDER",
    ["Line-of-sight link range", "Maximum distance in metres for an MPU-5 mesh link when terrain does not block the path between the two nodes."],
    ["ACRE2", "MPU-5"],
    [500, 20000, 5000, 0],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(nlosRange),
    "SLIDER",
    ["Short link range", "Distance in metres inside which an MPU-5 mesh link works even when terrain blocks the path."],
    ["ACRE2", "MPU-5"],
    [0, 5000, 800, 0],
    true
] call CBA_fnc_addSetting;
