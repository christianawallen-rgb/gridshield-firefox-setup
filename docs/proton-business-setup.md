# Proton Business Setup för GridShield Security

**Tid:** 45 minuter
**Förutsättningar:** Proton Business-konto, gridshield.se-domän hos Loopia

---

## Översikt

Denna guide konfigurerar Proton Business som primary email-system för GridShield Security med:

- ✅ **End-to-end krypterad email** (christian.wallen@gridshield.se)
- ✅ **SimpleLogin Premium** för alias-hantering
- ✅ **Proton Pass för Business** - lösenordshantering
- ✅ **Schweizisk jurisdiktion** (starkare privacy än EU/Sverige)
- ✅ **NIS2/GDPR-compliant** out-of-the-box
- ✅ **Perfect för OT/ICS säkerhetskonsulter**

---

## Varför Proton Business för GridShield?

### Säkerhetsfördelar

**End-to-End Encryption:**
- Alla mail krypterade med PGP automatiskt
- **Zero-access architecture** - inte ens Proton kan läsa dina mail
- Metadata minimerad (IP-adresser inte loggade)
- Offline brute-force attacks omöjliga

**Swiss Jurisdiction:**
- Federal Data Protection Act (starkare än GDPR)
- Kräver Schweizisk domstolsbeslut för data access
- Skyddad från EU data requests utan domstolsbeslut
- Perfect för kritisk infrastruktur-konsulter

**Zero-Knowledge Architecture:**
- Lösenord aldrig skickat till server
- Secure Remote Password (SRP) protocol
- All data krypterad client-side

### Compliance-Fördelar

**NIS2-Ready:**
- End-to-end encryption (Article 21.2)
- Incident response capabilities
- Audit logs
- Secure communication channels

**GDPR Article 32:**
- State-of-the-art encryption
- Pseudonymization (SimpleLogin aliases)
- Regular security testing
- Data breach protection

---

## Fas 1: Domänkonfiguration i Proton

### Steg 1.1: Logga in på Proton Business

1. Öppna: https://account.proton.me
2. Logga in med ditt Proton Business-konto
3. Navigera till: **Mail** → **Settings** → **Domain names**

### Steg 1.2: Lägg till gridshield.se

1. Klicka **Add domain**
2. Ange: `gridshield.se`
3. Klicka **Add domain**

**Proton visar nu:**
- TXT record för domänverifiering
- MX records för mail-routing
- SPF/DKIM/DMARC records för säkerhet

### Steg 1.3: Verifiera ägarskap

**DNS-konfiguration krävs i Loopia (se [dns-configuration.md](dns-configuration.md)):**

**TXT Record för verifiering:**
```
Host: @
Type: TXT
Value: protonmail-verification=xxxxxxxxxxxxxxxx
TTL: 3600
```

**Lägg till i Loopia:**
1. Logga in på Loopia
2. Välj gridshield.se
3. **DNS** → **Add Record**
4. Typ: `TXT`
5. Host: `@`
6. Värde: `protonmail-verification=...` (från Proton)
7. **Save**

**Vänta 5-15 minuter, sedan:**
1. Tillbaka till Proton
2. Klicka **Verify domain**
3. ✅ **Domain verified** ska visas

---

## Fas 2: DNS Records för Email

### Steg 2.1: MX Records (Mail Exchange)

**VIKTIGT:** Ta bort ALLA befintliga MX records först!

**Lägg till i Loopia:**

```
Priority: 10
Host: @
Target: mail.protonmail.ch
TTL: 3600

Priority: 20
Host: @
Target: mailsec.protonmail.ch
TTL: 3600
```

**I Loopia DNS-konsol:**
1. Ta bort gamla MX records (om några finns)
2. **Add Record** → Typ: `MX`
3. Priority: `10`
4. Host: `@`
5. Target: `mail.protonmail.ch`
6. **Save**
7. Upprepa för priority `20` med `mailsec.protonmail.ch`

### Steg 2.2: SPF Record (Anti-Spoofing)

**SPF = Sender Policy Framework** - Förhindrar att någon annan skickar mail från gridshield.se

**Lägg till i Loopia:**
```
Type: TXT
Host: @
Value: v=spf1 include:_spf.protonmail.ch ~all
TTL: 3600
```

