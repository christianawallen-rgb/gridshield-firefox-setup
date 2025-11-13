# GridShield Security - Quick Reference Card

**Skriv ut detta och ha bredvid datorn under setup!**

---

## 🎯 Day 1 Timeline

| Tid | Steg | Guide |
|-----|------|-------|
| 0:00 | Pre-Setup | day-1-setup-checklist.md |
| 0:15 | Proton Business Setup | proton-business-setup.md |
| 1:00 | DNS Configuration | dns-configuration-loopia.md |
| 1:30 | DNS Wait (☕ break) | - |
| 2:00 | Email Testing | day-1-setup-checklist.md |
| 2:15 | Windows 11 Install | Standard installation |
| 2:45 | Firefox Setup | quick-start.md |
| 3:45 | Windows Terminal | IMPLEMENTATION-GUIDE.md |
| 4:05 | WSL2 Kali (optional) | scripts/setup-wsl-kali.sh |
| 4:35 | Final Verification | day-1-setup-checklist.md |

**Total: ~4-5 timmar**

---

## 📧 Email Architecture

```
📧 gridshield.se → Proton Business (primary)
   └─ christian.wallen@gridshield.se

🎭 alias.gridshield.se → SimpleLogin Premium
   ├─ gitlab@alias.gridshield.se
   ├─ claroty@alias.gridshield.se
   └─ kraftnat@alias.gridshield.se

☁️ m365.gridshield.se → Microsoft 365 (collaboration only)
   └─ christian.wallen@m365.gridshield.se
```

---

## 🌐 DNS Records Cheatsheet

### Proton Business (gridshield.se)

```
TXT  @                    protonmail-verification=XXXXX
MX   @  10                mail.protonmail.ch
MX   @  20                mailsec.protonmail.ch
TXT  @                    v=spf1 include:_spf.protonmail.ch ~all
CNAME protonmail._domainkey   protonmail.domainkey.dXXXX...
CNAME protonmail2._domainkey  protonmail2.domainkey.dXXXX...
CNAME protonmail3._domainkey  protonmail3.domainkey.dXXXX...
TXT  _dmarc                v=DMARC1; p=quarantine; rua=mailto:postmaster@gridshield.se
```

### SimpleLogin (alias.gridshield.se)

```
TXT  alias                sl-verification=XXXXX
MX   alias  10            mx1.simplelogin.co
MX   alias  20            mx2.simplelogin.co
TXT  alias                v=spf1 include:simplelogin.co ~all
TXT  _dmarc.alias         v=DMARC1; p=quarantine; pct=100
```

---

## 🔥 Firefox Containers

| # | Name | Color | Usage |
|---|------|-------|-------|
| 1 | Work-M365 | 🔵 Blue | Microsoft 365, Azure |
| 2 | Work-Proton | 🟢 Green | Proton Mail, Pass, Drive |
| 3 | Development | 🟠 Orange | GitLab, GitHub |
| 4 | Client-Access | 🔴 Red | Svenska Kraftnät, clients |
| 5 | Security-Research | 🟣 Purple | CVE, Claroty, Nozomi |
| 6 | Testing-Sandbox | 🟡 Yellow | Pentesting, auto-delete |
| 7 | Personal | ⚪ Toolbar | Bank, LinkedIn |

---

## ⌨️ Essential Commands

### DNS Verification (PowerShell)

```powershell
# Check MX records
nslookup -type=mx gridshield.se

# Check TXT/SPF records
nslookup -type=txt gridshield.se

# Check SimpleLogin MX
nslookup -type=mx alias.gridshield.se

# Flush DNS cache
ipconfig /flushdns
```

### Firefox Installation

```powershell
# Run installer
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\Install-GridShieldFirefox.ps1
```

### WSL2 Kali Setup

```bash
# In Kali (WSL)
chmod +x setup-wsl-kali.sh
./setup-wsl-kali.sh

# GitHub Copilot Auth
github-copilot-cli auth

# Test Copilot
gp "list all Docker containers"

# Open Firefox from WSL
ff-gitlab  # Opens GitLab in Development container
```

### Windows Terminal

```
Ctrl+Shift+T    New tab
Ctrl+Shift+1    GridShield PowerShell
Ctrl+Shift+2    Kali Linux
Alt+Shift++     Split horizontal
Alt+Shift+-     Split vertical
```

---

## 🔐 Proton Pass Workflow

**Register på ny site:**
1. Click email field
2. Proton Pass → "Generate alias"
3. Auto-creates: `sitename@alias.gridshield.se`
4. Auto-generates password
5. Save → Both stored together

**Setup 2FA:**
1. Site shows QR code
2. Proton Pass → Add TOTP
3. Scan QR
4. Code auto-fills from Pass

