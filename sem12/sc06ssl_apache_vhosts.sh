#!/bin/bash

set -e

echo " Création d'un nouveau VirtualHost Apache avec SSL"

# 1. Demander les infos à l'utilisateur
read -p "Nom du VirtualHost (ex: backend1, api2) : " VHOST_NAME
read -p "Adresse IP ou nom de domaine (ServerName) : " SERVER_NAME
read -p "Port HTTPS [8443] : " PORT
PORT=${PORT:-8443}

# 2. Définir chemins
CERT_DIR="/etc/ssl/$VHOST_NAME"
WEB_ROOT="/var/www/$VHOST_NAME"
VHOST_FILE="/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf"

# 3. Créer les dossiers nécessaires
echo " Création des dossiers..."
sudo mkdir -p $CERT_DIR
sudo mkdir -p $WEB_ROOT

# 4. Créer une page index.html basique
echo "<h1>Bienvenue sur $VHOST_NAME en HTTPS 🎉</h1>" | sudo tee $WEB_ROOT/index.html > /dev/null

# 5. Générer le certificat SSL auto-signé
echo " Génération du certificat SSL..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=DevOps/OU=IT/CN=$SERVER_NAME" \
  -keyout $CERT_DIR/$VHOST_NAME.key \
  -out $CERT_DIR/$VHOST_NAME.crt

# 6. Créer le VirtualHost Apache
echo " Création du fichier de configuration Apache..."
sudo bash -c "cat > $VHOST_FILE" <<EOF
<VirtualHost *:$PORT>
    ServerAdmin webmaster@localhost
    ServerName $SERVER_NAME

    DocumentRoot $WEB_ROOT

    SSLEngine on
    SSLCertificateFile    $CERT_DIR/$VHOST_NAME.crt
    SSLCertificateKeyFile $CERT_DIR/$VHOST_NAME.key

    <Directory $WEB_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${VHOST_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${VHOST_NAME}_access.log combined
</VirtualHost>
EOF

# 7. Activer le vhost et SSL
echo " Activation du site et du module SSL..."
sudo a2enmod ssl
sudo a2ensite ${VHOST_NAME}-ssl.conf

# 8. Redémarrer Apache
echo " Redémarrage d'Apache..."
sudo systemctl reload apache2

# 9. Résumé
echo -e "\n VirtualHost \033[1;34m$VHOST_NAME\033[0m actif sur : \033[1;32mhttps://$SERVER_NAME:$PORT\033[0m"