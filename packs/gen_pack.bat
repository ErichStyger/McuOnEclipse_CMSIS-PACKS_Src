REM @ECHO OFF

REM Batch File for Generating a Software Pack
REM Usage:
REM gen_pack.bat FolderName
REM e.g.
REM gen_pack.bat Utility

REM *****************
REM Copy .pdsc file to current directory
REM *****************
del .\*.pdsc
copy .\%1\*.pdsc .

REM *****************
REM   Remove any existing error log file
REM *****************
DEL /q gen_pack_err.log

REM *****************
REM   Check for a single PDSC file
REM *****************
SET count=0
FOR %%x IN (*.pdsc) DO SET /a count+=1
IF NOT "%count%"=="1" GOTO ErrPDSC

REM *****************
REM   Set name of PDSC file to be packed
REM *****************
DIR /b *.pdsc > PDSCName.txt
SET /p PDSCName=<PDSCName.txt
DEL /q PDSCName.txt

REM ************
REM   Checking
REM ************
.\PackChk.exe .\%1\%PDSCName% -n MyPackName.txt

REM ************
REM   Check if PackChk.exe has completed successfully
REM ************
IF %errorlevel% neq 0 GOTO ErrPackChk

REM ************
REM   Pipe Pack's Name into Variable
REM ************
SET /p PackName=<MyPackName.txt
DEL /q MyPackName.txt

REM ************
REM   Packing
REM ************
cd %1
"C:\Program Files\7-Zip\7z.exe" a %PackName% -tzip
MOVE %PackName% ..\
cd ..
MOVE *.pack build
MOVE *.pdsc build
GOTO End

:ErrPDSC
ECHO There is more than one PDSC file present! >> gen_pack_err.log
EXIT /b

:ErrPackChk
ECHO PackChk.exe has encountered an error! >> gen_pack_err.log
EXIT /b

:End
ECHO End of batch file.