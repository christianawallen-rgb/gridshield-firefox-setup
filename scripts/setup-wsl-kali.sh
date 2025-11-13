#!/bin/bash

################################################################################
# GridShield Security - WSL2 Kali Linux Setup Script
# Version: 1.0
# Datum: 2025-11-13
#
# Detta skript konfigurerar WSL2 Kali Linux för GridShield Security med:
# - GitHub Copilot CLI integration
# - GitLab SSH-konfiguration
# - Firefox-integration från terminal
# - Security tools installation
# - Custom aliases och funktioner
#
# ANVÄNDNING:
#   chmod +x setup-wsl-kali.sh
#   ./setup-wsl-kali.sh
################################################################################

set -e  # Exit vid fel

# Färger för output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funktioner för formaterad output
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
show_banner() {
    clear
    echo -e "${GREEN}"
    echo "============================================"
    echo "  GridShield Security"
    echo "  WSL2 Kali Linux Setup"
    echo "  Version 1.0"
    echo "============================================"
    echo -e "${NC}"
}

# Kontrollera om skriptet körs i WSL
check_wsl() {
    log_info "Kontrollerar om skriptet körs i WSL..."
    if ! grep -qi microsoft /proc/version; then
        log_error "Detta skript måste köras i WSL2!"
        exit 1
    fi
    log_success "WSL2 detekterat"
}

# Uppdatera system
update_system() {
    log_info "Uppdaterar Kali Linux..."
    sudo apt update && sudo apt upgrade -y
    log_success "System uppdaterat"
}

# Installera essentiella verktyg
install_essential_tools() {
    log_info "Installerar essentiella verktyg..."

    sudo apt install -y \
        git \
        curl \
        wget \
        vim \
        nano \
        htop \
        tmux \
        screen \
        net-tools \
        iputils-ping \
        dnsutils \
        jq \
        python3 \
        python3-pip \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release

    log_success "Essentiella verktyg installerade"
}

# Installera Node.js (för Copilot CLI)
install_nodejs() {
    log_info "Installerar Node.js 20.x..."

    if command -v node &> /dev/null; then
        log_warning "Node.js redan installerat ($(node --version))"
        return
    fi

    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs

    log_success "Node.js installerat: $(node --version)"
    log_success "npm installerat: $(npm --version)"
}

# Installera GitHub Copilot CLI
install_copilot_cli() {
    log_info "Installerar GitHub Copilot CLI..."

    if command -v github-copilot-cli &> /dev/null; then
        log_warning "GitHub Copilot CLI redan installerat"
        return
    fi

    sudo npm install -g @githubnext/github-copilot-cli

    log_success "GitHub Copilot CLI installerat"
    log_info "Kör 'github-copilot-cli auth' för att autentisera"
}

# Installera Kali Security Tools
install_kali_tools() {
    log_info "Installerar Kali Security Tools..."

    # Fråga användaren vilka metapackages som ska installeras
    echo ""
    echo -e "${YELLOW}Vilka Kali metapackages vill du installera?${NC}"
    echo "1) kali-linux-default (Standard tools)"
    echo "2) kali-tools-web (Web application security)"
    echo "3) kali-tools-information-gathering (Reconnaissance)"
    echo "4) Alla ovanstående"
    echo "5) Hoppa över"
    echo ""
    read -p "Välj (1-5): " choice

    case $choice in
        1)
            sudo apt install -y kali-linux-default
            ;;
        2)
            sudo apt install -y kali-tools-web
            ;;
        3)
            sudo apt install -y kali-tools-information-gathering
            ;;
        4)
            sudo apt install -y kali-linux-default kali-tools-web kali-tools-information-gathering
            ;;
        5)
            log_info "Hoppar över Kali tools-installation"
            return
            ;;
        *)
            log_warning "Ogiltigt val - hoppar över"
            return
            ;;
    esac

    log_success "Kali Security Tools installerade"
}

