<#
.SYNOPSIS
    GridShield Security - Firefox Developer Edition Automated Installer

.DESCRIPTION
    Detta skript automatiserar installation och konfiguration av Firefox Developer Edition
    med säkerhetshärdning för GridShield Security's cybersäkerhetsarbete.

.PARAMETER SkipFirefoxInstall
    Hoppa över Firefox-installation (om redan installerat)

.PARAMETER SkipWSL
    Hoppa över WSL2/Kali Linux-installation

.PARAMETER ConfigureOnly
    Kör endast konfiguration (ingen installation)

.EXAMPLE
    .\Install-GridShieldFirefox.ps1
    # Fullständig installation

.EXAMPLE
    .\Install-GridShieldFirefox.ps1 -ConfigureOnly
    # Endast konfiguration

.NOTES
    Version: 1.0
    Datum: 2025-11-13
    Författare: GridShield Security
    Kräver: Windows 11 Pro, PowerShell 5.1+, Administratörsrättigheter
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipFirefoxInstall,

    [Parameter(Mandatory=$false)]
    [switch]$SkipWSL,

    [Parameter(Mandatory=$false)]
    [switch]$ConfigureOnly
)

#Requires -RunAsAdministrator

# ============================================================================
# GLOBAL VARIABLER
# ============================================================================

$Script:LogFile = "$env:TEMP\GridShield-Firefox-Install.log"
$Script:FirefoxPath = "C:\Program Files\Firefox Developer Edition"
$Script:FirefoxExe = "$FirefoxPath\firefox.exe"
$Script:ProfileName = "GridShield-Security"
$Script:DownloadPath = "$env:USERPROFILE\Downloads"

# ============================================================================
# HJÄLPFUNKTIONER
# ============================================================================

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    # Färgkodning
    $color = switch ($Level) {
        'INFO'    { 'White' }
        'WARNING' { 'Yellow' }
        'ERROR'   { 'Red' }
        'SUCCESS' { 'Green' }
    }

    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $Script:LogFile -Value $logMessage
}

function Test-InternetConnection {
    Write-Log "Testar internetanslutning..." -Level INFO
    try {
        $null = Test-Connection -ComputerName "8.8.8.8" -Count 1 -ErrorAction Stop
        Write-Log "Internetanslutning OK" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Ingen internetanslutning - vissa funktioner kan misslyckas" -Level WARNING
        return $false
    }
}

function Install-Winget {
    Write-Log "Kontrollerar om winget är installerat..." -Level INFO

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Log "winget redan installerat" -Level SUCCESS
        return $true
    }

    Write-Log "Installerar winget (Windows Package Manager)..." -Level INFO
    try {
        # Installera App Installer (innehåller winget)
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" `
            -OutFile "$env:TEMP\AppInstaller.msixbundle"

        Add-AppxPackage -Path "$env:TEMP\AppInstaller.msixbundle"
        Write-Log "winget installerat" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Misslyckades att installera winget: $_" -Level ERROR
        return $false
    }
}

# ============================================================================
# INSTALLATIONSFUNKTIONER
# ============================================================================

