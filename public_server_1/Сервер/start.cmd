@echo off
cls
title StartUp
:hlds
echo (%time%) HLDS Started...
reg add "HKCU\Software\Valve\Steam\ActiveProcess" /v SteamClientDll /t REG_SZ /d "" /f
start /wait /high hlds.exe -console -game cstrike +ip 0.0.0.0 +port 27015 +map de_dust2 +maxplayers 20 -nomaster -noipx -insecure
echo n| goto hlds
echo (%time%) HLDS Crashed, restarting...
goto hlds