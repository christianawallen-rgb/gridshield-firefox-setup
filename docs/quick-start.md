# GridShield Firefox Setup - Quick Start Guide

**Tid:** 60 minuter till produktionsklar miljö

---

## Översikt

Denna snabbstartsguide tar dig från noll till en fungerande, säker Firefox-miljö på 1 timme.

**Vad du får:**
- ✅ Firefox Developer Edition installerat
- ✅ 50+ säkerhetsinställningar aktiverade
- ✅ 7 isolerade containers konfigurerade
- ✅ Azure AD SSO aktiverat
- ✅ Essential Extensions installerade

---

## Steg 1: Klona Repository (5 min)

### Windows PowerShell

```powershell
# Öppna PowerShell
cd $env:USERPROFILE\Downloads

# Klona repository
git clone https://github.com/christianawallen-rgb/gridshield-firefox-setup.git
cd gridshield-firefox-setup
```

---

## Steg 2: Kör Automatisk Installation (20 min)

### PowerShell som Administratör

```powershell
# Högerklicka PowerShell → Kör som administratör

# Tillåt skriptkörning
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Kör installationsskriptet
.\scripts\Install-GridShieldFirefox.ps1
```

**Skriptet installerar:**
- Firefox Developer Edition
- Git for Windows
- Windows Terminal
- WSL2 + Kali Linux (valfritt)
- Skapar Firefox-profil "GridShield-Security"
- Tillämpar säkerhetsinställningar automatiskt

**Svara "J" när skriptet frågar om du vill öppna Firefox.**

---

## Steg 3: Installera Extensions (15 min)

### 3.1 Multi-Account Containers (Mozilla)

1. I Firefox, navigera till: `about:addons`
2. Sök efter "Multi-Account Containers"
3. Välj **Mozilla Firefox Multi-Account Containers**
4. Klicka **Add to Firefox**

**Importera färdig konfiguration:**

1. Klicka på Container-ikonen i verktygsfältet
2. **Manage Containers** → **Settings** → **Import/Export**
3. **Import** → Välj `assets/containers-config.json` från repository
4. Klicka **Import**

**Resultat:** 7 containers skapade automatiskt (Work-M365, Development, etc.)

### 3.2 uBlock Origin

1. `about:addons` → Sök "uBlock Origin"
2. **Add to Firefox**
3. Klicka på uBlock-ikonen → **Dashboard** (kugghjul)
4. **Filter lists:**
   - ✓ Alla "Ads" lists
   - ✓ Alla "Privacy" lists
   - ✓ Alla "Malware domains" lists
   - ✓ Annoyances (Cookie notices)
5. **Apply changes**

### 3.3 Bitwarden

1. `about:addons` → Sök "Bitwarden"
2. **Add to Firefox**
3. Klicka på Bitwarden-ikonen → **Log in**
4. Logga in med `christian.wallen@gridshield.se`
5. **Settings:**
   - Vault Timeout: `15 minutes`
   - Vault Timeout Action: `Lock`
   - Enable Auto-fill: ✓

### 3.4 FoxyProxy Standard

1. `about:addons` → Sök "FoxyProxy Standard"
2. **Add to Firefox**
3. Klicka på FoxyProxy → **Options**
4. **Add Proxy:**
   - Title: `Burp Suite`
   - Type: `HTTP`
   - Hostname: `127.0.0.1`
   - Port: `8080`
5. **Add Proxy:**
   - Title: `OWASP ZAP`
   - Type: `HTTP`
   - Hostname: `127.0.0.1`
   - Port: `8081`

### 3.5 Wappalyzer

1. `about:addons` → Sök "Wappalyzer"
2. **Add to Firefox**

---

## Steg 4: Testa Azure AD SSO (5 min)

1. Öppna ny tab i **Work-M365 container**:
   - Klicka "+" → Välj **Work-M365** (blå)
2. Navigera till: `https://portal.office.com`
3. **Förväntat resultat:** Automatisk inloggning med `christian.wallen@gridshield.se`

**Om inte automatisk inloggning:**

```powershell
# Verifiera Azure AD-anslutning
whoami /upn
# Ska visa: christian.wallen@gridshield.se
```

