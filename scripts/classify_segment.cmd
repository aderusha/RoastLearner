@echo off
:: feed classifier(s) the most recent segment in a loop for classification
:: USEAGE: classify_segment ^<knn|svm^> ^<recording path^>
setlocal

:: check to see if we've been given all of our args
if %2!==! (
  echo FATAL: not enough arguments
  echo USEAGE: %~n0 ^<knn^|svm^> ^<recording path^>
  goto end
)

:: check for a valid classifier
set classifier=%1
if not %classifier%==knn if not %classifier%==svm (
  echo FATAL: unknown classifier: %classifier%
  echo USEAGE: %~n0% ^<knn^|svm^> ^<recording path^>
  goto end
)

:: this script is called via a "start" command, which itself has an annoying
:: bug when passing parameters that contain quotes.  As a result, any file paths
:: handed to this script might be unquoted, and thus handled as a series of parameters
:: after %2.  This will collapse %2-%* into a single value.
shift
set recording_folder=%1
:recfolderloop
shift
if %1!==! goto recfolderdone
set recording_folder=%recording_folder% %1
goto recfolderloop
:recfolderdone

:: Now we have a folder path that may or may not contain quotes.  This breaks other
:: things, so remove those quotes if they exist.
set recording_folder=###%recording_folder%###
set recording_folder=%recording_folder:"###=%
set recording_folder=%recording_folder:###"=%
set recording_folder=%recording_folder:###=%

:: check for a valid recording folder
if not exist "%recording_folder%" (
  echo FATAL: recording path not found: "%recording_folder%"
  echo USEAGE: %~n0% ^<knn^|svm^> ^<recording path^>
  goto end
)

:: Define the minimum size for a recorded chunk.
set recording_size=88244

:: path to RoastLearner installation
set RoastLearnerDir=%~dp0

:: define our output file
set file_classifyout=%TEMP%\classify%classifier%-values.txt

set py27dir=C:\Python27

:: Check for default installation of Python 2.7
set py27exe=%py27dir%\python.exe
if not exist "%py27exe%" (
  echo FATAL: Python 2.7 interpreter not found at "%py27exe%".
  echo Please install Python 2.7 for Windows under the default
  echo folder.  Refer to the installation guide for details.
  goto end
)

:: Check for installation of PyAudioAnalysis under py27dir\scripts\PyAudioAnalysis
set pyAudioAnalysis=%py27dir%\Scripts\pyAudioAnalysis
if not exist "%pyAudioAnalysis%\audioAnalysis.py" (
  echo FATAL: AudioAnalysis not found at "%pyAudioAnalysis%\audioAnalysis.py"
  echo Please install pyAudioAnalysis and required libraries.
  echo Refer to the installation guide for details.
  goto end
)

:: Check to confirm we have a trained model available
set TrainedClassifier=%LOCALAPPDATA%\RoastLearner\classifiers\RoastLearner%classifier%
if not exist "%TrainedClassifier%" (
  echo FATAL: Trained classifier not found at "%TrainedClassifier%"
  echo Please run Train_Classifiers.cmd to train the classifiers.
  goto end
)

:: Create a temp filename to capture program output, check if it exists
:: try again if it does, then create it to prevent another instance from
:: stepping on it.
:gen_TempOutFile
set TempOutFile=%TEMP%\%classifier%-%RANDOM%-%TIME:~6,5%.tmp
if exist "%TempOutFile%" GOTO :gen_TempOutFile
type NUL>"%TempOutFile%"

:: Create a temp filename to copy recording input, check if it exists
:: try again if it does, then create it to prevent another instance from
:: stepping on it.
:gen_TempInFile
set TempInFile=%TEMP%\%classifier%-%RANDOM%-%TIME:~6,5%.wav
if exist "%TempInFile%" GOTO :gen_TempInFile
type NUL>"%TempInFile%"

:: set this to a dummy value
set last_recentfile=$$notafilename

:: now change drive/path to our recording folder
pushd %recording_folder%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: monitor the recording directory for new files
:loop_recentfile
:: check if we have any files ready yet
if not exist *.wav goto loop_recentfile
:: find the most recent file in our folder greater than or equal to %recording_size%
for /f "tokens=*" %%a in ('dir /b /od *.wav') do if %%~za GEQ %recording_size% set new_recentfile=%%a
:: if we have a new file and it's the right size, classify it.
if not "%new_recentfile%"=="%last_recentfile%" goto classifyfile
:: otherwise, check again
goto loop_recentfile

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: We've caught a new file with the right size, run it against our classifier
:classifyfile
set last_recentfile=%new_recentfile%

:: copy the new file to our %TempInFile% to prevent file read conflict between multiple running classifiers
copy /y "%new_recentfile%" "%TempInFile%">NUL

echo Classifying file %new_recentfile%

"%py27exe%" "%pyAudioAnalysis%\audioAnalysis.py" classifyFile -i "%TempInFile%" --model %classifier% --classifier "%TrainedClassifier%">"%TempOutFile%"

type "%TempOutFile%"
for /f "tokens=1,2" %%y in ('findstr /R "^environment" %TempOutFile%') do set class_environment=%%z
for /f "tokens=1,2" %%y in ('findstr /R "^firstcrack" %TempOutFile%') do set class_firstcrack=%%z
echo Recording environment: %class_environment%
echo Recording firstcrack: %class_firstcrack%

echo %class_environment%,%class_firstcrack%>"%file_classifyout%"
type NUL>"%TempOutFile%"
goto loop_recentfile

:end
popd