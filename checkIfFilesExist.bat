@echo off

rem We need this set to use variables within for loops
SETLOCAL ENABLEDELAYEDEXPANSION

rem Set folder locations here
rem Must include following backslash at the end of the folder path
SET stagingUnprocessedFolder=""
SET stagingProbableDuplicatesFolder=""
SET stagingProbableUniquesFolder=""
SET folderToSearchForExisting=""

rem For each file in Unprocessed folder, search for it and move to appropriate subfolder
rem If duplicate, put in duplicates folder; if not, put in uniques folder
FOR /F %%G IN ('dir /b %stagingUnprocessedFolder%') DO (
	SET fileName=%%G
	SET search="dir /S !folderToSearchForExisting!!fileName! | findstr !fileName! | find /c /v "" "
	FOR /F "tokens=*" %%i IN (' !search! ') DO SET X=%%i
	IF !X! GEQ 2 (
		echo Probable duplicate, moving file to duplicates folder - !fileName!
		MOVE /-Y !stagingUnprocessedFolder!!fileName! !stagingProbableDuplicatesFolder!
	)
	ELSE (
		echo Probable unique, moving file to uniques folder - !fileName!
		MOVE /-Y !stagingUnprocessedFolder!!fileName! !stagingProbableUniquesFolder!
	)
)
pause