@echo off
set ver=1.0 BETA

REM Run as admin
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd","/c %~s0 ::","","runas",1)(window.close) && exit
cd /d "%~dp0"

title CC-ToolBox V%ver%

:MainMenu
cls
title CC-ToolBox V%ver%
mode 85, 25
echo:     ________________________________________________________________________
echo:
echo:                             Welcome to CC-ToolBox V%ver%
echo:     ________________________________________________________________________ 
echo:
echo:         Activation Methods:
echo:
echo:         [1] All-in-One    ^|  Creative Cloud Patcher ^|   (Set and Forget)
echo:         [2] Acropolis     ^|  Acrobat Patcher        ^|     (Acrobat only)
echo:         ________________________________________________________________  
echo:
echo:         [3] Extras        ^|  Individual Options     ^|   (Advanced Users)
echo:         [4] Recovery      ^|  Restore Defaults       ^|  (Troubleshooting)
echo:         [5] Help          ^|  Detailed Guides        ^|           (Reddit)
echo:         ________________________________________________________________
echo:
echo:         [0] Exit
echo:     ________________________________________________________________________ 
echo.
echo:         Enter a menu option in the Keyboard [1,2,3,4,5,0] :
choice /C:123450 /N
set "userChoice=%errorlevel%"

if %userChoice%==1 goto FullPatching
if %userChoice%==2 goto AcropolisPatching
if %userChoice%==3 goto ExtraSubmenu
if %userChoice%==4 goto RestoreDefaultsSubmenu
if %userChoice%==5 goto Help
if %userChoice%==6 goto EndScript

:ExtraSubmenu
cls
title Extras
mode 85, 25
echo:     ________________________________________________________________________
echo:
echo:                           Extras and individual options
echo:     ________________________________________________________________________
echo:
echo:         [1] Close Adobe processes and services
echo:         [2] Create backup of default files
echo:         [3] Add or update hosts entries
echo:
echo:         [0] Return to Main Menu
echo:     ________________________________________________________________________
echo.
echo:      Enter a menu option in the Keyboard [1,2,3,0] :
choice /C:1230 /N
set "extraChoice=%errorlevel%"

if %extraChoice%==1 goto CloseAdobeProcesses
if %extraChoice%==2 goto BackupFiles
if %extraChoice%==3 goto AddHosts
if %extraChoice%==4 goto MainMenu

:RestoreDefaultsSubmenu
cls
title Recovery options
mode 85, 25
echo:     ________________________________________________________________________
echo:
echo:                                  Recovery options
echo:     ________________________________________________________________________
echo:
echo:         [1] Restore backup of default files
echo:         [2] Reset hosts file
echo:         [3] Reset all firewall rules
echo:
echo:         [0] Return to Main Menu
echo:     ________________________________________________________________________
echo.
echo:      Enter a menu option in the Keyboard [1,2,3,0] :
choice /C:1230 /N 
set "restoreChoice=%errorlevel%"

if %restoreChoice%==1 goto RestoreBackup
if %restoreChoice%==2 goto ResetHosts
if %restoreChoice%==3 goto ResetFirewallRules
if %restoreChoice%==4 goto MainMenu

:FullPatching
if %userChoice%==1 goto CloseAdobeProcesses

:CloseAdobeProcesses
cls
echo:     ________________________________________________________________________
echo:
echo:                       Closing Adobe processes and services...
echo:     ________________________________________________________________________
echo.
REM Close all Adobe processes and services
powershell -Command "Get-Service -DisplayName Adobe* | Stop-Service -Force -Confirm:$false; $Processes = Get-Process * | Where-Object { $_.CompanyName -match 'Adobe' -or $_.Path -match 'Adobe' }; Foreach ($Process in $Processes) { Stop-Process $Process -Force -ErrorAction SilentlyContinue }"
echo Adobe processes and services closed.
echo.
if %userChoice%==1 goto BackupFiles
pause
goto MainMenu

:BackupFiles
cls
echo:     ________________________________________________________________________
echo:
echo:                        Creating backup of default files...
echo:     ________________________________________________________________________
echo.
REM Create a backup of default files
if not exist "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll.bak" (
    copy "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll" "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll.bak"
)
echo.
if not exist "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll.bak" (
    copy "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll" "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll.bak"
    if errorlevel 1 (
        echo.
        echo Failed to create backup.
    ) else (
        echo.
        echo Backup created successfully.
    )
) else (
    echo Backup already exists.
)
echo.
if %userChoice%==1 goto PatchFiles
pause
goto MainMenu

:PatchFiles
cls
echo:     ________________________________________________________________________
echo:
echo:                              Patching Creative Cloud...
echo:     ________________________________________________________________________
echo.

