# 🚀 Dev Workstation Ansible

Professzionális webfejlesztői környezet automatizált telepítése **Debian 12 (Bookworm)** rendszeren.

Egy parancs — és 15 perc múlva kész a teljes fejlesztői környezet.

## Indítás

```bash
sudo apt update && sudo apt install -y ansible git
git clone git@gitlab.com:CEGNEV/dev-workstation-ansible.git ~/.dotfiles
cd ~/.dotfiles
bash start.sh
```

> **Figyelem!** A `start.sh` futtatása előtt írd át a nevedet és email címedet a `group_vars/all.yml` fájlban, vagy a script interaktívan bekéri.

## Projekt struktúra

```text
├── start.sh                    ← Indító script (ezt kell futtatni)
├── setup.yml                   ← Fő Ansible playbook
├── verify.yml                  ← Post-install ellenőrzés
├── group_vars/all.yml          ← Konfiguráció (név, email, verziók)
├── roles/
│   ├── 01_system/              ← APT csomagok, Git, SSH, GitLab CLI
│   ├── 02_shell/               ← Zsh, Zinit, Starship prompt
│   ├── 03_docker/              ← Docker CE + Compose, lazydocker
│   ├── 04_php/                 ← PHP 7.4/8.2/8.3/8.4, Composer
│   ├── 05_node/                ← NVM, Node 18/20/22, Vue CLI
│   ├── 06_flutter/             ← Dart SDK + FVM
│   ├── 07_local_infra/         ← Traefik, MySQL, Redis, Mailpit, mkcert
│   └── 08_quality_tools/       ← PHPStan, Pint, ESLint, Prettier
├── templates/project-scaffold/ ← Sablon új Laravel projekthez
└── docs/ONBOARDING.md          ← Teljes útmutató új fejlesztőknek
```

## Mit telepít?

| Kategória | Eszközök |
|-----------|----------|
| **PHP** | 7.4, 8.2, 8.3, 8.4 (Sury) + Composer + Laravel Installer |
| **Node.js** | 18, 20, 22 (NVM) + pnpm + Vue CLI + Vite |
| **Flutter** | Dart SDK + FVM (opcionális) |
| **Docker** | CE + Compose + Buildx + lazydocker |
| **Shell** | Zsh + Zinit + Starship prompt + modern CLI tools |
| **Infra** | Traefik (*.test routing) + MySQL 8.0 + Redis 7 + Mailpit |
| **HTTPS** | mkcert wildcard tanúsítványok |
| **DNS** | dnsmasq (*.test → 127.0.0.1) |
| **Linting** | PHPStan, Laravel Pint, PHPCS, ESLint, Prettier, Biome |

## Mindennapi használat

```bash
# PHP verzióváltás
switch-php 8.3
switch-php 8.2

# Node verzióváltás
nvm use 20

# Új Laravel projekt
new-laravel projektnev

# Hasznos aliasok
art           # → php artisan
tinker        # → php artisan tinker
lg            # → lazygit
ld            # → lazydocker
ll            # → részletes lista
z projektnev  # → okos cd (zoxide)
```

## Hasznos URL-ek

| Szolgáltatás | URL |
|-------------|-----|
| Mailpit | http://localhost:8025 |
| Traefik Dashboard | http://localhost:8080 |
| MySQL | `127.0.0.1:3306` (root / devroot) |
| Redis | `127.0.0.1:6379` |

## Szelektív futtatás

Nem kell mindig mindent telepíteni — tag-ekkel szűrhetsz:

```bash
ansible-playbook setup.yml --ask-become-pass --tags docker
ansible-playbook setup.yml --ask-become-pass --tags php
ansible-playbook setup.yml --ask-become-pass --tags shell
ansible-playbook setup.yml --ask-become-pass --tags infra
```

## Környezet frissítése

```bash
cd ~/.dotfiles
git pull
ansible-playbook setup.yml --ask-become-pass
```

A playbook idempotens — csak a változásokat telepíti.

## Ellenőrzés

```bash
ansible-playbook verify.yml
```
