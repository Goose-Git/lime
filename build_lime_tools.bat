@echo off
REM A simple script to rebuild the Lime tools.
REM Place this script inside lime/8,2,2/ or your current Lime version folder.
REM Double-click the script to run it.

REM Change to the script's own directory.
cd /d "%~dp0"

REM Build the Lime tools directly.
REM This avoids using "lime rebuild tools" if you only want to rebuild the tools.
cd tools

haxe tools.hxml

if errorlevel 1 (
	echo.
	echo Failed to build Lime tools.
	pause
	exit /b 1
)

echo.
echo Built Lime tools!
pause