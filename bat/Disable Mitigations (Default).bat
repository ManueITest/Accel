@echo off
setlocal

set "___args="%~f0" %*"
fltmc > nul 2>&1 || (
	powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList """/c $env:___args"""" 2> nul || (
		echo You must run this script as admin.
		if "%*"=="" pause
		exit /b 1
	)
	exit /b
)

powershell -ExecutionPolicy Bypass -Command "& $env:WinDir\RapidScripts\UtilityScripts\Control-Mitigations.ps1 -MyArgument disable_mitigations"

pause
exit /b