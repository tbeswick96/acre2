class CfgWeapons {
    class ACRE_BaseRadio;
    class CBA_MiscItem_ItemInfo;

    class ACRE_MPU5: ACRE_BaseRadio {
        displayName = QUOTE(NAME_MPU5);
        useActionTitle = QUOTE(NAME_MPU5);
        picture = QPATHTOF(data\mpu5_icon_ca.paa);
        model = QPATHTOF(data\MPU5.p3d);
        descriptionShort = "Persistent Systems MPU-5 Wave Relay MANET radio";

        scopeCurator = 2;
        scope = 2;

        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 10;
            scope = 0;
        };

        class Library {
            libTextDesc = QUOTE(NAME_MPU5);
        };

        EGVAR(arsenalStats,frequencyMin) = 1350e6;
        EGVAR(arsenalStats,frequencyMax) = 1390e6;
        EGVAR(arsenalStats,transmitPower) = MPU5_POWER;
        EGVAR(arsenalStats,effectiveRange) = "Mesh, 2-5km per hop";
    };

    RADIO_ID_LIST(ACRE_MPU5)
};
