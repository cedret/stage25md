Parfait ! Voici un script Bash pour tester que **ton reverse proxy Nginx communique correctement en HTTPS avec le backend**, c’est-à-dire que :

- 🔄 Le reverse proxy **retransmet bien** les requêtes vers le backend  
- 🔐 Il **vérifie le certificat** du backend signé par ta CA  
- ✅ Tu obtiens une **réponse HTTP correcte via le reverse proxy**

---

## 💻 Script : `test-reverse-proxy-to-backend.sh`

```bash
#!/bin/bash

# === CONFIGURATION ===
REVERSE_PROXY_IP="192.168.1.100"
REVERSE_PROXY_PORT="443"  # ou 80 si HTTP, ou autre si personnalisé
CA_CERT="./certs/ca/my-ca.crt"  # Chemin vers le cert de la CA utilisée par Nginx pour vérifier le backend

echo "🌐 Test de la communication client → Nginx → backend (via HTTPS)"

# 1. Test avec curl vers Nginx (client → reverse proxy)
echo -e "\n🧪 Requête HTTPS vers https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT"

curl -vk "https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" --resolve $REVERSE_PROXY_IP:$REVERSE_PROXY_PORT:$REVERSE_PROXY_IP --cacert "$CA_CERT"

# 2. Test d’un code HTTP uniquement
echo -e "\n✅ Code HTTP retourné :"
curl -s -o /dev/null -w "%{http_code}\n" "https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" --cacert "$CA_CERT"

# 3. Vérifie si proxy_ssl_verify fonctionne en débranchant le backend
echo -e "\n🔐 Vérifie que Nginx bloque si le cert du backend est faux (à tester manuellement)"

# 4. Facultatif : afficher les headers
echo -e "\n📨 En-têtes HTTP renvoyés :"
curl -s -D - "https://$REVERSE_PROXY_IP:$REVERSE_PROXY_PORT" --cacert "$CA_CERT" -o /dev/null
```

---

## 🧪 Que vérifie ce script ?

- Le **reverse proxy Nginx répond bien**
- Il **transmet la requête vers le backend**
- Le code HTTP (`200`, `502`, etc.) reflète l’état du backend
- Nginx **n'accepte que les certs valides** s’il est bien configuré avec `proxy_ssl_verify on;`

---

### ✅ Bonus : Cas de test

- Si tu **remplaces le cert du backend par un mauvais** non signé par la CA → Nginx devrait renvoyer une **erreur 502**
- Si tout est bien configuré → tu vois le contenu servi par Apache backend (genre `Bienvenue sur backend`)

---

Tu veux un petit script d’intégration automatisé qui vérifie les 2 flux (client → Nginx → backend) + backend direct, avec couleurs et tout ?