**Om visar lokalt konto:**
- Windows Settings → Accounts → Access work or school → Connect
- Logga in med `christian.wallen@gridshield.se`
- Starta om Firefox

---

## Steg 5: Verifiera Säkerhet (5 min)

### Test 1: WebRTC-läckage

Öppna: https://browserleaks.com/webrtc

**Förväntat:** "WebRTC is not supported" eller inga IP-adresser synliga

### Test 2: Fingerprinting

Öppna: https://coveryourtracks.eff.org/

**Förväntat:** "Strong protection against tracking"

### Test 3: Container-isolering

1. Logga in på `gmail.com` i **Work-Google container**
2. Öppna `gmail.com` i **Personal container**
3. **Förväntat:** Inte inloggad (containers isolerade)

---

## Steg 6: Bekanta dig med Containers (10 min)

### Öppna tabs i rätt container

**Metod 1: Klicka på "+"**
1. Klicka på "+" för ny tab
2. Välj container från listan
3. Navigera till önskad webbplats

**Metod 2: Högerklicka på länk**
1. Högerklicka på en länk
2. Välj "Open Link in New Container Tab"
3. Välj container

**Metod 3: Automatisk domänassociering**

Vissa domäner öppnas automatiskt i rätt container:
- `portal.office.com` → Work-M365
- `gitlab.com` → Development
- `nvd.nist.gov` → Security-Research

---

## Container-användning (Snabbreferens)

| Container | När använda | Exempel |
|-----------|-------------|---------|
| **Work-M365** | Microsoft-tjänster | Office 365, Azure Portal, Teams |
| **Work-Google** | Google Workspace | Gmail, Drive, Docs |
| **Development** | Utveckling | GitLab, GitHub, Stack Overflow |
| **Client-Access** | Klientportaler | Svenska Kraftnät, energibolag |
| **Security-Research** | Säkerhetsforskning | CVE-databaser, Claroty |
| **Testing-Sandbox** | Osäkra sidor | Pentesting, auto-delete cookies |
| **Personal** | Privat | Bank, LinkedIn, sociala medier |

---

## Steg 7: Anpassa UI (Valfritt, 5 min)

### Installera GridShield UI-tema

1. Navigera till: `about:support`
2. **Profile Directory** → **Open Directory**
3. Skapa mappen `chrome` (om den inte finns)
4. Kopiera `assets/userChrome.css` från repository till `chrome/userChrome.css`
5. Starta om Firefox

**Resultat:**
- Dark theme med GridShield-färger
- Förstärkta container-indikatorer
- Cybersecurity-fokuserat UI

---

## Nästa Steg

**Du har nu en fungerande grundsetup!**

För att gå vidare:

1. **GitLab/GitHub Integration:** Se [gitlab-github-setup.md](gitlab-github-setup.md)
2. **Burp Suite Integration:** Se [burp-suite-setup.md](burp-suite-setup.md)
3. **WSL2 Kali Linux:** Se [wsl-kali-setup.md](wsl-kali-setup.md)
4. **Windows Terminal:** Se [windows-terminal-setup.md](windows-terminal-setup.md)

**Eller följ fullständiga guiden:** [IMPLEMENTATION-GUIDE.md](../IMPLEMENTATION-GUIDE.md)

---

## Felsökning

### Problem: Firefox kraschar vid start

**Lösning:**
1. Öppna Task Manager (Ctrl+Shift+Esc)
2. Avsluta alla `firefox.exe` processer
3. Starta Firefox igen

### Problem: Extensions installeras inte

**Lösning:**
- Verifiera internetanslutning
- Prova igen efter omstart av Firefox
- Kontrollera att du använder addons.mozilla.org

### Problem: SSO fungerar inte

**Lösning:**
```powershell
# Verifiera Azure AD-anslutning
dsregcmd /status
# Leta efter "AzureAdJoined : YES"
```

Om "NO":
- Settings → Accounts → Access work or school
- Connect → `christian.wallen@gridshield.se`

---

## Support

**Problem? Kontakta:**
- IT Support: `it-support@gridshield.se`
- Security incidents: `security@gridshield.se`

**GitHub Issues:**
https://github.com/christianawallen-rgb/gridshield-firefox-setup/issues

---

**Grattis! Du har nu en säker, container-isolerad Firefox-miljö! 🛡️🔥**
