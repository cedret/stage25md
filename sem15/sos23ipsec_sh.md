Parfait ! Voici une **version améliorée du script** `verif_ipsec.sh` qui :

- Garde une trace complète dans un fichier de log (`/var/log/ipsec_verif.log`)
- Affiche les résultats en temps réel
- Organise proprement les sections
- Gère les erreurs simples
cg
---

### ✅ Script complet avec logs détaillés

```bash
#!/bin/bash

LOG_FILE="/var/log/ipsec_verif.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Créer ou vider le fichier de log
sudo bash -c "echo '=== 🔐 Vérification IPsec - $TIMESTAMP ===' > $LOG_FILE"

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "\n[1] 🔍 État du tunnel IPsec"
sudo ipsec status | grep -E 'ESTABLISHED|INSTALLED' | tee -a "$LOG_FILE"
if [ $? -ne 0 ]; then
  log "❌ Aucun tunnel IPsec établi."
fi

log "\n[2] 📊 Compteurs de paquets IPsec (XFRM)"
sudo ip -s xfrm state | awk '/src | packets| bytes/' | tee -a "$LOG_FILE"

log "\n[3] 📡 Paquets ESP captés (protocole IPsec - 5 secondes)"
sudo timeout 5 tcpdump -ni any esp 2>/dev/null | tee -a "$LOG_FILE"
if [ $? -ne 0 ]; then
  log "❌ Aucun paquet ESP détecté (vérifie que du trafic passe pendant la capture)"
fi

log "\n[4] 🌐 Test HTTP vers le backend"
read -p "Entrez l'IP du backend (ex: 192.168.10.93): " backend_ip
curl_output=$(curl -s -o /dev/null -w "%{http_code}" http://$backend_ip)
log "Code HTTP reçu de $backend_ip : $curl_output"
if [ "$curl_output" != "200" ]; then
  log "⚠️ Le backend ne répond pas correctement (code $curl_output)"
fi

log "\n[5] 🪵 Derniers logs StrongSwan (10 lignes)"
sudo journalctl -u strongswan --no-pager -n 10 | tee -a "$LOG_FILE"

log "\n✅ Vérification terminée. Rapport complet : $LOG_FILE"
```

---

### 🔧 Instructions d'utilisation

1. Enregistre le script :
   ```bash
   nano verif_ipsec.sh
   ```

2. Colle le script, sauvegarde et rends-le exécutable :
   ```bash
   chmod +x verif_ipsec.sh
   ```

3. Lance-le :
   ```bash
   sudo ./verif_ipsec.sh
   ```

4. Pour consulter le rapport plus tard :
   ```bash
   sudo less /var/log/ipsec_verif.log
   ```

---

Tu veux que je te l’adapte pour fonctionner en **cron** ou avec **mail automatique du rapport** ?