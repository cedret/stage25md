#!/bin/bash
#Variables pour la coloration syntaxique
# set -x 
blanc="\033[0m"
noir="\033[30m"
rouge="\033[1;31m"
vert="\033[32m"
orange="\033[33m"
jaune="\033[1;33m"
gris="\033[0;37m"
bleu="\033[1;34m"
reset="\033[m"

echo -e "\n${rouge}========== THE CHECKER =========="
echo "========== =========== =========="
echo -e "${jaune}chmod +x script.sh, localisé dans"
pwd

echo -e "\n${rouge}=== Système d'exploitation ===${jaune}"
OS_NAME=$(lsb_release -d | cut -f2-)
OS_VERSION=$(lsb_release -r | cut -f2-)
ARCHITECTURE=$(uname -m)
echo "Nom: $OS_NAME - Version: $OS_VERSION - Architecture: $ARCHITECTURE"

echo -e "${rouge}\n=== Adresse IP v4 ===${jaune}"
ip -4 a
echo -e "\n${rouge}=== Hostname ===${jaune}"
hostname

while true;
do

echo -e "${bleu}\n=== Configurer cette machine avec Ubuntu 20 ==="
echo -e "${jaune}11 -> Vérif VERSIONS"
echo -e "${jaune}12 -> Config RESEAU"
echo -e "${jaune}13 -> Install PROD Apache2   14 -> Install PROD Apache-Tomcat   15 -> Install RVPX"
echo -e "${jaune}16 -> Install SS-SSL PROD    17 -> Install SS-SSL RVPX          18 -> Install IpSec"
echo -e "${jaune}19 -> Kali promiscuité       20 -> TCPDump                      21 -> Autre?"
echo -e "${jaune}22 -> Eteindre serveur       23 -> Editer ce script             24 -> Historique des commandes"
echo -e "${blanc} 0 -> Quitter"

read reponse

case $reponse in

    11)
    echo -e "\n${rouge}=== CONFIG PRODUCTION ======================"
    # Vérifier la version d'Apache Tomcat
    echo -e "\n${jaune}=== Apache Tomcat Version ==="
    curl -s http://localhost:8080 | grep 'Server version' || echo -e "${blanc}Tomcat absent/ inaccessible"

    echo -e "\n${jaune}=== Apache Version ==="
    APACHE_VERSION=$(apache2 -v 2>/dev/null || httpd -v 2>/dev/null || echo -e "${blanc}Apache2 absent")
    echo -e "${blanc}Apache Version: $APACHE_VERSION"

    echo -e "\n${jaune}=== Version de la JVM ==="
    JVM_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    JVM_VENDOR=$(java -version 2>&1 | awk -F '"' '/version/ {getline; print $0}')
    echo -e "${blanc}JVM Version: $JVM_VERSION"
    echo -e "${blanc}JVM Vendor: $JVM_VENDOR"

    echo -e "\n${jaune}=== PostgreSQL Version ==="
    POSTGRES_VERSION=$(psql --version 2>/dev/null || echo -e "${blanc}PostgreSQL absent")
    echo -e "${blanc}Postrgres Version: $POSTGRES_VERSION"

    echo -e "\n${rouge}=== CONFIG REVERSE PROXY ======================"
    echo -e "\n${jaune}=== Nginx Version ==="
    NGINX_VERSION=$(nginx -v 2>&1 | awk -F '/' '{print $2}' || echo -e "${blanc}Nginx absent")
    echo -e "${blanc}Nginx Version: $NGINX_VERSION"

    echo -e "\n${jaune}=== PHP Version ==="
    PHP_VERSION=$(php -v 2>/dev/null | head -n 1 || echo -e "${blanc}PHP absent")
    echo -e "${blanc}PHP Version: $PHP_VERSION"

    echo -e "\n${jaune}=== Certbot Version ==="
    CERTBOT_VERSION=$(certbot --version 2>/dev/null || echo -e "${blanc}Certbot absent")
    echo -e "${blanc}Certbot Version: $CERTBOT_VERSION"

    echo -e "\n${jaune}=== Openssl Version ==="
    OPENSSL_VERSION=$(openssl version 2>/dev/null || echo -e "${blanc}Openssl absent")
    echo -e "${blanc}Openssl Version: $OPENSSL_VERSION"
