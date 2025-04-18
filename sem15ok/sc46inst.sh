#!/bin/bash
#Variables pour la coloration syntaxique
# set -x 
blanc="\033[0m"
jaune="\033[1;33m"
noir="\033[30m"
rouge="\033[1;31m"
vert="\033[32m"
orange="\033[33m"
gris="\033[1;30m"
bleu="\033[1;34m"
pourpre="\033[1;35m"
reset="\033[m"

# historique des versions
# v1x initiale
# v2x + automatisation réseau et extension
# v3x nouveau menu et extension
# v4x nouveau menu, +automatisation rvpx et extension
# v44 +rvpx auto
# v45 +ssl rvpx auto
# v46 +ssl prod auto

version="170425"

testversions()
{
    #Choix 11
    echo -e "\n${vert}========== 11 CONFIG PRODUCTION ======================"
    # Vérifier la version d'Apache Tomcat
    echo -e "${jaune}----- Apache Tomcat Version -----"
    curl -s http://localhost:8080 | grep 'Server version' || echo -e "${blanc}Tomcat absent/ inaccessible"

    echo -e "${jaune}----- Apache Version -----"
    APACHE_VERSION=$(apache2 -v 2>/dev/null || httpd -v 2>/dev/null || echo -e "${blanc}Apache2 absent")
    echo -e "${blanc}Apache Version: $APACHE_VERSION"

    echo -e "${jaune}----- Version de la JVM -----"
    JVM_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    JVM_VENDOR=$(java -version 2>&1 | awk -F '"' '/version/ {getline; print $0}')
    echo -e "${blanc}JVM Version: $JVM_VERSION"
    echo -e "${blanc}JVM Vendor: $JVM_VENDOR"

    echo -e "${jaune}----- PostgreSQL Version -----"
    POSTGRES_VERSION=$(psql --version 2>/dev/null || echo -e "${blanc}PostgreSQL absent")
    echo -e "${blanc}Postrgres Version: $POSTGRES_VERSION"

    echo -e "\n${vert}=== CONFIG REVERSE PROXY ======================"
    echo -e "${jaune}----- Nginx Version -----"
    NGINX_VERSION=$(nginx -v 2>&1 | awk -F '/' '{print $2}' || echo -e "${blanc}Nginx absent")
    echo -e "${blanc}Nginx Version: $NGINX_VERSION"

    echo -e "${jaune}----- PHP Version -----"
    PHP_VERSION=$(php -v 2>/dev/null | head -n 1 || echo -e "${blanc}PHP absent")
    echo -e "${blanc}PHP Version: $PHP_VERSION"

    echo -e "\n${vert}=== CONFIG SECURITE ======================"
    echo -e "${jaune}----- Certbot Version -----"
    CERTBOT_VERSION=$(certbot --version 2>/dev/null || echo -e "${blanc}Certbot absent")
    echo -e "${blanc}Certbot Version: $CERTBOT_VERSION"

    echo -e "${jaune}----- Openssl Version -----"
    OPENSSL_VERSION=$(openssl version 2>/dev/null || echo -e "${blanc}Openssl absent")
    echo -e "${blanc}Openssl Version: $OPENSSL_VERSION"
#    openssl version
    echo -e "${jaune}----- IPsec Version -----"
    IPSEC_VERSION=$(ipsec version 2>/dev/null || echo -e "${blanc}IPsec absent")
    echo -e "${blanc}IPsec Version: $IPSEC_VERSION"
    echo -e "\n${jaune}----- Chiffrement ? -----"
    echo -e "${jaune} ipsec stop/ start?"
    echo -e "${blanc}Utiliser le choix suivant (13)"
}

veriffrwl()
{
    #Choix 12
    echo -e "\n${vert}========== 12 Ports Firewall${blanc}."
    sudo ss -ltnp
    echo -e "\n${vert}========== Firewall "
    FIREWALL=$(sudo ufw status 2>/dev/null || echo -e "${blanc}FIREWALL absent")
    echo -e "${blanc}Firewall: $FIREWALL"
#    sudo ufw status
    sudo ufw app list
    echo -e "\n${vert}========== 12.2 Filtrer avec Wireshark${blanc}."
    echo -e "${jaune} ip.addr == 192.168.80.102 && ip.addr==192.168.80.139 ou tcp.port == 443"
    echo -e "\n${vert}========== 12.3 Vérfier avec TCPdump${blanc}."
    echo -e "${jaune} sudo tcpdump -i eth0 host [IP_REVERSE_PROXY] and host [IP_BACKEND] and port 443 -w ssl_traffic.pcap"
    echo -e "\n${vert}========== 12.4 Ouvrir pour Nginx${blanc}."
    echo -e "\n${jaune}----- sudo ufw allow 'Nginx Full'${blanc}"
    echo -e "\n${jaune}----- sudo ufw delete allow 'Nginx HTTP'${blanc}"
}

