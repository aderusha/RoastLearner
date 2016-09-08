@echo off
setlocal
:: This script is directly called by Artisan to return external program values.
:: It collects data from various sources which drop the values in a file.
:: This allows some degree of async data collection, preventing Artisan
:: from having to wait on the individual programs actually collecting the 
:: data.
::
:: Artisan's expectations are simple.  It wants 2, 4, or 6 comma seperated values
:: each time it runs the external program script (every second? 3 seconds? frequently.)
:: To make this happen quickly, we're launching the monitors which collect the
:: data in separate processes and then drop a file to communicate results between them
:: and this script.  This script reads the files created by those other processes and
:: presents the collected values to Artisan in the way it expects.  If it can't
:: find the needed data, it'll make up a null/zero value for Artisan to digest.
::
:: An example output might look something like this:
:: 78.9,45,100,0,100,0
::
:: Access to the datafiles should be fast. If you make modifications to this script,
:: make sure they execute quickly or you'll choke Artisan up.

:: path to RoastLearner installation
set RoastLearnerDir=%~dp0

:: Set path to the data files dropped by the running classifiers.
:: DHT refers to my network humidty/temp collector project, if you don't
:: have that running it shouldn't bother anything.
set file_dhtvalues="%TEMP%\dht-values.txt"
set file_classifysvm="%TEMP%\classifysvm-values.txt"
set file_classifyknn="%TEMP%\classifyknn-values.txt"

:: Check for ambient temp and humidty readings
if exist %file_dhtvalues% for /F "tokens=1,2 usebackq delims=," %%a in (%file_dhtvalues%) do set dht_ambient=%%a&&set dht_humid=%%b
if %dht_ambient%!==! set dht_ambient=0.0
if %dht_humid%!==! set dht_humid=0.0

:: Check for data from classifysvm
if exist %file_classifysvm% for /F "tokens=1,2 usebackq delims=," %%a in (%file_classifysvm%) do set svm_environment=%%a&&set svm_firstcrack=%%b
if %svm_environment%!==! set svm_environment=0
if %svm_firstcrack%!==! set svm_firstcrack=0

:: Check for data from classifyknn
if exist %file_classifyknn% for /F "tokens=1,2 usebackq delims=," %%a in (%file_classifyknn%) do set knn_environment=%%a&&set knn_firstcrack=%%b
if %knn_environment%!==! set knn_environment=0
if %knn_firstcrack%!==! set knn_firstcrack=0

:: output collected values if we have DHT data
if exist %file_dhtvalues% echo %dht_ambient%,%dht_humid%,%svm_environment%,%svm_firstcrack%,%knn_environment%,%knn_firstcrack%

:: output collected values if we don't have DHT data
if not exist %file_dhtvalues% echo %svm_environment%,%svm_firstcrack%,%knn_environment%,%knn_firstcrack%

:end