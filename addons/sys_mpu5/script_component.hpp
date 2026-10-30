#define COMPONENT sys_mpu5
#define COMPONENT_BEAUTIFIED MPU-5
#include "\idi\acre\addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_SYS_MPU5
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SYS_MPU5
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SYS_MPU5
#endif

#include "\idi\acre\addons\main\script_macros.hpp"
#include "\idi\acre\addons\sys_components\script_acre_component_defines.hpp"

#define NAME_MPU5 MPU-5
#define MPU5_TALKGROUPS 16
#define MPU5_EMERGENCY_TALKGROUP 16
#define MPU5_BASE_FREQUENCY 1370
#define MPU5_FREQUENCY_STEP 0.025
#define MPU5_POWER 6000
#define MPU5_ID_PREFIX "acre_mpu5_id_"
#define MPU5_MONITORS_STATE "mpu5Monitors"
#define MPU5_MONITOR_AUDIO_STATE "mpu5MonitorAudio"
#define MPU5_TX_SLOTS_STATE "mpu5TxSlots"
#define MPU5_TX_TALKGROUP_STATE "mpu5TxTalkgroup"
#define MPU5_GATEWAY_STATE "mpu5Gateway"
#define MPU5_BRIDGE_STATE "mpu5Bridge"
#define MPU5_BRIDGE_RETURN_STATE "mpu5BridgeReturn"
#define MPU5_BRIDGE_CHANNEL 16
#define MPU5_TX_SLOTS 4
#define MPU5_GATEWAY_RANGE 10
#define MPU5_TX_SWITCH_DELAY 0.3
#define MPU5_TX_RESET_DELAY 1
#define MPU5_EAR_DEFAULT -2
#define MPU5_LEGACY_MODES ["singleChannel", "singleChannelPRR"]
#define MPU5_HOP_QUALITY(hops) (((1 - 0.02 * ((hops) - 1)) min 1) max 0.8)
#define MPU5_ANTENNA_HEIGHT 1.5
#define MPU5_NODE_REFRESH 2
#define MPU5_REACH_CACHE 0.5