# Konfigurera SSH
configure_ssh() {
    log_info "Konfigurerar SSH..."

    SSH_DIR="$HOME/.ssh"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # SSH config
    SSH_CONFIG="$SSH_DIR/config"

    if [ -f "$SSH_CONFIG" ]; then
        log_warning "SSH config finns redan - backar upp till config.backup"
        cp "$SSH_CONFIG" "$SSH_CONFIG.backup"
    fi

    cat > "$SSH_CONFIG" << 'EOF'
# GridShield Security - SSH Configuration

# GitLab
Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile ~/.ssh/gitlab_ed25519
  IdentitiesOnly yes
  AddKeysToAgent yes

# GitHub
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_ed25519
  IdentitiesOnly yes
  AddKeysToAgent yes

# Default settings
Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
  AddKeysToAgent yes
  Compression yes
EOF

    chmod 600 "$SSH_CONFIG"
    log_success "SSH konfigurerat"

    # Generera SSH-nycklar om de inte finns
    if [ ! -f "$SSH_DIR/gitlab_ed25519" ]; then
        log_info "Genererar GitLab SSH-nyckel..."
        read -p "Ange din email (för SSH-nyckel): " email
        ssh-keygen -t ed25519 -C "gitlab-${email}" -f "$SSH_DIR/gitlab_ed25519" -N ""
        log_success "GitLab SSH-nyckel genererad"
        echo ""
        echo -e "${YELLOW}=== GITLAB PUBLIC KEY ===${NC}"
        cat "$SSH_DIR/gitlab_ed25519.pub"
        echo -e "${YELLOW}=========================${NC}"
        echo ""
        log_info "Lägg till ovanstående nyckel i GitLab: https://gitlab.com/-/profile/keys"
        read -p "Tryck Enter för att fortsätta..."
    fi

    if [ ! -f "$SSH_DIR/github_ed25519" ]; then
        log_info "Genererar GitHub SSH-nyckel..."
        read -p "Ange din email (för SSH-nyckel): " email
        ssh-keygen -t ed25519 -C "github-${email}" -f "$SSH_DIR/github_ed25519" -N ""
        log_success "GitHub SSH-nyckel genererad"
        echo ""
        echo -e "${YELLOW}=== GITHUB PUBLIC KEY ===${NC}"
        cat "$SSH_DIR/github_ed25519.pub"
        echo -e "${YELLOW}=========================${NC}"
        echo ""
        log_info "Lägg till ovanstående nyckel i GitHub: https://github.com/settings/keys"
        read -p "Tryck Enter för att fortsätta..."
    fi
}

# Konfigurera Git
configure_git() {
    log_info "Konfigurerar Git..."

    read -p "Ange ditt namn (för Git): " git_name
    read -p "Ange din email (för Git): " git_email

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor vim

    # Git aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

    log_success "Git konfigurerat för $git_name <$git_email>"
}

# Skapa bashrc-konfiguration
configure_bashrc() {
    log_info "Konfigurerar .bashrc med GridShield aliases..."

    BASHRC="$HOME/.bashrc"
    BACKUP="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"

    # Backup befintlig .bashrc
    if [ -f "$BASHRC" ]; then
        cp "$BASHRC" "$BACKUP"
        log_info "Backup av .bashrc skapad: $BACKUP"
    fi

    # Lägg till GridShield-konfiguration
    cat >> "$BASHRC" << 'EOF'

# ============================================================================
# GridShield Security - Custom Configuration
# ============================================================================

# Färger för terminalen
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export TERM=xterm-256color

# Prompt customization
export PS1="\[\033[01;32m\]🛡️ \u@gridshield\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

# === GITHUB COPILOT CLI ===
if command -v github-copilot-cli &> /dev/null; then
    alias copilot='github-copilot-cli'
    alias gp='github-copilot-cli suggest'
    alias ge='github-copilot-cli explain'

    # Copilot wrapper-funktion
    copilot_run() {
        local query="$*"
        local suggestion=$(github-copilot-cli suggest "$query" 2>/dev/null)
        echo "🤖 Copilot säger: $suggestion"
        read -p "Kör detta kommando? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            eval "$suggestion"
        fi
    }
    alias gpr='copilot_run'
fi

# === GITLAB ALIASES ===
alias gl-status='git status'
alias gl-log='git lg'
alias gl-push='git push origin $(git branch --show-current)'
alias gl-pull='git pull origin $(git branch --show-current)'
alias gl-clone='git clone'

# GitLab Copilot-integration
if command -v github-copilot-cli &> /dev/null; then
    alias gl-mr='gpr "Create GitLab merge request from current branch to main, remove source branch after merge"'
    alias gl-commit='gpr "Stage all changes and create a git commit with descriptive message"'
fi

# === GITHUB ALIASES ===
alias gh-status='git status'
alias gh-push='git push origin $(git branch --show-current)'
alias gh-pull='git pull origin $(git branch --show-current)'

# === FIREFOX INTEGRATION ===
# Öppna URLs i Windows Firefox från WSL
FIREFOX_PATH="/mnt/c/Program Files/Firefox Developer Edition/firefox.exe"

open_firefox() {
    local url="$1"
    if [ -f "$FIREFOX_PATH" ]; then
        "$FIREFOX_PATH" "$url" &> /dev/null &
    else
        echo "Firefox Developer Edition hittades inte i Windows"
    fi
}

# Firefox shortcuts för olika containers
alias ff-gitlab='open_firefox "https://gitlab.com"'
alias ff-github='open_firefox "https://github.com"'
alias ff-azure='open_firefox "https://portal.azure.com"'
alias ff-m365='open_firefox "https://portal.office.com"'

# Öppna aktuellt Git-repo i Firefox
ff-repo() {
    local remote_url=$(git config --get remote.origin.url 2>/dev/null)
    if [ -z "$remote_url" ]; then
        echo "Ingen Git remote hittades"
        return 1
    fi

    # Konvertera SSH URL till HTTPS
    local https_url=$(echo "$remote_url" | sed 's/git@/https:\/\//' | sed 's/.com:/.com\//' | sed 's/.git$//')
    open_firefox "$https_url"
}

# === SECURITY TOOLS ALIASES ===
alias nmap-quick='sudo nmap -sV -T4 -O -F --version-light'
alias nmap-full='sudo nmap -sS -sV -T4 -A -p-'
alias sqlmap-quick='sqlmap --batch --random-agent'

# Metasploit
alias msfconsole-quiet='msfconsole -q'

# Burp Suite proxy (om körs i Windows)
alias set-burp='export http_proxy=http://127.0.0.1:8080 && export https_proxy=http://127.0.0.1:8080'
alias unset-burp='unset http_proxy && unset https_proxy'

# === SYSTEM ALIASES ===
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# === PROJECT SHORTCUTS ===
# Anpassa dessa efter dina projekt
alias projects='cd ~/projects && ll'
alias gridshield='cd ~/projects/gridshield && ll'

# === USEFUL FUNCTIONS ===

# Snabb sökning i historik
h() {
    if [ -z "$1" ]; then
        history
    else
        history | grep "$1"
    fi
}

# Skapa katalog och cd dit
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Visa aktuell public IP
myip() {
    curl -s https://api.ipify.org && echo
}

# Port scan (egen maskin)
portscan() {
    local target="${1:-localhost}"
    nmap -p- "$target"
}

# === WELCOME MESSAGE ===
echo ""
echo -e "${GREEN}🛡️  GridShield Security - Kali Linux${NC}"
echo -e "${CYAN}Type 'gp \"your question\"' for GitHub Copilot help${NC}"
echo ""

# ============================================================================
# End of GridShield Security Configuration
# ============================================================================
EOF

    log_success "bashrc konfigurerat med GridShield aliases"
}

