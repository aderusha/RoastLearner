@echo off
:: Launch a SoX recording of audio from the default recording device
:: and launch script(s) to classify recorded data
setlocal

:: path to RoastLearner installation
set RoastLearnerDir=%~dp0

:: path to sox executable
set SoXpath=%RoastLearnerDir%SoX\sox.exe
if not exist "%SoXpath%" echo FATAL: SoX.exe not found at "%SoXpath%".  Exiting. && pause && goto end
:: base path to save recordings
set WAVpath=%LOCALAPPDATA%\RoastLearner\recordings
if not exist "%WAVpath%" echo FATAL: Recordings folder not found at "%WAVpath%".  Exiting. && pause && goto end
:: recording slice size in seconds
set RecSlice=1

:: Clear out result files if they are still around
set file_classifysvm="%TEMP%\classifysvm-values.txt"
set file_classifyknn="%TEMP%\classifyknn-values.txt"
if exist %file_classifysvm% del %file_classifysvm%
if exist %file_classifyknn% del %file_classifyknn%

:: Each recording session will need to be saved in its own folder.
:: Generate a timestamp in a format similar to Artisan and create the new folder
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set WAVfile=recording_%date:~-2,2%-%date:~-10,2%-%date:~-7,2%_%hr%%time:~3,2%
set SessionWAVpath=%WAVpath%\%WAVfile%
md "%SessionWAVpath%"
if not exist "%SessionWAVpath%" echo FATAL: Could not create session folder "%SessionWAVpath%".  Exiting. && pause && goto end

:: Launch SoX to start recording to our target dir
start "Recording audio to %SessionWAVpath%" /MIN "%SoXpath%" --channels 1 --rate 44100 --bits 16 --type waveaudio default "%SessionWAVpath%\%WAVfile%-%%4n.wav" trim 0 %RecSlice% : newfile : restart

:: Launch background scripts to classify recorded data
:: note that the %SessionWAVpath% cannot be quoted or it'll break the stupid start command
start "KNN Classifier Process" /MIN "%RoastLearnerDir%classify_segment.cmd" knn %SessionWAVpath%
start "SVM Classifier Process" /MIN "%RoastLearnerDir%classify_segment.cmd" svm %SessionWAVpath%

:end