@echo off

	:: Ensure PowerShell is available
	where PowerShell >nul 2>&1 || (
    echo PowerShell is not available. Please install or enable PowerShell.
    pause & exit 1
	)
	
	:: Checks for Admin rights and elevates to Admin if needed
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
    if '%errorlevel%' NEQ '0' (
		goto uacprompt
    ) else ( goto gotadmin )
    :uacprompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
    :gotadmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
	
	:: Initialize environment
	setlocal EnableExtensions enabledelayedexpansion
	
	:: Allow powershell scripts
	reg add "HKCU\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f >nul 2>&1
	
:: ----------------------------------------------------------
:: --------------------Disable Recall------------------------
:: ----------------------------------------------------------
echo 	Disabling Windows Recall

	:: Disable AI Data Analysis and Recall
	reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsAI" /v "AllowRecallEnablement" /t REG_DWORD /d 0 /f >nul 2>&1
	
	:: Disable Recall Feature
	Dism /Online /Disable-Feature /Featurename:Recall /NoRestart >nul 2>&1
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ------------------Disable Background Apps-----------------
:: ----------------------------------------------------------
echo 	Disabling Background Apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----------------Disable Microsoft Copilot----------------
:: ----------------------------------------------------------
echo 	Disabling Microsoft Copilot

	:: Disable Copilot button and service
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------------------Disable GameDVR---------------------
:: ----------------------------------------------------------
echo 	Disabling GameDVR
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
:: ----------------------------------------------------------


:: ----------------------------------------------------------
echo 	Removing Xbox App

	:: Uninstall 'Microsoft.GamingApp' Store app
	PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.GamingApp' | Remove-AppxPackage" >nul 2>&1
	PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.GamingApp_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }" >nul 2>&1
	PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Xbox.TCUI' | Remove-AppxPackage" >nul 2>&1
	PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.XboxGamingOverlay' | Remove-AppxPackage" >nul 2>&1
	PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.XboxGameOverlay' | Remove-AppxPackage" >nul 2>&1
	PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.XboxIdentityProvider' | Remove-AppxPackage" >nul 2>&1
	:: Mark 'Microsoft.GamingApp' as deprovisioned to block reinstall during Windows updates.
	:: Create "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.GamingApp_8wekyb3d8bbwe" registry key

echo 	Removing Game Bar
	:: Uninstall 'Microsoft.XboxGamingOverlay' Store app
	PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.XboxGamingOverlay' | Remove-AppxPackage"
	:: Mark 'Microsoft.XboxGamingOverlay' as deprovisioned to block reinstall during Windows updates.
	:: Create "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGamingOverlay_8wekyb3d8bbwe" registry key
	PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGamingOverlay_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }" >nul 2>&1
	:: Uninstall 'Microsoft.XboxGameOverlay' Store app
	PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.XboxGameOverlay' | Remove-AppxPackage"
	:: Mark 'Microsoft.XboxGameOverlay' as deprovisioned to block reinstall during Windows updates.
	:: Create "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGameOverlay_8wekyb3d8bbwe" registry key
	PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGameOverlay_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }" >nul 2>&1
echo 	Removing UWP Apps
	:: Remove UWP apps except Store & Notepad
	PowerShell -NoProfile -Command "Get-AppxPackage -AllUsers | Where-Object {$_.Name -notlike '*Microsoft.WindowsNotepad*' -and $_.Name -notlike '*Microsoft.WindowsStore*' -and $_.Name -notlike '*NVIDIA*' -and $_.Name -notlike '*CBS*'} | Remove-AppxPackage -ErrorAction SilentlyContinue"
	
