<#
Released under MIT License

Copyright (c) 2023 Brandon J. Navarro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# Version 202308

<# 
    To run create LogUtil.bat file
        powershell.exe -excutionpolicy bypass -file "C:\FILE\PATH\TO\LogUtil.ps1"

    To run with Task Schedular
        Action:
            Start a Program
            Program/Script: cmd.exe
            Arguments: c/ start "" "C:\FILE\PATH\TO\LogUtil.bat"
#>

# Set Backup Path
$BackupPath = " "

# Get Domain and Computer Information (Basic)
$UserDomain = $ENV:USERDOMAIN
$UserName = $ENV:USERNAME
$Hostname = $ENV:COMPUTERNAME

<#
    # Convert Hostname to Site Node Number
    $Site = $Hostname.Substring(0,4)

    # Pull .ini file to determine backup location
    $Lines = Get-Content -path "\\DOMAIN\sysvol\DOMAIN\LogUtil\LogUtil.ini"
    foreach ( $Line in $Lines) {
        if ($Line -Match "^DEFAULT\:") {
            $SaveLine = $Line
        }
        if ( $Line -match "^$Site\:") {
            $SaveLine = $Line
        }
    }

    # Example .ini file
        # Default site
        Default:\\FilePath\FileShare$

        # Other Site
        Site:\\FilePath\FileShare$

    # Split the .ini entry to determine file path for backup
    $BackupPath = $SaveLine.Split(":")[1]
#>

# Get date
$Date = Get-Date -Format "yyyy-MM-dd"

# Get Distinguished Name for Computer and Convert it to a Destination Folder
$DN = (Get-ItemProperty -Path "REGISTARY:: HKLM\SOFWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine")."Distinguished-Name"
$A = $DN -split (",DC=")
$B = $A[0] -split (",")
[array]::Reverse($B)
$MyFolder = $null

foreach ( $C in $B ) {
    if ( $C -match "^OU=") {
        $C = $C -replace ("OU=","")
        $C = $C -replace ( " ","_")
        $MyFolder += "\"
    }
}

$MyFolder = $MyFolder.Trim("\\")
$DestinationFolder = ( $BackupPath + "\EventLogs" + $Date + "\" + $MyFolder).Trim("Servers")

$LocalBackupPath = "C:\Logs"

$logs = "Application","Security","System"

# Backup Function
function Backup_Logs ([string] $LogType) {
    $Error.Clear()
    Write-Host "Processing Log: $LogType" -ForegroundColor Yellow

    # Create Backup Directory
    $DTG = Get-Date -Format "yyyy-MM-dd-HH-mm-ss-XXX"
    $NewName = "$HostName-" + $Log + "-" + $DTG
    $NewName = $NewName -replace (" ","_")
    $LogPath = $LocalBackupPath + "\" + $NewName + ".evtx"

    try {
        $Log = gwmi win32_nteventlogfile -Filter "logfilename = '$LogType'" -ErrorAction SilentlyContinue
    } catch {
        $Log = $null
    }

    # Backup logs to "C:\Logs"
    if ($Log -like "*") {
        $LogStatus = $Log.BackupEventLog($LogPath)
        if ($LogStatus.ReturnValue -ne 0) {
            $Message = "Backup of $LogType log failed"
            Write-Host $Message -BackgroundColor Green -ForegroundColor Red
            Write-EventLog -LogName "Application" -Source "LogUtil" -EventId 350 -Message $Message -EntryType Error
        }
    } else {
        $Message = "Unable to retrieve $LogType log."
        Write-Host $Message -ForegroundColor Red
        Write-EventLog -LogName "Application" -Source "LogUtil" -EventId 350 -Message $Message -EntryType Error
    }
}

# Priamary Script #

# Backup logs
if ((Test-Path -Path $LocalBackupPath) -eq $ture) {
    foreach ($Log in $Logs) {
        Backup_Logs ($Log)
    }
} else {
    $Message = "Cannot Find Log Archive Folder: $LocalBackupPath"
    Write-host $Message -ForegroundColor Red -BackgroundColor Black
    Write-EventLog -LogName "Application" -Source "LogUtil" -EntryType 327 -Message $Message -EntryType Error
}

# Find and move Archived Old Logs to "C:\Logs"
$OldFiles = Get-ChildItem "$ENV:SYSTEMROOT\System32\WinEvt\Logs\Archive*.evtx"
if ($OldFiles) {
    foreach ($Files in $OldFiles) {
        $Name = $File.name
        $NewArchive = $Name -replace ("Archive",$Hostname)
        Write-Host "Moving $File to 'n $LocalBackupPath\$NewArchive" -ForegroundColor Green
        Move-Item -Path $File.FullName -Destination $LocalBackupPath\$NewArchive
    }
} else {
    Write-Host "Moving any archived EVTX files from $ENV:SYSTEMROOT\System32\WinEvt\Logs" -ForegroundColor Yellow
}

# Creat the Directory and Move files to NetApp
try {
    New-Item -Path $DestinationFolder -ItemType Directory -ErrorAction SilentlyContinue
} catch {
    Write-Host "Destination folder already Exsist" -ForegroundColor Yellow
}
$LogFiles = Get-ChildItem $LocalBackupPath
foreach ($Item in $LogFiles){
    if (Test-Path ("$DestinationFolder" + "\" + "$($Item.name)")) {
        Write-Host "Removing $($Item.name)" -ForegroundColor Yellow
        Remove-Item -Path ("$($LocalBackupPath)" + "\" + "$($Item.name)")
    } else {
        Write-Host "Moving $($Item.name) to Netapp"
        Move-Item -Path ("$($LocalBackupPath)" + "\" + "$($Item.name)") -Destination "$DestinationFolder"
        Write-EventLog -LogName "Application" -Source "LogUtil" -EventId 327 -Message "Moved the following logs to the Netapp: $($Item.name)" -EntryType Information
    }
}
