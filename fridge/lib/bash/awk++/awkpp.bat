@echo off
:: (c) 2008 G. Grothendieck.  Freely available using same license as gawk.
setlocal
if "%1"=="" (echo Usage: awkpp [-c] prog[.awkpp] ...) && goto:eof
if "%1"=="-c" set COMPILE_ONLY=1
if "%1"=="/c" set COMPILE_ONLY=1
if defined COMPILE_ONLY (shift)

if exist "%1.awkpp" set PROG="%1.awkpp"
if exist "%1.awk++" set PROG="%1.awk++"
if exist "%1" set PROG="%1" 
if not defined PROG (echo awkpp.bat: could not find %1) && goto:eof

shift

:: find awkpp.awk
set scriptdir_=%~dp0
set lookin=%scriptdir_%;.;%PATH%;%userprofile%
if not defined AWKPP (
	for %%f in ("awkpp.awk") do set "AWKPP=%%~$lookin:f"
)
if not defined AWKPP (echo awkpp.bat: could not find awkpp.awk) && goto:eof

:: run awkpp
if defined COMPILE_ONLY (
	gawk -f %AWKPP% %PROG%
) else (
	gawk -f %AWKPP% %PROG% | gawk -f - %*
)
endlocal
 
