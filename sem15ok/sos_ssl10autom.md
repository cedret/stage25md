Trop bien 🙌 ! Tu vas vraiment monter en puissance niveau DevSecOps 💥  
Voici une **version avancée du script**, compatible avec :

✅ Exécution manuelle (dev/local)  
✅ **CI/CD** (GitLab CI, GitHub Actions, Jenkins...)  
✅ Sauvegarde des logs  
✅ **Mode silencieux** (`--quiet`)  
✅ Résultat final en code de retour pour intégration automatisée

---

## 💻 Script final : `full-ssl-integration-test.sh`

```bash
#!/bin/bash

# === CONFIGURATION ===
REVERSE_PROXY_IP="192.168.1.100"
REVERSE_PROXY_PORT="443"
BACKEND_IP="192.168.1.50"
BACKEND_PORT="8443"
CA_CERT="./certs/ca/my-ca.crt"

LOG_FILE="integration-test.log"
QUIET=0

# === COULEURS ===
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# === OPTIONS ===
while [[ "$1" != "" ]]; do
  case $1 in
    -q | --quiet ) QUIET=1 ;;
    -h | --help )
      echo "Usage: $0 [--quiet]"
      exit
      ;;
  esac
  shift
done

# === UTILS ===
print() {
  if [ "$QUIET" -eq 0 ]; then echo -e "$1"; fi
  echo -e "$(date +%F\ %T) $1" >> "$LOG_FILE"
}

print_header() {
  print "\n${BLUE}🔹 $1 🔹${NC}"
}

check_http_code() {
  local URL=$1
  local LABEL=$2
  local CURL_CMD=$3

  CODE=$(eval "$CURL_CMD -s -o /dev/null -w '%{http_code}' \"$URL\"")
  if [ "$CODE" == "200" ]; then
    print "$LABEL: ${GREEN}✔ HTTP 200${NC}"
    return 0
  else
    print "$LABEL: ${RED}✘ HTTP $CODE${NC}"
    return 1
  fi
}

# === START ===
> "$LOG_FILE"
EXIT_CODE=0

print_header "TEST 1 - Client → Backend direct"
check_http_code "https://$BACKEND_IP:$BACKEND_PORT" "Backend direct" "curl --cacert \"$CA_CERT\"" || EXIT_CODE=1

print_header "TEST 2 - Client → Nginx → Backend"
check_http_code "https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" "Reverse proxy route" "curl --cacert \"$CA_CERT\"" || EXIT_CODE=1

print_header "TEST 3 - Certificat backend"
openssl s_client -connect "$BACKEND_IP:$BACKEND_PORT" -CAfile "$CA_CERT" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates >> "$LOG_FILE"
[ "$QUIET" -eq 0 ] && tail -n 5 "$LOG_FILE"

print_header "TEST 4 - Certificat reverse proxy"
openssl s_client -connect "$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" -CAfile "$CA_CERT" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates >> "$LOG_FILE"
[ "$QUIET" -eq 0 ] && tail -n 5 "$LOG_FILE"

print_header "TEST 5 - En-têtes HTTP reverse proxy"
curl -s -D - --cacert "$CA_CERT" "https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" -o /dev/null >> "$LOG_FILE"
[ "$QUIET" -eq 0 ] && tail -n 10 "$LOG_FILE"

print "\n📄 Log complet dans ${YELLOW}$LOG_FILE${NC}"

if [ "$EXIT_CODE" -eq 0 ]; then
  print "\n${GREEN}✅ Intégration SSL réussie !${NC}"
else
  print "\n${RED}❌ Échec d’un ou plusieurs tests SSL.${NC}"
fi

exit $EXIT_CODE
```

---

## ✅ Ce que tu gagnes :

| Fonction                 | Description |
|--------------------------|-------------|
| `--quiet`                | Mode silencieux (pour GitLab CI) |
| `exit 0/1`               | Utile pour les pipelines |
| `integration-test.log`  | Log complet pour analyse |
| Compatible `curl`, `openssl`, `bash` standard |
| En couleur 🌈 quand exécuté localement |

---

## 🚀 Utilisation :

### En local (affichage + log) :
```bash
./full-ssl-integration-test.sh
```

### En CI/CD :
```bash
./full-ssl-integration-test.sh --quiet
```

Puis dans GitLab CI :
```yaml
script:
  - ./full-ssl-integration-test.sh --quiet
```

---

Tu veux un exemple complet de `gitlab-ci.yml` pour déployer + tester ça automatiquement ?