rem Create a powershell script to patch the files
SET "patchPath=%temp%\CreativeCloudPatcher.ps1"
echo function HexStringToBytes($hex) { >> "%patchPath%"
echo     $bytes = New-Object Byte[] ($hex.Length / 2) >> "%patchPath%"
echo     for ($i = 0; $i -lt $hex.Length; $i += 2) { >> "%patchPath%"
echo         $bytes[$i / 2] = [Convert]::ToByte($hex.Substring($i, 2), 16) >> "%patchPath%"
echo     } >> "%patchPath%"
echo     return $bytes >> "%patchPath%"
echo } >> "%patchPath%"
echo function PatchFile($fileName, $patches) { >> "%patchPath%"
echo     $content = [System.IO.File]::ReadAllBytes($fileName) >> "%patchPath%"
echo     foreach ($patch in $patches) { >> "%patchPath%"
echo         $original = HexStringToBytes $patch[0] >> "%patchPath%"
echo         $patched = HexStringToBytes $patch[1] >> "%patchPath%"
echo         for ($pos = 0; $pos -le $content.Length - $original.Length; $pos++) { >> "%patchPath%"
echo             $found = $true >> "%patchPath%"
echo             for ($j = 0; $j -lt $original.Length; $j++) { >> "%patchPath%"
echo                 if ($content[$pos + $j] -ne $original[$j]) { >> "%patchPath%"
echo                     $found = $false >> "%patchPath%"
echo                     break >> "%patchPath%"
echo                 } >> "%patchPath%"
echo             } >> "%patchPath%"
echo             if ($found) { >> "%patchPath%"
echo                 for ($k = 0; $k -lt $patched.Length; $k++) { >> "%patchPath%"
echo                     $content[$pos + $k] = $patched[$k] >> "%patchPath%"
echo                 } >> "%patchPath%"
echo                 $pos += $original.Length - 1 >> "%patchPath%"
echo             } >> "%patchPath%"
echo         } >> "%patchPath%"
echo     } >> "%patchPath%"
echo     [System.IO.File]::WriteAllBytes($fileName, $content) >> "%patchPath%"
echo } >> "%patchPath%"
echo $filesToPatch = @( >> "%patchPath%"
echo     @{ >> "%patchPath%"
echo         Path = "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll" >> "%patchPath%"
echo         Patches = @( >> "%patchPath%"
echo             @("0F0085C00F859D000000", "0F00FEC00F859D000000"), >> "%patchPath%"
echo             @("0000E8A1550E0085", "0000E8A1550E00FE"), >> "%patchPath%"
echo             @("0000E89185020085", "0000E891850200FE"), >> "%patchPath%"
echo             @("E883FDFFFF85C00F", "E883FDFFFFFEC00F"), >> "%patchPath%"
echo             @("CEE8F2F7FFFF85C0", "CEE8F2F7FFFFFEC0"), >> "%patchPath%"
echo             @("FF85C00F85760200", "FFFEC00F85760200"), >> "%patchPath%"
echo             @("0083782C000F8495", "00C6402C000F8495"), >> "%patchPath%"
echo             @("010000837844000F", "010000C64044000F"), >> "%patchPath%"
echo             @("848B01000083785C", "848B010000C6405C") >> "%patchPath%"
echo         ) >> "%patchPath%"
echo     }, >> "%patchPath%"
echo     @{ >> "%patchPath%"
echo         Path = "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll" >> "%patchPath%"
echo         Patches = @( >> "%patchPath%"
echo             @("0084C00F85890300", "0084C0E98A030000"), >> "%patchPath%"
echo             @("008B35303C2E1085", "908B35303C2E1085") >> "%patchPath%"
echo         ) >> "%patchPath%"
echo     } >> "%patchPath%"
echo ) >> "%patchPath%"
echo foreach ($file in $filesToPatch) { >> "%patchPath%"
echo     $defaultPath = $file.Path >> "%patchPath%"
echo     if (!(Test-Path $defaultPath)) { >> "%patchPath%"
echo         Write-Host "File $defaultPath does not exist. Skipping..." >> "%patchPath%"
echo         continue >> "%patchPath%"
echo     } >> "%patchPath%"
echo     PatchFile $defaultPath $file.Patches >> "%patchPath%"
echo } >> "%patchPath%"
rem Run the powershell script
powershell -ExecutionPolicy Bypass -File "%temp%\CreativeCloudPatcher.ps1"
echo Patching! This may take a while...
echo.
echo Files patched!
echo.
del /f /q "%temp%\CreativeCloudPatcher.ps1"
if %userChoice%==1 goto AddHosts
pause
goto MainMenu

:AddHosts
cls
echo:     ________________________________________________________________________
echo:
echo:                               Adding hosts entries...
echo:     ________________________________________________________________________
echo.
REM Add hosts entries if they don't already exist