confreseau()
{
    #Choix 13
    while true;
    do
    echo -e "\n${vert}========== Config IP fixe de base"
    echo -e "${jaune} sudo nano -l /etc/netplan/01-netcfg.yaml${vert} MODELE"
    sed -n '/res/p' repere.lst
    echo -e "${jaune} sudo hostnamectl set-hostname <new hostname>"
    echo -e "${vert}========== Config sur cette machine${blanc} [$(hostname)]"
    sudo netplan get
    echo -e "${vert}11 pour (re)faire le fichier 01-netcfg (prod.139) + hostname"
    echo -e "${vert}12 pour (re)faire le fichier 01-netcfg (rvpx.102) + hostname"
    echo -e "${vert}13 pour sudo nano /etc/hosts"
    echo -e "${vert}14 pour sudo netplan try"
    echo -e "${vert}15 pour sudo netplan apply - CHANGEMENT D'IP -"
    echo -e "${vert}0 menu principal ${blanc}"
    read reponse
case $reponse in

    11)
        cible2="/etc/netplan/01-netcfg.yaml"
        sudo rm -f $cible2
        sudo touch $cible2
        echo "network:" | sudo tee -a "$cible2"
        echo "  version: 2" | sudo tee -a "$cible2"
        echo "  renderer: networkd" | sudo tee -a "$cible2"
        echo "  ethernets:" | sudo tee -a "$cible2"
        echo "      ens33:" | sudo tee -a "$cible2" 
        echo "          dhcp4: false" | sudo tee -a "$cible2"
        echo "          addresses:" | sudo tee -a "$cible2"
        echo "              - 192.168.80.139/24" | sudo tee -a "$cible2"
        echo "          routes:" | sudo tee -a "$cible2"
        echo "              - to: default" | sudo tee -a "$cible2"
        echo "                via: 192.168.80.2" | sudo tee -a "$cible2"
        echo "          nameservers:" | sudo tee -a "$cible2"
        echo "              addresses:" | sudo tee -a "$cible2"
        echo "                  - 192.168.80.2" | sudo tee -a "$cible2"
        sudo hostnamectl set-hostname srv20prod
        echo -e "${vert} Vérifier et appliquer ATTENTION CHANGEMENT IP !!!"
        echo -e "${jaune} sudo nano /etc/hosts"
        echo -e "${jaune} sudo netplan apply"
        ;;
    12)
        cible2="/etc/netplan/01-netcfg.yaml"
        sudo rm -f $cible2
        sudo touch $cible2
        echo "network:" | sudo tee -a "$cible2"
        echo "  version: 2" | sudo tee -a "$cible2"
        echo "  renderer: networkd" | sudo tee -a "$cible2"
        echo "  ethernets:" | sudo tee -a "$cible2"
        echo "      ens33:" | sudo tee -a "$cible2" 
        echo "          dhcp4: false" | sudo tee -a "$cible2"
        echo "          addresses: [192.168.80.102/24]" | sudo tee -a "$cible2"
        echo "          routes:" | sudo tee -a "$cible2"
        echo "              - to: default" | sudo tee -a "$cible2"
        echo "                via: 192.168.80.2" | sudo tee -a "$cible2"
        echo "          nameservers:" | sudo tee -a "$cible2"
        echo "              addresses: [192.168.80.2]" | sudo tee -a "$cible2"
        sudo hostnamectl set-hostname srv20rvpx
        echo -e "${vert} Vérifier et appliquer ATTENTION CHANGEMENT IP !!!"
        echo -e "${jaune} sudo nano /etc/hosts"
        echo -e "${jaune} sudo netplan apply"
        ;;
    13)
        sudo nano /etc/hosts
        ;;
    14)
        sudo netplan try
        ;;
    15)
        sudo netplan apply
        ;;
    0)
    break
    ;;
esac
echo -e "${vert}\n=== Adresse IP v4 ===${blanc}"
ip -4 a
done    
}

installapache()
{
    #Choix 32
    echo -e "\n${vert}========== 32.0 Installation PROD (Apache2 only) [...139]${blanc} [$(hostname)]"
    echo -e "${blanc}>IP .(1)39  +Apache (+Tomcat)"
    echo -e "\n${jaune}----- Update${blanc}"
    sudo apt update
    echo -e "\n${jaune}----- Install openjdk-8-jre${blanc}"
    sudo apt-get install openjdk-8-jre
    echo -e "\n${jaune}----- Install postgresql-12${blanc}"
    sudo apt install postgresql-12
    echo -e "\n${jaune}----- Install apache2${blanc}"
    sudo apt install apache2
    echo -e "\n${jaune}----- Etat ufw${blanc}"
    sudo ufw status
    echo -e "\n${jaune}----- options${blanc}"
    echo -e "\n${jaune}..... sudo ufw allow 'Apache'"
    echo -e "\n${jaune}..... sudo ufw allow 'Apache Full'"
    echo -e "\n${jaune}..... sudo systemctl enable apache2"
    echo -e "\n${jaune}..... hostname -I"
    echo -e "${vert}========== Vérfier depuis navigateur [...139]"
}

installtomcat()
{
  # choix33
    echo -e "\n${vert}========== 33.0 Install PROD (Tomcat) [...139]${blanc} [$(hostname)]"
    echo -e "${blanc}>Installation Apache-Tomcat"
    echo -e "${jaune} cd /tmp"
    echo -e "${jaune} wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz"
    echo -e "${jaune} sudo mkdir /opt/tomcat8"
    echo -e "${jaune} sudo tar xvfz apache-tomcat-8.5.50.tar.gz -C /opt/tomcat8/ --strip-components=1"
    echo -e "${jaune} sudo groupadd tomcat8"
    echo -e "${jaune} sudo useradd -s /bin/false -g tomcat8 -d /opt/tomcat8 tomcat8"
    echo -e "${vert}---------A compléter..."
    echo -e "${blanc}--------- Fichier de service corrigé (2025/03)"
    echo -e "${vert}========== Vérfier depuis navigateur [...139]"
}

