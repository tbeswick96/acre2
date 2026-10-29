class CfgAcreComponents {
    class ACRE_BaseRadio;

    class ACRE_MPU5_BASE: ACRE_BaseRadio {
        class Interfaces;
        isAcre = 1;
    };

    class ACRE_MPU5: ACRE_MPU5_BASE {
        name = QUOTE(NAME_MPU5);
        sinadRating = -119;
        sensitivityMin = -116;
        sensitivityMax = -50;
        isPackRadio = 0;
        isDeployable = 0;

        connectors[] = {
            {"Antenna", ACRE_CONNECTOR_SMA},
            {"Audio/Data", ACRE_CONNECTOR_U_283}
        };
        defaultComponents[] = {
            {0, "ACRE_22CM_UHF_SMA"}
        };

        class InterfaceClasses {
            CfgAcreDataInterface = "DefaultRadioInterface";
            CfgAcreInteractInterface = "DefaultRadioInterface";
            CfgAcreTransmissionInterface = "DefaultRadioInterface";
            CfgAcrePhysicalInterface = "DefaultRadioInterface";
        };

        class Interfaces: Interfaces {
            class CfgAcreDataInterface {
                getListInfo = QFUNC(getChannelDescription);

                setVolume = QEFUNC(sys_bf888s,setVolume);
                getVolume = QEFUNC(sys_bf888s,getVolume);

                setSpatial = QEFUNC(sys_bf888s,setSpatial);
                getSpatial = QEFUNC(sys_bf888s,getSpatial);

                setChannelData = QEFUNC(sys_bf888s,setChannelData);
                getChannelData = QFUNC(getChannelData);
                getCurrentChannelData = QFUNC(getCurrentChannelData);

                getCurrentChannel = QEFUNC(sys_bf888s,getCurrentChannel);
                setCurrentChannel = QEFUNC(sys_bf888s,setCurrentChannel);

                getStates = QEFUNC(sys_bf888s,getStates);
                getState = QEFUNC(sys_bf888s,getState);
                setState = QEFUNC(sys_bf888s,setState);

                getOnOffState = QEFUNC(sys_bf888s,getOnOffState);
                setOnOffState = QEFUNC(sys_bf888s,setOnOffState);

                initializeComponent = QEFUNC(sys_bf888s,initializeRadio);

                getChannelDescription = QFUNC(getChannelDescription);

                isExternalAudio = QEFUNC(sys_bf888s,isExternalAudio);
            };

            class CfgAcrePhysicalInterface {
                getExternalAudioPosition = QEFUNC(sys_bf888s,getExternalAudioPosition);
            };

            class CfgAcreTransmissionInterface {
                handleBeginTransmission = QEFUNC(sys_bf888s,handleBeginTransmission);
                handleEndTransmission = QEFUNC(sys_bf888s,handleEndTransmission);

                handleSignalData = QEFUNC(sys_bf888s,handleSignalData);
                handleMultipleTransmissions = QFUNC(handleMultipleTransmissions);

                handlePTTDown = QEFUNC(sys_bf888s,handlePTTDown);
                handlePTTUp = QEFUNC(sys_bf888s,handlePTTUp);
            };

            class CfgAcreInteractInterface {
                openGui = QFUNC(openGui);
                closeGui = QFUNC(closeGui);
            };
        };
    };
};
