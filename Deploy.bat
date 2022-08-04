:: Deploy script for Unit2NS
::
:: This script compiles release versions of the 64 and 32 bit versions of
:: Unit2NS and places then into zip files ready for release.
::
:: This script uses MSBuild and Zip.exe

:: To use the script:
::   1) Start the Embarcadero RAD Studio Command Prompt to set the
::      required environment variables for MSBuild.
::   2) Set the ZIPROOT environment variable to the directory where zip.exe is
::      installed.
::   3) Change directory to the that where this script is located.
::   4) Run the script
::
:: Usage:
::   Deploy <version>
:: where
::  <version> is the version number of the release, e.g. 0.5.3-beta or 1.2.0

@echo off

echo -------------------------
echo Deploying Unit2NS Release
echo -------------------------

:: Check for required parameter
if "%1"=="" goto paramerror

:: Check for required environment variables
if "%ZipRoot%"=="" goto envvarerror

:: Set variables
set Version=%1
set BuildRoot=.\_build
set BuildExeRoot=%BuildRoot%\exe
set Win32Dir=%BuildExeRoot%\Win32\Release
set Win64Dir=%BuildExeRoot%\Win64\Release
set ReleaseDir=%BuildRoot%\release
set OutFile32=%ReleaseDir%\unit2ns-32bit-%Version%.zip
set OutFile64=%ReleaseDir%\unit2ns-64bit-%Version%.zip
set DocsDir=docs
set SrcDir=src

:: Make a clean directory structure
if exist %BuildRoot% rmdir /S /Q %BuildRoot%
mkdir %BuildExeRoot%
mkdir %BuildExeRoot%\Win32
mkdir %Win32Dir%
mkdir %BuildExeRoot%\Win64
mkdir %Win64Dir%
mkdir %ReleaseDir%

setlocal

:: Build Pascal
cd %SrcDir%

echo.
echo Building 32 bit version
echo.
msbuild Unit2NS.dproj /p:config=Release /p:platform=Win32
echo.

echo.
echo Building 64 bit version
echo.
msbuild Unit2NS.dproj /p:config=Release /p:platform=Win64
echo.

endlocal

:: Rename exe files as 32 and 64 bit
setlocal
cd %Win32Dir%
ren Unit2NS.exe Unit2NS32.exe
endlocal

setlocal
cd %Win64Dir%
ren Unit2NS.exe Unit2NS64.exe
endlocal

:: Create zip files
echo.
echo Creating zip files
%ZipRoot%\zip.exe -j -9 %OutFile32% %Win32Dir%\Unit2NS32.exe
%ZipRoot%\zip.exe -j -9 %OutFile64% %Win64Dir%\Unit2NS64.exe
%ZipRoot%\zip.exe -j -9 %OutFile32% %DocsDir%\README.txt
%ZipRoot%\zip.exe -j -9 %OutFile64% %DocsDir%\README.txt

echo.
echo ---------------
echo Build completed
echo ---------------

goto end

:: Error messages

:paramerror
echo.
echo ***ERROR: Please specify a version number as a parameter
echo.
goto end

:envvarerror
echo.
echo ***ERROR: ZipRoot environment variable not set
echo.
goto end

:: End
:end
