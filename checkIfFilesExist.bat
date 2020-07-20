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
rem dir /B doesn't list heading, file sizes, or summary
FOR /F "delims=" %%G IN ('dir /B %stagingUnprocessedFolder%') DO (
	SET fileName=%%G
	
	rem Search for this file ("fileName") in the variable folderToSearchForExisting
	rem This will list the contents of the folderToSearch folder and all subfolders, then use other operations to truncate it so that it only contains a list of matching filenames
	rem For example, if the fileName is test.exe, and that file shows up in the list, the output of this command will just be a truncated list of each occurrence of test.exe
	SET search="dir /B /S !folderToSearchForExisting!"!fileName!" | findstr "!fileName!" | find /i /c /v "" "
		rem dir /S includes subfolders
		rem dir /B doesn't list heading, file sizes, or summary; otherwise that would get included in the count of matching strings, which is bad!
		rem find /i makes it case insensitive
		rem find /c counts the number of lines
		rem find /v "" makes sure that empty lines (whitespace) are filtered out (?)
		rem The last find "" is just for syntax purposes; we're not actually finding anything at this point, we're just using the find command to clean up and count the results
		
	rem Need to set a variable that contains file size, and that needs to be compared as well, to make sure that two files are actually the same
	
	rem This is for testing purposes. Run script, look at output in dir.txt.
	rem dir /B /S !folderToSearchForExisting!"!fileName!" | findstr "!fileName!" | find /i /c /v "">>dir.txt
	
	rem For testing
	rem dir /B !stagingUnprocessedFolder!>>dir.txt
	
	rem Then, we iterate through each line in the search list
	rem The variable X contains the count, i.e. the number of items in the list that match fileName, which will necessarily be each line due to our search constraint above. So really this is just counting the number of lines!
	rem The "/F" is for reading text
	rem "Tokens" is a way to keep count
	FOR /F "tokens=*" %%i IN (' !search! ') DO SET X=%%i
	rem echo X: !X!
	IF !X! GEQ 2 (
		echo Probable duplicate, moving file to duplicates folder - !fileName!
		rem MOVE /-Y !stagingUnprocessedFolder!!fileName! !stagingProbableDuplicatesFolder!
		rem What if the current file being processed already exists in 00 Duplicates?
	) ELSE (
		echo Probable unique OR not in folderToSearch, NOT MOVING - !fileName!
	)
	rem Should we rewrite this to also consider file size? If fileName matches, and fileSize matches, THEN move the file as needed.

)
pause