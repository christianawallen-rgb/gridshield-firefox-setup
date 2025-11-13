# Bidra till GridShield Firefox Setup

Tack för ditt intresse att bidra till GridShield Firefox Setup! Detta dokument beskriver riktlinjer och process för att bidra till projektet.

---

## Innehållsförteckning

1. [Code of Conduct](#code-of-conduct)
2. [Hur kan jag bidra?](#hur-kan-jag-bidra)
3. [Rapportera buggar](#rapportera-buggar)
4. [Föreslå förbättringar](#föreslå-förbättringar)
5. [Pull Request Process](#pull-request-process)
6. [Stilguide](#stilguide)
7. [Utvecklingsmiljö](#utvecklingsmiljö)

---

## Code of Conduct

Detta projekt följer en professionell arbetsmiljö. Vi förväntar oss att alla bidragsgivare:

- Är respektfulla och konstruktiva i kommunikation
- Fokuserar på tekniska meriter
- Accepterar konstruktiv kritik
- Arbetar för projektets bästa

---

## Hur kan jag bidra?

### Rapportera buggar

Buggar rapporteras via [GitHub Issues](https://github.com/christianawallen-rgb/gridshield-firefox-setup/issues/new?template=bug_report.md).

**Innan du rapporterar:**
1. Kontrollera att buggen inte redan är rapporterad
2. Använd senaste versionen av koden
3. Försök isolera problemet

**Inkludera i din rapport:**
- Tydlig beskrivning av problemet
- Steg för att reproducera
- Förväntad vs. faktisk beteende
- Screenshots (om applicable)
- Systeminformation:
  - Windows version
  - Firefox Developer Edition version
  - Relevanta extension-versioner

**Exempel:**

```markdown
## Beskrivning
Azure AD SSO fungerar inte efter installation.

## Steg för att reproducera
1. Kör Install-GridShieldFirefox.ps1
2. Starta Firefox
3. Öppna portal.office.com i Work-M365 container
4. Blir tillfrågad om lösenord (förväntar automatisk inloggning)

## Förväntad beteende
Automatisk inloggning via Windows SSO

## Faktisk beteende
Prompt för användarnamn och lösenord

## System
- Windows 11 Pro 22H2
- Firefox Developer Edition 120.0
- Azure AD-joined: Yes (verified via dsregcmd)

## Screenshots
[Bifoga screenshot]
```

---

### Föreslå förbättringar

Feature requests rapporteras via [GitHub Issues](https://github.com/christianawallen-rgb/gridshield-firefox-setup/issues/new?template=feature_request.md).

**Inkludera:**
- Tydlig beskrivning av föreslagen feature
- Användningsfall (varför behövs detta?)
- Förslag på implementation (om möjligt)
- Alternativa lösningar du övervägt

**Exempel:**

```markdown
## Feature Request: Automatisk container-switching baserat på URL-pattern

### Beskrivning
Möjlighet att definiera egna URL-patterns för automatisk container-switching,
utöver de fördefinierade domänerna.

### Användningsfall
GridShield har klienter med egna portaler (t.ex. client1.example.com,
client2.example.com) som bör öppnas i Client-Access container automatiskt.

### Förslag på implementation
Lägg till en config-fil (JSON/YAML) där användare kan definiera:
```json
{
  "custom-mappings": [
    {"pattern": "*.example.com", "container": "Client-Access"},
    {"pattern": "*.intern.se", "container": "Development"}
  ]
}
```

### Alternativ
Manuellt lägga till varje domän i Multi-Account Containers (fungerar men är omständligt).
```

---

## Pull Request Process

### 1. Förberedelser

**Fork och klona repository:**

```bash
# Fork på GitHub, sedan:
git clone https://github.com/DIN-ANVÄNDARNAMN/gridshield-firefox-setup.git
cd gridshield-firefox-setup
```

**Skapa feature branch:**

```bash
git checkout -b feature/din-feature-namn
# ELLER
git checkout -b bugfix/beskrivning-av-bugg
```

### 2. Gör dina ändringar

**Följ stilguiden** (se nedan)

**Testa noggrant:**
- Kör Install-GridShieldFirefox.ps1 från början
- Verifiera att alla steg i IMPLEMENTATION-GUIDE.md fungerar
- Testa på en ren Windows 11-installation (om möjligt)

**Committa:**

```bash
git add .
git commit -m "Lägg till [feature]: Kort beskrivning

Längre beskrivning av vad som ändrats och varför.

Fixes #123 (om det fixar en issue)
"
```

### 3. Skicka Pull Request

**Push till din fork:**

```bash
git push origin feature/din-feature-namn
```

**Skapa PR på GitHub:**

1. Gå till din fork på GitHub
2. Klicka **Compare & pull request**
3. Fyll i PR-template:

```markdown
## Beskrivning
Tydlig beskrivning av vad PR:en gör.

## Typ av ändring
- [ ] Buggfix (non-breaking change som fixar ett problem)
- [ ] Ny feature (non-breaking change som lägger till funktionalitet)
- [ ] Breaking change (fix eller feature som orsakar befintlig funktionalitet att inte fungera)
- [ ] Dokumentationsuppdatering

## Hur har detta testats?
Beskriv vilka tester du kört för att verifiera dina ändringar.

- [ ] Testad på Windows 11 Pro 22H2
- [ ] Testad med Firefox Developer Edition 120.0
- [ ] Alla steg i IMPLEMENTATION-GUIDE.md fungerar
- [ ] Azure AD SSO fungerar
- [ ] Container-isolering fungerar

## Checklista
- [ ] Min kod följer projektets stilguide
- [ ] Jag har gjort self-review av min kod
- [ ] Jag har kommenterat min kod, särskilt i svåra delar
- [ ] Jag har uppdaterat dokumentationen
- [ ] Mina ändringar genererar inga nya warnings
- [ ] Jag har testat att mina ändringar fungerar
```

### 4. Code Review Process

**Vad händer nu:**
1. Automatiska checks körs (om konfigurerat)
2. Maintainers gör code review
3. Feedback ges (om nödvändigt)
4. Du gör eventuella ändringar
5. PR mergas när allt är godkänt

**Svara på feedback:**
- Var öppen för konstruktiv kritik
- Gör begärda ändringar i samma branch
- Pusha nya commits

```bash
# Gör ändringar baserat på feedback
git add .
git commit -m "Adresserar review-kommentarer från @reviewer"
git push origin feature/din-feature-namn
```

---

## Stilguide

### PowerShell Scripts

**Konventioner:**
- Använd verb-substantiv naming (t.ex. `Install-Firefox`, `Set-Configuration`)
- Kommentera komplext logik
- Inkludera parameter-hjälp
- Använd `Write-Log` för output (inte `Write-Host` direkt)

**Exempel:**

```powershell
<#
.SYNOPSIS
    Kort beskrivning av vad skriptet gör

.DESCRIPTION
    Längre beskrivning med detaljer

.PARAMETER ParameterName
    Beskrivning av parametern

.EXAMPLE
    .\Script.ps1 -ParameterName "Value"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ParameterName
)

function Verb-Noun {
    param([string]$Input)

    # Kommentar för komplex logik
    $result = $Input -replace "pattern", "replacement"
    return $result
}
```

### Bash Scripts

**Konventioner:**
- Använd `set -e` för att exit vid fel
- Kommentera sektioner
- Använd färgkodade log-funktioner
- Inkludera error handling

**Exempel:**

```bash
#!/bin/bash

set -e  # Exit vid fel

# Färger
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Huvudlogik
main() {
    log_info "Startar installation..."

    if ! command -v git &> /dev/null; then
        log_error "Git inte installerat"
    fi

    log_info "Installationen slutförd"
}

main "$@"
```

### Markdown Documentation

**Konventioner:**
- Använd tydliga headers (# → ## → ###)
- Inkludera kod-exempel med syntax highlighting
- Använd listor för steg-för-steg instruktioner
- Inkludera screenshots för komplexa UI-steg (i `assets/screenshots/`)

**Exempel:**

```markdown
# Rubrik 1

## Rubrik 2

### Steg 1: Beskrivning

Förklarande text.

\`\`\`powershell
# Kod-exempel med syntax highlighting
Install-Module -Name Module
\`\`\`

**Tips:** Använd gärna tips-boxar för extra information.
```

### JSON/CSS Files

**Konventioner:**
- Korrekt indentation (2 spaces för JSON, 2-4 för CSS)
- Kommentarer för komplexa sektioner
- Alfabetisk sortering av properties (där logiskt)

---

## Utvecklingsmiljö

### Setup för Contribution

**Krav:**
- Windows 11 Pro (för testing)
- Git for Windows
- PowerShell 5.1+
- Visual Studio Code (rekommenderat)

**Rekommenderade VS Code Extensions:**
- PowerShell
- Markdown All in One
- GitLens
- Code Spell Checker

### Testning

**Innan PR:**

1. **Ren installation:**
   ```powershell
   # På en VM eller ren Windows-installation
   .\scripts\Install-GridShieldFirefox.ps1
   ```

2. **Verifiera alla steg:**
   - Gå igenom IMPLEMENTATION-GUIDE.md steg-för-steg
   - Verifiera att alla links fungerar
   - Testa Azure AD SSO
   - Testa container-isolering

3. **Linting:**
   ```powershell
   # PowerShell scripts
   Invoke-ScriptAnalyzer -Path .\scripts\ -Recurse

   # Markdown
   markdownlint *.md docs/*.md
   ```

---

## Frågor?

**Kontakt:**
- GitHub Issues: [github.com/christianawallen-rgb/gridshield-firefox-setup/issues](https://github.com/christianawallen-rgb/gridshield-firefox-setup/issues)
- Email: christian.wallen@gridshield.se

**Tack för ditt bidrag! 🛡️**