#    openssl version
    ;;

  12)
    echo -e "${bleu}========== Config IP fixe de base"
    echo -e "${jaune} sudo nano -l /etc/netplan/01-netcfg.yaml"
    echo -e "${blanc}network:"
    echo -e "${blanc}  version: 2"
    echo -e "${blanc}  renderer: networkd"
    echo -e "${blanc}  ethernets:"
    echo -e "${blanc}    ens33:"
    echo -e "${blanc}      dhcp4: no"
    echo -e "${blanc}      addresses:"
    echo -e "${blanc}        - 192.168.80.?/24"
    echo -e "${blanc}      gateway4: 192.168.80.2"
    echo -e "${blanc}      nameservers:"
    echo -e "${blanc}          addresses: [192.168.80.2]"
    echo -e "${jaune} sudo netplan apply"
    echo -e "${jaune} hostnamectl set-hostname <new hostname>"
    echo -e "${jaune} sudo -l nano /etc/hosts"
    echo -e "${bleu}========== Config actuelle"
    cat /etc/netplan/01-netcfg.yaml
    ;;

  13)
    echo -e "${bleu}========== PROD Apache2 [...139]"
    echo -e "${blanc}>IP .(1)39 +JVM +PostgreSQL +Apache (+Tomcat) +Police MS"
    echo -e "${jaune} sudo apt-get install openjdk-8-jre"
    echo -e "${jaune} sudo apt install postgresql-12"
    echo -e "${jaune} sudo apt install apache2"
    echo -e "${jaune} sudo ufw allow 'Apache'"
    echo -e "${jaune} sudo apt install lynx"
    ;;

  14)
    echo -e "${bleu}========== PROD Tomcat [...139]"
    echo -e "${blanc}>Installation Apache-Tomcat"
    echo -e "${jaune} cd /tmp"
    echo -e "${jaune} wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz"
    echo -e "${jaune} sudo mkdir /opt/tomcat8"
    echo -e "${jaune} sudo tar xvfz apache-tomcat-8.5.50.tar.gz -C /opt/tomcat8/ --strip-components=1"
    echo -e "${jaune} sudo groupadd tomcat8"
    echo -e "${jaune} sudo useradd -s /bin/false -g tomcat8 -d /opt/tomcat8 tomcat8"
    echo -e "${vert}---------A compléter..."
    ;;

  15)
    echo -e "${vert}========== RVPX [...102]"
    echo -e "${blanc}+Nginx +Php +Certbot"
    echo -e "${jaune} sudo apt install nginx-full"
    echo -e "${jaune} sudo apt install php-fpm"
    echo -e "${jaune} sudo apt install lynx"
    echo -e "${jaune} sudo apt install certbot python3-certbot-nginx -y"
    echo -e "${vert}--------- Paramètres"
    echo -e "${jaune} curl http://192.168.80.139 (verif prod)"
    echo -e "${jaune} sudo nano -l/etc/nginx/sites-available/default"
    echo -e "${vert}--------- Contenu /sites-available/default ----- Attention aux $ manquants!"
    echo -e "${blanc}        server_name rp.test.fv;"
    echo -e "${blanc}#       location / {"
    echo -e "${blanc}#                # First attempt to serve request as file, then"
    echo -e "${blanc}#                # as directory, then fall back to displaying a 404."
    echo -e "${blanc}#               try_files \$uri \$uri/ =404;"
    echo -e "${blanc}#       }"
    echo -e "${blanc}        location / {"
    echo -e "${blanc}                proxy_pass http://192.168.80.139:80;"
    echo -e "${blanc}                proxy_set_header Host \$host;"
    echo -e "${blanc}                proxy_set_header X-Real-IP \$remote_addr;"
    echo -e "${blanc}                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"
    echo -e "${blanc}                proxy_set_header X-Forwarded-Proto \$scheme;"
    echo -e "${blanc}        }"
    echo -e "${jaune} sudo nginx -t"
    echo -e "${jaune} sudo systemctl restart nginx"
    echo -e "${vert}--------- Tester..."
    ;;

  16)
    echo -e "${vert}========== SS-SSL PROD"
    echo -e "${blanc}>Verif prod +SS-SSL +"
    echo -e "${jaune} curl http://...139"
    echo -e "${jaune} sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
    echo -e "${jaune}  -keyout /etc/ssl/private/nginx-selfsigned.key \\"
    echo -e "${jaune}  -out /etc/ssl/certs/nginx-selfsigned.crt"
    echo -e "${jaune} curl"
    echo -e "${jaune} a2enmod headers"
    echo -e "${jaune} sudo systemctl restart apache2"
    echo -e "${jaune} sudo a2enmod ssl"
    echo -e "${jaune} sudo ufw allow \"Apache Full\""
    echo -e "${jaune} sudo mkdir -p /etc/ssl/prod"
    echo -e "${jaune} cd /etc/ssl/prod"
    echo -e "${vert}--------- Vérifier !!!"
    echo -e "${jaune} sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
    echo -e "${jaune}  -keyout prod.key \\"
    echo -e "${jaune}  -out prod.crt"
    echo -e "${vert}--------- + Ip du PROD !!!"
    echo -e "${vert}--------- Option Diffie-Hellman ?"
    echo -e "${jaune}......... sudo nano /etc/apache2/sites-available/prod_ssl.conf"
    echo -e "${vert}--------- Création VirtualHost (attention aux $ manquants?)"
    echo -e "${blanc}<VirtualHost *:443>"
    echo -e "${blanc}    ServerAdmin webmaster@localhost"
    echo -e "${blanc}    ServerName 192.168.80.139  # ou prod.local"
    echo -e "${blanc}"
    echo -e "${blanc}    DocumentRoot /var/www/html"
    echo -e "${blanc}"
    echo -e "${blanc}    SSLEngine on"
    echo -e "${blanc}    SSLCertificateFile    /etc/ssl/prod/prod.crt"
    echo -e "${blanc}    SSLCertificateKeyFile /etc/ssl/prod/prod.key"
    echo -e "${blanc}"
    echo -e "${blanc}    <Directory /var/www/html>"
    echo -e "${blanc}        Options Indexes FollowSymLinks"
    echo -e "${blanc}        AllowOverride All"
    echo -e "${blanc}        Require all granted"
    echo -e "${blanc}    </Directory>"
    echo -e "${blanc}"
    echo -e "${blanc}    ErrorLog \${APACHE_LOG_DIR}/error.log"
    echo -e "${blanc}    CustomLog \${APACHE_LOG_DIR}/access.log combined"
    echo -e "${blanc}</VirtualHost>"
