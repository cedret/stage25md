#!/bin/bash

set -e

# Demander l'IP ou le nom du backend
read -p " Entrez l'adresse IP ou le nom de domaine du backend (ex: 192.168.1.50) : " DOMAIN_IP

# Demander le port (avec 8443 par défaut)
read -p " Entrez le port HTTPS souhaité pour Apache [8443] : " PORT
PORT=${PORT:-8443}

CERT_DIR="/etc/ssl/backend"
VHOST_FILE="/etc/apache2/sites-available/backend-ssl.conf"

echo " Création du dossier de certificats..."
sudo mkdir -p $CERT_DIR

echo " Génération du certificat SSL auto-signé..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Backend/OU=IT/CN=$DOMAIN_IP" \
  -keyout $CERT_DIR/backend.key \
  -out $CERT_DIR/backend.crt

echo " Création du VirtualHost Apache sur le port $PORT..."
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

echo " Activation du module SSL et du site HTTPS..."
sudo a2enmod ssl
sudo a2ensite backend-ssl.conf

echo " Redémarrage d'Apache..."
sudo systemctl reload apache2

echo -e "\n Terminé ! Ton backend est maintenant accessible en HTTPS : \033[1;32mhttps://$DOMAIN_IP:$PORT\033[0m"