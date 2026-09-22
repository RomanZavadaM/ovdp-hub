@echo off
setlocal
cd /d "%~dp0"
set "FLUTTER=flutter"
if defined FLUTTER_ROOT set "FLUTTER=%FLUTTER_ROOT%\bin\flutter.bat"
if not defined FLUTTER_ROOT if exist "%USERPROFILE%\Documents\Codex\tools\flutter\bin\flutter.bat" set "FLUTTER=%USERPROFILE%\Documents\Codex\tools\flutter\bin\flutter.bat"
call "%FLUTTER%" --version 2>nul | findstr /b /c:"Flutter 3.47.5 " >nul
if errorlevel 1 goto setup
call "%FLUTTER%" pub get --enforce-lockfile
if errorlevel 1 goto failed
echo Starting OVDP Hub on Windows. First launch builds native components.
echo In this console: r = hot reload, R = restart, q = quit.
call "%FLUTTER%" run -d windows --debug --no-pub
if errorlevel 1 goto failed
exit /b 0
:setup
echo Flutter 3.47.5 is required. Add Flutter to PATH or set FLUTTER_ROOT.
echo Windows also needs Visual Studio Desktop development with C++.
echo See START-README.md. No software was installed by this launcher.
pause
exit /b 1
:failed
echo Startup failed. Keep the error above and run flutter doctor -v.
echo See START-README.md. Your saved workspace has not been deleted.
pause
exit /b 1