**Förklaring:**
- `v=spf1` - SPF version 1
- `include:_spf.protonmail.ch` - Tillåt Protons mail-servrar
- `~all` - Soft fail för andra servrar (markera som spam)

### Steg 2.3: DKIM Records (Email Signing)

**DKIM = DomainKeys Identified Mail** - Kryptografisk signatur som bevisar att mail kommer från Proton

**Proton genererar 3 DKIM keys:**

**I Loopia, lägg till varje CNAME:**

```
DKIM 1:
Type: CNAME
Host: protonmail._domainkey
Target: protonmail.domainkey.dxxxx.domains.proton.ch
TTL: 3600

DKIM 2:
Type: CNAME
Host: protonmail2._domainkey
Target: protonmail2.domainkey.dxxxx.domains.proton.ch
TTL: 3600

DKIM 3:
Type: CNAME
Host: protonmail3._domainkey
Target: protonmail3.domainkey.dxxxx.domains.proton.ch
TTL: 3600
```

**OBS:** `dxxxx` är unikt för din Proton-konfiguration - kopiera exakt från Proton!

### Steg 2.4: DMARC Record (Policy Enforcement)

**DMARC = Domain-based Message Authentication** - Policy för hur mottagare ska hantera SPF/DKIM-failures

**Lägg till i Loopia:**
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

---

## Fas 3: Skapa Email-Adresser

### Steg 3.1: Primary Email Address

**I Proton:**
1. **Mail** → **Settings** → **Addresses**
2. **Add address**
3. Ange: `christian.wallen@gridshield.se`
4. **Display name:** Christian Wallén
5. **Set as primary**
6. **Save**

### Steg 3.2: Email Aliases

**Lägg till korta aliases:**

```
Alias 1: cw@gridshield.se
├── Kortnyckel för snabb kommunikation
└── Redirects to: christian.wallen@gridshield.se

Alias 2: christian@gridshield.se
├── Informell variant
└── Redirects to: christian.wallen@gridshield.se
```

**I Proton:**
1. **Addresses** → **Add alias**
2. Ange: `cw@gridshield.se`
3. **Forward to:** christian.wallen@gridshield.se
4. **Save**
5. Upprepa för `christian@gridshield.se`

### Steg 3.3: Functional Mailboxes (Shared)

**För företagsfunktioner:**

```
info@gridshield.se
├── Allmänna förfrågningar
├── Shared mailbox (flera användare kan accessa)
└── Auto-reply: "Tack för ditt mail..."

security@gridshield.se
├── Security incident reports
├── Vulnerability disclosures
└── 24/7 monitoring

support@gridshield.se
├── Customer support
└── Ticket system integration (future)

projects@gridshield.se
├── Project-specific communication
└── Shared with team (future)
```

**Skapa shared mailbox:**
1. **Mail** → **Settings** → **Addresses**
2. **Add address**
3. Ange: `info@gridshield.se`
4. **Type:** Shared mailbox
5. **Members:** Lägg till användare som ska ha access
6. **Save**

---

## Fas 4: SimpleLogin Premium Setup

### Steg 4.1: Aktivera SimpleLogin Premium

**SimpleLogin Premium är inkluderat i Proton Pass Plus!**

1. Öppna: https://app.simplelogin.io
2. **Sign in with Proton**
3. Använd: christian.wallen@gridshield.se
4. **SimpleLogin Premium automatiskt aktivt**

**Fördelar med Premium:**
- Unlimited aliases (standard: 10)
- Custom domains (alias.gridshield.se)
- Unlimited mailboxes
- PGP encryption
- API access

### Steg 4.2: Konfigurera Custom Alias Domain

**Använd subdomän för professionella aliases:**

**Domän:** `alias.gridshield.se`

**I SimpleLogin:**
1. **Settings** → **Custom domains**
2. **Add custom domain**
3. Ange: `alias.gridshield.se`

**DNS-konfiguration i Loopia:**