installrvpx()
{
  #Choix 31
    while true;
    do

    echo -e "\n${vert}========== Config sur cette machine (+update)${blanc} [$(hostname)]"
    echo -e "${vert}11 pour voir procédure"
    echo -e "${vert}12 pour appliquer procédure nginx-full + php-fpm"
    echo -e "${vert}13 pour ajouter procédure nginx-rvpx"
    echo -e "${vert}14 pour voir après procédures"
    echo -e "${vert}15 pour voir fichier default (si présent)"
    echo -e "${vert}16 pour tester/relancer"
    echo -e "${vert}17 pour curl backend"
    echo -e "${vert}0 menu principal ${blanc}"
    read reponse
    case $reponse in
    11)
        echo -e "${vert}========== Paramètres"
        #    curl http://192.168.80.139
        echo -e "${vert}========== 31.0 Install Reverse proxy [...102]"
        echo -e "\n${jaune}----- update${blanc}"
        echo -e "        sudo apt update"
        echo -e "\n${jaune}----- nginx-full${blanc}"
        echo -e "        sudo apt install nginx-full"
        echo -e "\n${jaune}----- php-fm${blanc}"
        echo -e "        sudo apt install php-fpm"
        echo -e "${jaune} sudo nano -l /etc/nginx/sites-available/default"
        echo -e "\n${jaune}----- nginx test${blanc}"
        echo -e "${jaune} sudo nginx -t"
        echo -e "\n${jaune}----- nginx restart${blanc}"
        echo -e "${jaune} sudo systemctl restart nginx"
        echo -e "\n${jaune}----- ls nginx sites-enabled${blanc}"
        echo -e "${jaune} ls -al /etc/nginx/sites-enabled/"
        echo -e "${vert}----- Tester depuis navigateur !!!!"
        echo -e "${jaune}.... sudo ufw allow 'Nginx HTTP'"
        echo -e "${vert}==========  MODELE /sites-available/default -----${blanc}"
        sed -n '/dfrvpx/p' repere.lst
        ;;
    12)
        echo -e "\n${jaune}----- update${blanc}"
        sudo apt update
        echo -e "\n${jaune}----- nginx-full${blanc}"
        sudo apt install nginx-full
        echo -e "\n${jaune}----- php-fm${blanc}"
        sudo apt install php-fpm
        echo -e "\n${jaune}----- TESTER SERVEUR(S) !!!!!!!!!! ${blanc}"
        echo -e "\n\n${blanc}"
        ;;    
    13)
        echo -e "${vert}========== 31.0 Install Reverse proxy [...102]"
        # Variables
        SERVER_NAME="rp.test.fv"     # Nom de domaine du reverse proxy
        BACKEND_IP="192.168.80.139"          # IP de la machine backend
        BACKEND_PORT="80"                 # Port du backend
        NGINX_CONF="/etc/nginx/sites-available/$SERVER_NAME"

        # Création du fichier de configuration Nginx
        cat <<EOF | sudo tee $NGINX_CONF > /dev/null
        server {
            listen 80;
            server_name $SERVER_NAME;
        
            location / {
                proxy_pass http://$BACKEND_IP:$BACKEND_PORT;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }
        }
EOF
        echo -e "\n${jaune}suppression lien site: default"        
        sudo rm /etc/nginx/sites-enabled/default

        echo -e "\n${jaune}Création du lien vers /sites-enabled/"
        sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/
        
        echo -e "\n${jaune}Test et rechargement de la configuration Nginx"
        sudo nginx -t && sudo systemctl reload nginx
        
        echo "Reverse proxy Nginx configuré vers $BACKEND_IP:$BACKEND_PORT"
        ;;
    14)
        cat /etc/nginx/sites-available/rp.test.fv
        ls /etc/nginx/sites-enabled/
        ;;
    15)
        cat /etc/nginx/sites-available/default
        ls /etc/nginx/sites-enabled/
        ;;
    16)
        sudo nginx -t
        sudo systemctl reload nginx
        sudo nginx -T | grep server_name
        ;;
    17)
        curl http://pr.test.fv
        ;;
    0)
    break
    ;;
    esac
done
}

installssrvpx ()
{
#Choix 34
    while true;
    do
    echo -e "\n${vert}========== Config sur cette machine (+update)${blanc} [$(hostname)]"
    echo -e "${vert}11 pour voir procédure ss-ssl+rvpx"
    echo -e "${vert}12 pour appliquer procédure ss-ssl+rvpx"
    echo -e "${vert}13 si besoin Diffie-Hellman"
    echo -e "${vert}14 si besoin Certbot"   
    echo -e "${vert}15 pour voir après procédures"
    echo -e "${vert}16 pour voir fichier default (si présent)"
    echo -e "${vert}17 pour tester/relancer"
    echo -e "${vert}18 pour curl backend"
    echo -e "${vert}19 Modifier proxy_pass avec ssl-prod !"
    echo -e "${vert}0 menu principal ${blanc}"
    read reponse
    case $reponse in

    11)
    echo -e "\n${vert}========== 34.0 Procédure SS-SSL RVPX (self-signed SSL)${blanc} [$(hostname)]"
