<#
.SYNOPSIS
    GridShield Security - Firefox Profile Backup Script

.DESCRIPTION
    Skapar en säkerhetskopia av din Firefox-profil inklusive:
    - Bookmarks
    - Passwords (krypterade)
    - Extensions
    - Containers
    - User preferences

.PARAMETER BackupPath
    Destination för backup (default: Documents\GridShield-Backups)

.PARAMETER ProfileName
    Namn på Firefox-profil att backa upp (default: GridShield-Security)

.PARAMETER IncludePasswords
    Inkludera lösenord i backup (default: false för säkerhet)

.EXAMPLE
    .\Backup-FirefoxProfile.ps1
    # Standard backup

.EXAMPLE
    .\Backup-FirefoxProfile.ps1 -BackupPath "D:\Backups" -IncludePasswords
    # Backup till annan plats, inkludera lösenord

.NOTES
    Version: 1.0
    Datum: 2025-11-13
    Författare: GridShield Security
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = "$env:USERPROFILE\Documents\GridShield-Backups",

    [Parameter(Mandatory=$false)]
    [string]$ProfileName = "GridShield-Security",

    [Parameter(Mandatory=$false)]
    [switch]$IncludePasswords
)

# Färger för output
$Script:Colors = @{
    Info = 'Cyan'
    Success = 'Green'
    Warning = 'Yellow'
    Error = 'Red'
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = $Script:Colors[$Level]
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  GridShield Security" -ForegroundColor Cyan
    Write-Host "  Firefox Profile Backup" -ForegroundColor Cyan
    Write-Host "  Version 1.0" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Find-FirefoxProfile {
    param([string]$ProfileName)

    Write-Log "Söker efter Firefox-profil: $ProfileName" -Level Info

    $profilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"

    if (-not (Test-Path $profilesPath)) {
        Write-Log "Firefox profiles-mapp hittades inte: $profilesPath" -Level Error
        return $null
    }

    $profile = Get-ChildItem -Path $profilesPath -Directory |
        Where-Object { $_.Name -like "*$ProfileName*" } |
        Select-Object -First 1

    if ($profile) {
        Write-Log "Profil hittad: $($profile.FullName)" -Level Success
        return $profile.FullName
    }
    else {
        Write-Log "Profil '$ProfileName' hittades inte" -Level Error
        Write-Log "Tillgängliga profiler:" -Level Info
        Get-ChildItem -Path $profilesPath -Directory | ForEach-Object {
            Write-Host "  - $($_.Name)" -ForegroundColor Yellow
        }
        return $null
    }
}

function New-BackupDirectory {
    param([string]$Path)

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupDir = Join-Path $Path "Firefox-Backup_$timestamp"

    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Write-Log "Backup-katalog skapad: $backupDir" -Level Success
    }

    return $backupDir
}

function Backup-ProfileFiles {
    param(
        [string]$ProfilePath,
        [string]$BackupDir,
        [bool]$IncludePasswords
    )

    Write-Log "Skapar backup av profilfilar..." -Level Info

    # Viktiga filer att backa upp
    $filesToBackup = @(
        "places.sqlite",           # Bookmarks och history
        "favicons.sqlite",         # Favicons
        "permissions.sqlite",      # Site permissions
        "content-prefs.sqlite",    # Content preferences
        "formhistory.sqlite",      # Form history
        "cookies.sqlite",          # Cookies
        "prefs.js",                # User preferences
        "user.js",                 # Custom preferences (GridShield config)
        "handlers.json",           # Protocol handlers
        "search.json.mozlz4",      # Search engines
        "containers.json",         # Multi-Account Containers (om finns)
        "extension-settings.json"  # Extension settings
    )

    if ($IncludePasswords) {
        Write-Log "Inkluderar lösenord (krypterade)" -Level Warning
        $filesToBackup += @(
            "key4.db",             # Master password key
            "logins.json"          # Passwords (encrypted)
        )
    }
    else {
        Write-Log "Hoppar över lösenord (använd -IncludePasswords för att inkludera)" -Level Info
    }

    $backedUpCount = 0

    foreach ($file in $filesToBackup) {
        $sourcePath = Join-Path $ProfilePath $file
        if (Test-Path $sourcePath) {
            $destPath = Join-Path $BackupDir $file
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            Write-Log "  ✓ $file" -Level Success
            $backedUpCount++
        }
        else {
            Write-Log "  ⚠ $file (inte funnen)" -Level Warning
        }
    }

    Write-Log "Backade upp $backedUpCount filer" -Level Success
}

function Backup-Extensions {
    param(
        [string]$ProfilePath,
        [string]$BackupDir
    )

    Write-Log "Skapar backup av extensions..." -Level Info

    $extensionsPath = Join-Path $ProfilePath "extensions"

    if (Test-Path $extensionsPath) {
        $destExtensionsPath = Join-Path $BackupDir "extensions"
        Copy-Item -Path $extensionsPath -Destination $destExtensionsPath -Recurse -Force

        $extensionCount = (Get-ChildItem $extensionsPath | Measure-Object).Count
        Write-Log "Backade upp $extensionCount extensions" -Level Success
    }
    else {
        Write-Log "Inga extensions hittades" -Level Warning
    }
}