```
TXT Record (Verification):
Type: TXT
Host: alias
Value: sl-verification=xxxxxxxx
TTL: 3600

MX Records (Mail routing):
Priority: 10
Host: alias
Target: mx1.simplelogin.co
TTL: 3600

Priority: 20
Host: alias
Target: mx2.simplelogin.co
TTL: 3600

SPF Record:
Type: TXT
Host: alias
Value: v=spf1 include:simplelogin.co ~all
TTL: 3600

DMARC Record:
Type: TXT
Host: _dmarc.alias
Value: v=DMARC1; p=quarantine; pct=100; rua=mailto:postmaster@gridshield.se
TTL: 3600
```

**Verifiera i SimpleLogin:**
1. **Custom domains** → alias.gridshield.se
2. **Verify domain**
3. ✅ **Domain verified**

### Steg 4.3: Skapa Alias-Strategi

**Systematic alias naming convention:**

```
KATEGORI: Development
├── gitlab@alias.gridshield.se → christian.wallen@gridshield.se
├── github@alias.gridshield.se → christian.wallen@gridshield.se
├── docker@alias.gridshield.se → christian.wallen@gridshield.se
└── npm@alias.gridshield.se → christian.wallen@gridshield.se

KATEGORI: Security Vendors
├── claroty@alias.gridshield.se
├── nozomi@alias.gridshield.se
├── dragos@alias.gridshield.se
├── tenable@alias.gridshield.se
└── burpsuite@alias.gridshield.se

KATEGORI: Client Portals
├── kraftnat@alias.gridshield.se (Svenska Kraftnät)
├── vattenfall@alias.gridshield.se
├── fortum@alias.gridshield.se
└── eon@alias.gridshield.se

KATEGORI: Disposable (Random)
├── webinar-nov-2025@alias.gridshield.se
├── conference-stockholm@alias.gridshield.se
└── download-whitepaper@alias.gridshield.se
```

**Skapa alias i SimpleLogin:**
1. **Aliases** → **New alias**
2. Prefix: `gitlab`
3. Domain: `alias.gridshield.se`
4. Mailbox: christian.wallen@gridshield.se
5. **Create**

**Tips:** Använd beskrivande namn så du vet var mail kommer från!

---

## Fas 5: Proton Pass för Business

### Steg 5.1: Aktivera Proton Pass

**Proton Pass = Lösenordshanterare med SimpleLogin-integration**

1. Öppna: https://pass.proton.me
2. Logga in med Proton Business-konto
3. **Automatic setup** - Pass Plus aktivt direkt

**Funktioner:**
- Unlimited logins
- Unlimited vaults
- 2FA TOTP codes
- Passkeys support
- SimpleLogin alias-generator
- Password health monitoring
- Dark web monitoring
- Secure notes

### Steg 5.2: Installera Browser Extension

**Firefox:**
1. Öppna: about:addons
2. Sök: "Proton Pass"
3. **Add to Firefox**
4. Klicka på Proton Pass-ikonen
5. **Sign in** → christian.wallen@gridshield.se
6. **Unlock with:** Master password / Biometric

**Settings i extension:**
- ✅ Enable autofill
- ✅ Enable autosave
- ✅ Generate SimpleLogin aliases automatically
- ✅ Use biometric unlock (fingerprint)
- ✅ 2FA TOTP codes

### Steg 5.3: Migrera från Bitwarden (om applicable)

**Export från Bitwarden:**
1. Bitwarden → **Tools** → **Export Vault**
2. Format: **JSON**
3. Spara: `bitwarden-export.json`

**Import till Proton Pass:**
1. Proton Pass → **Settings** → **Import**
2. Source: **Bitwarden**
3. Välj: `bitwarden-export.json`
4. **Import**

**Verifiera:**
- Kontrollera att alla logins importerades
- Test auto-fill på några sidor
- Ta bort Bitwarden-export (känslig data!)

### Steg 5.4: SimpleLogin Integration

**Auto-generate aliases vid ny login:**

**Workflow:**
1. Navigera till: claroty.com/register
2. Klicka i email-fältet
3. Proton Pass visar: **Generate alias with SimpleLogin**
4. Klicka → Skapar: `claroty@alias.gridshield.se`
5. Password auto-genererad
6. **Save** → Both alias + password sparade tillsammans
7. 2FA setup → TOTP code också i samma vault entry