#    echo -e "${blanc}>Verif prod en http, puis +SS-SSL +..."
    echo -e "${jaune}----- Si besoin certbot (authentifié)${blanc}"
    echo -e "${jaune}.... sudo apt install certbot python3-certbot-nginx -y"
    echo -e "\n${jaune}----- Test avec: curl http://...139"
    echo -e "\n${vert}----- Créations dossier, clé, certif, pré-rempli ici avec IP du RVPX${blanc}"
    echo -e "${jaune}-----     sudo mkdir -p /etc/ssl/rvpx"
    echo -e "${jaune}-----     sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/rvpx/nginx-selfsigned.key -out /etc/ssl/rvpx/nginx-selfsigned.crt -subj '/C=FR/ST=IDF/L=IVRY/O=auto/CN=192.168.80.102'"
    echo -e "${vert}--------- Si option Diffie-Hellman"
    echo -e "${jaune}.... sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048"
    echo -e "${jaune} sudo nano -l /etc/nginx/sites-available/default"
    echo -e "${vert}--------- SS-SSL NGINX ( sans reverse proxy )${jaune}"
    sed -n '/#rvpx/p' repere.lst
    echo -e "${vert}--------- SS-SSL NGINX (avec RVPX vers serveur PROD)${jaune}"
    sed -n '/#ssrvpx/p' repere.lst
    echo -e "${vert}--------- Vérifier/modifier dans 'default' APRES activation sur serveur PROD${jaune}"
    echo -e "${jaune} sudo nano /etc/nginx/sites-available/default "
    echo -e "${vert} location / {"
    echo -e "${vert}     proxy_pass https://192.168.80.139:443;"
    echo -e "${vert}     proxy_ssl_verify off;  # car cert self-signed"
    echo -e "${vert}     proxy_set_header Host $host;"
    echo -e "${vert}     proxy_set_header X-Real-IP $remote_addr;"
    echo -e "${vert} }"
    echo -e "${jaune} sudo nginx -t && sudo systemctl reload nginx"
    echo -e "${vert}--------- Tester... (verif rvpx)"
    echo -e "${jaune}..... curl -k https://rp.test.fv"
    echo -e "${jaune}..... sudo ufw allow 'Nginx Full'"
    echo -e "${jaune}..... sudo ufw delete allow 'Nginx HTTP'"
    ;;

    12)
        # Variables
        SERVER_NAME="rp.test.fv"         # Le nom de domaine (ou IP)
        BACKEND_IP="192.168.80.139"      # IP du serveur backend
        BACKEND_PORT="443"               # Port backend
        NGINX_CONF="/etc/nginx/sites-available/$SERVER_NAME"
        CERT_DIR="/etc/ssl/nginx/$SERVER_NAME"
        echo -e "${vert}========== 34.0 Install SS-SSL RVPX (self-signed SSL)${blanc} [$(hostname)]"
        echo -e "\n${jaune}----- Créations dossier, clé, certif, pré-rempli ici avec IP du RVPX${blanc}"
        sudo mkdir -p $CERT_DIR
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
             -keyout $CERT_DIR/selfsigned.key \
             -out $CERT_DIR/selfsigned.crt \
             -subj "/C=FR/ST=IDF/L=IVRY/O=auto/CN=$SERVER_NAME"

        cat <<EOF | sudo tee $NGINX_CONF > /dev/null
        server {
            listen 443 ssl;
            server_name $SERVER_NAME;
        
            ssl_certificate     $CERT_DIR/selfsigned.crt;
            ssl_certificate_key $CERT_DIR/selfsigned.key;
        
            location / {
                proxy_pass http://$BACKEND_IP:$BACKEND_PORT;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            }
        }
        
        # Redirige HTTP vers HTTPS
        server {
            listen 80;
            server_name $SERVER_NAME;
            return 301 https://\$host\$request_uri;
        }
EOF
        
        echo -e "\n${jaune}Création du lien vers /sites-enabled/"
        sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/
            
        echo -e "\n${jaune}Test et rechargement de la configuration Nginx"
        sudo nginx -t && sudo systemctl reload nginx
        
#        echo -e "\n${jaune}Suppression site par défaut (si présent)"
#        if [ -e /etc/nginx/sites-enabled/default ];
#         then
#          echo "Suppression du site 'default'..."
#          sudo rm /etc/nginx/sites-enabled/default
#        fi
    
        echo -e "${vert}Nginx est configuré avec SSL auto-signé vers $BACKEND_IP:$BACKEND_PORT"
        echo -e "${jaune}Tester : https://$SERVER_NAME (accepte le certificat auto-signé)"
    
        echo -e "${vert}--------- Tests et firewall?"
        echo -e "${jaune}..... curl -k https://rp.test.fv"
        echo -e "${jaune}..... sudo ufw allow 'Nginx Full'"
        echo -e "${jaune}..... sudo ufw delete allow 'Nginx HTTP'"
        ;;
    13) 
        echo -e "${vert}13 si besoin Diffie-Hellman"
        ;;
    14)
        echo -e "${vert}14 si besoin Certbot"   
        ;;
    15)
        echo -e "${vert}15 pour voir après procédures"
        ;;
    16)
        echo -e "${vert}16 pour voir fichier default (si présent)"
        ;;
    17)
        echo -e "${vert}17 pour tester/relancer"
        ;;
    18)
        curl https://pr.test.fv
        ;;
    19)
        echo -e "${vert}Modifier dans NGINX: proxy_pass"
        echo -e "${jaune}proxy_pass https://$BACKEND_IP:$BACKEND_PORT;"
        echo -e "${jaune}proxy_ssl_verify off;"
        ;;
    0)
    break
    ;;
    esac
done
}