function Backup-ChromeFolder {
    param(
        [string]$ProfilePath,
        [string]$BackupDir
    )

    Write-Log "Skapar backup av chrome-mapp (userChrome.css, etc.)..." -Level Info

    $chromePath = Join-Path $ProfilePath "chrome"

    if (Test-Path $chromePath) {
        $destChromePath = Join-Path $BackupDir "chrome"
        Copy-Item -Path $chromePath -Destination $destChromePath -Recurse -Force
        Write-Log "Chrome-mapp backad" -Level Success
    }
    else {
        Write-Log "Chrome-mapp inte funnen" -Level Warning
    }
}

function Export-Metadata {
    param(
        [string]$BackupDir,
        [string]$ProfilePath
    )

    Write-Log "Exporterar metadata..." -Level Info

    $metadata = @{
        BackupDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ProfilePath = $ProfilePath
        ProfileName = $ProfileName
        WindowsVersion = (Get-CimInstance Win32_OperatingSystem).Caption
        FirefoxVersion = (Get-ItemProperty -Path "C:\Program Files\Firefox Developer Edition\firefox.exe" -ErrorAction SilentlyContinue).VersionInfo.FileVersion
        IncludedPasswords = $IncludePasswords.IsPresent
        BackupBy = $env:USERNAME
        ComputerName = $env:COMPUTERNAME
    }

    $metadataPath = Join-Path $BackupDir "backup-metadata.json"
    $metadata | ConvertTo-Json | Set-Content -Path $metadataPath

    Write-Log "Metadata exporterad" -Level Success
}

function Show-BackupSummary {
    param([string]$BackupDir)

    $backupSize = (Get-ChildItem -Path $BackupDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    $backupSizeFormatted = "{0:N2} MB" -f $backupSize

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  BACKUP SLUTFÖRD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Log "Backup-plats: $BackupDir" -Level Info
    Write-Log "Backup-storlek: $backupSizeFormatted" -Level Info
    Write-Host ""
    Write-Log "Vad som backades upp:" -Level Info
    Write-Host "  ✓ Bookmarks och history" -ForegroundColor Green
    Write-Host "  ✓ User preferences (prefs.js, user.js)" -ForegroundColor Green
    Write-Host "  ✓ Extensions och deras inställningar" -ForegroundColor Green
    Write-Host "  ✓ Containers-konfiguration" -ForegroundColor Green
    Write-Host "  ✓ Site permissions" -ForegroundColor Green
    Write-Host "  ✓ Chrome-anpassningar (userChrome.css)" -ForegroundColor Green

    if ($IncludePasswords) {
        Write-Host "  ✓ Lösenord (krypterade)" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ Lösenord EJ inkluderade" -ForegroundColor Yellow
        Write-Host "    (Använd -IncludePasswords för att inkludera)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Log "För att återställa backup:" -Level Info
    Write-Host "  .\Restore-FirefoxProfile.ps1 -BackupPath '$BackupDir'" -ForegroundColor Cyan
    Write-Host ""
}

# Huvudprogram
function Main {
    Show-Banner

    Write-Log "Startar backup av Firefox-profil" -Level Info
    Write-Log "Profil: $ProfileName" -Level Info
    Write-Log "Destination: $BackupPath" -Level Info
    Write-Host ""

    # Stäng Firefox om det körs
    $firefoxProcess = Get-Process -Name firefox -ErrorAction SilentlyContinue
    if ($firefoxProcess) {
        Write-Log "Firefox körs - måste stängas för säker backup" -Level Warning
        $response = Read-Host "Stäng Firefox nu? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Stop-Process -Name firefox -Force
            Start-Sleep -Seconds 2
            Write-Log "Firefox stängt" -Level Success
        }
        else {
            Write-Log "Backup avbruten" -Level Error
            exit 1
        }
    }

    # Hitta profil
    $profilePath = Find-FirefoxProfile -ProfileName $ProfileName
    if (-not $profilePath) {
        Write-Log "Kunde inte hitta profil - avbryter" -Level Error
        exit 1
    }

    # Skapa backup-katalog
    $backupDir = New-BackupDirectory -Path $BackupPath

    # Backup
    Backup-ProfileFiles -ProfilePath $profilePath -BackupDir $backupDir -IncludePasswords $IncludePasswords.IsPresent
    Backup-Extensions -ProfilePath $profilePath -BackupDir $backupDir
    Backup-ChromeFolder -ProfilePath $profilePath -BackupDir $backupDir
    Export-Metadata -BackupDir $backupDir -ProfilePath $profilePath

    # Komprimera backup (valfritt)
    Write-Host ""
    $response = Read-Host "Vill du komprimera backup till .zip? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Log "Komprimerar backup..." -Level Info
        $zipPath = "$backupDir.zip"
        Compress-Archive -Path $backupDir -DestinationPath $zipPath -Force
        Write-Log "Backup komprimerad: $zipPath" -Level Success

        $removeOriginal = Read-Host "Ta bort okomprimerad backup? (y/n)"
        if ($removeOriginal -eq 'y' -or $removeOriginal -eq 'Y') {
            Remove-Item -Path $backupDir -Recurse -Force
            Write-Log "Okomprimerad backup borttagen" -Level Success
            $backupDir = $zipPath
        }
    }

    # Sammanfattning
    Show-BackupSummary -BackupDir $backupDir
}

# Kör
Main
