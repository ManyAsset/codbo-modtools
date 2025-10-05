@echo off
cls

del "%IW_PROJECT_BIN%\logfile.txt" 1>nul 2>nul

IF NOT "%IW_PROJECT_VERSION%"=="t5_v26_mods" (
   echo "ERROR: You are not running the right project. IW_PROJECT_VERSION=%IW_PROJECT_VERSION%, instead of t5_v26_mods"
   pause
   goto :EOF
)

setlocal

set STEAM=
for /F "usebackq delims== tokens=2" %%i in (`ftype steam`) do set STEAM=%%~dpi
echo STEAM=%STEAM%
set BLOPS=%STEAM%steamapps\common\call of duty black ops\
echo BLOPS=%BLOPS%
echo.

cd /D "%BLOPS%"
if not exist BlackOps.exe goto :NOT_STEAM
if not exist BlackOpsMP.exe goto :NOT_STEAM

if /I "%1"=="clean" (
 set clean_list=aitype animation_assets assettgtcache bin convertcache deffiles detail_maps export_errors map_source materialfactory model_export mods raw shadercache source_data sw4 temp_assets texture_assets xanim_export zone_source
 for %%i in (%clean_list%) do rmdir /s /q %%i
)

set RAWDIRS=aitype character destructibledef destructiblepiece glass images info lights maps material_properties materials mpbody mphead mptype physconstraints physic rumble sample_game_files ui_mp vehicles weapons xanim xmodel xmodelalias xmodelparts xmodelpieces xmodelsurfs

:OK

rem icacls "%IW_PROJECT_GAMEDIR%" /save icacls.txt
rem icacls . /restore icacls.txt /T

call :JUNCTION bin "%IW_PROJECT_GAMEDIR%\bin"
call :JUNCTION docs "%IW_PROJECT_GAMEDIR%\docs"
call :JUNCTION map_source "%IW_PROJECT_GAMEDIR%\map_source"
call :JUNCTION mods "%IW_PROJECT_GAMEDIR%\mods"
call :JUNCTION deffiles "%IW_PROJECT_GAMEDIR%\deffiles"
call :JUNCTION zone_source "%IW_PROJECT_GAMEDIR%\share\zone_source"
call :JUNCTION detail_maps "%IW_PROJECT_GAMEDIR%\detail_maps"
call :JUNCTION animation_assets "%IW_PROJECT_GAMEDIR%\animation_assets"
call :JUNCTION sw4 "%IW_PROJECT_GAMEDIR%\sw4"
call :JUNCTION raw "%IW_PROJECT_GAMEDIR%\raw_generated"

mkdir raw
for /D %%i in (%IW_PROJECT_GAMEDIR%\share\raw\*) do (
  call :JUNCTION "raw\%%~ni" %%i
)

for /f "usebackq" %%i in ("%IW_PROJECT_BIN%/converter_gdt_dirs_0.txt") do (
  call :JUNCTION "%%i" "%IW_PROJECT_GAMEDIR%\%%i"
)

call :JUNCTION raw\fonts "%IW_PROJECT_GAMEDIR%\pc\raw\fonts"

set IW > set.tmp
for /f "delims==" %%i in (set.tmp) do set %%i=
del set.tmp

set TL > set.tmp
for /f "delims==" %%i in (set.tmp) do set %%i=
del set.tmp

set

cd bin
launcher
goto :EOF

:NOT_STEAM
echo. Can't locate Black Ops Steam installation
echo.
echo. Looked for Steam here [%STEAM%]
echo. And for Black Ops here [%BLOPS%]
echo.
echo.
pause
goto :EOF

:JUNCTION
rd %1
call "%IW_PROJECT_BIN%\junction.exe" -q %1 %2 | "%IW_PROJECT_BIN%\tee" -a "%IW_PROJECT_BIN%\logfile.txt"
goto :EOF
