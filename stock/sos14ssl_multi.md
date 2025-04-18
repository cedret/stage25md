Parfait 👌 Voici une **version améliorée** du script qui :

✅ Teste **plusieurs hôtes (IP ou noms DNS)**  
❌ Affiche les **échecs clairement**  
📣 Peut **envoyer une alerte (par mail, log, ou autre selon ce que tu veux)**  

---

## 🧾 Script : `check_multiple_apache_ssl.sh`

```bash
#!/bin/bash

# Liste des backends Apache à tester (IP:PORT ou HOST:PORT)
BACKENDS=(
  "192.168.1.100:443"
  "192.168.1.101:443"
  "apache.interne.lan:443"
)

# Fichier de log (optionnel)
LOGFILE="/tmp/apache_ssl_check.log"

# Pour envoyer un mail en cas d'erreur (facultatif, nécessite 'mailutils')
SEND_ALERT=true
ALERT_EMAIL="admin@example.com"

# Initialisation
echo "🔎 Vérification des connexions SSL vers les backends Apache" > "$LOGFILE"
ERROR_FOUND=false

for BACKEND in "${BACKENDS[@]}"; do
    HOST=$(echo "$BACKEND" | cut -d: -f1)
    PORT=$(echo "$BACKEND" | cut -d: -f2)

    echo -e "\n🔍 Test de $HOST:$PORT" | tee -a "$LOGFILE"
    
    OUTPUT=$(echo | openssl s_client -connect "$HOST:$PORT" -servername "$HOST" 2>/dev/null)

    if echo "$OUTPUT" | grep -q "BEGIN CERTIFICATE"; then
        SUBJECT=$(echo "$OUTPUT" | grep "subject=" | sed 's/^.*CN=//')
        ISSUER=$(echo "$OUTPUT" | grep "issuer=" | sed 's/^.*CN=//')
        VERIFY=$(echo "$OUTPUT" | grep "Verify return code: 0 (ok)")

        echo "✅ OK : Certificat CN=$SUBJECT - Émis par $ISSUER" | tee -a "$LOGFILE"
    else
        echo "❌ ÉCHEC : Impossible d'établir une connexion SSL avec $HOST:$PORT" | tee -a "$LOGFILE"
        ERROR_FOUND=true
    fi
done

# 🔔 Alerte par mail si échec
if $ERROR_FOUND && $SEND_ALERT; then
    SUBJECT="[ALERTE] Échec SSL sur un ou plusieurs backends Apache"
    mail -s "$SUBJECT" "$ALERT_EMAIL" < "$LOGFILE"
    echo -e "\n📧 Alerte envoyée à $ALERT_EMAIL"
fi
```

---

### ✅ Ce que fait le script :

- Vérifie chaque backend via `openssl s_client`
- Journalise les résultats dans un fichier (`/tmp/apache_ssl_check.log`)
- Si un ou plusieurs tests échouent :
  - Une alerte email est envoyée (si `SEND_ALERT=true`)
- Affiche un résumé propre en console

---

### 🛠 Pour l'utiliser :

1. Installe `mailutils` si tu veux les alertes par mail :
   ```bash
   sudo apt install mailutils
   ```
2. Configure `ALERT_EMAIL` avec ton adresse.
3. Exécute :
   ```bash
   chmod +x check_multiple_apache_ssl.sh
   ./check_multiple_apache_ssl.sh
   ```

---

💡 Tu préfères une alerte par **Slack**, **Telegram**, ou **Discord webhook** au lieu du mail ? Je peux adapter le script pour ça aussi.