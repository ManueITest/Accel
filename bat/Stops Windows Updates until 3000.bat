@echo off
setlocal EnableDelayedExpansion
color 0B
title Stop Windows Update Until 3000

:: ----------------------------------------------------------
:: -------Pause Windows Update until max allowed date--------
:: ----------------------------------------------------------	
echo 	Pausing Windows Updates until 1/1/3000

	:: Stop services
	net stop wuauserv >nul 2>&1
	net stop bits >nul 2>&1
	net stop dosvc >nul 2>&1
	:: Set date (ISO 8601 format)
	set "PAUSE_EXPIRY=3000-01-01T12:00:00Z" >nul 2>&1
	set "PAUSE_START=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%T00:00:00Z" >nul 2>&1
	:: Configure settings
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseUpdatesExpiryTime /t REG_SZ /d "%PAUSE_EXPIRY%" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseUpdatesStartTime /t REG_SZ /d "%PAUSE_START%" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesStartTime /t REG_SZ /d "%PAUSE_START%" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesEndTime /t REG_SZ /d "%PAUSE_EXPIRY%" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesStartTime /t REG_SZ /d "%PAUSE_START%" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesEndTime /t REG_SZ /d "%PAUSE_EXPIRY%" /f >nul 2>&1
:: ----------------------------------------------------------
