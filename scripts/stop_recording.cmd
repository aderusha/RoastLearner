@echo off
:: stop audio recording and classifier engines
setlocal

:: Kill running processes
taskkill /IM cmd.exe /FI "WINDOWTITLE eq KNN Classifier Process*"
taskkill /IM cmd.exe /FI "WINDOWTITLE eq SVM Classifier Process*"
taskkill /IM sox.exe /FI "WINDOWTITLE eq Recording audio to*"

:: Clear out remaining files
set file_classifysvm="%TEMP%\classifysvm-values.txt"
set file_classifyknn="%TEMP%\classifyknn-values.txt"
if exist %file_classifysvm% del %file_classifysvm%
if exist %file_classifyknn% del %file_classifyknn%