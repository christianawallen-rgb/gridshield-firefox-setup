# DNS-konfiguration i Loopia för GridShield Security

**Komplett DNS-setup för Proton Business + Microsoft 365 Hybrid Architecture**

---

## Översikt

Denna guide konfigurerar DNS hos Loopia för:
- **gridshield.se** → Proton Business (primary email)
- **alias.gridshield.se** → SimpleLogin Premium (email aliases)
- **m365.gridshield.se** → Microsoft 365 (collaboration only, NO email)

---

## Del 1: gridshield.se (Proton Business)

### 1.1 Domänverifiering (TXT Record)

**Från Proton: Settings → Domain names → gridshield.se**

```
Type: TXT
Host: @
Value: protonmail-verification=xxxxxxxxxxxxxxxx
TTL: 3600
```

**I Loopia:**
1. Logga in → gridshield.se → **DNS**
2. **Lägg till post**
3. Typ: `TXT`
4. Värdnamn: `@`
5. Målvärd/Värde: `protonmail-verification=...` (kopiera exakt från Proton)
6. TTL: `3600`
7. **Spara**

### 1.2 MX Records (Mail Routing)

**VIKTIGT: Ta bort ALLA befintliga MX-poster först!**

**MX Record 1:**
```
Type: MX
Priority: 10
Host: @
Target: mail.protonmail.ch
TTL: 3600
```

**MX Record 2:**
```
Type: MX
Priority: 20
Host: @
Target: mailsec.protonmail.ch
TTL: 3600
```

**I Loopia:**
1. Ta bort alla gamla MX-poster
2. **Lägg till post** → Typ: `MX`
3. Prioritet: `10`
4. Värdnamn: `@`
5. Målvärd: `mail.protonmail.ch` (inkludera INTE punkt i slutet)
6. TTL: `3600`
7. **Spara**
8. Upprepa för prioritet `20` med `mailsec.protonmail.ch`

### 1.3 SPF Record (Sender Policy Framework)

```
Type: TXT
Host: @
Value: v=spf1 include:_spf.protonmail.ch ~all
TTL: 3600
```

**Förklaring:**
- `v=spf1` - SPF version 1
- `include:_spf.protonmail.ch` - Tillåt Protons mailservrar
- `~all` - Soft fail för andra (markera som spam)

**I Loopia:**
1. **Lägg till post** → Typ: `TXT`
2. Värdnamn: `@`
3. Målvärd/Värde: `v=spf1 include:_spf.protonmail.ch ~all`
4. TTL: `3600`
5. **Spara**

### 1.4 DKIM Records (Email Signing)

**Från Proton: 3 CNAME-poster visas under domain settings**

**DKIM 1:**
```
Type: CNAME
Host: protonmail._domainkey
Target: protonmail.domainkey.dxxxx.domains.proton.ch
TTL: 3600
```

**DKIM 2:**
```
Type: CNAME
Host: protonmail2._domainkey
Target: protonmail2.domainkey.dxxxx.domains.proton.ch
TTL: 3600
```

**DKIM 3:**
```
Type: CNAME
Host: protonmail3._domainkey
Target: protonmail3.domainkey.dxxxx.domains.proton.ch
TTL: 3600
```

**OBS: `dxxxx` är unikt för ditt Proton-konto - kopiera EXAKT från Proton!**

**I Loopia (för varje DKIM):**
1. **Lägg till post** → Typ: `CNAME`
2. Värdnamn: `protonmail._domainkey` (för första)
3. Målvärd: `protonmail.domainkey.dxxxx.domains.proton.ch` (från Proton)
4. TTL: `3600`
5. **Spara**
6. Upprepa för `protonmail2._domainkey` och `protonmail3._domainkey`

### 1.5 DMARC Record (Policy Enforcement)

```
Type: TXT
Host: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@gridshield.se; pct=100; adkim=s; aspf=s
TTL: 3600
```

**Förklaring:**
- `p=quarantine` - Sätt failure-mail i karantän
- `rua=mailto:postmaster@gridshield.se` - Skicka rapporter hit
- `pct=100` - Policy gäller 100% av mailen
- `adkim=s` - Strict DKIM alignment
- `aspf=s` - Strict SPF alignment

**I Loopia:**
1. **Lägg till post** → Typ: `TXT`
2. Värdnamn: `_dmarc`
3. Målvärd/Värde: `v=DMARC1; p=quarantine; rua=mailto:postmaster@gridshield.se; pct=100; adkim=s; aspf=s`
4. TTL: `3600`
5. **Spara**

---

## Del 2: alias.gridshield.se (SimpleLogin Premium)

