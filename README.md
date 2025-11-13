# GridShield Security - Firefox Developer Edition Setup

**Zero Trust Browser Environment för OT/ICS Cybersecurity**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows 11](https://img.shields.io/badge/Windows-11-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![Firefox Developer Edition](https://img.shields.io/badge/Firefox-Developer%20Edition-FF7139?logo=firefox-browser)](https://www.mozilla.org/firefox/developer/)

---

## Översikt

Detta repository innehåller en **komplett implementeringsplan och automatiserade installationsskript** för att konfigurera Firefox Developer Edition som en säker, container-isolerad arbetsmiljö anpassad för **GridShield Security's cybersäkerhetsarbete** inom OT/ICS-området.

### Vad du får

✅ **Zero Trust-arkitektur** med 7 isolerade containers
✅ **Microsoft 365/Azure AD Seamless SSO**
✅ **50+ säkerhetsinställningar** (WebRTC-blockering, HTTPS-Only, telemetri-avstängning)
✅ **Purple Team-verktygslåda** (Burp Suite, OWASP ZAP, Kali Linux-integration)
✅ **GitLab/GitHub/GitBook-integration**
✅ **Windows Terminal-optimering**
✅ **GitHub Copilot CLI-automation**

---

## Snabbstart

### För Windows-användare (Rekommenderat)

**Steg 1: Ladda ner repository**

```powershell
# Klona repository
git clone https://github.com/yourusername/gridshield-firefox-setup.git
cd gridshield-firefox-setup
```

**Steg 2: Kör automatisk installation**

```powershell
# Öppna PowerShell som Administratör
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Kör installationsskriptet
.\scripts\Install-GridShieldFirefox.ps1
```

**Vad skriptet gör:**
- ✅ Installerar Firefox Developer Edition
- ✅ Installerar Git for Windows
- ✅ Installerar Windows Terminal
- ✅ Installerar WSL2 + Kali Linux
- ✅ Skapar Firefox-profil "GridShield-Security"
- ✅ Tillämpar 50+ säkerhetsinställningar automatiskt
- ✅ Skapar skrivbordsgenväg

**Tidsåtgång:** ~15-20 minuter

**Steg 3: Manuella steg (krävs)**

Efter automatisk installation:
1. Installera [Essential Extensions](#essential-extensions) (15 min)
2. Konfigurera [Containers](#container-struktur) (20 min)
3. Testa [Azure AD SSO](#microsoft-365-integration) (5 min)

**Total setup:** ~1 timme för produktionsklar miljö

---

## Dokumentation

### Huvuddokument

📘 **[IMPLEMENTATION-GUIDE.md](IMPLEMENTATION-GUIDE.md)** - Komplett steg-för-steg guide (alla 12 faser)

### Innehåll

| Fas | Beskrivning | Tid | Prioritet |
|-----|-------------|-----|-----------|
| **1-2** | Installation & Security Hardening | 30 min | ⚠️ Kritisk |
| **3-4** | Containers & Extensions | 60 min | ⚠️ Kritisk |
| **5-7** | M365/GitLab/Google Integration | 45 min | 🔸 Hög |
| **8-9** | Security Testing & WSL Kali | 30 min | 🔹 Medium |
| **10-11** | Windows Terminal & Copilot CLI | 45 min | 🔸 Hög |
| **12** | Maintenance & Best Practices | Löpande | ⚠️ Kritisk |

---

## Container-struktur

Firefox Multi-Account Containers skapar **isolerade browsing-miljöer** för olika ändamål:

| Container | Färg | Användning | Exempel |
|-----------|------|-----------|---------|
| **🔵 Work-M365** | Blå | Microsoft 365, Azure, Teams | `portal.office.com`, `portal.azure.com` |
| **🟢 Work-Google** | Grön | Google Workspace | `mail.google.com`, `drive.google.com` |
| **🟠 Development** | Orange | GitLab, GitHub, GitBook | `gitlab.com`, `github.com` |
| **🔴 Client-Access** | Röd | Klientportaler (Svenska Kraftnät, etc.) | Lägg till efter behov |
| **🟣 Security-Research** | Lila | CVE-databaser, Claroty, Nozomi | `nvd.nist.gov`, `claroty.com` |
| **🟡 Testing-Sandbox** | Gul | Osäkra sidor, auto-delete cookies | Används för pentesting |
| **⚪ Personal** | Vit | Bank, LinkedIn, privat | `linkedin.com`, bank-domäner |

**Zero Trust-principen:**
- Ingen cross-contamination mellan containers
- Automatisk cookie-radering i Testing-Sandbox
- Client-Access isolerad från resten

---

## Essential Extensions

Installeras **endast** från [Mozilla Add-ons](https://addons.mozilla.org):

| Extension | Syfte | Konfiguration |
|-----------|-------|---------------|
| **Multi-Account Containers** | Container-isolering | Se [Fas 3](IMPLEMENTATION-GUIDE.md#fas-3-container-configuration) |
| **uBlock Origin** | Ad/tracker blocking | Aktivera alla "Privacy" & "Malware" filter lists |
| **Bitwarden** | Lösenordshantering | Vault timeout: 15 min, Auto-fill aktiverad |
| **FoxyProxy** | Burp Suite/ZAP proxy | Burp: `127.0.0.1:8080`, ZAP: `127.0.0.1:8081` |
| **Wappalyzer** | Teknologi-fingerprinting | Används i Development & Security-Research |
| **Cookie-Editor** | Session manipulation | Endast i Development & Testing-Sandbox |
| **User-Agent Switcher** | User-agent manipulation | För reconnaissance |

---

## Microsoft 365 Integration

### Azure AD Seamless SSO

Firefox konfigureras automatiskt för **Windows Integrated Authentication** med Azure AD/Entra ID:

**Automatisk inloggning på:**
- ✅ portal.office.com
- ✅ portal.azure.com
- ✅ teams.microsoft.com
- ✅ *.sharepoint.com
- ✅ Alla Microsoft-tjänster

**Hur det fungerar:**
- Använder ditt Windows 11-konto (`christian.wallen@gridshield.se`)
- Ingen manuell inloggning behövs
- Fungerar med Conditional Access Policies

**Konfiguration:**

Automatiskt tillämpad i `user.js`:
```javascript
network.negotiate-auth.trusted-uris = .microsoft.com,.microsoftonline.com,...
network.http.windows-sso.enabled = true
```

---

## Security Testing

### Burp Suite Integration

**Förutsättning:** Burp Suite Community/Pro installerat

**Setup:**
1. Starta Burp → Proxy → `127.0.0.1:8080`
2. Firefox → FoxyProxy → Aktivera "Burp Suite"
3. Importera Burp CA-certifikat (`http://burpsuite` → Download)
4. Firefox → `about:preferences#privacy` → Certificates → Import

**Användning:**
- Öppna **Testing-Sandbox container**
- Aktivera FoxyProxy "Burp Suite"
- All trafik interceptas i Burp

### OWASP ZAP Integration

Liknande setup med port `8081` - se [Fas 8](IMPLEMENTATION-GUIDE.md#fas-8-security-testing-configuration)

---

## WSL2 Kali Linux Integration

**Installation (inkluderat i automatiskt skript):**

```powershell
wsl --install -d kali-linux
```

**Kali → Firefox Integration:**

```bash
# Kör sqlmap via Burp Suite proxy (kör i Windows Firefox)
sqlmap -u "http://target.com/vuln.php?id=1" \
  --proxy="http://127.0.0.1:8080" \
  --batch
```

**Resultat:** Kali-verktyg → Burp Suite (Windows) → Firefox containers

---

## Windows Terminal Optimering

### Custom Profiler

**Inkluderat i setup:**
- 🛡️ **GridShield PowerShell** - Huvudprofil med GridShield-tema
- 🐧 **Kali Linux (WSL2)** - Direkt åtkomst till Kali
- ⚡ **Git Bash** - För Git-operationer
- 🔧 **Development (Node.js)** - Med Node/npm förkonfigurerat

### Genvägar

| Kommando | Funktion |
|----------|----------|
| `Ctrl+Shift+T` | Ny tab |
| `Alt+Shift++` | Dela horisontellt |
| `Alt+Shift+-` | Dela vertikalt |
| `Ctrl+,` | Öppna inställningar |

---

## GitHub Copilot CLI

### Installation (WSL2)

```bash
# I Kali Linux (WSL2)
sudo npm install -g @githubnext/github-copilot-cli
github-copilot-cli auth
```

### Användning

**Aliases (auto-konfigurerade):**

```bash
# Kommandoförslag
gp "List all running Docker containers"

# Förklara kommandon
ge "docker run -d -p 8080:80 nginx"

# GitLab-integration
gl-mr   # Skapa Merge Request
gl-status   # Kontrollera pipeline

# Firefox-integration från terminal
ff-gitlab   # Öppna GitLab i Development container
ff-azure    # Öppna Azure Portal i Work-M365 container
```

---

## Säkerhetsfunktioner

### Privacy & Security Hardening

**50+ inställningar inkluderat:**

- ✅ **WebRTC inaktiverat** - Förhindrar IP-läckage
- ✅ **HTTPS-Only mode** - Tvingar krypterad trafik
- ✅ **Telemetri avstängt** - Ingen data till Mozilla
- ✅ **Fingerprinting resistance** - Svårare att spåra
- ✅ **First-party isolation** - Cookies isolerade per site
- ✅ **DNS prefetching avstängt** - Förhindrar DNS-läckage
- ✅ **Geolocation avstängt** - Ingen positionsdelning

**Verifiera säkerhet:**

```
Testa WebRTC: https://browserleaks.com/webrtc
Testa fingerprinting: https://coveryourtracks.eff.org/
```

**Förväntat resultat:**
- "WebRTC is not supported" eller inga IP-adresser synliga
- "Strong protection against tracking"

---

## Underhåll

### Veckorutiner (15 min)

- [ ] Uppdatera Firefox: `about:help`
- [ ] Uppdatera Extensions: `about:addons`
- [ ] Verifiera Testing-Sandbox cookie-cleanup
- [ ] Exportera Bitwarden-backup

### Månadsrutiner (30 min)

- [ ] Säkerhetsaudit (WebRTC, fingerprinting)
- [ ] Extension security review
- [ ] SSH-nyckel rotation (valfritt)
- [ ] Burp/ZAP CA-certifikat förnyelse

**Fullständig guide:** [Fas 12 - Maintenance](IMPLEMENTATION-GUIDE.md#fas-12-maintenance--best-practices)

---

## Troubleshooting

### Vanliga problem

| Problem | Lösning |
|---------|---------|
| **Azure AD SSO fungerar inte** | Verifiera: `whoami /upn` ska visa `christian.wallen@gridshield.se` |
| **Burp Certificate Error** | Importera om CA från `http://burpsuite` (med proxy aktiverad) |
| **Container-isolering fungerar inte** | Kontrollera: `privacy.firstparty.isolate = true` i `about:config` |
| **Extensions funkar inte i containers** | Verifiera: Extension permissions → "Run in Private Windows" ✓ |

**Fullständig troubleshooting:** [Appendix B](IMPLEMENTATION-GUIDE.md#appendix-b-troubleshooting-guide)

---

## Repository-struktur

```
gridshield-firefox-setup/
├── README.md                       # Denna fil
├── IMPLEMENTATION-GUIDE.md         # Komplett guide (alla 12 faser)
├── LICENSE                         # MIT License
├── scripts/
│   ├── Install-GridShieldFirefox.ps1   # Automatiskt installationsskript
│   └── Uninstall-GridShieldFirefox.ps1 # Avinstallationsskript (valfritt)
├── docs/
│   ├── containers-setup.md         # Detaljerad container-konfiguration
│   ├── azure-ad-sso.md             # Azure AD SSO-felsökning
│   └── security-checklist.md       # Månatlig säkerhetschecklista
└── assets/
    ├── screenshots/                # Screenshots för guiden
    └── logos/                      # GridShield/Firefox-logotyper
```

---

## Systemkrav

### Minimum

- **OS:** Windows 11 Pro (22H2 eller senare)
- **RAM:** 16 GB (32 GB rekommenderat)
- **Disk:** 50 GB ledigt utrymme
- **Nätverk:** Stabil internetanslutning

### Konton

- GridShield Microsoft 365-konto (`christian.wallen@gridshield.se`)
- GitHub-konto med Copilot-licens
- GitLab-konto
- Bitwarden Premium (rekommenderat)

---

## Licens

Detta projekt är licensierat under [MIT License](LICENSE).

**OBS:** Vissa komponenter (Firefox, Burp Suite, OWASP ZAP) har sina egna licenser.

---

## Kontakt & Support

**GridShield Security**
- **Intern dokumentation:** `\\gridshield\docs\firefox-setup`
- **IT Support:** `it-support@gridshield.se`
- **Security incidents:** `security@gridshield.se`

**GitHub Issues:**
- [Rapportera bug](https://github.com/yourusername/gridshield-firefox-setup/issues/new?template=bug_report.md)
- [Föreslå feature](https://github.com/yourusername/gridshield-firefox-setup/issues/new?template=feature_request.md)

---

## Bidrag

Interna bidrag välkomnas! Se [CONTRIBUTING.md](CONTRIBUTING.md) för riktlinjer.

---

## Changelog

### Version 1.0 (2025-11-13)

**Initial release:**
- ✅ Komplett implementeringsguide (12 faser)
- ✅ Automatiskt PowerShell-installationsskript
- ✅ Container-konfigurationer (7 st)
- ✅ Azure AD SSO-integration
- ✅ Burp Suite/OWASP ZAP-integration
- ✅ WSL2 Kali Linux-integration
- ✅ Windows Terminal-optimering
- ✅ GitHub Copilot CLI-automation

---

**God cybersäkerhet! 🛡️🔥**

*GridShield Security - Protecting Critical Infrastructure*
