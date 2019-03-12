@echo off

REM Import the contents of a Katalon project into another Katalon project 

echo ######################################################################################
echo # Katalon Project Updater                                                            #
echo # v1.0                                                                               #
echo #                                                                                    #
echo # This will update a Katalon project with the latest keywords, test cases,           #
echo # profiles, objects and listeners from another Katalon project.                      #
echo ######################################################################################
echo.

setlocal
cd /d %~dp0

set src_dir=%~dp0..
set target_dir=""

echo Enter the location of your target Katalon project (e.g. c:\code\katalon_sample):
set /p target_dir=

echo.

if exist %target_dir% (
    echo Updates will be applied to the Katalon project in %target_dir% using the project in %src_dir%
    echo.
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Update.ps1' -SrcDir '%src_dir%' -TargetDir '%target_dir%'"
) ELSE (
    echo The directory you entered does not exist
)

pause