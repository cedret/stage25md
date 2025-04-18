Parfait, voici un **script Bash** simple pour :

✅ Générer un certificat SSL auto-signé  
✅ Créer un VirtualHost Apache écoutant en HTTPS sur le port 8443  
✅ Activer SSL sur Apache

Ce script est à exécuter **sur ton serveur backend Ubuntu** où Apache est installé.

---

### 💻 Script : `setup-apache-ssl-backend.sh`

```bash
#!/bin/bash

set -e

CERT_DIR="/etc/ssl/backend"
DOMAIN_IP="192.168.1.50"  # À modifier si besoin
PORT="8443"
VHOST_FILE="/etc/apache2/sites-available/backend-ssl.conf"

echo "🔧 Création du dossier de certificats..."
sudo mkdir -p $CERT_DIR

echo "🔐 Génération du certificat SSL auto-signé..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Backend/OU=IT/CN=$DOMAIN_IP" \
  -keyout $CERT_DIR/backend.key \
  -out $CERT_DIR/backend.crt

echo "📄 Création du VirtualHost Apache sur le port $PORT..."
sudo bash -c "cat > $VHOST_FILE" <<EOF
<VirtualHost *:$PORT>
    ServerAdmin webmaster@localhost
    ServerName $DOMAIN_IP

    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    $CERT_DIR/backend.crt
    SSLCertificateKeyFile $CERT_DIR/backend.key

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

echo "⚙️ Activation du module SSL et du site HTTPS..."
sudo a2enmod ssl
sudo a2ensite backend-ssl.conf

echo "🔄 Redémarrage d'Apache..."
sudo systemctl reload apache2

echo "✅ Terminé ! Ton backend est maintenant disponible en HTTPS sur https://$DOMAIN_IP:$PORT"
```

---

### 🚀 Utilisation :

1. Sauvegarde le script :
```bash
nano setup-apache-ssl-backend.sh
```

2. Colle le code, puis enregistre avec `Ctrl + O`, `Entrée`, `Ctrl + X`

3. Rends-le exécutable :
```bash
chmod +x setup-apache-ssl-backend.sh
```

4. Exécute-le avec sudo :
```bash
sudo ./setup-apache-ssl-backend.sh
```

---

Tu veux que je t’ajoute une option pour **choisir dynamiquement l'IP ou le port** dans le script (mode interactif) ?