# GridShield Security - Firefox Developer Edition & Windows Terminal Implementation Guide

**Version:** 1.0
**Datum:** 2025-11-13
**Författare:** GridShield Security
**Syfte:** Komplett säkerhetsimplementation för Firefox Developer Edition och Windows Terminal optimering

---

## Innehållsförteckning

1. [Översikt](#1-översikt)
2. [Pre-Installation Checklista](#2-pre-installation-checklista)
3. [Fas 1: Installation & Initial Setup](#fas-1-installation--initial-setup)
4. [Fas 2: Core Security Hardening](#fas-2-core-security-hardening)
5. [Fas 3: Container Configuration](#fas-3-container-configuration)
6. [Fas 4: Essential Extensions](#fas-4-essential-extensions)
7. [Fas 5: Microsoft 365 / Azure AD Integration](#fas-5-microsoft-365--azure-ad-integration)
8. [Fas 6: Google Workspace Integration](#fas-6-google-workspace-integration)
9. [Fas 7: GitLab & Development Tools](#fas-7-gitlab--development-tools)
10. [Fas 8: Security Testing Configuration](#fas-8-security-testing-configuration)
11. [Fas 9: WSL Kali Linux Integration](#fas-9-wsl-kali-linux-integration)
12. [Fas 10: Windows Terminal Optimering](#fas-10-windows-terminal-optimering)
13. [Fas 11: Copilot CLI Integration](#fas-11-copilot-cli-integration)
14. [Fas 12: Maintenance & Best Practices](#fas-12-maintenance--best-practices)
15. [Appendix A: Quick Reference](#appendix-a-quick-reference)
16. [Appendix B: Troubleshooting Guide](#appendix-b-troubleshooting-guide)
17. [Appendix C: Security Incident Response](#appendix-c-security-incident-response)

---

## 1. Översikt

### 1.1 Målsättning

Denna implementeringsguide skapar en **Zero Trust**, **Purple Team-ready** arbetsmiljö för GridShield Security med fokus på:

- **OT/ICS Cybersecurity** - Isolerade miljöer för klientarbete (Svenska Kraftnät, energibolag)
- **Penetrationstestning** - Burp Suite, OWASP ZAP, Kali Linux-integration
- **Secure Development** - GitLab, GitHub, GitBook med container-isolering
- **Microsoft 365 Integration** - Seamless SSO med Azure AD/Entra ID
- **Privacy & Security** - 50+ säkerhetsinställningar, container-isolering, telemetri-avstängning

### 1.2 Säkerhetsfilosofi

**Zero Trust Principles:**
- Ingen cross-contamination mellan arbetsområden
- Automatisk session-cleanup i Testing-Sandbox
- WebRTC-blockering mot IP-läckage
- HTTPS-Only mode för all trafik
- Enhanced Tracking Protection (Strict)

**Purple Team Capabilities:**
- Traffic analysis via Burp Suite/ZAP
- Cookie/session manipulation
- User-agent switching för reconnaissance
- Container-based testing environment

### 1.3 Tidsplan

| Fas | Uppskattad tid | Prioritet |
|-----|----------------|-----------|
| Fas 1-2 | 30 min | Kritisk |
| Fas 3-4 | 60 min | Kritisk |
| Fas 5-7 | 45 min | Hög |
| Fas 8-9 | 30 min | Medium |
| Fas 10-11 | 45 min | Hög |
| Fas 12 | Löpande | Kritisk |

**Total initial setup:** ~3-4 timmar

---

## 2. Pre-Installation Checklista

### 2.1 Systemkrav

- [ ] **OS:** Windows 11 Pro (22H2 eller senare)
- [ ] **RAM:** Minst 16 GB (32 GB rekommenderat)
- [ ] **Disk:** 50 GB ledigt utrymme
- [ ] **Nätverk:** Stabil internetanslutning
- [ ] **Konton:**
  - GridShield Microsoft 365-konto (`christian.wallen@gridshield.se`)
  - GitHub-konto med Copilot-licens
  - GitLab-konto
  - Bitwarden Premium (rekommenderat)

### 2.2 Förberedelser

**Ladda ner följande filer till Ventoy USB:**

```powershell
# Firefox Developer Edition
https://www.mozilla.org/en-US/firefox/developer/

# Bitwarden Desktop
https://bitwarden.com/download/

# Windows Terminal (om inte förinstallerat)
https://github.com/microsoft/terminal/releases

# Git for Windows
https://git-scm.com/download/win
```

### 2.3 Backup

- [ ] Exportera befintliga Firefox-bokmärken (om applicable)
- [ ] Säkerhetskopiera befintliga SSH-nycklar
- [ ] Dokumentera nuvarande nätverksinställningar

---

## Fas 1: Installation & Initial Setup

### 1.1 Installera Firefox Developer Edition

**Steg 1: Installera via PowerShell (Administratör)**

```powershell
# Kör PowerShell-installationsskriptet
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\Install-GridShieldFirefox.ps1
```

**ELLER manuell installation:**

1. Högerklicka på Firefox Developer Edition installer
2. Välj "Run as Administrator"
3. **Viktigt:** Välj "Custom Installation"
   - Installationsväg: `C:\Program Files\Firefox Developer Edition`
   - Avmarkera "Use Firefox Developer Edition as my default browser" (konfigureras senare)
   - Avmarkera "Send anonymous usage data to Mozilla"

**Steg 2: Första uppstart**

```powershell
# Starta Firefox från PowerShell för att verifiera installation
& "C:\Program Files\Firefox Developer Edition\firefox.exe"
```

**Konfigurera vid första start:**
- [ ] Stäng välkomstskärmen
- [ ] Navigera till `about:preferences`
- [ ] Gå till **Privacy & Security** → Välj "Strict" för Enhanced Tracking Protection
- [ ] Avmarkera "Ask to save passwords" (Bitwarden används istället)

### 1.2 Skapa Firefox-profil för GridShield

**Steg 3: Skapa dedikerad profil**

```
Adressfält: about:profiles
```

1. Klicka "Create a New Profile"
2. Namn: `GridShield-Security`
3. Mapp: Välj `C:\Users\<ditt-användarnamn>\AppData\Roaming\Mozilla\Firefox\Profiles\GridShield`
4. Klicka "Launch profile in new browser"

**Steg 4: Sätt som standardprofil**

```powershell
# Skapa genväg med fast profil
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Firefox GridShield.lnk")
$Shortcut.TargetPath = "C:\Program Files\Firefox Developer Edition\firefox.exe"
$Shortcut.Arguments = "-P GridShield-Security"
$Shortcut.Save()
```

---

## Fas 2: Core Security Hardening

### 2.1 About:Config Säkerhetsinställningar

**Navigera till:** `about:config`

**Acceptera varningen och fortsätt**

Kopiera och klistra in följande inställningar **EN I TAGET** i sökfältet och ändra värdet:

#### 2.1.1 Privacy & Telemetry

```javascript
// Stäng av all telemetri
toolkit.telemetry.enabled = false
toolkit.telemetry.unified = false
toolkit.telemetry.archive.enabled = false
datareporting.healthreport.uploadEnabled = false
datareporting.policy.dataSubmissionEnabled = false
browser.ping-centre.telemetry = false
browser.newtabpage.activity-stream.feeds.telemetry = false
browser.newtabpage.activity-stream.telemetry = false

// Stäng av Pocket
extensions.pocket.enabled = false

// Stäng av Firefox Studies
app.shield.optoutstudies.enabled = false
```

#### 2.1.2 WebRTC (IP-läckage prevention)

```javascript
media.peerconnection.enabled = false
media.peerconnection.ice.default_address_only = true
media.peerconnection.ice.no_host = true
media.peerconnection.ice.proxy_only_if_behind_proxy = true
```

#### 2.1.3 DNS & Prefetching

```javascript
network.dns.disablePrefetch = true
network.dns.disablePrefetchFromHTTPS = true
network.predictor.enabled = false
network.prefetch-next = false
network.http.speculative-parallel-limit = 0
```

#### 2.1.4 HTTPS-Only Mode

```javascript
dom.security.https_only_mode = true
dom.security.https_only_mode_ever_enabled = true
dom.security.https_first = true
```

#### 2.1.5 Fingerprinting Protection

```javascript
privacy.resistFingerprinting = true
privacy.trackingprotection.fingerprinting.enabled = true
privacy.trackingprotection.cryptomining.enabled = true
privacy.firstparty.isolate = true
```

#### 2.1.6 Cross-Origin Security

```javascript
network.http.referer.XOriginPolicy = 2
network.http.referer.XOriginTrimmingPolicy = 2
privacy.partition.network_state = true
```

#### 2.1.7 Safe Browsing (behåll aktiverat)

```javascript
browser.safebrowsing.malware.enabled = true
browser.safebrowsing.phishing.enabled = true
```

#### 2.1.8 WebGL (Inaktivera för ökad säkerhet)

```javascript
webgl.disabled = true
webgl.enable-webgl2 = false
```

#### 2.1.9 Geolocation

```javascript
geo.enabled = false
geo.provider.network.url = ""
```

#### 2.1.10 Clipboard API

```javascript
dom.event.clipboardevents.enabled = false
```

### 2.2 Verifiera inställningar

**Steg 1: Testa WebRTC-läckage**

Öppna: https://browserleaks.com/webrtc

**Förväntat resultat:** "WebRTC is not supported" eller inga IP-adresser synliga

**Steg 2: Testa fingerprinting**

Öppna: https://coveryourtracks.eff.org/

**Förväntat resultat:** "Strong protection against tracking"

---

## Fas 3: Container Configuration

### 3.1 Installera Multi-Account Containers

**Steg 1: Installera tillägget**

```
about:addons → Extensions → Sök "Multi-Account Containers"
```

Välj **Mozilla Firefox Multi-Account Containers** (officiell från Mozilla)

**Steg 2: Skapa containers**

Klicka på container-ikonen i verktygsfältet → **Manage Containers**

### 3.2 Container-struktur för GridShield

#### Container 1: Work-M365 (Blå)

**Syfte:** Microsoft 365, Teams, Azure Portal, Entra ID

**Konfiguration:**
- Namn: `Work-M365`
- Färg: Blå
- Ikon: Briefcase
- **Settings:**
  - "Block cookies from other containers" ✓
  - "Block all access to non-Microsoft domains" ✗ (för flexibilitet)

**Domäner som alltid öppnas här:**
```
*.microsoft.com
*.microsoftonline.com
*.office.com
*.sharepoint.com
*.onedrive.com
*.teams.microsoft.com
portal.azure.com
*.azurewebsites.net
```

#### Container 2: Work-Google (Grön)

**Syfte:** Google Workspace (om används)

**Konfiguration:**
- Namn: `Work-Google`
- Färg: Grön
- Ikon: Circle

**Domäner:**
```
*.google.com
*.googleapis.com
mail.google.com
drive.google.com
docs.google.com
```

#### Container 3: Development (Orange)

**Syfte:** GitLab, GitHub, GitBook, utvecklarverktyg

**Konfiguration:**
- Namn: `Development`
- Färg: Orange
- Ikon: Cog

**Domäner:**
```
*.gitlab.com
*.github.com
*.gitbook.com
*.npmjs.com
*.pypi.org
*.docker.com
*.stackoverflow.com
```

#### Container 4: Client-Access (Röd)

**Syfte:** Klientportaler - Svenska Kraftnät, energibolag, OT/ICS-system

**Konfiguration:**
- Namn: `Client-Access`
- Färg: Röd
- Ikon: Fence
- **VIKTIGT:** Högsta säkerhetsnivå

**Domäner:** (lägg till efter behov)
```
*.svenskakraftnät.se
*.vattenfall.se
*.eon.se
*.fortum.se
[Lägg till klient-specifika domäner här]
```

#### Container 5: Security-Research (Lila)

**Syfte:** CVE-databaser, Claroty, Nozomi, ICS-CERT

**Konfiguration:**
- Namn: `Security-Research`
- Färg: Lila
- Ikon: Fingerprint

**Domäner:**
```
*.cve.org
*.nvd.nist.gov
*.claroty.com
*.nozominetworks.com
*.cisa.gov
*.ics-cert.us-cert.gov
*.dragos.com
*.tenable.com
*.rapid7.com
```

#### Container 6: Testing-Sandbox (Gul)

**Syfte:** Osäkra sidor, testmiljöer, automatisk cookie-radering

**Konfiguration:**
- Namn: `Testing-Sandbox`
- Färg: Gul
- Ikon: Skull
- **Settings:**
  - "Delete cookies when all tabs closed" ✓
  - "Never save passwords" ✓

**Användning:** Öppna manuellt - ingen automatisk domänassociering

#### Container 7: Personal (Vit)

**Syfte:** Bank, LinkedIn, privata angelägenheter

**Konfiguration:**
- Namn: `Personal`
- Färg: Grå/Vit
- Ikon: Pet

**Domäner:**
```
*.linkedin.com
*.facebook.com
*.twitter.com
[Lägg till bank-domäner här]
```

### 3.3 Container Best Practices

**Använd alltid rätt container:**
- Klicka på "+" → Välj container → Öppna tab
- Högerklicka på länk → "Open Link in New Container Tab"

**Verifiering:**
- Container-namn visas i tabb-färgen
- Ctrl+. (punkt) visar aktiv container

---

## Fas 4: Essential Extensions

### 4.1 Säkerhetsverifierade tillägg

**VIKTIGT:** Installera **endast** tillägg från Mozilla Add-ons (addons.mozilla.org)

#### Extension 1: uBlock Origin

**Funktion:** Ad/tracker blocking, malware protection

**Installation:**
```
about:addons → Search "uBlock Origin" → Add to Firefox
```

**Konfiguration:**
1. Klicka på uBlock Origin-ikonen
2. Gå till Dashboard (kugghjul)
3. **Filter lists:** Aktivera:
   - ✓ All "Ads" lists
   - ✓ All "Privacy" lists
   - ✓ All "Malware domains" lists
   - ✓ Annoyances (Cookie notices, etc.)
4. **My filters:** Lägg till:
```
! GridShield Security custom filters
||doubleclick.net^
||google-analytics.com^
||facebook.com/tr/*
||linkedin.com/px/*
```

#### Extension 2: Bitwarden

**Funktion:** Lösenordshantering (Zero Trust)

**Installation:**
```
about:addons → Search "Bitwarden" → Add to Firefox
```

**Konfiguration:**
1. Klicka på Bitwarden-ikonen → **Log in**
2. Använd `christian.wallen@gridshield.se`
3. **Settings:**
   - Vault Timeout: `15 minutes`
   - Vault Timeout Action: `Lock`
   - Enable Auto-fill: ✓
   - Enable Auto-fill on Page Load: ✗ (säkerhet)
4. **Container integration:**
   - Bitwarden fungerar över alla containers

#### Extension 3: FoxyProxy

**Funktion:** Proxy-switching för Burp Suite/OWAP ZAP

**Installation:**
```
about:addons → Search "FoxyProxy Standard" → Add to Firefox
```

**Konfiguration:**
1. Klicka på FoxyProxy-ikonen → **Options**
2. **Add Proxy:**
   - Title: `Burp Suite`
   - Type: `HTTP`
   - Hostname: `127.0.0.1`
   - Port: `8080`
3. **Add Proxy:**
   - Title: `OWASP ZAP`
   - Type: `HTTP`
   - Hostname: `127.0.0.1`
   - Port: `8081`
4. **Default:** "Use Firefox settings" (inaktiverad proxy)

**Användning:**
- Testing-Sandbox container → Aktivera proxy → Intercepta trafik

#### Extension 4: Wappalyzer

**Funktion:** Teknologi-fingerprinting

**Installation:**
```
about:addons → Search "Wappalyzer" → Add to Firefox
```

**Användning:** Klicka på ikonen för att se webbplatsens teknologi-stack

#### Extension 5: Cookie-Editor

**Funktion:** Session manipulation för pen-testing

**Installation:**
```
about:addons → Search "Cookie-Editor" → Add to Firefox
```

**Konfiguration:**
- Permissions: Tillåt endast i Development och Testing-Sandbox containers

#### Extension 6: User-Agent Switcher

**Funktion:** User-agent manipulation för reconnaissance

**Installation:**
```
about:addons → Search "User-Agent Switcher and Manager" → Add to Firefox
```

**Custom User-Agents:**
```
Googlebot: Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
Mobile: Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15
Tor Browser: Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0
```

#### Extension 7: React Developer Tools

**Funktion:** Frontend-analys (endast Development container)

**Installation:**
```
about:addons → Search "React Developer Tools" → Add to Firefox
```

#### Extension 8: Vue.js devtools

**Funktion:** Frontend-analys för Vue.js

**Installation:**
```
about:addons → Search "Vue.js devtools" → Add to Firefox
```

### 4.2 Extension Security Audit

**Månatlig kontroll:**

1. Gå till `about:addons`
2. Verifiera att alla extensions är uppdaterade
3. Kontrollera permissions för nya uppdateringar
4. Ta bort oanvända extensions

**Varningssignaler:**
- Extension begär onödiga permissions
- Ej uppdaterad på >6 månader
- Utvecklare har ändrats
- Negativa recensioner om malware

---

## Fas 5: Microsoft 365 / Azure AD Integration

### 5.1 Azure AD Entra ID SSO

**Steg 1: Aktivera Windows SSO i Firefox**

```
about:config
```

Sök och ändra:

```javascript
network.negotiate-auth.trusted-uris = .microsoft.com,.microsoftonline.com,.office.com,.sharepoint.com,.live.com,.azure.com,.azurewebsites.net
network.negotiate-auth.delegation-uris = .microsoft.com,.microsoftonline.com
network.automatic-ntlm-auth.trusted-uris = .microsoft.com,.microsoftonline.com
network.http.windows-sso.enabled = true
```

**För Azure AD specifikt:**

```javascript
network.http.microsoft-entra-sso.enabled = true
```

### 5.2 Testa SSO-integration

**Steg 2: Verifiera automatisk inloggning**

1. Öppna ny tab i **Work-M365 container**
2. Navigera till: `https://portal.office.com`
3. **Förväntat resultat:** Automatisk inloggning med `christian.wallen@gridshield.se`
4. Testa även:
   - `https://portal.azure.com`
   - `https://teams.microsoft.com`
   - `https://gridshield.sharepoint.com`

**Om inloggning INTE fungerar automatiskt:**

**Felsökning:**

```powershell
# Verifiera att du är inloggad i Windows med Azure AD
whoami /upn
# Ska visa: christian.wallen@gridshield.se
```

**Om whoami visar lokalt konto:**
- Gå till **Windows Settings** → **Accounts** → **Access work or school**
- Klicka **Connect** → Logga in med `christian.wallen@gridshield.se`

### 5.3 Conditional Access Policy Support

**Om GridShield använder Azure AD Conditional Access:**

**Steg 3: Verifiera device compliance**

```
about:config → Sök
```

```javascript
network.http.windows-sso.device-compliance-enabled = true
```

**Denna inställning:**
- Skickar device compliance-data till Azure AD
- Tillåter Firefox att uppfylla Conditional Access policies
- Krävs om GridShield kräver "Compliant Device" policy

---

## Fas 6: Google Workspace Integration

### 6.1 SAML SSO (Om används)

**Om GridShield använder Google Workspace:**

**Steg 1: Konfigurera Google-domäner**

```
about:config
```

```javascript
network.negotiate-auth.trusted-uris = .google.com,.googleapis.com,.gstatic.com
```

**Steg 2: Testa inloggning**

1. Öppna **Work-Google container**
2. Navigera till: `https://mail.google.com`
3. Logga in med `christian.wallen@gridshield.se` (om Google Workspace är konfigurerat)

**Om INTE Google Workspace:**
- Använd personligt Google-konto
- Begränsa till Personal container

---

## Fas 7: GitLab & Development Tools

### 7.1 GitLab SSH-konfiguration

**Förutsättning:** Git for Windows installerat

**Steg 1: Generera SSH-nyckel (från PowerShell)**

```powershell
# Navigera till .ssh-mappen
cd $env:USERPROFILE\.ssh

# Generera Ed25519-nyckel för GitLab
ssh-keygen -t ed25519 -C "gitlab-christian@gridshield.se" -f gitlab_ed25519

# Starta SSH-agent
Start-Service ssh-agent
Set-Service -Name ssh-agent -StartupType Automatic

# Lägg till nyckeln
ssh-add gitlab_ed25519
```

**Steg 2: Lägg till SSH-nyckel i GitLab**

```powershell
# Kopiera publik nyckel till clipboard
Get-Content gitlab_ed25519.pub | Set-Clipboard
```

1. Öppna GitLab i **Development container**: `https://gitlab.com/-/profile/keys`
2. Klicka **Add new key**
3. Klistra in (Ctrl+V)
4. Title: `GridShield-Windows-Firefox`
5. Expiration: Sätt till 1 år
6. Klicka **Add key**

**Steg 3: Testa SSH-anslutning**

```powershell
ssh -T git@gitlab.com
```

**Förväntat resultat:**
```
Welcome to GitLab, @<ditt-användarnamn>!
```

### 7.2 GitHub Integration

**Steg 4: GitHub SSH-nyckel**

```powershell
cd $env:USERPROFILE\.ssh
ssh-keygen -t ed25519 -C "github-christian@gridshield.se" -f github_ed25519
ssh-add github_ed25519

# Kopiera publik nyckel
Get-Content github_ed25519.pub | Set-Clipboard
```

**Lägg till på GitHub:**
1. Öppna i **Development container**: `https://github.com/settings/keys`
2. **New SSH key** → Klistra in → **Add key**

**Steg 5: SSH Config**

Skapa/redigera: `C:\Users\<ditt-namn>\.ssh\config`

```ssh-config
# GitLab
Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile ~/.ssh/gitlab_ed25519
  IdentitiesOnly yes

# GitHub
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_ed25519
  IdentitiesOnly yes
```

### 7.3 GitBook Integration

**Om du använder GitBook:**

1. Öppna i **Development container**: `https://app.gitbook.com`
2. Logga in med GitHub/GitLab
3. Aktivera **GitHub/GitLab Sync** för automatisk publicering

---

## Fas 8: Security Testing Configuration

### 8.1 Burp Suite Integration

**Förutsättning:** Burp Suite Community/Pro installerat

**Steg 1: Starta Burp Suite**

```powershell
# Om installerat via Chocolatey
burpsuite
```

**Steg 2: Konfigurera proxy**

1. Burp → **Proxy** → **Options**
2. **Proxy Listeners:** Verifiera `127.0.0.1:8080`
3. **Intercept Client Requests:** Aktivera

**Steg 3: Konfigurera Firefox (FoxyProxy)**

1. Öppna **Testing-Sandbox container**
2. Klicka FoxyProxy → Välj **Burp Suite**
3. Navigera till: `http://burpsuite`
4. **CA Certificate** → Klicka **Download**
5. Spara som `burp-ca.der`

**Steg 4: Importera Burp CA i Firefox**

```
about:preferences#privacy → Certificates → View Certificates → Import
```

1. Välj `burp-ca.der`
2. ✓ **Trust this CA to identify websites**
3. Klicka **OK**

**Steg 5: Testa interception**

1. FoxyProxy: Burp Suite aktiverad
2. Navigera till: `https://example.com`
3. **Burp Intercept** ska visa requesten
4. Klicka **Forward** för att släppa igenom

### 8.2 OWASP ZAP Integration

**Liknande process som Burp:**

**Steg 1: Starta ZAP**

```powershell
# Om installerat
zap.bat
```

**Steg 2: Konfigurera proxy**

ZAP → **Tools** → **Options** → **Local Proxies**
- Address: `127.0.0.1`
- Port: `8081`

**Steg 3: FoxyProxy**

Lägg till ZAP-proxy (se Fas 4, Extension 3)

**Steg 4: Importera ZAP CA**

ZAP → **Tools** → **Options** → **Dynamic SSL Certificates** → **Save**

Importera i Firefox (samma process som Burp)

---

## Fas 9: WSL Kali Linux Integration

### 9.1 Installera WSL2 + Kali Linux

**Steg 1: Aktivera WSL2 (PowerShell Admin)**

```powershell
# Aktivera WSL
wsl --install

# Verifiera version
wsl --version

# Installera Kali Linux
wsl --install -d kali-linux

# Sätt Kali som default
wsl --set-default kali-linux
```

**Steg 2: Första konfiguration av Kali**

```bash
# Öppna WSL
wsl

# Uppdatera Kali
sudo apt update && sudo apt upgrade -y

# Installera metapackages för pentest-verktyg
sudo apt install -y kali-linux-default kali-tools-web
```

### 9.2 Kali → Firefox Integration

**Steg 3: Dela Burp CA-certifikat med Kali**

```powershell
# Från Windows PowerShell
Copy-Item "$env:USERPROFILE\Downloads\burp-ca.der" \\wsl$\kali-linux\home\<kali-user>\
```

**Steg 4: Importera i Kali (för curl/wget)**

```bash
# I WSL
sudo cp ~/burp-ca.der /usr/local/share/ca-certificates/burp-ca.crt
sudo update-ca-certificates
```

### 9.3 Använda Kali-verktyg via Firefox

**Scenario: Kör sqlmap via Firefox-proxy**

```bash
# I Kali WSL
sqlmap -u "http://target.com/vulnerable.php?id=1" \
  --proxy="http://127.0.0.1:8080" \
  --batch
```

**Resultat:** All trafik från sqlmap går via Burp Suite (körs på Windows)

---

## Fas 10: Windows Terminal Optimering

### 10.1 Installera Windows Terminal

**Via PowerShell (Admin):**

```powershell
winget install Microsoft.WindowsTerminal
```

**ELLER från Microsoft Store:**
- Sök "Windows Terminal"
- Klicka **Install**

### 10.2 Konfigurera GridShield-profiler

**Steg 1: Öppna settings.json**

Windows Terminal → **Settings** (Ctrl+,) → **Open JSON file**

**Steg 2: Lägg till GridShield-profiler**

Hitta `"profiles"` → `"list"` och lägg till:

```json
{
  "profiles": {
    "list": [
      {
        "name": "🛡️ GridShield PowerShell",
        "commandline": "pwsh.exe -NoLogo",
        "icon": "C:\\Users\\<ditt-namn>\\Pictures\\gridshield-logo.png",
        "colorScheme": "GridShield Dark",
        "font": {
          "face": "CascadiaCode Nerd Font",
          "size": 11
        },
        "startingDirectory": "C:\\GridShield\\Projects",
        "backgroundImage": null,
        "backgroundImageOpacity": 0.2,
        "useAcrylic": true,
        "acrylicOpacity": 0.85
      },
      {
        "name": "🐧 Kali Linux (WSL2)",
        "commandline": "wsl.exe -d kali-linux",
        "icon": "C:\\Users\\<ditt-namn>\\Pictures\\kali-logo.png",
        "colorScheme": "Kali Dark",
        "font": {
          "face": "CascadiaCode Nerd Font",
          "size": 10
        },
        "startingDirectory": "//wsl$/kali-linux/home/<kali-user>"
      },
      {
        "name": "⚡ Git Bash",
        "commandline": "C:\\Program Files\\Git\\bin\\bash.exe --login -i",
        "icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico",
        "colorScheme": "Campbell",
        "startingDirectory": "%USERPROFILE%\\Projects"
      },
      {
        "name": "🔧 Development (Node.js)",
        "commandline": "pwsh.exe -NoLogo -NoExit -Command \"& {Write-Host '🔧 Development Environment'; node --version; npm --version}\"",
        "colorScheme": "One Half Dark",
        "startingDirectory": "C:\\GridShield\\Projects"
      }
    ]
  }
}
```

### 10.3 Custom Color Schemes

**Lägg till under `"schemes"`:**

```json
{
  "schemes": [
    {
      "name": "GridShield Dark",
      "background": "#0C0C0C",
      "foreground": "#00FF41",
      "black": "#0C0C0C",
      "blue": "#0037DA",
      "cyan": "#3A96DD",
      "green": "#00FF41",
      "purple": "#881798",
      "red": "#C50F1F",
      "white": "#CCCCCC",
      "yellow": "#F9F1A5",
      "brightBlack": "#767676",
      "brightBlue": "#3B78FF",
      "brightCyan": "#61D6D6",
      "brightGreen": "#16C60C",
      "brightPurple": "#B4009E",
      "brightRed": "#E74856",
      "brightWhite": "#F2F2F2",
      "brightYellow": "#F9F1A5"
    },
    {
      "name": "Kali Dark",
      "background": "#1C1C1C",
      "foreground": "#00FF00",
      "black": "#000000",
      "blue": "#0037DA",
      "cyan": "#00FFFF",
      "green": "#00FF00",
      "purple": "#881798",
      "red": "#FF0000",
      "white": "#CCCCCC",
      "yellow": "#FFFF00",
      "brightBlack": "#555555",
      "brightBlue": "#3B78FF",
      "brightCyan": "#00FFFF",
      "brightGreen": "#00FF00",
      "brightPurple": "#B4009E",
      "brightRed": "#FF0000",
      "brightWhite": "#FFFFFF",
      "brightYellow": "#FFFF00"
    }
  ]
}
```

### 10.4 Terminal Best Practices

**Genvägar:**

| Kommando | Funktion |
|----------|----------|
| `Ctrl+Shift+T` | Ny tab |
| `Ctrl+Shift+W` | Stäng tab |
| `Alt+Shift++` | Dela horisontellt |
| `Alt+Shift+-` | Dela vertikalt |
| `Ctrl+,` | Öppna inställningar |
| `F11` | Fullskärm |

---

## Fas 11: Copilot CLI Integration

### 11.1 Installera GitHub Copilot CLI (WSL2)

**Steg 1: Installera Node.js i Kali**

```bash
# I WSL Kali
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version  # Ska vara v20.x
```

**Steg 2: Installera GitHub Copilot CLI**

```bash
sudo npm install -g @githubnext/github-copilot-cli
```

**Steg 3: Autentisera med GitHub**

```bash
github-copilot-cli auth
```

**Följ instruktionerna:**
1. Öppna browsern (använd **Development container**)
2. Navigera till GitHub-länken
3. Logga in med ditt GitHub-konto (måste ha Copilot-licens)
4. Klistra in device code
5. Bekräfta

### 11.2 Konfigurera Copilot-aliases

**Steg 4: Lägg till aliases i .bashrc**

```bash
# Öppna .bashrc
nano ~/.bashrc

# Lägg till i slutet:
# === GitHub Copilot CLI ===
alias copilot='github-copilot-cli'
alias gp='github-copilot-cli suggest'
alias ge='github-copilot-cli explain'

# Copilot-funktioner för GitLab
copilot_gitlab() {
    local query="$*"
    local suggestion=$(github-copilot-cli suggest "$query")
    echo "🤖 Copilot säger: $suggestion"
    read -p "Kör detta? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        eval "$suggestion"
    fi
}

# GitLab-aliases
alias gl-mr='copilot_gitlab "Create GitLab merge request from current branch, target main, remove source branch"'
alias gl-status='copilot_gitlab "Check GitLab pipeline status and recent activity"'
alias gl-clone='copilot_gitlab "Clone GitLab repository"'

# GitBook-aliases
alias gb-build='copilot_gitlab "Build GitBook from current directory"'
alias gb-serve='copilot_gitlab "Serve GitBook locally on port 4000"'

# Firefox-integration
open_in_firefox() {
    local url="$1"
    local container="${2:-default}"
    /mnt/c/Program\ Files/Firefox\ Developer\ Edition/firefox.exe "$url" &
}

alias ff-gitlab='open_in_firefox "https://gitlab.com/$(git remote -v | grep origin | head -1 | cut -d: -f2 | cut -d. -f1)" Development'
alias ff-github='open_in_firefox "https://github.com/$(git remote -v | grep origin | head -1 | cut -d: -f2 | cut -d. -f1)" Development'
alias ff-azure='open_in_firefox "https://portal.azure.com" Work-M365'

# Spara och ladda om
source ~/.bashrc
```

### 11.3 Användningsexempel

**Exempel 1: Få kommandoförslag**

```bash
gp "List all running Docker containers with their CPU usage"
```

**Copilot svarar:**
```
docker stats --no-stream
```

**Exempel 2: Förklara kommandon**

```bash
ge "docker run -d -p 8080:80 nginx"
```

**Copilot förklarar vad kommandot gör**

**Exempel 3: GitLab Merge Request**

```bash
# Skapa automatiskt MR från nuvarande branch
gl-mr
```

**Copilot genererar:**
```bash
git push -o merge_request.create -o merge_request.target=main -o merge_request.remove_source_branch
```

---

## Fas 12: Maintenance & Best Practices

### 12.1 Veckorutiner

**Varje måndag morgon (15 min):**

- [ ] **Firefox-uppdatering:**
  ```
  about:help → Sök efter uppdateringar
  ```

- [ ] **Extension-audit:**
  ```
  about:addons → Kontrollera uppdateringar
  ```

- [ ] **Container-cleanup:**
  - Testing-Sandbox: Verifiera att cookies raderas
  - Work-M365: Logga ut/in för att testa SSO

- [ ] **Bitwarden-backup:**
  - Exportera Vault (krypterat)
  - Spara på säker plats (inte cloud)

### 12.2 Månadsrutiner

**Första fredagen varje månad (30 min):**

- [ ] **Säkerhetsaudit:**
  - Testa WebRTC-läckage: https://browserleaks.com/webrtc
  - Testa fingerprinting: https://coveryourtracks.eff.org/
  - Verifiera HTTPS-Only mode fungerar

- [ ] **Extension Security Review:**
  ```
  about:addons → Granska permissions för alla extensions
  ```
  - Ta bort oanvända extensions
  - Kontrollera utvecklare-legitimitet

- [ ] **SSH-nyckel rotation (valfritt):**
  ```powershell
  ssh-keygen -t ed25519 -C "gitlab-christian@gridshield.se" -f gitlab_ed25519_new
  ```

- [ ] **Burp/ZAP CA-certifikat:**
  - Verifiera att certifikat är giltiga
  - Förnya om <30 dagar kvar

### 12.3 Kvartalsrutiner

**Varje kvartal (60 min):**

- [ ] **Fullständig Firefox-ominstallation (valfritt):**
  - Exportera bokmärken
  - Dokumentera containers
  - Avinstallera → Installera nytt
  - Återställ konfiguration

- [ ] **WSL2 Kali-uppdatering:**
  ```bash
  sudo apt update && sudo apt full-upgrade -y
  sudo apt autoremove -y
  ```

- [ ] **Windows Terminal-optimering:**
  - Uppdatera CascadiaCode font
  - Granska profiler
  - Testa nya features

### 12.4 Incident Response

**Om misstänkt säkerhetsincident:**

1. **Isolera omedelbart:**
   - Stäng alla Firefox-tabs
   - Koppla från nätverk (om nödvändigt)

2. **Dokumentera:**
   - Vilken container användes?
   - Vilken webbplats?
   - Vilka actions utfördes?

3. **Rensa:**
   ```
   about:preferences#privacy → Clear Data
   ```
   - Välj **ENDAST** den drabbade container
   - Rensa cookies, cache, history

4. **Rapportera:**
   - Informera GridShield Security-team
   - Dokumentera i incident log

5. **Återställ:**
   - Verifiera att container är ren
   - Byt lösenord (om applicable)
   - Rotiera SSH-nycklar (om applicable)

---

## Appendix A: Quick Reference

### A.1 Snabbkommandon

| Kommando | Funktion |
|----------|----------|
| `Ctrl+Shift+P` | Öppna ny private window |
| `Ctrl+.` | Visa aktiv container |
| `Ctrl+Shift+E` | Öppna i ny container |
| `F12` | Developer Tools |
| `Ctrl+Shift+K` | Web Console |
| `Ctrl+Shift+I` | Inspector |

### A.2 Container Shortcuts

| Container | Kortkommando | Använd för |
|-----------|--------------|-----------|
| Work-M365 | `Ctrl+Shift+1` | Microsoft 365, Azure |
| Development | `Ctrl+Shift+3` | GitLab, GitHub, kod |
| Testing-Sandbox | `Ctrl+Shift+6` | Osäkra sidor |

*(Konfigurera i Multi-Account Containers → Manage Containers → Keyboard Shortcuts)*

### A.3 Viktiga URLs

```
Firefox:
  about:config        - Avancerade inställningar
  about:profiles      - Profilhantering
  about:addons        - Extensions
  about:preferences   - Grundinställningar
  about:support       - Troubleshooting

Microsoft:
  portal.office.com   - Office 365
  portal.azure.com    - Azure Portal
  admin.microsoft.com - M365 Admin

Development:
  gitlab.com          - GitLab
  github.com          - GitHub
  app.gitbook.com     - GitBook

Security Testing:
  browserleaks.com    - Privacy/security test
  coveryourtracks.eff.org - Fingerprinting test
```

### A.4 Emergency Commands

**Nödsituation - Rensa ALLT:**

```
about:preferences#privacy → Clear Data → Clear ALL
```

**Återställ Firefox till standard:**

```
about:support → Refresh Firefox
```

**Radera specifik container:**

Multi-Account Containers → Manage Containers → [Container] → Delete

---

## Appendix B: Troubleshooting Guide

### B.1 Azure AD SSO fungerar inte

**Symptom:** Firefox frågar efter lösenord på portal.office.com

**Lösning:**

1. Verifiera Windows-inloggning:
   ```powershell
   whoami /upn
   ```
   Ska visa: `christian.wallen@gridshield.se`

2. Kontrollera about:config:
   ```javascript
   network.http.windows-sso.enabled = true
   network.negotiate-auth.trusted-uris = .microsoft.com,.microsoftonline.com
   ```

3. Testa i ny container:
   - Skapa ny Work-M365 container
   - Testa på nytt

4. Om fortfarande problem:
   ```powershell
   # Återanslut till Azure AD
   dsregcmd /leave
   # Starta om
   # Settings → Accounts → Access work or school → Connect
   ```

### B.2 Burp Suite Certificate Error

**Symptom:** "Warning: Potential Security Risk Ahead" trots importerat CA-certifikat

**Lösning:**

1. Verifiera att certifikatet är importerat:
   ```
   about:preferences#privacy → Certificates → View Certificates → Authorities
   ```
   Sök efter "PortSwigger"

2. Om inte listat:
   - Ta bort gammalt certifikat
   - Ladda om från `http://burpsuite` (med proxy aktiverad)
   - Importera igen

3. Kontrollera FoxyProxy:
   - Verifiera att `127.0.0.1:8080` är korrekt
   - Testa med "Burp Suite everywhere" mode

### B.3 Container-isolering fungerar inte

**Symptom:** Cookies/sessions läcker mellan containers

**Lösning:**

1. Verifiera Firefox-version:
   ```
   about:support → Application Basics → Version
   ```
   Måste vara Firefox Developer Edition 120+

2. Kontrollera Container-inställningar:
   Multi-Account Containers → Preferences → "Isolate containers from each other" ✓

3. Testa isolering:
   - Logga in på gmail.com i Work-Google container
   - Öppna gmail.com i Personal container
   - Ska **inte** vara inloggad

4. Om fortfarande problem:
   ```
   about:config → privacy.firstparty.isolate = true
   ```

### B.4 Extensions funkar inte i containers

**Symptom:** uBlock Origin/Bitwarden fungerar inte i vissa containers

**Lösning:**

1. Kontrollera extension-permissions:
   ```
   about:addons → [Extension] → Permissions → "Run in Private Windows" ✓
   ```

2. Verifiera container-access:
   Multi-Account Containers → Extension preferences → Allow in all containers

3. Återinstallera extension:
   - Avinstallera
   - Starta om Firefox
   - Installera igen

---

## Appendix C: Security Incident Response

### C.1 Malicious Extension Detected

**Tecken på malware:**
- Oväntade popups
- Omdirigering till okända sidor
- Ökad CPU-användning
- Requests till okända domäner (synliga i Burp/ZAP)

**Omedelbara åtgärder:**

1. **Koppla från nätverk**
2. **Identifiera extension:**
   ```
   about:addons → Extensions
   ```
   Leta efter nya/okända extensions
3. **Ta bort omedelbart**
4. **Rensa data:**
   ```
   about:preferences#privacy → Clear Data → ALL
   ```
5. **Scanna system:**
   ```powershell
   # Windows Defender Quick Scan
   Start-MpScan -ScanType QuickScan
   ```

6. **Rotiera känsliga credentials:**
   - Byt lösenord i Bitwarden
   - Rotiera SSH-nycklar
   - Kontakta GridShield IT

### C.2 Phishing Attack

**Om du klickat på misstänkt länk:**

1. **Identifiera container:**
   - Om Work-M365: **Hög risk** - kontakta IT omedelbart
   - Om Testing-Sandbox: **Låg risk** - radera container

2. **Rensa drabbad container:**
   Multi-Account Containers → Manage Containers → [Container] → Delete → Skapa ny

3. **Scanna för malware:**
   ```powershell
   Start-MpScan -ScanType FullScan
   ```

4. **Rapportera:**
   - Dokumentera URL
   - Screenshot (om möjligt)
   - Rapportera till GridShield Security

### C.3 Suspected Man-in-the-Middle Attack

**Tecken:**
- Oväntat certifikatvarning på känd webbplats
- Ändrat certifikat-fingerprint
- SSL-fel på tidigare fungerande sidor

**Åtgärder:**

1. **Stoppa all aktivitet**
2. **Verifiera nätverk:**
   ```powershell
   ipconfig /all
   netstat -an | findstr ESTABLISHED
   ```
3. **Koppla från WiFi/Ethernet**
4. **Kontakta GridShield Network Security**
5. **Rensa Firefox:**
   ```
   about:preferences#privacy → Clear Data → Cookies + Cache
   ```

---

## Slutkommentar

Denna implementeringsguide skapar en **produktionsklar, säker arbetsmiljö** för GridShield Security's cybersäkerhetsbehov. Genom att följa alla faser får du:

✅ **Zero Trust-arkitektur** med container-isolering
✅ **Seamless Microsoft 365/Azure AD SSO**
✅ **Purple Team-verktygslåda** (Burp Suite, ZAP, Kali Linux)
✅ **Utvecklarmiljö** integrerad med GitLab, GitHub, GitBook
✅ **Privacy-hardening** med 50+ säkerhetsinställningar
✅ **Automated workflows** via GitHub Copilot CLI

**Viktigt att komma ihåg:**
- Följ vecko/månads-rutinerna (Fas 12)
- Använd alltid rätt container för rätt ändamål
- Rapportera säkerhetsincidenter omedelbart
- Håll extensions och Firefox uppdaterade

**Support:**
- Intern dokumentation: `\\gridshield\docs\firefox-setup`
- IT Support: `it-support@gridshield.se`
- Security incidents: `security@gridshield.se`

---

**God cybersäkerhet! 🛡️🔥**

*GridShield Security - Protecting Critical Infrastructure*
