@echo off
setlocal enabledelayedexpansion

if not exist "@acre2" mkdir "@acre2"
if not exist "@acre2\addons" mkdir "@acre2\addons"
if not exist "@acre2\optionals" mkdir "@acre2\optionals"

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set armake=tools\armake_w64.exe) else (set armake=tools\armake_w32.exe)

for /d %%f in (addons\*) do (
    set folder=%%f
    set name=!folder:addons\=!
    echo   PBO  @acre2\addons\acre_!name!.pbo
    !armake! build -i include -w unquoted-string -w redefinition-wo-undef -f !folder! @acre2\addons\acre_!name!.pbo
)

for /d %%f in (optionals\*) do (
    set folder=%%f
    set name=!folder:optionals\=!
    echo   PBO  @acre2\optionals\acre_!name!.pbo
    !armake! build -i include -w unquoted-string -w redefinition-wo-undef -f !folder! @acre2\optionals\acre_!name!.pbo
)

pause
