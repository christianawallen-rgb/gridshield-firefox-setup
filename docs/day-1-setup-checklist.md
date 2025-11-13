# GridShield Security - Day 1 Setup Checklist

**Total tid:** 4-5 timmar från noll till produktionsklar miljö
**Datum:** Genomför helst på en helg/lugn dag

---

## 📋 Översikt

Denna checklist koordinerar **alla guider** i rätt ordning för att sätta upp din kompletta GridShield Security-miljö på ett enda dygn.

**Vad du får efter Day 1:**
- ✅ End-to-end encrypted email (Proton Business)
- ✅ Unlimited email aliases (SimpleLogin Premium)
- ✅ Secure password manager (Proton Pass)
- ✅ Zero Trust Firefox med 7 containers
- ✅ Microsoft 365 hybrid-integration
- ✅ Windows Terminal optimering
- ✅ WSL2 Kali Linux för pentesting
- ✅ Burp Suite/OWASP ZAP integration

---

## ⏱️ Timeline & Estimat

| Fas | Tid | Kan pausas? | Guide |
|-----|-----|-------------|-------|
| **Pre-Setup** | 15 min | ✅ | [Steg 1](#steg-1-pre-setup-förberedelser-15-min) |
| **Proton Business Setup** | 45 min | ✅ | [Steg 2](#steg-2-proton-business-setup-45-min) |
| **DNS Configuration** | 30 min | ✅ | [Steg 3](#steg-3-dns-konfiguration-i-loopia-30-min) |
| **DNS Propagation Wait** | 30-60 min | ✅ ☕ | [Steg 4](#steg-4-vänta-på-dns-propagation-30-60-min) |
| **Email Testing** | 15 min | ❌ | [Steg 5](#steg-5-email-testing--verification-15-min) |
| **Windows 11 Installation** | 30 min | ❌ | [Steg 6](#steg-6-windows-11-installation-30-min) |
| **Firefox Setup** | 60 min | ✅ | [Steg 7](#steg-7-firefox-developer-edition-setup-60-min) |
| **Windows Terminal** | 20 min | ✅ | [Steg 8](#steg-8-windows-terminal-optimering-20-min) |
| **WSL2 Kali Linux** | 30 min | ✅ | [Steg 9](#steg-9-wsl2-kali-linux-optional-30-min) |
| **Final Verification** | 15 min | ❌ | [Steg 10](#steg-10-final-verification--testing-15-min) |

**Total:** ~4-5 timmar (inkl. väntetider)

---

## 🎯 Färdiga Material att Ha Tillgängliga

### Konton & Credentials

- [ ] Proton Business-konto (inloggningsuppgifter redo)
- [ ] Loopia-konto (gridshield.se DNS-access)
- [ ] Microsoft 365-konto (om du har, annars skapas nytt)
- [ ] GitHub-konto (för Copilot CLI)
- [ ] GitLab-konto (för development)

### Hårdvara

- [ ] Huvuddator (Windows 11 Pro kommer installeras)
- [ ] Backup-enhet (för att läsa guider under installation)
- [ ] Ventoy USB (med Windows 11 ISO + detta repository)
- [ ] Smartphone (för 2FA codes)

### Nedladdade Filer (På Ventoy USB)

- [ ] Windows 11 Pro ISO
- [ ] Detta repository (gridshield-firefox-setup)
- [ ] Firefox Developer Edition installer (backup)
- [ ] Proton Mail Desktop installer (backup)

---

## Steg 1: Pre-Setup Förberedelser (15 min)

### 1.1 Läs Igenom Alla Guider (Snabbt)

**Skim through (5 min vardera):**
- [ ] `docs/proton-business-setup.md` - Få översikt av Proton-setup
- [ ] `docs/dns-configuration-loopia.md` - Förstå DNS-records
- [ ] `docs/quick-start.md` - Firefox snabbstart
- [ ] `IMPLEMENTATION-GUIDE.md` - Full guide (referens)

**Tips:** Öppna alla PDFs/guider på din backup-enhet så du har dem tillgängliga under installation.

### 1.2 Säkerhetskopiera Befintlig Data (Om Applicable)

**Om du har befintlig Windows-installation:**
- [ ] Backup viktiga filer till extern disk/cloud
- [ ] Exportera befintliga Firefox bookmarks (om du har)
- [ ] Exportera Bitwarden vault (om du använder)
- [ ] Lista installerade program (för reinstallation)

**Om fresh install:**
- [ ] Skippa detta steg

### 1.3 Förbered Recovery Options

- [ ] Skriv ner Proton account recovery email/phone
- [ ] Spara Loopia login credentials säkert
- [ ] Ha tillgång till telefon för 2FA

---

## Steg 2: Proton Business Setup (45 min)

**📖 Fullständig Guide:** `docs/proton-business-setup.md`

### 2.1 Logga In på Proton Business

- [ ] Öppna: https://account.proton.me
- [ ] Logga in med ditt Proton Business-konto
- [ ] Verifiera att du har Business-plan aktiv

### 2.2 Lägg Till gridshield.se Domän

- [ ] Navigate: **Mail** → **Settings** → **Domain names**
- [ ] Klicka: **Add domain**
- [ ] Ange: `gridshield.se`
- [ ] Kopiera TXT verification code (format: `protonmail-verification=...`)

**💾 Spara alla DNS-värden som Proton visar - du behöver dem i nästa steg!**

### 2.3 Skapa Email-Adress

- [ ] **Mail** → **Settings** → **Addresses**
- [ ] **Add address:** `christian.wallen@gridshield.se`
- [ ] **Set as primary address**
- [ ] **Add aliases:**
  - [ ] `cw@gridshield.se`
  - [ ] `christian@gridshield.se`

### 2.4 Skapa Shared Mailboxes (Optional, kan göras senare)

- [ ] `info@gridshield.se` - General inquiries
- [ ] `security@gridshield.se` - Security reports
- [ ] `support@gridshield.se` - Customer support
- [ ] `projects@gridshield.se` - Project communication

### 2.5 SimpleLogin Premium Setup

- [ ] Öppna: https://app.simplelogin.io
- [ ] **Sign in with Proton**
- [ ] Verifiera att Premium är aktivt
- [ ] **Settings** → **Custom domains** → **Add domain**
- [ ] Ange: `alias.gridshield.se`
- [ ] Kopiera verification code + DNS-värden

---

## Steg 3: DNS Konfiguration i Loopia (30 min)

**📖 Fullständig Guide:** `docs/dns-configuration-loopia.md`

### 3.1 Logga In på Loopia

- [ ] Öppna: https://customerzone.loopia.se
- [ ] Logga in
- [ ] Välj: `gridshield.se`
- [ ] Gå till: **DNS**

### 3.2 Rensa Befintliga Records (VIKTIGT!)

**Ta bort alla gamla MX records FÖRST:**
- [ ] Ta bort gamla MX records (om några finns)
- [ ] Ta bort gamla SPF TXT records (om konflikt)

### 3.3 Lägg Till Proton Business DNS Records

**Följ exakt ordning från `dns-configuration-loopia.md`:**

#### TXT: Domain Verification
- [ ] Type: `TXT`
- [ ] Host: `@`
- [ ] Value: `protonmail-verification=xxxxxxx` (från Proton)
- [ ] TTL: `3600`

#### MX: Mail Routing
- [ ] MX Priority `10` → `mail.protonmail.ch`
- [ ] MX Priority `20` → `mailsec.protonmail.ch`

#### TXT: SPF
- [ ] Host: `@`
- [ ] Value: `v=spf1 include:_spf.protonmail.ch ~all`

#### CNAME: DKIM (3 st)
- [ ] `protonmail._domainkey` → `protonmail.domainkey.dXXXX.domains.proton.ch`
- [ ] `protonmail2._domainkey` → `protonmail2.domainkey.dXXXX.domains.proton.ch`
- [ ] `protonmail3._domainkey` → `protonmail3.domainkey.dXXXX.domains.proton.ch`

**OBS:** `dXXXX` är unikt för ditt Proton-konto - kopiera EXAKT från Proton!

#### TXT: DMARC
- [ ] Host: `_dmarc`
- [ ] Value: `v=DMARC1; p=quarantine; rua=mailto:postmaster@gridshield.se; pct=100; adkim=s; aspf=s`

### 3.4 Lägg Till SimpleLogin DNS Records

**För alias.gridshield.se:**

#### TXT: Verification
- [ ] Host: `alias`
- [ ] Value: `sl-verification=xxxxxxx` (från SimpleLogin)

#### MX: Alias Routing
- [ ] MX Priority `10` (Host: `alias`) → `mx1.simplelogin.co`
- [ ] MX Priority `20` (Host: `alias`) → `mx2.simplelogin.co`

#### TXT: SPF för Alias
- [ ] Host: `alias`
- [ ] Value: `v=spf1 include:simplelogin.co ~all`

#### TXT: DMARC för Alias
- [ ] Host: `_dmarc.alias`
- [ ] Value: `v=DMARC1; p=quarantine; pct=100; rua=mailto:postmaster@gridshield.se`

### 3.5 Spara Allt

- [ ] **Spara** alla DNS records i Loopia
- [ ] Dubbelkolla att inget är feltskrivet
- [ ] Verifiera inga extra punkter (`.`) i slutet av värden

---

## Steg 4: Vänta på DNS Propagation (30-60 min)

### 4.1 Initial Wait (15 min)

**Gör något annat medan DNS propagerar:**
- [ ] Ta en kaffe ☕
- [ ] Läs igenom Firefox setup guide
- [ ] Förbered Windows 11 USB

### 4.2 Check DNS Propagation (Efter 15 min)

**PowerShell commands:**
```powershell
# Check MX records
nslookup -type=mx gridshield.se

# Förväntat resultat:
# gridshield.se mail exchanger = 10 mail.protonmail.ch
# gridshield.se mail exchanger = 20 mailsec.protonmail.ch

# Check TXT records (SPF)
nslookup -type=txt gridshield.se

# Check MX för alias-subdomain
nslookup -type=mx alias.gridshield.se
```

**Online checker:**
- [ ] Gå till: https://dnschecker.org
- [ ] Check: `gridshield.se` MX records
- [ ] Verifiera: Green checkmarks globalt

### 4.3 Extended Wait (Om inte propagerat)

**Om DNS inte visar korrekt:**
- [ ] Vänta ytterligare 15-30 minuter
- [ ] Flush DNS cache: `ipconfig /flushdns`
- [ ] Check igen

---

## Steg 5: Email Testing & Verification (15 min)

**📖 Guide:** `docs/proton-business-setup.md` (Fas 9)

### 5.1 Verifiera Domän i Proton

- [ ] Tillbaka till Proton: **Settings** → **Domain names**
- [ ] gridshield.se → **Verify domain**
- [ ] ✅ **Domain verified** ska visas

### 5.2 Skicka Test Email

- [ ] Öppna Proton Mail: https://mail.proton.me
- [ ] **Compose** ny email
- [ ] **To:** `christian.wallen@gridshield.se` (till dig själv)
- [ ] **Subject:** `DNS Test - GridShield Security`
- [ ] **Body:** `Testing email delivery efter DNS-konfiguration.`
- [ ] **Send**

**Förväntat resultat:**
- [ ] Email delivered inom 1-2 minuter
- [ ] Synlig i inbox

### 5.3 Check Email Headers

- [ ] Öppna test-email
- [ ] **More** → **View headers**
- [ ] Verifiera:
  - [ ] `SPF: PASS`
  - [ ] `DKIM: PASS`
  - [ ] `DMARC: PASS`

### 5.4 Mail-Tester.com Score

- [ ] Gå till: https://www.mail-tester.com
- [ ] Kopiera email-adressen som visas
- [ ] Send email från Proton Mail till den adressen
- [ ] Gå tillbaka till mail-tester.com
- [ ] **Check your score**

**Mål:** 10/10 ⭐

**Om lägre score:**
- [ ] Check errors listed
- [ ] Fix DNS records enligt feedback
- [ ] Test igen

### 5.5 SimpleLogin Alias Test

- [ ] SimpleLogin: **New alias** → `test@alias.gridshield.se`
- [ ] Send email FROM extern (Gmail, etc.) till `test@alias.gridshield.se`
- [ ] Check: Email forwarded till `christian.wallen@gridshield.se`

---

## Steg 6: Windows 11 Installation (30 min)

**📖 Guide:** Använd standard Windows 11 installation + Azure AD join

### 6.1 Boot från Ventoy USB

- [ ] Sätt i Ventoy USB
- [ ] Starta om dator
- [ ] Boot från USB (F12/Del/F2 beroende på BIOS)
- [ ] Välj: Windows 11 Pro ISO

### 6.2 Windows 11 Installation

- [ ] Språk: **Svenska** (eller English)
- [ ] Version: **Windows 11 Pro** (VIKTIGT för Azure AD)
- [ ] Partition: **Clean install** (radera gamla partitions)
- [ ] Vänta på installation (15-20 min)

### 6.3 OOBE Setup (Out-of-Box Experience)

- [ ] Region: **Sverige**
- [ ] Keyboard: **Swedish**
- [ ] Nätverk: **Anslut till WiFi/Ethernet**

### 6.4 Microsoft Account / Azure AD Join

**Välj EN av följande:**

**Option A: Azure AD Join (Rekommenderat för M365):**
- [ ] "Sign in with work or school account"
- [ ] Ange: `christian.wallen@m365.gridshield.se`
- [ ] (Om m365-tenant inte finns: Skapa först i Microsoft 365 Admin)

**Option B: Lokalt konto (Enklare initial setup):**
- [ ] "Set up for personal use"
- [ ] "Sign in without Microsoft account"
- [ ] Användarnamn: `christian`
- [ ] (Kan joina Azure AD senare)

### 6.5 Privacy Settings

- [ ] **Disable** alla tracking options (Location, Diagnostics, etc.)
- [ ] **Enable:** Windows Hello (fingerprint/face om tillgängligt)
- [ ] **Disable:** Cortana

### 6.6 Initial Windows Update

- [ ] **Settings** → **Windows Update** → **Check for updates**
- [ ] Installera alla kritiska uppdateringar
- [ ] Starta om om nödvändigt

---

## Steg 7: Firefox Developer Edition Setup (60 min)

**📖 Fullständig Guide:** `docs/quick-start.md` + `IMPLEMENTATION-GUIDE.md`

### 7.1 Klona Repository

**PowerShell:**
```powershell
cd $env:USERPROFILE\Downloads
git clone https://github.com/christianawallen-rgb/gridshield-firefox-setup.git
cd gridshield-firefox-setup
```

**Om git inte installerat:**
- [ ] Kopiera från Ventoy USB istället

### 7.2 Automatisk Installation

**PowerShell (som Administrator):**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\Install-GridShieldFirefox.ps1
```

**Skriptet installerar:**
- [ ] Firefox Developer Edition
- [ ] Git for Windows
- [ ] Windows Terminal
- [ ] WSL2 (optional, välj 'N' om du gör det senare)
- [ ] Skapar profil "GridShield-Security"
- [ ] Tillämpar säkerhetsinställningar (user.js)

**Tid:** ~15-20 minuter

### 7.3 Installera Essential Extensions

**I Firefox:**

#### Multi-Account Containers
- [ ] `about:addons` → Sök "Multi-Account Containers"
- [ ] **Add to Firefox** (Mozilla official)

**Importera container-konfiguration:**
- [ ] Container-ikonen → **Manage Containers** → **Settings**
- [ ] **Import/Export** → **Import**
- [ ] Välj: `gridshield-firefox-setup\assets\containers-config.json`
- [ ] ✅ **7 containers skapade automatiskt**

#### uBlock Origin
- [ ] `about:addons` → Sök "uBlock Origin"
- [ ] **Add to Firefox**
- [ ] Dashboard → **Filter lists** → Aktivera: Ads, Privacy, Malware

#### Proton Pass
- [ ] `about:addons` → Sök "Proton Pass"
- [ ] **Add to Firefox**
- [ ] Logga in: `christian.wallen@gridshield.se`
- [ ] **Settings:**
  - [ ] Enable autofill
  - [ ] Enable SimpleLogin alias generation
  - [ ] Use biometric unlock

#### FoxyProxy Standard
- [ ] `about:addons` → Sök "FoxyProxy Standard"
- [ ] **Add to Firefox**
- [ ] **Options** → **Add Proxy:**
  - [ ] Burp Suite: `127.0.0.1:8080`
  - [ ] OWASP ZAP: `127.0.0.1:8081`

#### Wappalyzer
- [ ] `about:addons` → Sök "Wappalyzer"
- [ ] **Add to Firefox**

### 7.4 Installera userChrome.css (Optional)

**För GridShield Dark Theme:**

1. [ ] `about:support` → **Profile Directory** → **Open Directory**
2. [ ] Skapa mapp: `chrome`
3. [ ] Kopiera: `gridshield-firefox-setup\assets\userChrome.css` → `chrome\userChrome.css`
4. [ ] Starta om Firefox

**Resultat:** Dark theme med förstärkta container-indikatorer

### 7.5 Testa Azure AD SSO (Om M365 används)

- [ ] Öppna ny tab i **Work-M365 container**
- [ ] Navigera: `https://portal.office.com`
- [ ] **Förväntat:** Automatisk inloggning

**Om inte automatisk:**
```powershell
# Verifiera Azure AD join
whoami /upn
# Ska visa: christian.wallen@m365.gridshield.se
```

### 7.6 Testa Proton Mail Integration

- [ ] Öppna ny tab i **Work-Proton container**
- [ ] Navigera: `https://mail.proton.me`
- [ ] Logga in: `christian.wallen@gridshield.se`
- [ ] ✅ Ska öppnas automatiskt i Work-Proton container

---

## Steg 8: Windows Terminal Optimering (20 min)

**📖 Guide:** `IMPLEMENTATION-GUIDE.md` (Fas 10)

### 8.1 Installera Windows Terminal (Om inte redan)

**PowerShell:**
```powershell
winget install Microsoft.WindowsTerminal
```

**Eller:** Microsoft Store → "Windows Terminal"

### 8.2 Importera GridShield Settings

- [ ] Windows Terminal → **Settings** (Ctrl+,)
- [ ] **Open JSON file**
- [ ] Backup befintlig `settings.json`
- [ ] Ersätt innehåll med: `gridshield-firefox-setup\assets\windows-terminal-settings.json`
- [ ] **Anpassa sökvägar:**
  - [ ] Byt `%USERNAME%` mot ditt användarnamn
  - [ ] Verifiera Git Bash path om den är annorlunda
- [ ] **Spara**
- [ ] Starta om Terminal

**Resultat:** 6 profiler färdiga:
- 🛡️ GridShield PowerShell
- 🐧 Kali Linux (WSL2, om installerat)
- ⚡ Git Bash
- 🔧 Development (Node.js)
- 🐍 Python Environment
- 🔒 Security Tools (Admin)

### 8.3 Testa Profiler

- [ ] `Ctrl+Shift+T` → Ny tab
- [ ] Testa varje profil
- [ ] Verifiera färgscheman

---

## Steg 9: WSL2 Kali Linux (Optional, 30 min)

**📖 Guide:** `IMPLEMENTATION-GUIDE.md` (Fas 9) + `scripts/setup-wsl-kali.sh`

### 9.1 Installera WSL2 + Kali (Om inte redan)

**PowerShell (Admin):**
```powershell
wsl --install -d kali-linux
```

**Vänta på installation, sedan:**
- [ ] Sätt användarnamn/lösenord för Kali
- [ ] Vänta på Kali att starta klart

### 9.2 Kör Setup-Skript

**I Kali (WSL):**
```bash
cd ~
# Kopiera skript från Windows
cp /mnt/c/Users/<ditt-namn>/Downloads/gridshield-firefox-setup/scripts/setup-wsl-kali.sh ~/
chmod +x setup-wsl-kali.sh
./setup-wsl-kali.sh
```

**Skriptet installerar:**
- [ ] Node.js 20.x
- [ ] GitHub Copilot CLI
- [ ] SSH-konfiguration (GitLab, GitHub)
- [ ] Git-konfiguration
- [ ] GridShield bashrc aliases
- [ ] Kali security tools (optional)

**Tid:** ~20-30 minuter

### 9.3 GitHub Copilot CLI Auth

**I Kali:**
```bash
github-copilot-cli auth
```

- [ ] Följ instruktioner i browsern (Firefox, Development container)
- [ ] Logga in med GitHub-konto
- [ ] Bekräfta device code

### 9.4 Testa Integration

**Test 1: Copilot Command Suggestion**
```bash
gp "list all running processes sorted by CPU usage"
```

**Test 2: Firefox Integration från WSL**
```bash
ff-gitlab  # Öppnar GitLab i Firefox Development container
```

**Test 3: SSH till GitLab**
```bash
ssh -T git@gitlab.com
# Förväntat: "Welcome to GitLab, @yourusername!"
```

---

## Steg 10: Final Verification & Testing (15 min)

### 10.1 Email System Test

**Proton Mail:**
- [ ] Send email till extern (Gmail, etc.)
- [ ] Receive reply
- [ ] Check: SPF/DKIM/DMARC PASS

**SimpleLogin Alias:**
- [ ] Skapa alias: `test@alias.gridshield.se`
- [ ] Send från extern till alias
- [ ] Verify: Forwarded korrekt
- [ ] Reply från alias
- [ ] Verify: Recipient ser alias, inte main email

### 10.2 Firefox Container Test

**Work-M365:**
- [ ] Öppna: `https://portal.office.com`
- [ ] Verify: Opens in Work-M365 container (blue)
- [ ] Check: Auto-login om Azure AD joined

**Work-Proton:**
- [ ] Öppna: `https://mail.proton.me`
- [ ] Verify: Opens in Work-Proton container (green)
- [ ] Check: Session persists

**Development:**
- [ ] Öppna: `https://gitlab.com`
- [ ] Verify: Opens in Development container (orange)

**Testing-Sandbox:**
- [ ] Öppna random site
- [ ] Close all Sandbox tabs
- [ ] Reopen → Verify: Cookies deleted (not logged in)

### 10.3 Security Verification

**WebRTC Leak Test:**
- [ ] Öppna: https://browserleaks.com/webrtc
- [ ] **Förväntat:** "WebRTC is not supported" eller inga IP-läckor

**Fingerprinting Test:**
- [ ] Öppna: https://coveryourtracks.eff.org/
- [ ] **Förväntat:** "Strong protection against tracking"

**Password Manager:**
- [ ] Test Proton Pass autofill på någon site
- [ ] Verify: SimpleLogin alias auto-suggested

### 10.4 Windows Terminal Test

- [ ] Öppna: GridShield PowerShell profile
- [ ] Kör: `node --version`, `git --version`
- [ ] Öppna: Kali Linux profile (om installerat)
- [ ] Kör: `gp "system information"`

### 10.5 System Health Check

**Windows:**
```powershell
# Check BitLocker status (bör vara enabled)
manage-bde -status

# Check Windows Defender
Get-MpComputerStatus

# Check disk space
Get-PSDrive C
```

**Firefox:**
```
about:support
# Check: No errors
# Profile: GridShield-Security
```

---

## 🎉 Post-Setup: Du Är Klar!

### Sammanfattning av Vad Du Har Nu

**Email Infrastructure:**
- ✅ End-to-end encrypted email (@gridshield.se)
- ✅ Unlimited professional aliases (@alias.gridshield.se)
- ✅ Swiss privacy protection
- ✅ Mail-tester.com score: 10/10
- ✅ NIS2/GDPR-compliant

**Browser Security:**
- ✅ Firefox Developer Edition med 50+ security settings
- ✅ 7 isolated containers (Zero Trust)
- ✅ GridShield Dark Theme
- ✅ Essential security extensions

**Password Management:**
- ✅ Proton Pass för Business
- ✅ SimpleLogin alias integration
- ✅ 2FA TOTP codes
- ✅ Biometric unlock

**Development Environment:**
- ✅ Windows Terminal med 6 profiler
- ✅ WSL2 Kali Linux (optional)
- ✅ GitHub Copilot CLI
- ✅ Git/GitLab/GitHub configured
- ✅ SSH keys generated

**Microsoft 365 Integration:**
- ✅ Azure AD device management (optional)
- ✅ Teams för collaboration
- ✅ SharePoint för documents
- ✅ OneDrive syncing

---

## 📅 Maintenance Schedule

### Daily (2 min)

- [ ] Check Proton Mail inbox
- [ ] Review any security alerts

### Weekly (15 min)

- [ ] Firefox update check
- [ ] Extension updates
- [ ] Windows Update
- [ ] Proton Pass password health check

### Monthly (30 min)

- [ ] Full security audit (WebRTC, fingerprinting)
- [ ] SSH key review
- [ ] SimpleLogin alias cleanup (disable unused)
- [ ] Backup Firefox profile
- [ ] Review email sender reputation

### Quarterly (60 min)

- [ ] Full system security review
- [ ] WSL2 Kali full upgrade
- [ ] Review all active sessions (Proton, Microsoft, etc.)
- [ ] Update security tools (Burp Suite, etc.)
- [ ] Document changes to infrastructure

---

## 🆘 Emergency Contacts

**Proton Support:**
- Email: https://proton.me/support
- Business priority support

**Loopia Support:**
- Telefon: 021-12 82 22
- Email: support@loopia.se

**Microsoft 365 Support:**
- Sverige: +46 8 519 95 000
- Admin portal: https://admin.microsoft.com

**GitHub Support:**
- https://github.com/support

---

## 📚 Referensdokumentation

**Huvudguider:**
- [Proton Business Setup](proton-business-setup.md) - Detaljerad email-konfiguration
- [DNS Configuration Loopia](dns-configuration-loopia.md) - DNS steg-för-steg
- [Quick Start](quick-start.md) - Firefox 60-min setup
- [Burp Suite Setup](burp-suite-setup.md) - Security testing
- [IMPLEMENTATION-GUIDE.md](../IMPLEMENTATION-GUIDE.md) - Fullständig 12-fas guide

**Assets:**
- `assets/containers-config.json` - Import till Multi-Account Containers
- `assets/userChrome.css` - GridShield Dark Theme
- `assets/windows-terminal-settings.json` - Terminal-profiler

**Scripts:**
- `scripts/Install-GridShieldFirefox.ps1` - Automatisk installation
- `scripts/Backup-FirefoxProfile.ps1` - Backup-lösning
- `scripts/setup-wsl-kali.sh` - WSL2/Kali automation

---

## ✅ Final Checklist

**Mark när helt klar:**

- [ ] ✅ Proton Business email fungerar perfekt
- [ ] ✅ SimpleLogin aliases forwards korrekt
- [ ] ✅ DNS mail-tester.com score: 10/10
- [ ] ✅ Firefox containers isolerade och färgkodade
- [ ] ✅ Proton Pass autofill fungerar
- [ ] ✅ Windows Terminal alla profiler ok
- [ ] ✅ WSL2 Kali Linux (om installerat) fungerar
- [ ] ✅ Azure AD SSO (om används) fungerar
- [ ] ✅ Burp Suite CA-certifikat importerat (om används)
- [ ] ✅ GitHub/GitLab SSH nycklar konfigurerade
- [ ] ✅ All documentation bookmarked/saved

---

**🎊 GRATTIS! GridShield Security har nu military-grade cybersecurity setup! 🛡️🔐**

**Total tid använd:** ________ timmar

**Notes/Issues encountered:**
```
[Skriv ner eventuella problem och hur de löstes för framtida referens]




```

**Next steps:**
1. Bekanta dig med alla system
2. Skapa klient-specifika SimpleLogin aliases efter behov
3. Setup Burp Suite för penetrationstesting (se guide)
4. Konfigurera backups enligt maintenance schedule
5. Börja använda systemet i produktion!

---

**Repository:** https://github.com/christianawallen-rgb/gridshield-firefox-setup

**Version:** 1.0 - Complete Day 1 Setup
**Datum:** 2025-11-13
