# 🚀 Új Fejlesztő Onboarding — Lépésről lépésre

Üdv a csapatban! Ez az útmutató végigvezet a fejlesztői környezeted beállításán. **Normális esetben 15-20 perc az egész**, utána azonnal tudsz dolgozni.

---

## 1. Előfeltételek

Egy tiszta **Debian 12 (Bookworm)** telepítés kell, felhasználói fiókkal és sudo jogosultsággal.

> Ha virtuális gépben dolgozol, legalább **4 GB RAM** és **50 GB SSD** ajánlott.

---

## 2. Ansible és Git telepítése

```bash
sudo apt update && sudo apt install -y ansible git
```

---

## 3. A repó letöltése

```bash
git clone git@gitlab.com:CEGNEV/dev-workstation-ansible.git ~/.dotfiles
cd ~/.dotfiles
```

> 🔑 Ha még nincs SSH kulcsod a GitLabban, először HTTPS-sel klónozz:
> ```bash
> git clone https://gitlab.com/CEGNEV/dev-workstation-ansible.git ~/.dotfiles
> ```
> Az Ansible generálni fog neked SSH kulcsot, amit utána beállíthatsz a GitLab fiókodban.

---

## 4. Személyes adatok beállítása

Nyisd meg a `group_vars/all.yml` fájlt és írd át a következőket:

```yaml
git_name: "A Te Neved"
git_email: "te.email@webceg.hu"
```

Csak ez a két sor kell, minden más automatikus!

---

## 5. Futtatás

```bash
cd ~/.dotfiles
ansible-playbook setup.yml --ask-become-pass
```

A rendszer kérni fogja a sudo jelszavadat, utána kb. 10-15 percig telepít.

---

## 6. Befejezés

A telepítés végén három dolgot kell tenned:

### 6.1 Kijelentkezés és visszajelentkezés

```bash
logout
```

Ez kell ahhoz, hogy a Docker csoport és a Zsh shell érvényre jusson.

### 6.2 SSH kulcs beállítása a GitLabban

```bash
cat ~/.ssh/id_ed25519.pub
```

Másold ki a kimenetet, és illeszd be a GitLabban: **Settings → SSH Keys → Add key**

### 6.3 Ellenőrzés

```bash
cd ~/.dotfiles
ansible-playbook verify.yml
```

Ha minden zöld, készen állsz!

---

## 7. Mindennapi használat — Gyorsreferencia

### PHP verzióváltás

```bash
switch-php 8.3       # Átállítás PHP 8.3-ra
switch-php 8.2       # Átállítás PHP 8.2-re
switch-php            # Aktuális verzió és elérhető verziók kiírása
```

### Node.js verzióváltás

```bash
nvm use 20           # Átállítás Node 20-ra
nvm use 22           # Átállítás Node 22-re
```

> 💡 Ha a projekt mappában van `.nvmrc` fájl, a terminál automatikusan átvált a megfelelő Node verzióra!

### Új Laravel projekt indítása

```bash
new-laravel pelda-projekt     # Létrehozza a projektet
cd pelda-projekt
```

Ezután másold be a Docker Compose sablont:
```bash
cp ~/.dotfiles/templates/project-scaffold/docker-compose.yml.example docker-compose.yml
```

Cseréld ki a `PROJEKTNEV` szöveget mindenhol a projekt nevére, majd:
```bash
docker compose up -d
```

Nyisd meg: **https://pelda-projekt.test** ✨

### Hasznos URL-ek

| Szolgáltatás | URL | Leírás |
|-------------|-----|--------|
| **Mailpit** | http://localhost:8025 | Kiküldött emailek megtekintése |
| **Traefik** | http://localhost:8080 | Reverse proxy dashboard |
| **MySQL** | `127.0.0.1:3306` | root / devroot |
| **Redis** | `127.0.0.1:6379` | Jelszó nélkül |

### Hasznos parancsok

| Parancs | Mit csinál |
|---------|-----------|
| `lg` | lazygit — Git TUI |
| `ld` | lazydocker — Docker TUI |
| `art` | php artisan |
| `tinker` | php artisan tinker |
| `gs` | git status |
| `ll` | Részletes fájllistázás (eza) |
| `lt` | Fastruktúra nézet |
| `z projektnev` | Okos cd (zoxide) — megjegyzi a könyvtáraidat |

### Flutter/Dart

```bash
fvm use stable               # Stable Flutter SDK használata
fvm use 3.22.0               # Specifikus verzió
flutter doctor                # Telepítés ellenőrzése (fvm-en át megy)
```

---

## 8. Hibaelhárítás

### "Docker: permission denied"
Kijelentkeztél és visszajelentkeztél a telepítés után? Ha igen:
```bash
groups
```
A kimenetben kell lennie `docker`-nek. Ha nincs, futtasd újra a `--tags docker` részt.

### "*.test domain nem működik"
```bash
nslookup valami.test 127.0.0.1
```
Ha nem válaszol, a dnsmasq nem fut:
```bash
sudo systemctl status dnsmasq
sudo systemctl restart dnsmasq
```

### "HTTPS tanúsítvány nem megbízható"
```bash
mkcert -install
```
Ezután indítsd újra a böngészőt.

### "PHP extension hiányzik"
```bash
php -m | grep -i KITERJESZTES_NEVE
```
Ha nincs benne:
```bash
sudo apt install php8.3-KITERJESZTES
```

### Teljes újratelepítés
```bash
cd ~/.dotfiles
ansible-playbook setup.yml --ask-become-pass
```
A playbook idempotens — bármikor újrafuttatható, csak a hiányzó dolgokat telepíti.

---

## 9. A környezet frissítése

Ha a csapattárs frissíti a repót (pl. új PHP kiterjesztés, új tool):

```bash
cd ~/.dotfiles
git pull
ansible-playbook setup.yml --ask-become-pass
```

Csak a változások futnak le, a meglévő konfiguráció marad.

---
