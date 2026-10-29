class CfgAcreRadioModes {
    class mpu5Mesh {
        availability = QFUNC(meshAvailability);
        speaking = QFUNC(meshSpeaking);
        channelHash[] = {
            "frequencyTX",
            "frequencyRX",
            "power",
            "mode",
            "talkgroup"
        };
    };
};