#### Activation ssl
    echo -e "${jaune} sudo a2ensite prod_ssl.conf"
    echo -e "${jaune} sudo systemctl restart apache2"
#### Tester
    echo -e "${jaune} curl -k https://192.168.80.139:443"
    echo -e "${jaune} sudo mkdir /var/www/your_domain_or_ip pour index.html???"
    echo -e "${vert}--------- Résultats"
    ;;
  17)
    echo -e "${vert}========== SS-SSL RVPX"
    echo -e "${blanc}>Verif prod +SS-SSL +"
    echo -e "${jaune} curl http://...139"
    echo -e "${jaune} sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
    echo -e "${jaune}  -keyout /etc/ssl/private/nginx-selfsigned.key \\"
    echo -e "${jaune}  -out /etc/ssl/certs/nginx-selfsigned.crt"
    echo -e "${vert}--------- + Ip du RVPX !!!"
    echo -e "${vert}--------- Option Diffie-Hellman"
    echo -e "${jaune}}......... sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048"
    echo -e "${jaune} sudo nano -l /etc/nginx/sites-available/default"
    echo -e "${vert}--------- Afficher 'default' AVANT PROD, attention aux $"
    echo -e "${blanc}server {"
    echo -e "${blanc}    listen 80;"
    echo -e "${blanc}    server_rp.test.fv;"
    echo -e "${blanc}    # Redirection HTTP -> HTTPS"
    echo -e "${blanc}    return 301 https://$host$request_uri;"
    echo -e "${blanc}}"
    echo -e "${blanc}server {"
    echo -e "${blanc}    listen 443 ssl;"
    echo -e "${blanc}    server_rp.test.fv;"
    echo -e "${blanc}    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;"
    echo -e "${blanc}    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;"
    echo -e "${blanc}# Activer selon Diffie-Hellman précédent ou pas?"
    echo -e "${blanc}#    ssl_dhparam /etc/ssl/certs/dhparam.pem;"
    echo -e "${blanc}    ssl_protocols TLSv1.2 TLSv1.3;"
    echo -e "${blanc}    ssl_ciphers HIGH:!aNULL:!MD5;"
    echo -e "${blanc}    ssl_prefer_server_ciphers on;"
    echo -e "${blanc}    # Reverse proxy vers Apache"
    echo -e "${blanc}    location / {"
    echo -e "${blanc}        proxy_pass http://192.168.80.139:80;"
    echo -e "${blanc}        proxy_set_header Host $host;"
    echo -e "${blanc}        proxy_set_header X-Real-IP $remote_addr;"
    echo -e "${blanc}        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
    echo -e "${blanc}        proxy_set_header X-Forwarded-Proto $scheme;"
    echo -e "${blanc}    }"
    echo -e "${blanc}}"
    echo -e "${vert}--------- Vérifier/modifier18 dans 'default' APRES PROD"
    echo -e "${jaune} sudo nano /etc/nginx/sites-available/default "
    echo -e "${blanc} location / {"
    echo -e "${blanc}     proxy_pass https://192.168.80.139:443;"
    echo -e "${blanc}     proxy_ssl_verify off;  # car cert self-signed"
    echo -e "${blanc}     proxy_set_header Host $host;"
    echo -e "${blanc}     proxy_set_header X-Real-IP $remote_addr;"
    echo -e "${blanc} }"
    echo -e "${jaune} sudo nginx -t && sudo systemctl reload nginx"
    echo -e "${vert}--------- Tester... (verif rvpx)"
    echo -e "${jaune} curl -k https://rp.test.fv"
    ;;
  18)
    history
    ;;
  19)
    history
    ;;
  20)
    history
    ;;
  21)

    ;;
  22)
    sudo poweroff
    ;;
  23)
    sudo nano -l vchk.sh
    ;;
  24)
    history
    ;;
  0)
    break
    ;;
esac
echo ""
done
echo -e "\n${vert}====== RAPPELS"
echo -e "${blanc}sudo apt update?"
echo -e "ATTENTION aux identations et aux vm actives"
echo -e "${blanc}Fin de script"
echo -e "${blanc}Tester (depuis) les serveurs?"
