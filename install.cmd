@echo off
setlocal
:: Installation script to deploy required components
:: Change the values below to reflect installation specifics for your system

:: Artisan installation folder.  If you've installed it elsewhere, change it below
set artisanDir=C:\Program Files\Artisan
:: The scripts must live in a folder underneath %artisanDir%
set RoastLearnerDir=%artisanDir%\scripts\RoastLearner

:: Python 27 must be installed in the following directory for the time being
set py27Dir=C:\Python27

:: PyAudioAnalysis must be installed in the following directory for the time being
set pyAudAnDir=%py27Dir%\scripts\PyAudioAnalysis

:: Recordings and trained classifiers must be installed in the following directory
set recordingDir=%LOCALAPPDATA%\RoastLearner

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Artisan appears to require that any external programs it is calling must
:: live under it's installation directory.  This causes problems in Windows
:: as the Program Files folder is protected from writing unless you're running
:: as an administrator.  As a result we will deploy our scripts to this folder,
:: which requires Admin privileges for the installer.  Recordings will be saved
:: under %LOCALAPPDATA% which should be writable during runtime without elevation.
::
:: The following code handles checking our privileges and elevating automatically.
:: Taken from: http://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check for permissions
if "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
  >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) else (
  >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
:: If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
  echo Requesting administrative privileges...
  goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /b

:gotAdmin
pushd "%CD%"
cd /d "%~dp0"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Pre-flight checks

:: Check for Artisan install
if not exist "%artisanDir%\artisan.exe" (
  echo FATAL: Artisan installation not found under %artisanDir%.
  echo Please install Artisan under the default folder or modify
  echo the install.cmd to provide the install location.
  echo Refer to the installation guide for details.
  echo.
  pause
  goto end
)

:: Check for Python 2.7 install
if not exist "%py27Dir%\python.exe" (
  echo FATAL: Python 2.7 installation not found under %py27Dir%.
  echo Please install Python 2.7 for Windows under the default
  echo folder.  Refer to the installation guide for details.
  echo.
  pause
  goto end
)

:: Check for installation of PyAudioAnalysis under py27Dir\scripts\PyAudioAnalysis
if not exist "%pyAudAnDir%\audioAnalysis.py" (
  echo FATAL: pyAudioAnalysis not found at "%pyAudAnDir%\audioAnalysis.py"
  echo Please install pyAudioAnalysis and required libraries.
  echo Refer to the installation guide for details.
  echo.
  pause
  goto end
)

:: Check for our install dir, if it's not there, attempt to create it
if not exist "%RoastLearnerDir%" md "%RoastLearnerDir%"
:: Check again and fail if we can't access the directory for some reason
if not exist "%RoastLearnerDir%" (
  echo FATAL: Failed to create installation directory: "%RoastLearnerDir%"
  echo.
  pause
  goto end
)

:: Check for our recording dir, if it's not there, attempt to create it
if not exist "%recordingDir%" md "%recordingDir%"
:: Check again and fail if we can't access the directory for some reason
if not exist "%recordingDir%" (
  echo FATAL: Failed to create recording directory: "%recordingDir%"
  echo.
  pause
  goto end
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Installation

:: Copy scripts to %RoastLearnerDir%
echo Installing scripts to "%RoastLearnerDir%"
xcopy "%~dp0\scripts" "%RoastLearnerDir%" /y /e /q
if errorlevel 1 (
  echo FATAL: File copy returned an error installing to: "%RoastLearnerDir%"
  echo.
  pause
  goto end
)

:: Copy recording folder structure to %recordingDir%
echo Creating recording folders in "%recordingDir%"
xcopy "%~dp0\recordings" "%recordingDir%" /y /e /q
if errorlevel 1 (
  echo FATAL: File copy returned an error installing to: "%recordingDir%"
  echo.
  pause
  goto end
)

:: Create desktop shortcut to recordings folder
set tempLnkScript="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %tempLnkScript%
echo sLinkFile = "%USERPROFILE%\Desktop\RoastLearner Recordings.lnk" >> %tempLnkScript%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %tempLnkScript%
echo oLink.TargetPath = "%WINDIR%\Explorer.exe" >> %tempLnkScript%
echo oLink.Arguments ="%recordingDir%" >> %tempLnkScript%
echo oLink.Save >> %tempLnkScript%
cscript /nologo %tempLnkScript%
del %tempLnkScript%
if not exist "%USERPROFILE%\Desktop\RoastLearner Recordings.lnk" (
  echo WARNING: Failed to create desktop shortcut to: %recordingDir%
)

:: Create shortcut to re-train the classifiers
set tempLnkScript="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %tempLnkScript%
echo sLinkFile = "%recordingDir%\Re-train Classifiers.lnk" >> %tempLnkScript%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %tempLnkScript%
echo oLink.TargetPath = "%RoastLearnerDir%\train_classifiers.cmd" >> %tempLnkScript%
echo oLink.WorkingDirectory ="%RoastLearnerDir%" >> %tempLnkScript%
echo oLink.Save >> %tempLnkScript%
cscript /nologo %tempLnkScript%
del %tempLnkScript%
if not exist "%USERPROFILE%\Desktop\RoastLearner Recordings.lnk" (
  echo WARNING: Failed to create desktop shortcut to: %recordingDir%
)

echo SUCCESS: deployed RoastLearner to "%RoastLearnerDir%"
pause
goto end

:end