installssprod ()
{
    #Choix 35
    while true;
    do
    echo -e "\n${vert}========== Config sur cette machine (+update)${blanc} [$(hostname)]"
    echo -e "${vert}11 pour voir procédure ss-ssl+apache"
    echo -e "${vert}12 pour appliquer procédure ss-ssl+apache"
    echo -e "${vert}13 si besoin Diffie-Hellman"
    echo -e "${vert}14 si besoin Certbot"   
    echo -e "${vert}15 pour voir après procédures"
    echo -e "${vert}16 pour voir fichier default (si présent)"
    echo -e "${vert}17 pour tester/relancer"
    echo -e "${vert}18 pour curl backend"    
    echo -e "${vert}0 menu principal ${blanc}"
    read reponse

    case $reponse in
        11)
        echo -e "${vert}========== 35.0 Procédure SS-SSL PROD (self-signed SSL)${blanc} [$(hostname)]"
        echo -e "${jaune}curl http://192.168.80.139"
        echo -e "\n${jaune}----- Si besoin headers${blanc}"
        echo -e "${jaune}.... sudo a2enmod headers"
        echo -e "${jaune}.... sudo systemctl restart apache2"
        echo -e "\n${jaune}----- Activation a2enmod ssl, ufw${blanc}"
        echo -e "\n${jaune}sudo a2enmod ssl"
        echo -e "\n${jaune}sudo ufw allow 'Apache Full'"
        echo -e "\n${jaune}----- Crétions répertoire, clé, certif${blanc}"
        echo -e "\n${jaune}sudo mkdir -p /etc/ssl/prod"
        echo -e "${jaune} sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
        echo -e "${jaune}  -keyout prod.key \\"
        echo -e "${jaune}  -out prod.crt"
        echo -e "${vert}--------- + Ip du serveur PROD !!! (pré-rempli ici)${blanc}"
        echo -e "\n${jaune}sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/prod/prod.key -out /etc/ssl/prod/prod.crt -subj '/C=FR/ST=IDF/L=IVRY/O=auto/CN=192.168.80.139'"
        echo -e "${vert}--------- Si Option Diffie-Hellman sur serveur prod???"
        echo -e "${jaune} sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048"
        echo -e "${vert}--------- Création VirtualHost (attention aux $ manquants?)"
        echo -e "${jaune} sudo nano /etc/apache2/sites-available/prod_ssl.conf${blanc24}"
        echo -e "\n${jaune}sed -n '/#vhsspr/p' repere.lst"
        echo -e "\n${jaune}cat /etc/apache2/sites-available/prod_ssl.conf"
        echo -e "\n${jaune}----- Activation config${blanc}"
        echo -e "${jaune} apachectl -t"
        echo -e "${jaune} sudo a2ensite prod_ssl.conf"
        echo -e "${jaune} sudo systemctl reload apache2"
        echo -e "${jaune} sudo systemctl restart apache2"
        echo -e "${jaune} curl -k https://192.168.80.139:443"
        echo -e "${jaune} sudo mkdir /var/www/your_domain_or_ip pour index.html???"
        echo -e "${vert}--------- Ajout HTS, autres ?"
        ;;
    12)

# Variables temoin
#SERVER_NAME="rp.test.fv"         # Le nom de domaine (ou IP)
#BACKEND_IP="192.168.80.139"      # IP du serveur backend
#BACKEND_PORT="443"               # Port backend
##NGINX_CONF="/etc/nginx/sites-available/$SERVER_NAME"
#CERT_DIR="/etc/ssl/nginx/$SERVER_NAME"
# -------------------------
        DOMAIN="pr.test.fv"                   # Pour CN du certificat
        APACHE_CONF="/etc/apache2/sites-available/ssprod.conf"
        APACHE_PORT="443"
        CERT_DIR="/etc/ssl/apache2"

        echo -e "${vert}========== 35.0 Install SS-SSL PROD (self-signed SSL)${blanc} [$(hostname)]"

        echo -e "\n${jaune}----- Activation module ssl pour Apache${blanc}"
        sudo a2enmod ssl
#        sudo ufw allow "Apache Full"
        echo -e "\n${jaune}----- Crétions répertoire, clé, certif${blanc}"
        sudo mkdir -p $CERT_DIR
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout $CERT_DIR/ssprod.key \
            -out $CERT_DIR/ssprod.crt \
            -subj "/C=FR/ST=IDF/L=IVRY/O=auto/CN=$DOMAIN"

        echo -e "${vert}--------- Configuration Apache2 (VirtualHost)"
        cat <<EOF | sudo tee $APACHE_CONF > /dev/null
        <VirtualHost *:$APACHE_PORT>
            ServerName $DOMAIN
        
            SSLEngine on
            SSLCertificateFile    $CERT_DIR/ssprod.crt
            SSLCertificateKeyFile $CERT_DIR/ssprod.key
        
            DocumentRoot /var/www/html
        
            <Directory /var/www/html>
                AllowOverride All
                Require all granted
            </Directory>
        
            ErrorLog \${APACHE_LOG_DIR}/ssl_error.log
            CustomLog \${APACHE_LOG_DIR}/ssl_access.log combined
        </VirtualHost>
EOF

        echo -e "\n${jaune}Activation du site SSL Apache (port443)"
        sudo a2ensite ssprod.conf
        sudo systemctl restart apache2
            
        echo -e "\n${jaune}Ecoute sur HTTPS (port 443)"
        sudo lsof -i :443 | grep apache2 || echo "Vérifie qu'Apache écoute sur 443"
        ;;
    13) 
        echo -e "${vert}13 si besoin Diffie-Hellman"
        ;;
    14)
        echo -e "${vert}14 si besoin Certbot"   
        ;;
    15)
        echo -e "${vert}15 pour voir après procédures"
        ;;
    16)
        echo -e "${vert}16 pour voir fichier default (si présent)"
        ;;
    17)
        echo -e "${vert}17 pour tester/relancer"
        ;;
    18)
        curl https://pr.test.fv
        ;;
    0)
        break
        ;;
    esac
done
}

