#include "script_component.hpp"
/*
 * Author: UKSF
 * Registers the MPU-5 talk-group preset and builds the shared talk-group channel data.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call acre_sys_mpu5_fnc_presetInformation
 *
 * Public: No
 */

GVAR(channelData) = [];
private _presetData = HASH_CREATE;
private _channels = HASHLIST_CREATELIST(["frequencyTX"]);

for "_talkgroup" from 1 to MPU5_TALKGROUPS do {
    private _frequency = MPU5_BASE_FREQUENCY + (_talkgroup - 1) * MPU5_FREQUENCY_STEP;

    private _channel = HASHLIST_CREATEHASH(_channels);
    HASH_SET(_channel,"frequencyTX",_frequency);
    HASH_SET(_channel,"frequencyRX",_frequency);
    HASH_SET(_channel,"power",MPU5_POWER);
    HASH_SET(_channel,"talkgroup",_talkgroup);
    HASHLIST_PUSH(_channels,_channel);

    private _data = HASH_CREATE;
    HASH_SET(_data,"mode","mpu5Mesh");
    HASH_SET(_data,"frequencyTX",_frequency);
    HASH_SET(_data,"frequencyRX",_frequency);
    HASH_SET(_data,"power",MPU5_POWER);
    HASH_SET(_data,"talkgroup",_talkgroup);
    GVAR(channelData) pushBack _data;
};

HASH_SET(_presetData,"channels",_channels);
["ACRE_MPU5", "default", _presetData] call EFUNC(sys_data,registerRadioPreset);
