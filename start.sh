#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════╗
# ║  Dev Workstation — Indító Script                                ║
# ║                                                                  ║
# ║  Használat:  bash start.sh                                      ║
# ║  Vagy:       chmod +x start.sh && ./start.sh                    ║
# ╚═══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Színek ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "  ${CYAN}ℹ${NC}  $1"; }
success() { echo -e "  ${GREEN}✅${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC}  $1"; }
error()   { echo -e "  ${RED}❌${NC} $1"; exit 1; }
step()    { echo -e "\n  ${BOLD}── $1 ──${NC}"; }

banner() {
    echo ""
    echo -e "${BOLD}${CYAN}"
    echo "  ╔══════════════════════════════════════════════════════════╗"
    echo "  ║                                                          ║"
    echo "  ║   🚀  Fejlesztői Környezet Telepítő                     ║"
    echo "  ║       Debian 12 (Bookworm) • Ansible Powered             ║"
    echo "  ║                                                          ║"
    echo "  ╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ═══════════════════════════════════════════════
# 1. Ellenőrzések
# ═══════════════════════════════════════════════
check_system() {
    step "Rendszer ellenőrzése"

    # OS check
    if [ ! -f /etc/os-release ]; then
        error "Nem található /etc/os-release — ez Debian rendszer?"
    fi
    . /etc/os-release

    if [ "$ID" != "debian" ]; then
        error "Ez a script Debian rendszerre készült. Jelenlegi: $ID $VERSION_ID"
    fi

    if [ "$VERSION_ID" != "12" ] && [ "$VERSION_ID" != "13" ]; then
        warn "Debian $VERSION_ID detektálva — a script Debian 12/13-ra van optimalizálva"
        read -rp "  Folytatod mégis? (i/n): " choice
        [[ "$choice" =~ ^[iIyY]$ ]] || exit 0
    fi
    success "Debian $VERSION_ID ($VERSION_CODENAME)"

    # sudo check
    if ! sudo -v 2>/dev/null; then
        error "Sudo jogosultság szükséges"
    fi
    success "Sudo jogosultság rendben"
}

# ═══════════════════════════════════════════════
# 2. Ansible telepítése (ha nincs)
# ═══════════════════════════════════════════════
install_ansible() {
    step "Ansible ellenőrzése"

    if command -v ansible-playbook &>/dev/null; then
        success "Ansible már telepítve: $(ansible --version | head -1)"
    else
        info "Ansible telepítése..."
        sudo apt update -qq
        sudo apt install -y -qq ansible >/dev/null 2>&1
        success "Ansible telepítve: $(ansible --version | head -1)"
    fi
}

# ═══════════════════════════════════════════════
# 3. Személyes adatok bekérése
# ═══════════════════════════════════════════════
collect_info() {
    step "Személyes adatok"

    local config_file="group_vars/all.yml"

    # Aktuális értékek kiolvasása
    local current_name current_email
    current_name=$(grep '^git_name:' "$config_file" | sed 's/git_name: *"//' | sed 's/".*//')
    current_email=$(grep '^git_email:' "$config_file" | sed 's/git_email: *"//' | sed 's/".*//')

    echo ""
    read -rp "  Teljes neved [${current_name}]: " git_name
    git_name="${git_name:-$current_name}"

    read -rp "  Email címed [${current_email}]: " git_email
    git_email="${git_email:-$current_email}"

    # Beírás a config fájlba
    sed -i "s|^git_name:.*|git_name: \"$git_name\"|" "$config_file"
    sed -i "s|^git_email:.*|git_email: \"$git_email\"|" "$config_file"

    success "Beállítva: $git_name <$git_email>"

    # Flutter kérdés
    echo ""
    read -rp "  Szükséged van Flutter/Dart fejlesztésre? (i/n) [i]: " flutter_choice
    flutter_choice="${flutter_choice:-i}"

    if [[ "$flutter_choice" =~ ^[nN]$ ]]; then
        sed -i "s|^install_flutter:.*|install_flutter: false|" "$config_file"
        info "Flutter kihagyva"
    else
        sed -i "s|^install_flutter:.*|install_flutter: true|" "$config_file"
        success "Flutter telepítésre kerül"
    fi
}

# ═══════════════════════════════════════════════
# 4. Összegzés
# ═══════════════════════════════════════════════
show_summary() {
    step "Telepítésre kerül"

    echo ""
    echo -e "  ${DIM}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "  ${DIM}│${NC}  PHP          7.4 · 8.2 · 8.3 · 8.4             ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  Node.js      18 · 20 · 22 (NVM)                ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  Docker       CE + Compose + Traefik            ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  Shell        Zsh + Zinit + Starship            ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  MySQL        8.0 (globális konténer)            ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  Redis        7 (globális konténer)              ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  Mailpit      Email tesztelés                    ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  HTTPS        mkcert (*.test)                    ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  DNS          dnsmasq (*.test → localhost)       ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  Linting      PHPStan · Pint · ESLint · Prettier${DIM}│${NC}"

    local flutter_val
    flutter_val=$(grep 'install_flutter:' group_vars/all.yml | awk '{print $2}')
    if [ "$flutter_val" = "true" ]; then
        echo -e "  ${DIM}│${NC}  Flutter      FVM + Dart SDK                    ${DIM}│${NC}"
    fi

    echo -e "  ${DIM}└─────────────────────────────────────────────────┘${NC}"
    echo ""

    read -rp "  Elindítod a telepítést? (i/n) [i]: " confirm
    confirm="${confirm:-i}"

    if [[ ! "$confirm" =~ ^[iIyY]$ ]]; then
        info "Megszakítva. Később: ansible-playbook setup.yml --ask-become-pass"
        exit 0
    fi
}

# ═══════════════════════════════════════════════
# 5. Ansible futtatás
# ═══════════════════════════════════════════════
run_playbook() {
    step "Ansible playbook futtatása"
    echo ""
    info "A rendszer kérni fogja a sudo jelszavadat..."
    echo ""

    ansible-playbook setup.yml --ask-become-pass
}

# ═══════════════════════════════════════════════
# 6. Befejezés
# ═══════════════════════════════════════════════
finish() {
    echo ""
    echo -e "${BOLD}${GREEN}"
    echo "  ╔══════════════════════════════════════════════════════════╗"
    echo "  ║                                                          ║"
    echo "  ║   🎉  Telepítés kész!                                    ║"
    echo "  ║                                                          ║"
    echo "  ╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "  ${BOLD}Következő lépések:${NC}"
    echo ""
    echo -e "  ${BOLD}1.${NC} Jelentkezz ki és vissza (vagy: ${CYAN}newgrp docker${NC})"
    echo ""
    echo -e "  ${BOLD}2.${NC} SSH kulcs → GitLab:"
    echo -e "     ${CYAN}cat ~/.ssh/id_ed25519.pub${NC}"
    echo -e "     ${DIM}→ GitLab: Settings → SSH Keys → Add key${NC}"
    echo ""
    echo -e "  ${BOLD}3.${NC} Ellenőrzés:"
    echo -e "     ${CYAN}ansible-playbook verify.yml${NC}"
    echo ""
    echo -e "  ${BOLD}Hasznos linkek:${NC}"
    echo -e "     Mailpit:   ${CYAN}http://localhost:8025${NC}"
    echo -e "     Traefik:   ${CYAN}http://localhost:8080${NC}"
    echo ""
}

# ═══════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════
main() {
    banner
    check_system
    install_ansible
    collect_info
    show_summary
    run_playbook
    finish
}

main "$@"