echo 	Disabling Optional Features
PowerShell -NoProfile -Command "$bloat = @('App.StepsRecorder~~~~0.0.1.0','App.Support.QuickAssist~~~~0.0.1.0','Browser.InternetExplorer~~~~0.0.11.0','Hello.Face.18967~~~~0.0.1.0','Hello.Face.20134~~~~0.0.1.0','MathRecognizer~~~~0.0.1.0','Media.WindowsMediaPlayer~~~~0.0.12.0','Microsoft.Wallpapers.Extended~~~~0.0.1.0','Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0','Microsoft.Windows.WordPad~~~~0.0.1.0','OneCoreUAP.OneSync~~~~0.0.1.0','OpenSSH.Client~~~~0.0.1.0','Print.Fax.Scan~~~~0.0.1.0','Print.Management.Console~~~~0.0.1.0','WMIC~~~~','Windows.Kernel.LA57~~~~0.0.1.0'); $bloat | ForEach-Object {Remove-WindowsCapability -Online -Name $_ -ErrorAction SilentlyContinue}" >nul 2>&1

echo 	Removing Legacy Features
	for %%F in (
		"WCF-Services45"
		"WCF-TCP-PortSharing45"
		"MediaPlayback"
		"Printing-PrintToPDFServices-Features"
		"Printing-XPSServices-Features"
		"Printing-Foundation-Features"
		"Printing-Foundation-InternetPrinting-Client"
		"MSRDC-Infrastructure"
		"SMB1Protocol"
		"SMB1Protocol-Client"
		"SMB1Protocol-Deprecation"
		"SmbDirect"
		"Windows-Identity-Foundation"
		"MicrosoftWindowsPowerShellV2Root"
		"MicrosoftWindowsPowerShellV2"
		"WorkFolders-Client"
	) do (
		Dism /Online /NoRestart /Disable-Feature /FeatureName:%%F >nul 2>&1
	)
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------------Remove Remote Desktop------------------
:: ----------------------------------------------------------
echo 	Removing Remote Desktop

	:: Disable the Remote Desktop features and remove the added firewall rules
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f >nul 2>&1
	netsh advfirewall firewall set rule group="remote desktop" new enable=No >nul 2>&1
	:: Set the registry value: "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance!fAllowToGetHelp"
	PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance'; $data =  '0'; reg add 'HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance' /v 'fAllowToGetHelp' /t 'REG_DWORD' /d "^""$data"^"" /f" >nul 2>&1
	:: Set the registry value: "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance!fAllowFullControl"
	PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance'; $data =  '0'; reg add 'HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance' /v 'fAllowFullControl' /t 'REG_DWORD' /d "^""$data"^"" /f" >nul 2>&1
	:: Set the registry value: "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services!AllowBasic"
	PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; $data =  '0'; reg add 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' /v 'AllowBasic' /t 'REG_DWORD' /d "^""$data"^"" /f" >nul 2>&1
	:: Mute system sounds using PowerShell
	PowerShell -Command "Add-Type -TypeDefinition \$('using System.Runtime.InteropServices; public class Audio { [DllImport(\"winmm.dll\")] public static extern int waveOutSetVolume(IntPtr hwo, uint dwVolume); }'); [Audio]::waveOutSetVolume([IntPtr]::Zero, 0)" >nul 2>&1

	:: Silent uninstall sequence
::	start /B mstsc.exe /Uninstall >nul 2>&1
::	timeout /t 10 /nobreak >nul 2>&1

	:: Kill processes
::	taskkill /F /IM mstsc.exe >nul 2>&1
::	taskkill /F /IM WindowsUpdate.exe >nul 2>&1
::	taskkill /F /IM wuauclt.exe >nul 2>&1

	:: Restore sound
::	PowerShell -Command "[Audio]::waveOutSetVolume([IntPtr]::Zero, 0xFFFF)" >nul 2>&1

	:: Self-destruct if needed (optional)
	:: del "%~f0" >nul 2>&1
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------------------Remove OneDrive---------------------
:: ----------------------------------------------------------	
echo 	Removing OneDrive

	taskkill /F /IM OneDrive.exe >nul 2>&1
	timeout /t 1 /nobreak >nul
	if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
		"%SystemRoot%\SysWOW64\OneDriveSetup.exe" -uninstall -quiet
	)
	if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
		"%SystemRoot%\System32\OneDriveSetup.exe" -uninstall -quiet
	)
	PowerShell -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*OneDrive*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue" >nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------------Reinstall Microsoft Store-----------------
