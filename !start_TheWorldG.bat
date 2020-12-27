@echo off
set curpath=%~dp0

set KBE_ROOT=D:/TheWorld/KBEngine/kbengine/
set KBE_RES_PATH=D:/TheWorld/KBEngine/kbengine/kbe/res/;D:/TheWorld/Client/TheWorld_Assets/;D:/TheWorld/Client/TheWorld_Assets/scripts/;D:/TheWorld/Client/TheWorld_Assets/res/
set KBE_BIN_PATH=%curpath%

@echo KBE_ROOT=%KBE_ROOT%
@echo KBE_RES_PATH=%KBE_RES_PATH%
@echo KBE_BIN_PATH=%KBE_BIN_PATH%

del /Q %KBE_BIN_PATH%\log.log

cd /D %curpath%
start Godot_v3.2.3-stable_win64.exe -v --path %curpath%godot_proj -e
