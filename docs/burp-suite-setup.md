# Burp Suite Integration med Firefox Developer Edition

**Tid:** 20 minuter

---

## Översikt

Denna guide konfigurerar Firefox för att fungera sömlöst med Burp Suite för web application security testing.

**Vad du får:**
- ✅ Burp Suite proxy-integration
- ✅ CA-certifikat korrekt installerat
- ✅ Snabb proxy-switching via FoxyProxy
- ✅ Testing-Sandbox container för isolerad testing

---

## Förutsättningar

- ✅ Firefox Developer Edition installerat (från huvudguiden)
- ✅ FoxyProxy extension installerat
- ✅ Burp Suite Community/Professional installerat

**Installera Burp Suite:**

```powershell
# Via Chocolatey
choco install burp-suite-free-edition

# ELLER ladda ner från:
# https://portswigger.net/burp/communitydownload
```

---

## Steg 1: Konfigurera Burp Suite Proxy

### 1.1 Starta Burp Suite

```powershell
# Om installerat via Chocolatey
burpsuite

# ELLER starta från installation directory
```

### 1.2 Verifiera Proxy-inställningar

1. Burp Suite → **Proxy** tab → **Options**
2. **Proxy Listeners:**
   - Verifiera att `127.0.0.1:8080` finns i listan
   - Om inte, klicka **Add**:
     - Bind to port: `8080`
     - Bind to address: `127.0.0.1` (Loopback only)
     - Klicka **OK**

3. **Intercept Client Requests:**
   - ✓ **Intercept requests based on the following rules**
   - Standardregler är OK för början

---

## Steg 2: Konfigurera FoxyProxy i Firefox

### 2.1 Lägg till Burp Suite Proxy

FoxyProxy ska redan vara installerat (från huvudguiden). Om inte:

1. `about:addons` → Sök "FoxyProxy Standard"
2. **Add to Firefox**

### 2.2 Konfigurera Burp-profil

1. Klicka på FoxyProxy-ikonen i verktygsfältet
2. **Options**
3. **Add Proxy**:
   - **Title:** `Burp Suite`
   - **Proxy Type:** `HTTP`
   - **Proxy IP address:** `127.0.0.1`
   - **Port:** `8080`
   - **Username/Password:** Lämna tomt
4. **Save**

### 2.3 Lägg till OWASP ZAP (valfritt)

Om du också använder OWASP ZAP:

1. **Add Proxy**:
   - **Title:** `OWASP ZAP`
   - **Proxy Type:** `HTTP`
   - **Proxy IP address:** `127.0.0.1`
   - **Port:** `8081`
2. **Save**

---

## Steg 3: Installera Burp CA-certifikat

**VIKTIGT:** Detta steg krävs för att intercepta HTTPS-trafik utan certifikatvarningar.

### 3.1 Aktivera Burp-proxy i Firefox

1. Klicka på FoxyProxy-ikonen
2. Välj **Burp Suite**
3. Verifiera att FoxyProxy visar "Using proxy Burp Suite for all URLs"

### 3.2 Ladda ner Burp CA-certifikat

1. Med Burp-proxy aktiverad, navigera till: `http://burpsuite`
2. Klicka på **CA Certificate** (överst till höger)
3. Spara filen som `burp-ca-cert.der` (t.ex. i Downloads)

**OBS:** Detta kräver att Burp Suite körs och proxy är aktiverad!

### 3.3 Importera certifikat i Firefox

1. I Firefox, navigera till: `about:preferences#privacy`
2. Scrolla ner till **Certificates** → Klicka **View Certificates**
3. **Authorities** tab → **Import**
4. Välj `burp-ca-cert.der`
5. ✓ **Trust this CA to identify websites**
6. Klicka **OK**

### 3.4 Verifiera installation

1. Gå till **Authorities** tab igen
2. Sök efter "PortSwigger"
3. Du ska se:
   - **PortSwigger CA**
   - Issuer: PortSwigger CA

---

## Steg 4: Testa Interception

### 4.1 Förbered Testing-Sandbox Container

1. Öppna ny tab
2. Klicka "+" → Välj **Testing-Sandbox** (gul container)