### 2.1 SimpleLogin Verification (TXT Record)

**Från SimpleLogin: Custom domains → alias.gridshield.se**

```
Type: TXT
Host: alias
Value: sl-verification=xxxxxxxxxxxxxxxx
TTL: 3600
```

**I Loopia:**
1. **Lägg till post** → Typ: `TXT`
2. Värdnamn: `alias`
3. Målvärd/Värde: `sl-verification=...` (från SimpleLogin)
4. TTL: `3600`
5. **Spara**

### 2.2 MX Records (SimpleLogin Mail Routing)

**MX Record 1:**
```
Type: MX
Priority: 10
Host: alias
Target: mx1.simplelogin.co
TTL: 3600
```

**MX Record 2:**
```
Type: MX
Priority: 20
Host: alias
Target: mx2.simplelogin.co
TTL: 3600
```

**I Loopia:**
1. **Lägg till post** → Typ: `MX`
2. Prioritet: `10`
3. Värdnamn: `alias`
4. Målvärd: `mx1.simplelogin.co`
5. TTL: `3600`
6. **Spara**
7. Upprepa för `mx2.simplelogin.co` med prioritet `20`

### 2.3 SPF Record för alias-subdomän

```
Type: TXT
Host: alias
Value: v=spf1 include:simplelogin.co ~all
TTL: 3600
```

**I Loopia:**
1. **Lägg till post** → Typ: `TXT`
2. Värdnamn: `alias`
3. Målvärd/Värde: `v=spf1 include:simplelogin.co ~all`
4. TTL: `3600`
5. **Spara**

### 2.4 DMARC Record för alias-subdomän

```
Type: TXT
Host: _dmarc.alias
Value: v=DMARC1; p=quarantine; pct=100; rua=mailto:postmaster@gridshield.se
TTL: 3600
```

**I Loopia:**
1. **Lägg till post** → Typ: `TXT`
2. Värdnamn: `_dmarc.alias`
3. Målvärd/Värde: `v=DMARC1; p=quarantine; pct=100; rua=mailto:postmaster@gridshield.se`
4. TTL: `3600`
5. **Spara**

---

## Del 3: m365.gridshield.se (Microsoft 365 Collaboration)

**OBS: Endast för Teams, SharePoint, Azure AD - INTE för email!**

### 3.1 Microsoft 365 Verification (TXT Record)

**Från Microsoft 365 Admin: Setup → Domains → m365.gridshield.se**

```
Type: TXT
Host: m365
Value: MS=msXXXXXXXX
TTL: 3600
```

**I Loopia:**
1. **Lägg till post** → Typ: `TXT`
2. Värdnamn: `m365`
3. Målvärd/Värde: `MS=msXXXXXXXX` (från Microsoft)
4. TTL: `3600`
5. **Spara**

### 3.2 MX Records (ENDAST OM Exchange Online används - REKOMMENDERAS INTE)

**SKIP THIS - Vi använder Proton för email, inte Microsoft!**

Om du av misstag aktiverade Exchange Online, inaktivera det i M365 Admin.

### 3.3 Autodiscover (För Outlook/Teams)

```
Type: CNAME
Host: autodiscover.m365
Target: autodiscover.outlook.com
TTL: 3600
```

**I Loopia:**
1. **Lägg till post** → Typ: `CNAME`
2. Värdnamn: `autodiscover.m365`
3. Målvärd: `autodiscover.outlook.com`
4. TTL: `3600`
5. **Spara**

### 3.4 SPF för m365-subdomän (Om ingen email)

```
Type: TXT
Host: m365
Value: v=spf1 -all
TTL: 3600
```

**Förklaring:** `-all` betyder "ingen email ska skickas från denna subdomän"

**I Loopia:**
1. **Lägg till post** → Typ: `TXT`
2. Värdnamn: `m365`
3. Målvärd/Värde: `v=spf1 -all`
4. TTL: `3600`
5. **Spara**

---

## Verifiering & Testing

### Steg 1: Kontrollera DNS Propagation

**Vänta 15-30 minuter efter DNS-ändringar, sedan:**

```bash
# Check MX records för gridshield.se
nslookup -type=mx gridshield.se

# Förväntat resultat:
# gridshield.se mail exchanger = 10 mail.protonmail.ch
# gridshield.se mail exchanger = 20 mailsec.protonmail.ch

# Check MX för alias.gridshield.se
nslookup -type=mx alias.gridshield.se

# Förväntat resultat:
# alias.gridshield.se mail exchanger = 10 mx1.simplelogin.co
# alias.gridshield.se mail exchanger = 20 mx2.simplelogin.co

# Check TXT records (SPF)
nslookup -type=txt gridshield.se

# Förväntat resultat:
# gridshield.se text = "v=spf1 include:_spf.protonmail.ch ~all"
# gridshield.se text = "protonmail-verification=..."
```

