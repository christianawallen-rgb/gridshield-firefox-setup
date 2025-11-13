<#
.SYNOPSIS
    GridShield Security - Firefox Uninstaller

.DESCRIPTION
    Avinstallerar Firefox Developer Edition och rensar GridShield-konfiguration.

    VARNING: Detta tar bort:
    - Firefox Developer Edition
    - GridShield-Security profil
    - Alla bookmarks, extensions, och inställningar
    - Desktop shortcuts

.PARAMETER KeepProfile
    Behåll Firefox-profil (ta endast bort programmet)

.PARAMETER BackupFirst
    Skapa backup innan avinstallation

.EXAMPLE
    .\Uninstall-GridShieldFirefox.ps1
    # Standard avinstallation (frågar om backup)

.EXAMPLE
    .\Uninstall-GridShieldFirefox.ps1 -BackupFirst -KeepProfile
    # Skapa backup och behåll profil

.NOTES
    Version: 1.0
    Datum: 2025-11-13
    Författare: GridShield Security
    Kräver: Administratörsrättigheter
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$KeepProfile,

    [Parameter(Mandatory=$false)]
    [switch]$BackupFirst
)

$Script:FirefoxPath = "C:\Program Files\Firefox Developer Edition"
$Script:ProfilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
$Script:ProfileName = "GridShield-Security"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $colors = @{
        Info = 'Cyan'
        Success = 'Green'
        Warning = 'Yellow'
        Error = 'Red'
    }

    Write-Host "[$Level] $Message" -ForegroundColor $colors[$Level]
}

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "  GridShield Security" -ForegroundColor Red
    Write-Host "  Firefox Uninstaller" -ForegroundColor Red
    Write-Host "  Version 1.0" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
}

function Confirm-Uninstall {
    Write-Host ""
    Write-Host "VARNING: Detta kommer att ta bort:" -ForegroundColor Red
    Write-Host "  - Firefox Developer Edition" -ForegroundColor Yellow
    if (-not $KeepProfile) {
        Write-Host "  - GridShield-Security profil" -ForegroundColor Yellow
        Write-Host "  - Alla bookmarks och extensions" -ForegroundColor Yellow
        Write-Host "  - Alla inställningar och containers" -ForegroundColor Yellow
    }
    Write-Host "  - Desktop shortcuts" -ForegroundColor Yellow
    Write-Host ""

    $response = Read-Host "Är du säker? Skriv 'YES' för att fortsätta"

    if ($response -ne 'YES') {
        Write-Log "Avinstallation avbruten" -Level Info
        exit 0
    }
}

function Backup-Profile {
    Write-Log "Skapar backup innan avinstallation..." -Level Info

    $backupScript = Join-Path $PSScriptRoot "Backup-FirefoxProfile.ps1"

    if (Test-Path $backupScript) {
        & $backupScript -IncludePasswords
        Write-Log "Backup slutförd" -Level Success
    }
    else {
        Write-Log "Backup-skript hittades inte: $backupScript" -Level Warning
        $manual = Read-Host "Fortsätt utan backup? (y/n)"
        if ($manual -ne 'y' -and $manual -ne 'Y') {
            Write-Log "Avinstallation avbruten" -Level Info
            exit 0
        }
    }
}

function Stop-Firefox {
    Write-Log "Stänger Firefox om det körs..." -Level Info

    $firefoxProcess = Get-Process -Name firefox -ErrorAction SilentlyContinue

    if ($firefoxProcess) {
        Stop-Process -Name firefox -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Log "Firefox stängt" -Level Success
    }
    else {
        Write-Log "Firefox körs inte" -Level Info
    }
}

function Uninstall-Firefox {
    Write-Log "Avinstallerar Firefox Developer Edition..." -Level Info

    # Leta efter avinstallare
    $uninstallers = @(
        "$Script:FirefoxPath\uninstall\helper.exe",
        "C:\Program Files (x86)\Firefox Developer Edition\uninstall\helper.exe"
    )

    $uninstaller = $uninstallers | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($uninstaller) {
        Write-Log "Kör avinstallare: $uninstaller" -Level Info
        Start-Process -FilePath $uninstaller -ArgumentList "/S" -Wait
        Write-Log "Firefox avinstallerat" -Level Success
    }
    else {
        Write-Log "Avinstallare hittades inte - försöker manuell borttagning" -Level Warning

        if (Test-Path $Script:FirefoxPath) {
            Remove-Item -Path $Script:FirefoxPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Firefox-mapp borttagen" -Level Success
        }
    }

    # Ta bort via winget om tillgängligt
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Log "Verifierar borttagning via winget..." -Level Info
        winget uninstall Mozilla.Firefox.DeveloperEdition --silent 2>$null
    }
}