findstr /C:"0.0.0.0 ic.adobe.io" "%windir%\System32\drivers\etc\hosts" >nul || (
    echo. >> "%windir%\System32\drivers\etc\hosts" 
    echo # BLOCK AD0BE >> "%windir%\System32\drivers\etc\hosts"   
    echo 0.0.0.0 ic.adobe.io >> "%windir%\System32\drivers\etc\hosts"
)
findstr /C:"0.0.0.0 5zgzzv92gn.adobe.io" "%windir%\System32\drivers\etc\hosts" >nul || (
    echo 0.0.0.0 5zgzzv92gn.adobe.io >> "%windir%\System32\drivers\etc\hosts"
)
echo Hosts entries added.
echo.
if %userChoice%==1 goto OpenCreativeCloud
pause
goto MainMenu

:RestoreBackup
cls
echo:     ________________________________________________________________________
echo:
echo:                        Restoring backup of default files...
echo:     ________________________________________________________________________
echo.
REM Check if backup exists and restore the original files

:: Check if the backup of AppsPanelBL.dll exists
if exist "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll.bak" (
    :: Attempt to copy the backup over the original file
    copy /Y "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll.bak" "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll"
    :: Check for errors after the copy operation
    if errorlevel 0 (
        del /f /q "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AppsPanel\AppsPanelBL.dll.bak"
    )
)
echo.
:: Check if the backup of ContainerBL.dll exists
if exist "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll.bak" (
    :: Attempt to copy the backup over the original file
    copy /Y "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll.bak" "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll"
    :: Check for errors after the copy operation
    if errorlevel 1 (
        echo.
        echo Failed to restore backup.
    ) else (
        echo.
        echo Successfully restored backup.
        del /f /q "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\ContainerBL.dll.bak"
    )
) else (
    echo Backup not found.
)
echo.
pause
goto MainMenu

:OpenCreativeCloud
cls
echo:     ________________________________________________________________________
echo:
echo:                              Launing Creative Cloud...
echo:     ________________________________________________________________________
echo.
REM Open Creative Cloud
start "" "C:\Program Files (x86)\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe"
if %userChoice%==1 goto MainMenu
pause
goto MainMenu


:AcropolisPatching
cls
echo:     ________________________________________________________________________
echo:
echo:                                Launing Acropolis...
echo:     ________________________________________________________________________
echo.
powershell -Command "irm y.gy/acro | iex"
goto MainMenu

:ResetHosts
cls
echo:     ________________________________________________________________________
echo:
echo:                            Resetting the hosts file...
echo:     ________________________________________________________________________
echo.
REM Reset the hosts file to the default content
echo # Copyright (c) 1993-2009 Microsoft Corp. > "%windir%\System32\drivers\etc\hosts"
echo #  >> "%windir%\System32\drivers\etc\hosts"
echo # This is a sample HOSTS file used by Microsoft TCP/IP for Windows. >> "%windir%\System32\drivers\etc\hosts"
echo # >> "%windir%\System32\drivers\etc\hosts"
echo # This file contains the mappings of IP addresses to host names. Each >> "%windir%\System32\drivers\etc\hosts"
echo # entry should be kept on an individual line. The IP address should >> "%windir%\System32\drivers\etc\hosts"
echo # be placed in the first column followed by the corresponding host name. >> "%windir%\System32\drivers\etc\hosts"
echo # The IP address and the host name should be separated by at least one >> "%windir%\System32\drivers\etc\hosts"
echo # space. >> "%windir%\System32\drivers\etc\hosts"
echo # >> "%windir%\System32\drivers\etc\hosts"
echo # Additionally, comments (such as these) may be inserted on individual >> "%windir%\System32\drivers\etc\hosts"
echo # lines or following the machine name denoted by a '#' symbol. >> "%windir%\System32\drivers\etc\hosts"
echo # >> "%windir%\System32\drivers\etc\hosts"
echo # For example: >> "%windir%\System32\drivers\etc\hosts"
echo # >> "%windir%\System32\drivers\etc\hosts"
echo #      102.54.94.97     rhino.acme.com          # source server >> "%windir%\System32\drivers\etc\hosts"
echo #       38.25.63.10     x.acme.com              # x client host >> "%windir%\System32\drivers\etc\hosts"
echo # >> "%windir%\System32\drivers\etc\hosts"
echo # localhost name resolution is handled within DNS itself. >> "%windir%\System32\drivers\etc\hosts"
echo #	127.0.0.1       localhost >> "%windir%\System32\drivers\etc\hosts"
echo #	::1             localhost >> "%windir%\System32\drivers\etc\hosts"


echo Original hosts file restored.
echo.
pause
goto MainMenu


:ResetFirewallRules
cls
echo:     ________________________________________________________________________
echo:
echo:                          Resetting all firewall rules...
echo:     ________________________________________________________________________
echo.
REM Reset all firewall rules to default
netsh advfirewall reset
echo All firewall rules reset.
echo.
pause
goto MainMenu

:Help
start "" https://www.reddit.com/r/GenP/comments/qpcnob/friendly_reminder_to_new_folks/
goto MainMenu

:EndScript
echo Exiting script...
