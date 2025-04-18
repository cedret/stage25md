Parfait ✅ Voici un **script Bash de test complet** pour vérifier :

- Que le **backend est bien accessible en HTTPS**
- Que le **certificat est valide et signé par ta CA**
- Que la **chaîne de certification est reconnue par Nginx ou curl**
- (Optionnel) Affiche les détails du certificat

---

## 💻 Script : `test-backend-cert.sh`

```bash
#!/bin/bash

# === Configuration ===
BACKEND_IP="192.168.1.50"
BACKEND_PORT="8443"
CA_CERT="./certs/ca/my-ca.crt"  # chemin vers ta CA
HOST="$BACKEND_IP:$BACKEND_PORT"

echo "🔎 Test de la connexion HTTPS vers https://$HOST"

# 1. Vérification avec curl (avec la CA locale)
echo -e "\n🧪 Test avec curl (vérification via CA locale)..."
curl --cacert "$CA_CERT" -s -o /dev/null -w "%{http_code}\n" "https://$HOST"

# 2. Vérification avec openssl s_client
echo -e "\n🔐 Détails du certificat avec openssl s_client :"
openssl s_client -connect "$HOST" -CAfile "$CA_CERT" -verify_return_error </dev/null 2>/dev/null | openssl x509 -noout -text

# 3. Vérifier l'identité du certificat
echo -e "\n🔍 Sujet et émetteur du certificat :"
openssl s_client -connect "$HOST" -CAfile "$CA_CERT" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer

# 4. Test en cas d'erreur (avec --insecure)
echo -e "\n⚠️ Test sans vérification (ne PAS utiliser en prod) :"
curl -k -s -o /dev/null -w "%{http_code}\n" "https://$HOST"
```

---

## 🚀 Utilisation :

1. Place ce script à la racine de ton projet Ansible :
```bash
nano test-backend-cert.sh
```

2. Colle le contenu, rends-le exécutable :
```bash
chmod +x test-backend-cert.sh
```

3. Exécute :
```bash
./test-backend-cert.sh
```

---

## ✅ Ce que tu verras :
- Code HTTP `200` si tout va bien ✅
- Infos sur le certificat (Common Name, validité, CA)
- En cas de problème, curl ou OpenSSL te dira que le **certificat n’est pas reconnu ou mal signé**

---

Tu veux aussi un équivalent pour tester automatiquement que **Nginx reverse proxy forwarde bien en HTTPS vers le backend** ?