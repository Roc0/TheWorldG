@echo off
set curpath=%~dp0

rem remember python37_d.dll/python37.dll
copy /Y ..\TheWorld_GD_ClientDll\x64\*.dll %curpath%godot_proj\Client\

set KBE_ROOT=D:/TheWorld/KBEngine/kbengine/
rem set KBE_ASSETS=D:/TheWorld/Client/TheWorld_Assets/
set KBE_RES_PATH=D:/TheWorld/KBEngine/kbengine/kbe/res/;D:/TheWorld/Client/TheWorld_Assets/;D:/TheWorld/Client/TheWorld_Assets/scripts/;D:/TheWorld/Client/TheWorld_Assets/res/
set KBE_BIN_PATH=%curpath%godot_proj\Client
rem set KBE_BIN_PATH=D:/TheWorld/Client/TheWorldG/godot_proj/Client/

@echo KBE_ROOT=%KBE_ROOT%
rem @echo KBE_ASSETS=%KBE_ASSETS%
@echo KBE_RES_PATH=%KBE_RES_PATH%
@echo KBE_BIN_PATH=%KBE_BIN_PATH%

del /Q %KBE_BIN_PATH%\log.log

cd /D %curpath%
call Godot_v3.2.3-stable_win64.exe -v --path %curpath%godot_proj -e
