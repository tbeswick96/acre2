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
#define MPU5_ANTENNA_HEIGHT 1.5
#define MPU5_NODE_REFRESH 2
#define MPU5_REACH_CACHE 0.5