**Resultat:**
- En vault entry innehåller: email alias, password, 2FA code
- All communication från Claroty går till christian.wallen@gridshield.se
- Om spam: Disable alias i SimpleLogin → Mail blockerat

---

## Fas 6: Proton Mail Desktop Integration

### Steg 6.1: Installera Proton Mail Desktop App

**Windows:**
1. Öppna: https://proton.me/mail/desktop
2. **Download for Windows**
3. Kör installer: `ProtonMail-Setup.exe`
4. Logga in: christian.wallen@gridshield.se

**Funktioner:**
- Native desktop app (inte webmail)
- Offline access till encrypted mail
- Notifications
- Multiple accounts support
- Better än Mail Bridge (enklare, stabilare)

### Steg 6.2: Proton Mail Bridge (Alternativ)

**Om du vill använda Outlook/Thunderbird:**

1. Download: https://proton.me/mail/bridge
2. Install: Proton Mail Bridge
3. Sign in: christian.wallen@gridshield.se
4. **Bridge genererar credentials:**

```
IMAP Server: 127.0.0.1
Port: 1143
SMTP Server: 127.0.0.1
Port: 1025
Username: christian.wallen@gridshield.se
Password: [Bridge-generated]
```

**Configure Outlook:**
1. Outlook → **Add Account** → **Manual setup**
2. IMAP/SMTP settings från Bridge
3. **Test connection**
4. ✅ Done

**Fördelar:**
- Använd Outlook om du föredrar det
- All mail fortfarande end-to-end encrypted
- Synkar med Proton web/mobile

**Nackdelar:**
- Bridge måste köra i bakgrunden
- Extra komplexitet
- Rekommenderar desktop app istället

---

## Fas 7: Mobile Setup (Android/iOS)

### Steg 7.1: Proton Mail App

**Android:**
1. Google Play Store → "Proton Mail"
2. Install
3. Sign in: christian.wallen@gridshield.se

**iOS:**
1. App Store → "Proton Mail"
2. Install
3. Sign in: christian.wallen@gridshield.se

**Features:**
- Push notifications
- End-to-end encryption
- Offline access
- Swipe gestures
- Dark mode

### Steg 7.2: Proton Pass App

**Install på Android/iOS:**
- Same process som Mail
- Biometric unlock
- Autofill i all apps (inte bara browser)

---

## Fas 8: Security Best Practices

### 8.1: Two-Factor Authentication

**Aktivera 2FA för Proton-konto:**

1. **Settings** → **Security** → **Two-factor authentication**
2. **Setup 2FA**
3. Välj metod:
   - **TOTP** (rekommenderat) - Använd Proton Pass för att spara TOTP code
   - **Security Key** (hardware) - YubiKey, etc.
4. **Backup codes** - Spara säkert

**VIKTIGT:** Spara backup codes på säker plats (inte digitalt!)

### 8.2: Recovery Method

**Setup recovery email/phone:**

1. **Settings** → **Recovery**
2. **Add recovery email:** använd INTE gridshield.se (circular dependency!)
3. Använd: Personlig Gmail/annat
4. **Verify** via code

**Varför:**
- Om du glömmer lösenord
- Om du förlorar 2FA device
- Account recovery

### 8.3: Session Management

**Revoke old sessions:**

1. **Settings** → **Security** → **Sessions**
2. Granska active sessions
3. **Revoke** gamla/okända sessions

**Best practice:**
- Review monthly
- Revoke unknown devices omedelbart
- Use unique device names

### 8.4: Email Encryption for Non-Proton Users

**När du mailar till non-Proton (Gmail, Outlook, etc.):**

**Option 1: Password-Protected (Automatic)**
1. Compose mail till `klient@svenskakraftnät.se`
2. Mail är INTE end-to-end encrypted (mottagare använder inte Proton)
3. Klicka **Lock icon** → **Set password**
4. Ange password
5. **Send**
6. Mottagare får link → Anger password → Läser encrypted mail

**Option 2: PGP (Manual)**
- Om mottagare har PGP public key
- Import their key i Proton
- Mail auto-encrypted med PGP

**Best practice för GridShield:**
- Känsliga dokument: Använd Proton Drive-link istället
- Set expiration (7 days)
- Send password via SMS/phone