# Skapa projektkatalog
create_project_dirs() {
    log_info "Skapar projektkatalogier..."

    mkdir -p "$HOME/projects/gridshield"
    mkdir -p "$HOME/tools"
    mkdir -p "$HOME/scripts"

    log_success "Projektkatalogier skapade"
}

# Installera ytterligare säkerhetsverktyg
install_additional_tools() {
    log_info "Vill du installera ytterligare säkerhetsverktyg? (y/n)"
    read -p "> " install_extra

    if [[ ! $install_extra =~ ^[Yy]$ ]]; then
        return
    fi

    log_info "Installerar ytterligare verktyg..."

    # Gobuster (directory bruteforcing)
    sudo apt install -y gobuster

    # ffuf (web fuzzer)
    sudo apt install -y ffuf

    # Subfinder (subdomain enumeration)
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

    # httpx (HTTP toolkit)
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

    log_success "Ytterligare verktyg installerade"
}

# Sammanfattning
show_summary() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  INSTALLATION SLUTFÖRD${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""

    log_info "Nästa steg:"
    echo ""
    echo "1. Autentisera GitHub Copilot CLI:"
    echo "   ${YELLOW}github-copilot-cli auth${NC}"
    echo ""
    echo "2. Testa Copilot:"
    echo "   ${YELLOW}gp \"list all running processes\"${NC}"
    echo ""
    echo "3. Lägg till SSH-nycklar i GitLab/GitHub (om inte redan gjort)"
    echo ""
    echo "4. Ladda om bashrc:"
    echo "   ${YELLOW}source ~/.bashrc${NC}"
    echo ""
    echo "5. Öppna Firefox från terminalen:"
    echo "   ${YELLOW}ff-gitlab${NC}"
    echo ""
    echo -e "${CYAN}Se IMPLEMENTATION-GUIDE.md för fullständig dokumentation${NC}"
    echo ""
}

# Huvudprogram
main() {
    show_banner

    check_wsl

    echo ""
    log_info "Detta skript kommer att installera och konfigurera:"
    echo "  - GitHub Copilot CLI"
    echo "  - Node.js 20.x"
    echo "  - Kali Security Tools"
    echo "  - SSH-konfiguration (GitLab, GitHub)"
    echo "  - Git-konfiguration"
    echo "  - GridShield bashrc aliases"
    echo "  - Firefox-integration"
    echo ""
    read -p "Fortsätt? (y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation avbruten"
        exit 0
    fi

    echo ""

    # Kör installationssteg
    update_system
    install_essential_tools
    install_nodejs
    install_copilot_cli
    install_kali_tools
    configure_ssh
    configure_git
    configure_bashrc
    create_project_dirs
    install_additional_tools

    show_summary
}

# Kör huvudprogrammet
main