installipsecprod()
{
    #Choix 38
    echo -e "${vert}========== 38.0 Install IPsec serveur production${blanc} [$(hostname)]"
    echo -e "\n${jaune}----- update${blanc}"
    sudo apt update
    echo -e "\n${jaune}----- strongswan${blanc}"
    sudo apt install strongswan
    echo -e "\n${jaune}----- ipsec status${blanc}"
    sudo systemctl status ipsec
# sudo apt install strongswan strongswan-plugin-eap-mschapv2
# sudo apt install strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins
# systemctl status strongswan-starter.service ; systemctl is-enabled strongswan-starter.service ???
    echo -e "${vert}Editer ipsec.conf"
    sudo nano /etc/ipsec.conf
    sed -n '/^isprod/,/^$/p' repere.lst
    echo -e "${vert}Editer ipsec.secrets, ajouter"
    echo -e "${jaune}: PSK \"987654321\""
    sudo nano /etc/ipsec.secrets
    echo -e "\n${jaune}----- ipsec restart, puis statusall${blanc}"
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} sudo ipsec statusall"
    echo -e "\n${blanc}----- Tester${blanc}"
    echo -e "${jaune} ping 192.168.80.139"
    echo -e "${jaune} curl http://192.168.80.139"
    echo -e "${jaune} sudo tcpdump -i ens33 esp"


# Pour IP forwarding par passerelle: sudo sysctl -w net.ipv4.ip_forward=1
# $ sudo mv /etc/ipsec.conf /etc/ipsec.conf.bkp
# Générer clé 'openssl rand -base64 32'
}

installipsecrvpx()
{
    #Choix 37
    echo -e "${vert}========== 37.0 Install IPsec reverse proxy${blanc} [$(hostname)]"
    echo -e "\n${jaune}----- update${blanc}"
    sudo apt update
    echo -e "\n${jaune}----- strongswan${blanc}"
    sudo apt install strongswan
    echo -e "\n${jaune}----- ipsec status${blanc}"
    sudo systemctl status ipsec
# sudo apt install strongswan strongswan-plugin-eap-mschapv2
# sudo apt install strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins
    echo -e "${vert}Editer ipsec.conf"
    sudo nano /etc/ipsec.conf
    sed -n '/^isrvpx/,/^$/p' repere.lst
    echo -e "${vert}Editer ipsec.secrets, ajouter"
    echo -e "${jaune}: PSK \"987654321\""
    sudo nano /etc/ipsec.secrets
    echo -e "\n${jaune}----- ipsec restart, puis statusall${blanc}"
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} sudo ipsec statusall"
    echo -e "${vert}Dans config Nginx, vérifier le pointage du proxy_pass:"
    echo -e "${jaune} sudo nano /etc/nginx/sites-available/default"
    echo -e "${vert}location / {"
    echo -e "${vert}    proxy_pass http://192.168.80.139;  # IP privée du backend Apache"
    echo -e "${vert}}"
    echo -e "${vert}Cette IP doit être celle du backend dans le sous-réseau sécurisé IPsec"
#    echo -e "${blanc}Assurez-vous que le backend écoute bien sur cette interface."
    echo -e "${vert}Tester la connectivité"
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} ping 192.168.80.139"
    echo -e "${jaune} curl http://192.168.80.139"
    echo -e "${jaune} sudo ipsec statusall"
    echo -e "${vert}Attention au Firewall"
    echo -e "${vert}Ouvrez les ports UDP **500** et **4500** pour IPsec sur les deux serveurs."
    echo -e "${vert}Autorisez le protocole **ESP** (protocol number 50)."
    echo -e "${jaune} sudo ufw allow 500,4500/udp"
    echo -e "${jaune} sudo ufw reload"
}

verifssl()
{
    #Choix 21
    # Adresse IP ou nom d'hôte du destinataire
    DEST1HOST="192.168.80.139"
    DEST1PORT=443
    echo -e "${jaune}========== 21 Vérification SSL vers ${blanc}$DEST1HOST:$DEST1PORT"
    echo -e "${blanc}"
    
    # Connexion SSL avec openssl
    OUTPUT1=$(echo | openssl s_client -connect "$DEST1HOST:$DEST1PORT" -servername "$DEST1HOST" 2>/dev/null)
    
    # Vérifie si le certificat a été récupéré
    if echo "$OUTPUT1" | grep -q "BEGIN CERTIFICATE"; then
        SUBJECT=$(echo "$OUTPUT1" | grep "subject=" | sed 's/^.*CN=//')
        ISSUER=$(echo "$OUTPUT1" | grep "issuer=" | sed 's/^.*CN=//')
        VALID=$(echo "$OUTPUT1" | grep "Verify return code: 0 (ok)")
    
        echo "Connexion SSL établie avec succès."
        echo "   Certificat CN : $SUBJECT"
        echo "   Émis par      : $ISSUER"
        echo "   Vérification  : ${VALID:-Échec de la validation}"
    else
        echo "Échec de la connexion SSL au destinataire."
    fi
#    curl -I https://pr.test.fv

    # TEST VERS NGINX
    # Adresse IP ou nom d'hôte du destinataire
    DEST2HOST="192.168.80.102"
    DEST2PORT=443
    
    echo -e "\n${jaune}========== Vérification SSL vers ${blanc}$DEST2HOST:$DEST2PORT"
    echo -e "${blanc}"
    
    # Connexion SSL avec openssl
    OUTPUT2=$(echo | openssl s_client -connect "$DEST2HOST:$DEST2PORT" -servername "$DEST2HOST" 2>/dev/null)
    
    # Vérifie si le certificat a été récupéré
    if echo "$OUTPUT2" | grep -q "BEGIN CERTIFICATE"; then
        SUBJECT=$(echo "$OUTPUT2" | grep "subject=" | sed 's/^.*CN=//')
        ISSUER=$(echo "$OUTPUT2" | grep "issuer=" | sed 's/^.*CN=//')
        VALID=$(echo "$OUTPUT2" | grep "Verify return code: 0 (ok)")
    
        echo "Connexion SSL établie avec succès."
        echo "   Certificat CN : $SUBJECT"
        echo "   Émis par      : $ISSUER"
        echo "   Vérification  : ${VALID:-Échec de la validation}"
    else
        echo "Échec de la connexion SSL au destinataire."
    fi
#    curl -I https://rp.test.fv
}