**Varför Testing-Sandbox?**
- Automatisk cookie-radering när alla tabs stängs
- Isolerad från andra containers
- Perfekt för web app testing

### 4.2 Aktivera Intercept

1. Burp Suite → **Proxy** → **Intercept**
2. Klicka **Intercept is off** så det blir **Intercept is on**

### 4.3 Testa med HTTPS-sajt

1. I Testing-Sandbox tab, navigera till: `https://example.com`
2. **Burp Suite ska visa requesten i Intercept-fliken**
3. Granska requesten
4. Klicka **Forward** för att släppa igenom

**Förväntat resultat:**
- Inga certifikatvarningar i Firefox
- Request synlig i Burp Suite
- Response kommer tillbaka efter Forward

---

## Steg 5: Advanced Configuration

### 5.1 Scope Configuration (Rekommenderat)

För att undvika att intercepta all trafik (inklusive Firefox updates, etc.):

1. Burp Suite → **Target** → **Site map**
2. Högerklicka på din måldomän (t.ex. `example.com`)
3. **Add to scope**
4. **Proxy** → **Options** → **Intercept Client Requests**
5. Lägg till regel:
   - **Enabled:** ✓
   - **Operator:** `And`
   - **Match Type:** `URL`
   - **Relationship:** `Is in target scope`
   - **Match Condition:** Lämna tom

**Resultat:** Burp interceptar endast trafik till domäner i scope.

### 5.2 Match and Replace Rules

För automatisk manipulation av requests:

1. Burp Suite → **Proxy** → **Options**
2. **Match and Replace**
3. **Add**:
   - **Type:** `Request header`
   - **Match:** `User-Agent: .*`
   - **Replace:** `User-Agent: GridShield-Pentest`
   - **Enabled:** ✓

**Användning:** Lägg till custom headers för testing.

### 5.3 TLS Pass Through

För att exkludera vissa domäner från HTTPS-interception:

1. **Proxy** → **Options**
2. **TLS Pass Through**
3. **Add**:
   - **Enabled:** ✓
   - **Host or IP range:** `*.microsoft.com`
   - **Port:** Lämna tom (alla portar)

**Användning:** Exkludera Microsoft-domäner (redan hanterade av Work-M365 container).

---

## Steg 6: Workflow Best Practices

### 6.1 Standard Testing Workflow

**Setup:**
1. Öppna **Testing-Sandbox container**
2. Aktivera FoxyProxy → **Burp Suite**
3. Burp Suite → **Intercept is on**
4. Navigera till målwebbplats

**Testing:**
1. Intercepta och modifiera requests
2. Använd **Repeater** för att testa variationer
3. Använd **Intruder** för fuzzing
4. Använd **Scanner** (Pro only) för automated scanning

**Cleanup:**
1. Stäng alla tabs i Testing-Sandbox
2. **Cookies raderas automatiskt**
3. Inaktivera FoxyProxy (tillbaka till "Disabled")

### 6.2 Quick Proxy Switching

**FoxyProxy Shortcuts:**

| Shortcut | Resultat |
|----------|----------|
| Klicka FoxyProxy → **Burp Suite** | Aktivera Burp-proxy |
| Klicka FoxyProxy → **Disabled** | Inaktivera proxy |
| Klicka FoxyProxy → **OWASP ZAP** | Byt till ZAP |

**Tips:** Använd keyboard shortcut för snabbare switching:
1. FoxyProxy Options → **Keyboard Shortcuts**
2. Sätt t.ex. `Ctrl+Shift+B` för Burp Suite

---

## Steg 7: Integration med Kali Linux (WSL2)

Om du har konfigurerat WSL2 Kali Linux (se [wsl-kali-setup.md](wsl-kali-setup.md)):

### 7.1 Kör Kali-verktyg via Burp

**Exempel: sqlmap**

```bash
# I WSL Kali
sqlmap -u "http://target.com/vuln.php?id=1" \
  --proxy="http://127.0.0.1:8080" \
  --batch
```

**Resultat:** sqlmap-trafik går via Burp Suite (körs i Windows).

**Exempel: nikto**

