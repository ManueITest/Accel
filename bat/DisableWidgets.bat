@echo off
:: This batch file disables unnecessary widgets

:: Disable News and Interests
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f

:: Disable Widgets
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f

:: Notify the user
echo Unnecessary widgets have been disabled.

pause