:: ----------------------------------------------------------	
echo 	Reinstalling Microsoft Store

	:: Reinstall Microsoft Store
	PowerShell -Command "Get-AppxPackage -AllUsers *Microsoft.WindowsStore* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\" -ErrorAction SilentlyContinue}" >nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Microsoft Text Input Application-------------
:: ----------------------------------------------------------
@REM echo 	Renaming Microsoft Text Input Application

	:: Kill the process
	taskkill /IM TextInputHost.exe /F /T >nul 2>&1

	:: Find CBS directory
	set "target_dir="
	for /d %%i in ("C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_*") do (
		set "target_dir=%%i"
	)

	if not defined target_dir goto :continue

	:: Take ownership and grant permissions
	takeown /f "%target_dir%\TextInputHost.exe" >nul 2>&1
	icacls "%target_dir%\TextInputHost.exe" /grant:r *S-1-5-32-544:F /inheritance:r >nul 2>&1

	:: Rename the executable
	ren "%target_dir%\TextInputHost.exe" "TextInputHost.ee" >nul 2>&1
:: ----------------------------------------------------------	


:: ----------------------------------------------------------
:: -----------------------Remove Edge------------------------
:: ----------------------------------------------------------
echo 	Uninstalling Edge

:: Download setup.exe from Repo
:: Check download / HASH
:: Remove Edge
:: Remove Extras
:: Remove APPX

:: #Admin Permissions
net session >NUL 2>&1 || (echo. & echo Run Script As Admin & echo. & pause)
title Edge Remover - 2/18/2025
set "expected=4963532e63884a66ecee0386475ee423ae7f7af8a6c6d160cf1237d085adf05e"

set "onHashErr=download"

set "fileSetup=%~dp0setup.exe"
if exist "%fileSetup%" goto file_check;
set "fileSetup=%tmp%\setup.exe"
if exist "%fileSetup%" goto file_check;

:file_download
set "onHashErr=error"
ipconfig | find "IPv" >NUL
if %errorlevel% neq 0 echo. & echo You are not connected to a network ! & echo. & pause

:: Downloading Required File
powershell -Command "try { (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ShadowWhisperer/Remove-MS-Edge/main/_Source/setup.exe', '%fileSetup%') } catch { Write-Host 'Error downloading the file.' }"
if not exist "%fileSetup%" echo File download failed. Check your internet connection & echo & pause

:file_check
powershell -Command "exit ((Get-FileHash '%fileSetup%' -Algorithm SHA256).Hash.ToLower() -ne '%expected%')"
if %errorlevel% neq 0 goto file_%onHashErr%
echo. & goto uninst_edge

:file_error
echo 	File hash does not match the expected value. & echo & pause


:: #Edge
:uninst_edge
:: Removing Edge
where /q "%ProgramFiles(x86)%\Microsoft\Edge\Application:*"
if %errorlevel% equ 0 start /w "" "%fileSetup%" --uninstall --system-level --force-uninstall


:: #WebView
:uninst_wv
:: Removing WebView
where /q "%ProgramFiles(x86)%\Microsoft\EdgeWebView\Application:*"
if %errorlevel% neq 0 goto cleanup_wv_junk
start /w "" "%fileSetup%" --uninstall --msedgewebview --system-level --force-uninstall
:: Delete empty folders
:cleanup_wv_junk
:: rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeWebView" >NUL 2>&1
for /f "delims=" %%d in ('dir /ad /b /s "%ProgramFiles(x86)%\Microsoft\EdgeWebView" 2^>NUL ^| sort /r') do rd "%%d" 2>NUL


:: #Additional Files

:: Desktop icon
:users_cleanup
:: Removing Additional Files

set "REG_USERS_PATH=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
for /f "skip=2 tokens=2*" %%c in ('reg query "%REG_USERS_PATH%" /v Public') do ( call :user_rem_lnks_by_path %%d )
for /f "skip=2 tokens=2*" %%c in ('reg query "%REG_USERS_PATH%" /v Default') do ( call :user_rem_lnks_by_path %%d )
for /f "skip=1 tokens=7 delims=\" %%k in ('reg query "%REG_USERS_PATH%" /k /f "*"') do ( call :user_rem_lnks_by_sid %%k )
goto users_done