```bash
nikto -h http://target.com -useproxy http://127.0.0.1:8080
```

### 7.2 Importera Burp CA i Kali

För att Kali-verktyg ska lita på Burp CA:

```bash
# Kopiera CA-certifikat från Windows
cp /mnt/c/Users/<ditt-namn>/Downloads/burp-ca-cert.der ~/

# Konvertera till .crt
openssl x509 -inform DER -in burp-ca-cert.der -out burp-ca.crt

# Installera
sudo cp burp-ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

**Verifiera:**
```bash
curl https://example.com
# Ska fungera utan certifikatvarning
```

---

## Steg 8: Troubleshooting

### Problem: "Warning: Potential Security Risk Ahead"

**Orsak:** Burp CA-certifikat inte korrekt installerat.

**Lösning:**
1. Verifiera att certifikatet är importerat:
   - `about:preferences#privacy` → **Certificates** → **View Certificates**
   - **Authorities** → Sök "PortSwigger"
2. Om inte listat:
   - Ta bort gammalt certifikat (om finns)
   - Ladda om från `http://burpsuite` (med proxy aktiverad)
   - Importera igen

### Problem: Burp interceptar inte trafik

**Checklista:**
1. ✓ Burp Suite körs
2. ✓ Proxy listener `127.0.0.1:8080` aktiverad
3. ✓ FoxyProxy visar "Using proxy Burp Suite"
4. ✓ Intercept is on

**Testa:**
```powershell
# Verifiera att Burp lyssnar på port 8080
netstat -an | findstr 8080
# Ska visa: TCP    127.0.0.1:8080         0.0.0.0:0              LISTENING
```

### Problem: Trafik till Microsoft-domäner interceptas

**Lösning:**
1. Använd **Work-M365 container** för Microsoft-tjänster (inte Testing-Sandbox)
2. ELLER lägg till TLS Pass Through:
   - Burp → **Proxy** → **Options** → **TLS Pass Through**
   - Add: `*.microsoft.com`, `*.microsoftonline.com`

### Problem: Firefox uppdateringar interceptas

**Lösning:**
Lägg till Firefox-domäner i TLS Pass Through:
```
*.mozilla.org
*.mozilla.net
aus5.mozilla.org
```

---

## Steg 9: OWASP ZAP Integration (Valfritt)

Om du föredrar OWASP ZAP över Burp Suite:

### 9.1 Installera OWASP ZAP

```powershell
choco install owasp-zap

# ELLER ladda ner från:
# https://www.zaproxy.org/download/
```

### 9.2 Konfigurera ZAP

1. Starta ZAP
2. **Tools** → **Options** → **Local Proxies**
   - Address: `127.0.0.1`
   - Port: `8081`
3. **Apply**

### 9.3 Importera ZAP CA-certifikat

1. **Tools** → **Options** → **Dynamic SSL Certificates**
2. **Save** → Spara som `zap-ca.cer`
3. Firefox → `about:preferences#privacy` → **Certificates**
4. **Import** → Välj `zap-ca.cer`
5. ✓ **Trust this CA to identify websites**

### 9.4 Använd ZAP istället för Burp

1. FoxyProxy → Välj **OWASP ZAP**
2. Testing-Sandbox container
3. Navigera till målwebbplats

---

## Sammanfattning

**Du har nu:**
- ✅ Burp Suite integrerat med Firefox
- ✅ CA-certifikat korrekt installerat
- ✅ FoxyProxy för snabb proxy-switching
- ✅ Testing-Sandbox för isolerad testing
- ✅ Kali Linux-verktyg kan använda Burp-proxy

**Workflow:**
1. Öppna Testing-Sandbox container
2. Aktivera Burp Suite via FoxyProxy
3. Intercepta och analysera trafik
4. Stäng container → Cookies raderas automatiskt

**Nästa steg:**
- Bekanta dig med Burp Suite features (Repeater, Intruder, Scanner)
- Läs OWASP Web Security Testing Guide
- Se [IMPLEMENTATION-GUIDE.md](../IMPLEMENTATION-GUIDE.md) för fler integrations-tips

---

**God pentesting! 🛡️🔥**