**Online verktyg:**
- DNS Propagation: https://dnschecker.org
- MX Lookup: https://mxtoolbox.com

### Steg 2: Test Email Delivery

**Send test email från Proton Mail:**
```
To: christian.wallen@gridshield.se (till dig själv)
Subject: DNS Test
Body: Testing email delivery efter DNS-konfiguration.

Förväntat resultat:
- Email delivered inom 1-2 minuter
- Ingen fördröjning
```

### Steg 3: Test Email Security

**Mail Tester:**
1. Gå till: https://www.mail-tester.com
2. Kopiera email-adressen som visas
3. Send email från Proton Mail till den adressen
4. Gå tillbaka till mail-tester.com
5. Klicka **Check your score**

**Förväntat resultat:** 10/10 score

**Om lägre score:**
- Check SPF, DKIM, DMARC errors
- Fix DNS records enligt feedback
- Test igen

### Steg 4: Test SimpleLogin Alias

**Skapa test-alias:**
1. SimpleLogin → New alias: `test@alias.gridshield.se`
2. Send email FRÅN extern (Gmail, etc.) till `test@alias.gridshield.se`
3. Check inbox på christian.wallen@gridshield.se

**Förväntat resultat:**
- Email forwarded korrekt
- Från-adress visar original sender
- Reply går via alias

---

## Troubleshooting

### Problem: "Domain verification failed" i Proton

**Orsak:** TXT record inte propagerad

**Fix:**
```bash
# Check TXT record
nslookup -type=txt gridshield.se

# Ska visa: protonmail-verification=...
# Om inte synlig: Vänta 15-30 min mer
```

**Force DNS refresh:**
```bash
# På Windows
ipconfig /flushdns
```

### Problem: Mail går till spam

**Orsak:** SPF/DKIM/DMARC inte korrekt

**Fix:**
1. Verifiera SPF record finns
2. Verifiera alla 3 DKIM CNAMEs
3. Verifiera DMARC record
4. Test på mail-tester.com
5. Check MXToolbox: https://mxtoolbox.com/domain/gridshield.se

### Problem: SimpleLogin alias inte funkar

**Orsak:** MX records för alias-subdomän saknas

**Fix:**
```bash
# Check MX för alias.gridshield.se
nslookup -type=mx alias.gridshield.se

# Ska visa:
# alias.gridshield.se mail exchanger = 10 mx1.simplelogin.co
# alias.gridshield.se mail exchanger = 20 mx2.simplelogin.co
```

### Problem: Loopia visar fel vid inmatning

**Vanliga misstag:**
- **Punkt i slutet av målvärden** - TA BORT punkt!
  - Fel: `mail.protonmail.ch.`
  - Rätt: `mail.protonmail.ch`
- **@ istället för tom värd** - Använd `@` för root domain
- **Citationstecken i TXT** - Loopia lägger till automatiskt, skriv UTAN quotes

---

## Komplett DNS-Översikt (Checklista)

### gridshield.se (Proton Business)

- [ ] TXT: protonmail-verification
- [ ] MX: 10 mail.protonmail.ch
- [ ] MX: 20 mailsec.protonmail.ch
- [ ] TXT (SPF): v=spf1 include:_spf.protonmail.ch ~all
- [ ] CNAME: protonmail._domainkey → protonmail.domainkey.dxxxx...
- [ ] CNAME: protonmail2._domainkey → protonmail2.domainkey.dxxxx...
- [ ] CNAME: protonmail3._domainkey → protonmail3.domainkey.dxxxx...
- [ ] TXT (DMARC): _dmarc → v=DMARC1; p=quarantine...

### alias.gridshield.se (SimpleLogin)

- [ ] TXT: sl-verification
- [ ] MX: 10 mx1.simplelogin.co
- [ ] MX: 20 mx2.simplelogin.co
- [ ] TXT (SPF): v=spf1 include:simplelogin.co ~all
- [ ] TXT (DMARC): _dmarc.alias → v=DMARC1...

### m365.gridshield.se (Microsoft 365)

- [ ] TXT: MS=msXXXXXX
- [ ] CNAME: autodiscover.m365 → autodiscover.outlook.com
- [ ] TXT (SPF): v=spf1 -all

---

**DNS-konfiguration klar! GridShield Security har nu professionell email-infrastruktur! 🛡️📧**
