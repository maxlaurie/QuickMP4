:: QuickMP4 v1.0
:: Converts MOVs to MP4s and downmixes the input audio to stereo
:: May take other video files but results will vary

@echo off

TITLE QuickMP4 v1.0

echo                            ,,
echo   .g8""8q.                 db        `7MM      `7MMM.     ,MMF'`7MM"""Mq.
echo .dP'    `YM.                           MM        MMMb    dPMM    MM   `MM.
echo dM'      `MM `7MM  `7MM  `7MM  ,p6"bo  MM  ,MP'  M YM   ,M MM    MM   ,M9 ,AM
echo MM        MM   MM    MM    MM 6M'  OO  MM ;Y     M  Mb  M' MM    MMmmdM9 AVMM
echo MM.      ,MP   MM    MM    MM 8M       MM;Mm     M  YM.P'  MM    MM    ,W' MM
echo `Mb.    ,dP'   MM    MM    MM YM.    , MM `Mb.   M  `YM'   MM    MM  ,W'   MM
echo   `"bmmd"'     `Mbod"YML..JMML.YMbmd'.JMML. YA..JML. `'  .JMML..JMML.AmmmmmMMmm
echo       MMb                                                                  MM
echo        `bood'                                            v1.0              MM
echo                                                          Max Laurie
echo:

:: Set ffprobe and ffmpeg binary locations
set "ffprobe=C:\bin\ffmpeg\bin\ffprobe.exe "
set "ffmpeg=C:\bin\ffmpeg\bin\ffmpeg.exe "

:: Loop through files provided
for %%n in ( %* ) do call:MainLoop %%n
echo:
echo   _   _        _ 
echo  ^| \ / \ ^|\ ^| ^|_ 
echo  ^|_/ \_/ ^| \^| ^|_ 
echo:                           
echo Press (the) any key to quit...
pause >nul
EXIT /B

:MainLoop
:: Set file info variables
set driveLetter=%~d1
set filePath=%~p1
set basename=%~n1
set extension=%~x1

:: Check if file is compatiable
set compatiableExtensions=.mov .MOV .mxf .MXF
set compatiability=FALSE
for %%a in ( %compatiableExtensions% ) do (
	if %extension% EQU %%a set compatiability=TRUE)

:: Skip file if not compatiable
if %compatiability% EQU FALSE (
	echo:
	echo Incorrect format - %basename%%extension%
	echo This tool accepts .mov and .mxf files only
	goto:eof )

:: Tell the user we're processing
echo:                               
echo Processing - %basename%%extension%

:: Set input/output names
set "fullPathToFile=%driveLetter%%filePath%%basename%%extension%"
set "outputFile=%driveLetter%%filePath%%basename%.mp4"

:: Get no of audio tracks
for /f %%i in ('""%ffprobe%" "%fullPathToFile%" -v error -select_streams a -show_entries stream^=index -of csv^=p^=0"') do set noOfAudioTracks=%%i

:: Do the conversion
cmd /c ""%ffmpeg%" -v quiet -stats -y -i "%fullPathToFile%" -filter_complex "[0:a]amerge=inputs=%noOfAudioTracks% [a]" -ac 2 -map 0:v -map "[a]" -vcodec libx264 -crf 15 -vf format=yuv420p -acodec aac -b:a 256k "%outputFile%""

goto:eof