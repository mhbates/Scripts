@echo off

rem We need this set to use variables within for loops
SETLOCAL ENABLEDELAYEDEXPANSION

rem Set folder locations here
rem Must include following backslash at the end of the folder path
SET stagingUnprocessedFolder=""
SET stagingProbableDuplicatesFolder=""
SET folderToSearchForExisting=""

rem For each file in Unprocessed folder, search for it and move to appropriate subfolder
rem If duplicate, put in duplicates folder; if not, put in uniques folder
FOR /F "delims=" %%G IN ('dir /b %stagingUnprocessedFolder%') DO (
	SET fileName=%%G

	rem Search for this file ("fileName") in the variable folderToSearchForExisting
	rem This will list the contents of the folderToSearch folder and all subfolders, then use other operations to truncate it so that it only contains a list of matching filenames
	rem For example, if the fileName is test.exe, and that file shows up in the list, the output of this command will just be a truncated list of each occurrence of test.exe
	SET search="dir /S !folderToSearchForExisting!"!fileName!" | findstr "!fileName!" | find /c /v "" "
	
	rem Then, we iterate through each line in the search list
	rem The variable X contains the count, i.e. the number of items in the list that match fileName, which will necessarily be each line due to our search constraint above. So really this is just counting the number of lines!
	rem The "/F" is for reading text
	rem "Tokens" is a way to keep count
	FOR /F "tokens=*" %%i IN (' !search! ') DO SET X=%%i
	IF !X! GEQ 2 (
		echo Probable duplicate, moving file to duplicates folder - !fileName!
		MOVE /-Y !stagingUnprocessedFolder!!fileName! !stagingProbableDuplicatesFolder!
	) ELSE (
		echo Probable unique OR not in folderToSearch, NOT MOVING - !fileName!
	)
	rem Should we rewrite this to also consider file size? If fileName matches, and fileSize matches, THEN move the file as needed.
)
pause