function Remove-Profile {
    if ($KeepProfile) {
        Write-Log "Behåller Firefox-profil (--KeepProfile specificerat)" -Level Info
        return
    }

    Write-Log "Tar bort GridShield-Security profil..." -Level Info

    $profile = Get-ChildItem -Path $Script:ProfilesPath -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*$Script:ProfileName*" } |
        Select-Object -First 1

    if ($profile) {
        Remove-Item -Path $profile.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Profil borttagen: $($profile.FullName)" -Level Success
    }
    else {
        Write-Log "Profil hittades inte" -Level Warning
    }

    # Ta bort profiles.ini om inga andra profiler finns
    $profilesIni = "$env:APPDATA\Mozilla\Firefox\profiles.ini"
    if (Test-Path $profilesIni) {
        $remainingProfiles = Get-ChildItem -Path $Script:ProfilesPath -Directory -ErrorAction SilentlyContinue
        if ($remainingProfiles.Count -eq 0) {
            Remove-Item -Path $profilesIni -Force -ErrorAction SilentlyContinue
            Write-Log "profiles.ini borttagen" -Level Success
        }
    }
}

function Remove-Shortcuts {
    Write-Log "Tar bort genvägar..." -Level Info

    $shortcuts = @(
        "$env:USERPROFILE\Desktop\Firefox GridShield.lnk",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Firefox Developer Edition.lnk",
        "$env:PUBLIC\Desktop\Firefox Developer Edition.lnk"
    )

    foreach ($shortcut in $shortcuts) {
        if (Test-Path $shortcut) {
            Remove-Item -Path $shortcut -Force -ErrorAction SilentlyContinue
            Write-Log "Borttagen: $shortcut" -Level Success
        }
    }
}

function Remove-RegistryEntries {
    Write-Log "Rensar register..." -Level Info

    $registryPaths = @(
        "HKCU:\Software\Mozilla\Firefox",
        "HKLM:\SOFTWARE\Mozilla\Firefox"
    )

    foreach ($path in $registryPaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Register rensad: $path" -Level Success
        }
    }
}

function Remove-AdditionalFiles {
    Write-Log "Tar bort ytterligare filer..." -Level Info

    # Mozilla-mapp i %APPDATA% (om inga andra Mozilla-produkter)
    $mozillaPath = "$env:APPDATA\Mozilla"
    if (Test-Path $mozillaPath) {
        $firefoxPath = Join-Path $mozillaPath "Firefox"
        if (Test-Path $firefoxPath) {
            # Kontrollera om det finns andra profiler
            $otherProfiles = Get-ChildItem -Path "$firefoxPath\Profiles" -Directory -ErrorAction SilentlyContinue
            if ($otherProfiles.Count -eq 0) {
                Remove-Item -Path $firefoxPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Log "Firefox AppData-mapp borttagen" -Level Success

                # Om Mozilla-mappen är tom, ta bort den också
                if ((Get-ChildItem -Path $mozillaPath -ErrorAction SilentlyContinue).Count -eq 0) {
                    Remove-Item -Path $mozillaPath -Force -ErrorAction SilentlyContinue
                    Write-Log "Mozilla-mapp borttagen" -Level Success
                }
            }
        }
    }

    # Loggfiler
    $logPath = "$env:TEMP\GridShield-Firefox-Install.log"
    if (Test-Path $logPath) {
        Remove-Item -Path $logPath -Force -ErrorAction SilentlyContinue
        Write-Log "Loggfil borttagen" -Level Success
    }
}

function Show-Summary {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  AVINSTALLATION SLUTFÖRD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""

    Write-Log "Följande har tagits bort:" -Level Info
    Write-Host "  ✓ Firefox Developer Edition" -ForegroundColor Green

    if (-not $KeepProfile) {
        Write-Host "  ✓ GridShield-Security profil" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ Profil behållen (kan tas bort manuellt)" -ForegroundColor Yellow
        Write-Host "    Plats: $Script:ProfilesPath" -ForegroundColor Yellow
    }

    Write-Host "  ✓ Genvägar" -ForegroundColor Green
    Write-Host "  ✓ Register-entries" -ForegroundColor Green
    Write-Host ""

    Write-Log "Firefox Developer Edition är nu avinstallerat från systemet" -Level Success
    Write-Host ""
}

# Huvudprogram
function Main {
    Show-Banner

    # Bekräftelse
    Confirm-Uninstall

    # Backup om begärt
    if ($BackupFirst) {
        Backup-Profile
    }
    elseif (-not $KeepProfile) {
        Write-Host ""
        $response = Read-Host "Vill du skapa backup innan borttagning? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Backup-Profile
        }
    }

    Write-Host ""
    Write-Log "Påbörjar avinstallation..." -Level Info

    # Stäng Firefox
    Stop-Firefox

    # Avinstallera
    Uninstall-Firefox
    Remove-Profile
    Remove-Shortcuts
    Remove-RegistryEntries
    Remove-AdditionalFiles

    # Sammanfattning
    Show-Summary

    # Omstart-prompt om nödvändigt
    $response = Read-Host "Vill du starta om datorn nu? (rekommenderat) (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Log "Startar om om 10 sekunder..." -Level Warning
        Write-Log "Tryck Ctrl+C för att avbryta" -Level Warning
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

# Kör
Main