function Install-FirefoxDeveloperEdition {
    Write-Log "============================================" -Level INFO
    Write-Log "Installerar Firefox Developer Edition" -Level INFO
    Write-Log "============================================" -Level INFO

    if (Test-Path $Script:FirefoxExe) {
        Write-Log "Firefox Developer Edition redan installerat i $Script:FirefoxPath" -Level SUCCESS
        return $true
    }

    Write-Log "Laddar ner Firefox Developer Edition..." -Level INFO

    try {
        # Använd winget om tillgängligt
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Log "Installerar via winget..." -Level INFO
            winget install Mozilla.Firefox.DeveloperEdition --silent --accept-source-agreements --accept-package-agreements
        }
        else {
            # Manuell nedladdning
            $downloadUrl = "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=win64&lang=en-US"
            $installerPath = "$env:TEMP\FirefoxDeveloperEdition.exe"

            Write-Log "Laddar ner från Mozilla..." -Level INFO
            $progressPreference = 'silentlyContinue'
            Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

            Write-Log "Kör installer..." -Level INFO
            Start-Process -FilePath $installerPath -ArgumentList "/S", "/InstallDirectoryPath=`"$Script:FirefoxPath`"" -Wait
        }

        # Verifiera installation
        if (Test-Path $Script:FirefoxExe) {
            Write-Log "Firefox Developer Edition installerat" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "Installation misslyckades - Firefox.exe hittades inte" -Level ERROR
            return $false
        }
    }
    catch {
        Write-Log "Fel vid installation: $_" -Level ERROR
        return $false
    }
}

function Install-GitForWindows {
    Write-Log "============================================" -Level INFO
    Write-Log "Installerar Git for Windows" -Level INFO
    Write-Log "============================================" -Level INFO

    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Log "Git redan installerat" -Level SUCCESS
        return $true
    }

    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Log "Installerar Git via winget..." -Level INFO
            winget install Git.Git --silent --accept-source-agreements --accept-package-agreements
            Write-Log "Git installerat" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "winget saknas - hoppar över Git-installation" -Level WARNING
            Write-Log "Installera manuellt från: https://git-scm.com/download/win" -Level INFO
            return $false
        }
    }
    catch {
        Write-Log "Fel vid Git-installation: $_" -Level ERROR
        return $false
    }
}

function Install-WindowsTerminal {
    Write-Log "============================================" -Level INFO
    Write-Log "Installerar Windows Terminal" -Level INFO
    Write-Log "============================================" -Level INFO

    if (Get-Command wt -ErrorAction SilentlyContinue) {
        Write-Log "Windows Terminal redan installerat" -Level SUCCESS
        return $true
    }

    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Log "Installerar Windows Terminal via winget..." -Level INFO
            winget install Microsoft.WindowsTerminal --silent --accept-source-agreements --accept-package-agreements
            Write-Log "Windows Terminal installerat" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "winget saknas - hoppar över Windows Terminal-installation" -Level WARNING
            Write-Log "Installera manuellt från Microsoft Store" -Level INFO
            return $false
        }
    }
    catch {
        Write-Log "Fel vid Windows Terminal-installation: $_" -Level ERROR
        return $false
    }
}

function Install-WSL2 {
    param(
        [Parameter(Mandatory=$false)]
        [switch]$SkipKaliInstall
    )

    Write-Log "============================================" -Level INFO
    Write-Log "Installerar WSL2 + Kali Linux" -Level INFO
    Write-Log "============================================" -Level INFO

    # Kontrollera om WSL redan är installerat
    $wslInstalled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    if ($wslInstalled.State -eq 'Enabled') {
        Write-Log "WSL redan aktiverat" -Level SUCCESS
    }
    else {
        Write-Log "Aktiverar WSL2..." -Level INFO
        try {
            wsl --install --no-distribution
            Write-Log "WSL2 installerat - OMSTART KRÄVS" -Level WARNING
            Write-Log "Kör skriptet igen efter omstart för att installera Kali Linux" -Level INFO
            return $false
        }
        catch {
            Write-Log "Fel vid WSL-installation: $_" -Level ERROR
            return $false
        }
    }

    # Installera Kali Linux
    if (-not $SkipKaliInstall) {
        Write-Log "Installerar Kali Linux..." -Level INFO
        try {
            wsl --install -d kali-linux
            Write-Log "Kali Linux installerat" -Level SUCCESS
            Write-Log "Konfigurera användarnamn/lösenord i Kali-fönstret som öppnas" -Level INFO
            return $true
        }
        catch {
            Write-Log "Fel vid Kali-installation: $_" -Level ERROR
            return $false
        }
    }

    return $true
}

# ============================================================================
# KONFIGURATIONSFUNKTIONER
# ============================================================================

function New-FirefoxProfile {
    Write-Log "============================================" -Level INFO
    Write-Log "Skapar Firefox-profil: $Script:ProfileName" -Level INFO
    Write-Log "============================================" -Level INFO

    try {
        # Starta Firefox Profile Manager
        Write-Log "Startar Firefox Profile Manager..." -Level INFO
        Write-Log "Skapa profilen '$Script:ProfileName' manuellt i fönstret som öppnas" -Level INFO

        Start-Process -FilePath $Script:FirefoxExe -ArgumentList "-CreateProfile", "$Script:ProfileName" -Wait

        Write-Log "Profil skapad" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Fel vid profilskapande: $_" -Level ERROR
        return $false
    }
}

function Set-FirefoxSecurityConfig {
    Write-Log "============================================" -Level INFO
    Write-Log "Tillämpar säkerhetskonfiguration" -Level INFO
    Write-Log "============================================" -Level INFO

    # Hitta profilmappen
    $profilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    $profileFolder = Get-ChildItem -Path $profilesPath -Directory | Where-Object { $_.Name -like "*$Script:ProfileName*" } | Select-Object -First 1

    if (-not $profileFolder) {
        Write-Log "Profilmapp hittades inte - hoppar över konfiguration" -Level WARNING
        Write-Log "Kör konfigurationen manuellt enligt IMPLEMENTATION-GUIDE.md" -Level INFO
        return $false
    }

    Write-Log "Profilmapp: $($profileFolder.FullName)" -Level INFO

    # Skapa user.js med säkerhetsinställningar
    $userJsPath = Join-Path $profileFolder.FullName "user.js"

    $securityConfig = @'
// GridShield Security - Firefox Security Hardening Configuration
// Version: 1.0
// Datum: 2025-11-13

// ============================================================================
// PRIVACY & TELEMETRY
// ============================================================================
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("extensions.pocket.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);

// ============================================================================
// WEBRTC (IP-LEAKAGE PREVENTION)
// ============================================================================
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.ice.no_host", true);
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);

// ============================================================================
// DNS & PREFETCHING
// ============================================================================
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.predictor.enabled", false);
user_pref("network.prefetch-next", false);
user_pref("network.http.speculative-parallel-limit", 0);

// ============================================================================
// HTTPS-ONLY MODE
// ============================================================================
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_ever_enabled", true);
user_pref("dom.security.https_first", true);

// ============================================================================
// FINGERPRINTING PROTECTION
// ============================================================================
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.firstparty.isolate", true);

// ============================================================================
// CROSS-ORIGIN SECURITY
// ============================================================================
user_pref("network.http.referer.XOriginPolicy", 2);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
user_pref("privacy.partition.network_state", true);

// ============================================================================
// SAFE BROWSING (KEEP ENABLED)
// ============================================================================
user_pref("browser.safebrowsing.malware.enabled", true);
user_pref("browser.safebrowsing.phishing.enabled", true);

// ============================================================================
// WEBGL (DISABLE FOR SECURITY)
// ============================================================================
user_pref("webgl.disabled", true);
user_pref("webgl.enable-webgl2", false);

// ============================================================================
// GEOLOCATION
// ============================================================================
user_pref("geo.enabled", false);
user_pref("geo.provider.network.url", "");

// ============================================================================
// CLIPBOARD API
// ============================================================================
user_pref("dom.event.clipboardevents.enabled", false);

// ============================================================================
// MICROSOFT 365 / AZURE AD SSO
// ============================================================================
user_pref("network.negotiate-auth.trusted-uris", ".microsoft.com,.microsoftonline.com,.office.com,.sharepoint.com,.live.com,.azure.com,.azurewebsites.net");
user_pref("network.negotiate-auth.delegation-uris", ".microsoft.com,.microsoftonline.com");
user_pref("network.automatic-ntlm-auth.trusted-uris", ".microsoft.com,.microsoftonline.com");
user_pref("network.http.windows-sso.enabled", true);

// ============================================================================
// ENHANCED TRACKING PROTECTION
// ============================================================================
user_pref("browser.contentblocking.category", "strict");
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);

// GridShield Security Configuration End
'@

    Write-Log "Skriver säkerhetskonfiguration till user.js..." -Level INFO
    Set-Content -Path $userJsPath -Value $securityConfig -Encoding UTF8
    Write-Log "Säkerhetskonfiguration tillämpad" -Level SUCCESS

    return $true
}

function New-DesktopShortcut {
    Write-Log "Skapar skrivbordsgenväg..." -Level INFO

    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $shortcutPath = "$env:USERPROFILE\Desktop\Firefox GridShield.lnk"
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $Script:FirefoxExe
        $Shortcut.Arguments = "-P $Script:ProfileName"
        $Shortcut.Description = "Firefox Developer Edition - GridShield Security Profile"
        $Shortcut.Save()

        Write-Log "Skrivbordsgenväg skapad: $shortcutPath" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Kunde inte skapa genväg: $_" -Level WARNING
        return $false
    }
}

function Install-FirefoxExtensions {
    Write-Log "============================================" -Level INFO
    Write-Log "Extensions måste installeras manuellt" -Level INFO
    Write-Log "============================================" -Level INFO

    Write-Log "Följande extensions rekommenderas:" -Level INFO
    Write-Log "  1. Multi-Account Containers (Mozilla)" -Level INFO
    Write-Log "  2. uBlock Origin" -Level INFO
    Write-Log "  3. Bitwarden" -Level INFO
    Write-Log "  4. FoxyProxy Standard" -Level INFO
    Write-Log "  5. Wappalyzer" -Level INFO
    Write-Log "  6. Cookie-Editor" -Level INFO
    Write-Log "" -Level INFO
    Write-Log "Se IMPLEMENTATION-GUIDE.md Fas 4 för detaljerade instruktioner" -Level INFO
}

# ============================================================================
# HUVUDPROGRAM
# ============================================================================

function Main {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  GridShield Security" -ForegroundColor Cyan
    Write-Host "  Firefox Developer Edition Installer" -ForegroundColor Cyan
    Write-Host "  Version 1.0" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Log "Installation startad" -Level INFO
    Write-Log "Loggfil: $Script:LogFile" -Level INFO

    # Systemkontroller
    Write-Log "Kontrollerar systemkrav..." -Level INFO

    $osVersion = (Get-CimInstance Win32_OperatingSystem).Caption
    Write-Log "OS: $osVersion" -Level INFO

    $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    Write-Log "RAM: $ramGB GB" -Level INFO

    if ($ramGB -lt 8) {
        Write-Log "Varning: Minst 16 GB RAM rekommenderas (du har $ramGB GB)" -Level WARNING
    }

    # Internetanslutning
    $internetOk = Test-InternetConnection

    if (-not $ConfigureOnly) {
        # Installera winget
        if (-not (Install-Winget)) {
            Write-Log "Vissa installationer kan misslyckas utan winget" -Level WARNING
        }

        # Installera Firefox
        if (-not $SkipFirefoxInstall) {
            if (-not (Install-FirefoxDeveloperEdition)) {
                Write-Log "Firefox-installation misslyckades" -Level ERROR
                return
            }
        }

        # Installera Git
        Install-GitForWindows | Out-Null

        # Installera Windows Terminal
        Install-WindowsTerminal | Out-Null

        # Installera WSL2
        if (-not $SkipWSL) {
            $wslResult = Install-WSL2
            if (-not $wslResult) {
                Write-Log "WSL-installation kräver omstart" -Level WARNING
            }
        }
    }

    # Konfiguration
    Write-Log "" -Level INFO
    Write-Log "============================================" -Level INFO
    Write-Log "KONFIGURATIONSFAS" -Level INFO
    Write-Log "============================================" -Level INFO

    # Skapa profil
    New-FirefoxProfile | Out-Null

    # Tillämpa säkerhetsinställningar
    Start-Sleep -Seconds 2
    Set-FirefoxSecurityConfig | Out-Null

    # Skapa genväg
    New-DesktopShortcut | Out-Null

    # Information om manuella steg
    Install-FirefoxExtensions

    # Sammanfattning
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  INSTALLATION SLUTFÖRD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""

    Write-Log "Nästa steg:" -Level INFO
    Write-Log "  1. Starta Firefox via genvägen på skrivbordet" -Level INFO
    Write-Log "  2. Installera Extensions (se IMPLEMENTATION-GUIDE.md Fas 4)" -Level INFO
    Write-Log "  3. Konfigurera Containers (se IMPLEMENTATION-GUIDE.md Fas 3)" -Level INFO
    Write-Log "  4. Testa Azure AD SSO (se IMPLEMENTATION-GUIDE.md Fas 5)" -Level INFO
    Write-Log "" -Level INFO
    Write-Log "Fullständig guide: IMPLEMENTATION-GUIDE.md" -Level SUCCESS
    Write-Log "Loggfil: $Script:LogFile" -Level INFO

    Write-Host ""
    Write-Host "Vill du öppna Firefox nu? (J/N): " -NoNewline -ForegroundColor Yellow
    $response = Read-Host

    if ($response -eq 'J' -or $response -eq 'j') {
        Write-Log "Startar Firefox..." -Level INFO
        Start-Process -FilePath $Script:FirefoxExe -ArgumentList "-P", "$Script:ProfileName"
    }
}

# Kör huvudprogrammet
Main
