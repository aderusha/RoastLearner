@echo off
:: train classifiers with supervised data in class folders
setlocal disableDelayedExpansion

:: path to RoastLearner installation
set RoastLearnerDir=%~dp0
:: path to Python executable
set py27dir=C:\Python27
:: Path to recordings
set recordingDir=%LOCALAPPDATA%\RoastLearner

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

:: Check for classified recordings folders
if not exist "%recordingDir%\classified_recordings\*" (
  echo FATAL: Could not find any class folders under "%recordingDir%\classified_recordings"
  goto end
)

pushd "%recordingDir%\classifiers"

:: Check to see if we have an existing trained model and back it up if so
if not exist RoastLearner* goto train_classifiers

:: check to see if our backup folder exists, make it if not
if not exist "trained_classifier_backup" md "trained_classifier_backup"
if not exist "trained_classifier_backup" echo FATAL: failed to create folder "trained_classifier_backup" && goto end

:: create a new incremental backup folder 
for /L %%v in (1,1,9999) do if not exist "trained_classifier_backup\backup_%%v" set backup_folder=trained_classifier_backup\backup_%%v && goto create_backup_folder
:create_backup_folder
md "%backup_folder%"
if not exist "%backup_folder%" echo FATAL: failed to create folder "%backup_folder%" && goto end

move RoastLearnerSVM*.* "%backup_folder%"
move RoastLearnerKNN*.* "%backup_folder%"

:train_classifiers
set class_list=
for /D %%z in ("..\classified_recordings"\*) do call set class_list=%%class_list%% "..\classified_recordings\%%z"

%py27exe% "%pyAudioAnalysis%\audioAnalysis.py" trainClassifier -i %class_list% --method svm -o RoastLearnerSVM
%py27exe% "%pyAudioAnalysis%\audioAnalysis.py" trainClassifier -i %class_list% --method knn -o RoastLearnerKNN

if not exist "RoastLearnerSVM" (
  echo FATAL: Failed to create SVM classifier.  Exiting.
  echo.
  pause
  goto end
)
if not exist "RoastLearnerKNN" (
  echo FATAL: Failed to create KNN classifier.  Exiting.
  echo.
  pause
  goto end
)

echo SUCCESS: Classifiers trained against classified recordings
pause
goto end

:end
popd