verifipsec()
{
    #Choix 22
    echo -e "${vert}========== 22 Vérification IPsec${jaune} ----- PURGER CACHE DES NAVIGATEURS !!!!!${blanc} [$(hostname)]"
    echo -e "${jaune}1.sudo ipsec statusall${blanc}."
    sudo ipsec statusall

    echo -e "${vert}========== Echelle 'charondebug':"
    echo -e "${blanc} -0 : Aucun log -1 : Erreurs seulement -2 : Infos (niveau 'normal', recommandé) -3 : Débogage détaillé -4 : Verbosité extrême (bruit fort )"

    echo -e "\n2.État du tunnel IPsec :"
    sudo ipsec status | grep -E 'ESTABLISHED|INSTALLED' || echo " Aucun tunnel établi"
    
    echo -e "\n3.Compteurs de paquets IPsec (XFRM) : Etat de sécurité"
    sudo ip -s xfrm state | awk '/src | packets| bytes/'
    
    echo -e "\n4.Paquets ESP captés (protocole IPsec) :"
    sudo timeout 5 tcpdump -ni any esp 2>/dev/null | head -n 10 || echo " Aucun paquet ESP détecté"
    
    echo -e "\n5.Test de connectivité vers autre serveur (HTTP via tunnel) :"
    read -p "Entrez l'IP à cibler: " cible_ip
    curl -s -o /dev/null -w "Code HTTP: %{http_code}\n" http://$cible_ip
    echo -e "\n${vert}(200 = ok)${blanc}."
    
    echo -e "\n6.Derniers logs StrongSwan :"
    sudo journalctl -u strongswan --no-pager -n 10
    
    echo -e "\n Vérification terminée."
}
verifipsec2()
{
    #Choix 23
    #!/bin/bash
    
    blanc="\033[0m"
    jaune="\033[1;33m"
    
    # Variables
    REMOTE_IP=192.168.80.139
    PRE_SHARED_KEY=987654321
    
    echo -e "\n${jaune}0-IP de cette machine${blanc}"
    hostname -I
    
    # Vérification de la connectivité réseau
    echo -e "\n${jaune}1-Vérification de la connectivité réseau avec $REMOTE_IP...${blanc}"
    ping -c 4 $REMOTE_IP
    if [ $? -ne 0 ]; then
        echo "Échec de la connectivité réseau avec $REMOTE_IP."
        exit 1
    fi
    
    # Vérification des configurations de pare-feu
    echo -e "\n2${jaune}-Vérification des configurations de pare-feu...${blanc}"
    sudo iptables -L -v -n | grep $REMOTE_IP
    if [ $? -ne 0 ]; then
        echo "Aucune règle de pare-feu trouvée pour $REMOTE_IP. Assurez-vous que les ports UDP 500 et 4500 sont ouverts."
    #    exit 1
    fi
    
    # Vérification des clés pré-partagées
    echo -e "\n${jaune}3-Vérification des clés pré-partagées...${blanc}"
    if [ "$PRE_SHARED_KEY" == "<CLÉ_PRÉ-PARTAGÉE>" ]; then
        echo "Veuillez définir la clé pré-partagée dans le script."
        exit 1
    fi
    
    # Vérification des associations de sécurité (SA)
    echo -e "\n${jaune}4-Vérification des associations de sécurité (SA)...${blanc}"
    sudo ipsec statusall | grep "$REMOTE_IP"
    if [ $? -ne 0 ]; then
        echo "Aucune association de sécurité (SA) trouvée pour $REMOTE_IP."
        exit 1
    fi
    
    # Vérification des journaux IPsec
    echo -e "\n${jaune}5-Vérification des journaux IPsec...${blanc}"
    sudo tail -n 50 /var/log/syslog | grep ipsec
    
    echo -e "\n${jaune}Tous les tests ont été complétés avec succès.${blanc}"
}