:user_rem_lnks_by_sid
if "%1"=="S-1-5-18" goto user_end
if "%1"=="S-1-5-19" goto user_end
if "%1"=="S-1-5-20" goto user_end
for /f "skip=2 tokens=2*" %%c in ('reg query "%REG_USERS_PATH%\%1" /v ProfileImagePath') do (
	call :user_rem_lnks_by_path %%d
	if "%UserProfile%"=="%%d" set "USER_SID=%1"
)
goto user_end

:user_rem_lnks_by_path
del /s /q "%1\Desktop\edge.lnk" >NUL 2>&1
del /s /q "%1\Desktop\Microsoft Edge.lnk" >NUL 2>&1

:user_end
timeout 4 >nul 2>&1

:users_done

:: System32
if exist "%SystemRoot%\System32\MicrosoftEdgeCP.exe" (
for /f "delims=" %%a in ('dir /b "%SystemRoot%\System32\MicrosoftEdge*"') do (
 takeown /f "%SystemRoot%\System32\%%a" >NUL 2>&1
 icacls "%SystemRoot%\System32\%%a" /inheritance:e /grant "%UserName%:(OI)(CI)F" /T /C >NUL 2>&1
 del /S /Q "%SystemRoot%\System32\%%a" >NUL 2>&1))

:: Folders
taskkill /im MicrosoftEdgeUpdate.exe /f >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\Edge" >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeCore" >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeUpdate" >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\Temp" >NUL 2>&1
rd /s /q "%AllUsersProfile%\Microsoft\EdgeUpdate" >NUL 2>&1

:: Files
del /s /q "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" >NUL 2>&1

:: Registry
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}" /f >NUL 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Edge" /f >NUL 2>&1

:: Tasks - Files
for /r "%SystemRoot%\System32\Tasks" %%f in (*MicrosoftEdge*) do del "%%f" >NUL 2>&1

:: Tasks - Name
for /f "skip=1 tokens=1 delims=," %%a in ('schtasks /query /fo csv') do (
for %%b in (%%a) do (
 if "%%b"=="MicrosoftEdge" schtasks /delete /tn "%%~a" /f >NUL 2>&1))

:: Update Services
set "service_names=edgeupdate edgeupdatem"
for %%n in (%service_names%) do (
 sc stop %%n >NUL 2>&1
 sc delete %%n >NUL 2>&1
 reg delete "HKLM\SYSTEM\CurrentControlSet\Services\%%n" /f >NUL 2>&1
)


:: #APPX
:: Removing APPX

if defined USER_SID goto rem_appX
for /f "delims=" %%a in ('powershell "(New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%a"

:rem_appX
set "REG_APPX_STORE=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore"
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like '*microsoftedge*' } | Select-Object -ExpandProperty PackageFullName"') do (
    if not "%%a"=="" (
        reg add "%REG_APPX_STORE%\EndOfLife\%USER_SID%\%%a" /f >NUL 2>&1
        reg add "%REG_APPX_STORE%\EndOfLife\S-1-5-18\%%a" /f >NUL 2>&1
        reg add "%REG_APPX_STORE%\Deprovisioned\%%a" /f >NUL 2>&1
        powershell -Command "Remove-AppxPackage -Package '%%a'" 2>NUL
        powershell -Command "Remove-AppxPackage -Package '%%a' -AllUsers" 2>NUL
    )
)

:: %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*
for /d %%d in ("%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*") do (
 takeown /f "%%d" /r /d y >NUL 2>&1
 icacls "%%d" /grant administrators:F /t >NUL 2>&1
 rd /s /q "%%d" >NUL 2>&1)
:: ----------------------------------------------------------


echo 	Restarting Explorer to Apply Changes
taskkill /f /im explorer.exe >nul
start explorer.exe >nul
pause
exit