---

## Fas 9: Testing & Verification

### 9.1: Test Email Delivery

**Send test email:**
```
To: christian.wallen@gridshield.se (to yourself)
Subject: Test Email från Proton Business
Body: Detta är ett test.

Expected result:
- Email delivered inom 1 minut
- Check SPF/DKIM/DMARC headers
```

**Check headers:**
1. Open email
2. **More** → **View headers**
3. Verifiera:
   - `SPF: PASS`
   - `DKIM: PASS`
   - `DMARC: PASS`

### 9.2: Test External Delivery

**Send to external (Gmail, Outlook):**
```
To: din-personliga@gmail.com
Subject: Test från GridShield Security
Body: Test av Proton Business setup.

Expected result:
- Delivered to inbox (NOT spam)
- SPF/DKIM/DMARC pass
```

**Check på Gmail:**
1. Öppna email
2. **Show original**
3. Verifiera `SPF: PASS`, `DKIM: PASS`, `DMARC: PASS`

### 9.3: Test SimpleLogin Alias

**Create test alias:**
1. SimpleLogin → New alias: `test@alias.gridshield.se`
2. Send mail FROM external till `test@alias.gridshield.se`
3. **Expected:** Mail forwarded till christian.wallen@gridshield.se

**Verify:**
- Check inbox
- Reply → Should come FROM alias, not main email

---

## Troubleshooting

### Problem: Domain verification fails

**Orsak:** DNS records inte propagerade än

**Lösning:**
- Vänta 15-30 minuter efter DNS-ändringar
- Check DNS propagation: https://dnschecker.org
- Verify MX records: `nslookup -type=mx gridshield.se`

### Problem: Mail går till spam

**Orsak:** SPF/DKIM/DMARC inte korrekt konfigurerade

**Lösning:**
1. Verify all DNS records i Loopia
2. Test på: https://www.mail-tester.com
3. Should score 10/10
4. Check SPF: https://mxtoolbox.com/spf.aspx

### Problem: Can't send mail

**Orsak:** MX records pekar inte till Proton

**Lösning:**
1. Check MX records:
   ```bash
   nslookup -type=mx gridshield.se
   ```
2. Should show:
   - `mail.protonmail.ch` (priority 10)
   - `mailsec.protonmail.ch` (priority 20)

### Problem: SimpleLogin alias not working

**Orsak:** Custom domain DNS inte korrekt

**Lösning:**
1. Check MX for alias.gridshield.se:
   ```bash
   nslookup -type=mx alias.gridshield.se
   ```
2. Should show:
   - `mx1.simplelogin.co`
   - `mx2.simplelogin.co`

---

## Maintenance & Best Practices

### Monthly Tasks

- [ ] Review active sessions (revoke gamla)
- [ ] Check email storage usage
- [ ] Review SimpleLogin aliases (disable oanvända)
- [ ] Update Proton Pass passwords (password health check)
- [ ] Backup 2FA codes

### Quarterly Tasks

- [ ] Review DNS records (verify integrity)
- [ ] Test disaster recovery (password reset flow)
- [ ] Review email security headers (mail-tester.com)
- [ ] Audit shared mailboxes (info@, security@)

### Annual Tasks

- [ ] Rotate 2FA method (new TOTP seed)
- [ ] Review Proton Business plan (upgrade if needed)
- [ ] Security audit (penetration test email security)

---

## Sammanfattning

**Du har nu:**
- ✅ End-to-end encrypted email (@gridshield.se)
- ✅ SimpleLogin Premium med custom domain (alias.gridshield.se)
- ✅ Proton Pass för lösenordshantering
- ✅ Swiss jurisdiction privacy protection
- ✅ NIS2/GDPR-compliant communication
- ✅ Professional email infrastructure

**Nästa steg:**
- [DNS Configuration Guide](dns-configuration.md) - Detaljerade DNS-instruktioner
- [Hybrid Architecture](hybrid-architecture.md) - Proton + Microsoft 365 integration
- [IMPLEMENTATION-GUIDE.md](../IMPLEMENTATION-GUIDE.md) - Firefox container setup

---

**Grattis! GridShield Security har nu military-grade email security! 🛡️🔐**