# DEBUT SCRIPT
echo -e "\n${bleu}========== ACTIONS ========== ========== $version =========="
#echo -e "\n${blanc}chmod +x; script localisé dans $(pwd)"
while true;
    do
    echo -e "${blanc}========== Services dans cette machine: $(hostname) | IP : $(hostname -I | awk '{print $1}')"
    OS_NAME=$(lsb_release -d | cut -f2-)
    OS_VERSION=$(lsb_release -r | cut -f2-)
    ARCHITECTURE=$(uname -m)
    echo "========== OS: $OS_NAME - Architecture: $ARCHITECTURE - Version: $OS_VERSION"
    echo -e "\n${vert} 11 -> VERSIONS actives    12 -> Firewall (etat)       13 -> Conf RESEAU"
    echo -e "${bleu} 14 -> Voir RVPX (default) 15 -> Voir PROD (status)    16 -> Logs"
    echo -e "${vert} 17 -> Voir SSL (clés)     18 -> Voir IpSec (config)   19 -> TEST + SOS"
    echo -e "${bleu} 21 -> Test SSL (conn.)    22 -> Test IPsec-1          23 -> Test IPsec-2"
    echo -e "\n${rouge} 31 -> Conf. RVPX          32 -> Conf. PROD/Apache2    33 -> Conf. PROD A/T/PG"
    echo -e "${jaune} 34 -> Conf. SS-SSL RVPX   35 -> Conf. SS-SSL PROD     36 -> Conf. Diffie-Hellman"
    echo -e "${rouge} 37 -> Conf. IpSec RVPX    38 -> Conf. IpSec PROD      39 -> test FTP"
    echo -e "${blanc}"
    echo -e "${gris} 41 -> Restart SSL         42 -> Rest+stat IPsec       43 -> Reload Nginx"
    echo -e "${blanc} 51 -> Eteindre serveur    52 -> Reboot                53 -> Lynx"
    echo -e "${gris} 54 -> Editer ce script    55 -> MAJ Scripts???        56 -> repere.lst"
    echo -e "\n${blanc} 0 -> Quitter"
    
    read reponse
    
    case $reponse in
    
    11)
        testversions
        ;;    
    12)
        veriffrwl
        ;;
    13)
        confreseau
        ;;    
    14)
        echo -e "\n${jaune}----- cat /etc/nginx/sites-available/default${blanc}"
        cat /etc/nginx/sites-available/default
        sudo systemctl status nginx
        ;;
    15)
        sudo systemctl status apache2
        # Chemin du fichier index.html
        INDEX_FILE="/var/www/html/index.html"
        # date et heure actuelles
        NOW=$(date '+%Y-%m-%d %H:%M:%S')
        # Texte à ajouter
        TEST_TEXT="<p>Test OK à $NOW</p>"
        # Vérifie si le fichier existe
        if [ -f "$INDEX_FILE" ]; then
            echo "$TEST_TEXT" >> "$INDEX_FILE"
            echo " Ligne ajoutée : $TEST_TEXT"
        else
            echo " Fichier $INDEX_FILE introuvable. Apache est-il installé ?"
        fi
        cat /etc/apache2/sites-available/prod_ssl.conf
        sudo apache2 -t
        ;;
    16)
        echo -e "${vert}========== Affichage de logs"
        echo -e "\n${vert}----- strongswan${blanc}."
        sudo journalctl -u strongswan
        echo -e "\n${jaune} sudo journalctl -u strongswan -f"
        echo -e "\n${jaune} sudo journalctl -f | grep charon"
        ;;

    17)
        echo -e "${vert}========== 17 Voir configuration self-signed SSL"
        echo -e "\n${jaune}17.1----- cat /etc/nginx/sites-available/default${blanc}."
        cat /etc/nginx/sites-available/default
        echo -e "\n${jaune}17.2----- cat /etc/ssl/private/nginx-selfsigned.key${blanc}."
        sudo cat /etc/ssl/rvpx/nginx-selfsigned.key
        echo -e "\n${jaune}17.3----- cat /etc/ssl/certs/nginx-selfsigned.crt${blanc}."
        cat /etc/ssl/rvpx/nginx-selfsigned.crt
        echo -e "\n${jaune}17.4----- cat /etc/apache2/sites-available/prod_ssl.conf${blanc}."
        cat /etc/apache2/sites-available/prod_ssl.conf    
        echo -e "\n${jaune}17.5----- cat /etc/ssl/prod/prod.key${blanc}"
        sudo cat /etc/ssl/prod/prod.key
        echo -e "\n${jaune}17.6----- cat /etc/ssl/prod/prod.crt${blanc}"
        cat /etc/ssl/prod/prod.crt
          ;;
      18)
        echo -e "${vert}========== 18 Voir configuration IPsec"
        echo -e "\n${jaune}18.1----- cat /etc/ipsec.conf${blanc}."
        cat /etc/ipsec.conf
        echo -e "\n${jaune}18.2----- cat /etc/ipsec.secrets${blanc}."
        sudo cat /etc/ipsec.secrets
        echo -e "\n${jaune}18.3----- cat /etc/ipsec.d/cacerts/ca-cert.pem${blanc}."
        cat /etc/ipsec.d/cacerts/ca-cert.pem
        echo -e "${blanc}====== Regarder les paquets ESP"
        echo -e "${jaune} sudo tcpdump -i ens33 esp"
        ;;
        19)
        echo -e "${vert}========== 19 Test SSL"
        echo -e "\n${jaune}19.1----- vers.139${blanc}."
        openssl s_client -connect 192.168.80.139:443
        echo -e "\n${jaune}19.2----- vers.102${blanc}."
        openssl s_client -connect 192.168.80.102:443
#        sed -n '/sos/p' repere.lst
        ;;
        21)
        verifssl
        ;;
        22)
        verifipsec
        ;;
        23)
        verifipsec2
        ;;
        56)
        cat repere.lst
        ;;
      31)
        installrvpx
        ;;
        32)
        installapache
        ;;
    
        33)
        installtomcat
        ;;
    
      34)
        installssrvpx
        ;;
      35)
        installssprod
        ;;
    
      37)
        installipsecrvpx
        ;;
      38)
        installipsecprod
        ;;
        39)
        sudo apt install vsftpd
        ;;
      41)
        echo -e "${blanc}to do"
        ;;
      42)
        sudo systemctl restart ipsec
        sudo systemctl status ipsec
        ;;
      43)
        sudo nginx -t
        sudo systemctl reload nginx
        ;;
    51)
        sudo poweroff
        ;;
    52)
        sudo reboot
        ;;
    54)
        sudo nano -l vchk.sh   
        ;;
    0)
        break
        ;;
    esac

echo ""
done
echo -e "\n${vert}====== RAPPELS"
echo -e "${blanc}sudo apt update, tester les serveurs?"
echo -e "ATTENTION aux identations et aux vm actives"
echo -e "${blanc}---------- ----------"