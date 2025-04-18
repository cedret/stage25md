💥 Voici un **script d’intégration complet et stylé** pour tester tout le flux :  
✅ **Client → Nginx → Backend**  
✅ **Client → Backend direct**  
✅ **Certificats valides**  
✅ **Codes HTTP + détails**  
✅ Couleurs + affichage propre pour CI, DevOps ou pentest 🔎

---

## 💻 Script : `full-ssl-integration-test.sh`

```bash
#!/bin/bash

# === CONFIGURATION ===
REVERSE_PROXY_IP="192.168.1.100"
REVERSE_PROXY_PORT="443"
BACKEND_IP="192.168.1.50"
BACKEND_PORT="8443"
CA_CERT="./certs/ca/my-ca.crt"

# === COULEURS ===
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# === FONCTIONS ===
print_header() {
  echo -e "\n${BLUE}🔹 $1 🔹${NC}"
}

check_http_code() {
  local URL=$1
  local LABEL=$2
  local CURL_CMD=$3

  CODE=$(eval "$CURL_CMD -s -o /dev/null -w '%{http_code}' \"$URL\"")

  if [ "$CODE" == "200" ]; then
    echo -e "$LABEL: ${GREEN}✔ HTTP 200${NC}"
  else
    echo -e "$LABEL: ${RED}✘ HTTP $CODE${NC}"
  fi
}

# === TESTS ===

print_header "TEST 1 - Backend direct (client → backend)"
check_http_code "https://$BACKEND_IP:$BACKEND_PORT" "Backend direct" "curl --cacert \"$CA_CERT\""

print_header "TEST 2 - Reverse proxy (client → nginx → backend)"
check_http_code "https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" "Reverse proxy route" "curl --cacert \"$CA_CERT\""

print_header "TEST 3 - Détails du certificat du backend"
openssl s_client -connect "$BACKEND_IP:$BACKEND_PORT" -CAfile "$CA_CERT" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates

print_header "TEST 4 - Détails du certificat visible depuis reverse proxy"
openssl s_client -connect "$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" -CAfile "$CA_CERT" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates

print_header "TEST 5 - En-têtes HTTP reverse proxy"
curl -s -D - --cacert "$CA_CERT" "https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" -o /dev/null

echo -e "\n${YELLOW}🧪 Test terminé.${NC} Vérifie les erreurs, codes HTTP, certificats, et connexions SSL."
```

---

## ✅ Résultat du script :

Tu obtiendras :
- ✔ ou ✘ pour chaque test
- Affichage de :
  - Certificats (subject, issuer, validité)
  - Codes HTTP
  - Headers HTTP

---

## 🚀 Utilisation :

1. Place ce script à la racine du projet :
```bash
nano full-ssl-integration-test.sh
```

2. Colle, puis rends-le exécutable :
```bash
chmod +x full-ssl-integration-test.sh
```

3. Lance-le :
```bash
./full-ssl-integration-test.sh
```

---

Tu veux une version encore plus poussée avec **log en fichier**, **mode silencieux**, ou **compatibilité CI/CD** (GitLab CI, Jenkins...) ?