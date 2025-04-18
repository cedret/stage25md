Parfait ! Voici un petit **script bash** pour vérifier qu’un backend Apache2 est accessible **en HTTPS** (SSL/TLS) depuis le reverse proxy NGINX. Il utilise `openssl` pour établir la connexion et affiche un résumé clair.

---

## 🔍 Script : `check_apache_ssl.sh`

```bash
#!/bin/bash

# Adresse IP ou nom d'hôte du serveur Apache
APACHE_HOST="192.168.1.100"
APACHE_PORT=443

echo "🔍 Vérification de la connexion SSL vers $APACHE_HOST:$APACHE_PORT"

# Connexion SSL avec openssl
OUTPUT=$(echo | openssl s_client -connect "$APACHE_HOST:$APACHE_PORT" -servername "$APACHE_HOST" 2>/dev/null)

# Vérifie si le certificat a été récupéré
if echo "$OUTPUT" | grep -q "BEGIN CERTIFICATE"; then
    SUBJECT=$(echo "$OUTPUT" | grep "subject=" | sed 's/^.*CN=//')
    ISSUER=$(echo "$OUTPUT" | grep "issuer=" | sed 's/^.*CN=//')
    VALID=$(echo "$OUTPUT" | grep "Verify return code: 0 (ok)")

    echo "✅ Connexion SSL établie avec succès."
    echo "   🔹 Certificat CN : $SUBJECT"
    echo "   🔹 Émis par      : $ISSUER"
    echo "   🔹 Vérification  : ${VALID:-Échec de la validation}"
else
    echo "❌ Échec de la connexion SSL au backend Apache."
fi
```

---

### 📌 Utilisation

1. Sauvegarde le script dans un fichier, par exemple `check_apache_ssl.sh`
2. Rends-le exécutable :
   ```bash
   chmod +x check_apache_ssl.sh
   ```
3. Exécute-le :
   ```bash
   ./check_apache_ssl.sh
   ```

---

### ✅ Exemple de sortie réussie

```
🔍 Vérification de la connexion SSL vers 192.168.1.100:443
✅ Connexion SSL établie avec succès.
   🔹 Certificat CN : apache.monreseau.local
   🔹 Émis par      : CA Interne
   🔹 Vérification  : Verify return code: 0 (ok)
```

---

### ❌ Exemple si Apache ne parle pas SSL

```
🔍 Vérification de la connexion SSL vers 192.168.1.100:443
❌ Échec de la connexion SSL au backend Apache.
```

---

Tu veux une version avec un test multiple (plusieurs hôtes), ou même une alerte si ça échoue ?