---

## ✅ Verification Checklist

### Email System
- [ ] Mail-tester.com: 10/10 score
- [ ] SPF: PASS
- [ ] DKIM: PASS
- [ ] DMARC: PASS
- [ ] SimpleLogin alias forwards correctly

### Firefox
- [ ] WebRTC: No leaks (browserleaks.com/webrtc)
- [ ] Fingerprinting: Strong protection (coveryourtracks.eff.org)
- [ ] Containers: 7 isolated, color-coded
- [ ] Proton Pass: Autofill works
- [ ] userChrome.css: Dark theme applied

### Windows Terminal
- [ ] 6 profiles configured
- [ ] Colors correct (GridShield Dark, Kali Dark)
- [ ] Kali Linux profile works (if WSL installed)

### WSL2/Kali
- [ ] GitHub Copilot CLI authenticated
- [ ] SSH to GitLab works (`ssh -T git@gitlab.com`)
- [ ] Firefox integration works (`ff-gitlab`)

---

## 🆘 Troubleshooting Quick Fixes

### DNS Not Propagating
```powershell
# Wait 30 min, then check
ipconfig /flushdns
nslookup -type=mx gridshield.se
```
**Online:** https://dnschecker.org

### Email Goes to Spam
1. Check: https://www.mail-tester.com (must be 10/10)
2. Verify: All DKIM CNAMEs correct
3. Verify: SPF TXT record exists
4. Verify: DMARC TXT record exists

### Firefox Container Not Working
```
about:config → privacy.firstparty.isolate = true
```
Restart Firefox

### Proton Pass Not Autofilling
1. Extension → Settings → Enable autofill
2. Site permissions → Allow Proton Pass
3. Reload page

### WSL Kali Not Starting
```powershell
wsl --shutdown
wsl --list --verbose
wsl -d kali-linux
```

---

## 📞 Support Contacts

| Service | Contact |
|---------|---------|
| **Proton** | https://proton.me/support |
| **Loopia** | +46 21-12 82 22, support@loopia.se |
| **Microsoft 365** | +46 8-519 95 000 |
| **GitHub** | https://github.com/support |

---

## 🔗 Important URLs

```
Proton Mail:        https://mail.proton.me
Proton Account:     https://account.proton.me
SimpleLogin:        https://app.simplelogin.io
Loopia DNS:         https://customerzone.loopia.se
M365 Admin:         https://admin.microsoft.com
Azure Portal:       https://portal.azure.com

Testing:
Mail Tester:        https://www.mail-tester.com
DNS Checker:        https://dnschecker.org
WebRTC Leak:        https://browserleaks.com/webrtc
Fingerprinting:     https://coveryourtracks.eff.org
```

---

## 📁 Repository Structure

```
gridshield-firefox-setup/
├── README.md
├── IMPLEMENTATION-GUIDE.md          # Full 12-phase guide
├── docs/
│   ├── day-1-setup-checklist.md     ⭐ START HERE
│   ├── quick-start.md               # Firefox 60-min
│   ├── proton-business-setup.md     # Email 45-min
│   ├── dns-configuration-loopia.md  # DNS 30-min
│   └── burp-suite-setup.md          # Security testing
├── scripts/
│   ├── Install-GridShieldFirefox.ps1  # Auto-installer
│   ├── Backup-FirefoxProfile.ps1      # Backup tool
│   └── setup-wsl-kali.sh              # Kali automation
└── assets/
    ├── containers-config.json         # Import to Firefox
    ├── userChrome.css                 # Dark theme
    └── windows-terminal-settings.json # Terminal config
```

---

## 🎯 Success Criteria (End of Day 1)

**Email:**
- ✅ Can send/receive from christian.wallen@gridshield.se
- ✅ SimpleLogin aliases forward correctly
- ✅ Mail-tester.com score: 10/10

**Browser:**
- ✅ Firefox with 7 isolated containers
- ✅ Proton Pass autofill works
- ✅ No WebRTC leaks
- ✅ Extensions installed and configured

**Development:**
- ✅ Windows Terminal with profiles
- ✅ WSL2 Kali Linux (optional)
- ✅ GitHub Copilot CLI working
- ✅ Git/GitLab/GitHub configured

**Security:**
- ✅ End-to-end encrypted email
- ✅ Swiss privacy protection
- ✅ Zero Trust browser architecture
- ✅ NIS2/GDPR-compliant

---

**📄 Print this page and keep it nearby during setup!**

**Repository:** https://github.com/christianawallen-rgb/gridshield-firefox-setup

**Version:** 1.0 | **Date:** 2025-11-13
