#!/bin/bash
#Variables pour la coloration syntaxique
# set -x 
blanc="\033[0m"
noir="\033[30m"
rouge="\033[1;31m"
vert="\033[32m"
orange="\033[33m"
jaune="\033[1;33m"
gris="\033[1;30m"
bleu="\033[1;34m"
pourpre="\033[1;35m"
reset="\033[m"

testversions()
{
    #Choix 11
    echo -e "\n${vert}=== CONFIG PRODUCTION ======================"
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

    echo -e "\n${vert}=== CONFIG REVERSE PROXY ======================"
    echo -e "\n${jaune}=== Nginx Version ==="
    NGINX_VERSION=$(nginx -v 2>&1 | awk -F '/' '{print $2}' || echo -e "${blanc}Nginx absent")
    echo -e "${blanc}Nginx Version: $NGINX_VERSION"

    echo -e "\n${jaune}=== PHP Version ==="
    PHP_VERSION=$(php -v 2>/dev/null | head -n 1 || echo -e "${blanc}PHP absent")
    echo -e "${blanc}PHP Version: $PHP_VERSION"

    echo -e "\n${vert}=== CONFIG SECURITE ======================"
    echo -e "\n${jaune}=== Certbot Version ==="
    CERTBOT_VERSION=$(certbot --version 2>/dev/null || echo -e "${blanc}Certbot absent")
    echo -e "${blanc}Certbot Version: $CERTBOT_VERSION"

    echo -e "\n${jaune}=== Openssl Version ==="
    OPENSSL_VERSION=$(openssl version 2>/dev/null || echo -e "${blanc}Openssl absent")
    echo -e "${blanc}Openssl Version: $OPENSSL_VERSION"
#    openssl version
    echo -e "\n${jaune}=== IPsec Version ==="
    IPSEC_VERSION=$(ipsec version 2>/dev/null || echo -e "${blanc}IPsec absent")
    echo -e "${blanc}IPsec Version: $IPSEC_VERSION"
}

installreseau()
{
    #Choix 12
    echo -e "${vert}========== Config IP fixe de base"
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
}

verifflux()
{
    #Choix 13
    echo -e "${vert}========== Filtrer avec Wireshark${blanc}."
    echo -e "${jaune} ip.addr == 192.168.80.102 && ip.addr==192.168.80.139 ou tcp.port == 443"
    echo -e "${jaune} sudo tcpdump -i eth0 host [IP_REVERSE_PROXY] and host [IP_BACKEND] and port 443 -w ssl_traffic.pcap"
    echo -e "${vert}========== Ports Firewall${blanc}."
    sudo ss -ltnp
    echo -e "${vert}========== Etat IPsec${blanc}."
    sudo ipsec statusall
}

installapache()
{
    #Choix 21
    echo -e "${vert}========== PROD Apache2 [...139]"
    echo -e "${blanc}>IP .(1)39 +JVM +PostgreSQL +Apache (+Tomcat) +Police MS"
    echo -e "${jaune} sudo apt-get install openjdk-8-jre"
    echo -e "${jaune} sudo apt install postgresql-12"
    echo -e "${jaune} sudo apt install apache2"
    echo -e "${jaune} sudo ufw allow 'Apache'"
    echo -e "${jaune} sudo "
}

installtomcat()
{
  # choix22
      echo -e "${vert}========== PROD Tomcat [...139]"
    echo -e "${blanc}>Installation Apache-Tomcat"
    echo -e "${jaune} cd /tmp"
    echo -e "${jaune} wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz"
    echo -e "${jaune} sudo mkdir /opt/tomcat8"
    echo -e "${jaune} sudo tar xvfz apache-tomcat-8.5.50.tar.gz -C /opt/tomcat8/ --strip-components=1"
    echo -e "${jaune} sudo groupadd tomcat8"
    echo -e "${jaune} sudo useradd -s /bin/false -g tomcat8 -d /opt/tomcat8 tomcat8"
    echo -e "${vert}---------A compléter..."
}

installipsecprod()
{
    #Choix 26
    echo -e "${vert}========== IPsec prod"
    echo -e "${blanc}"
    echo -e "${jaune} sudo apt update"
    echo -e "${jaune} sudo apt install strongswan"
    echo -e "${jaune} sudo systemctl status ipsec"
# sudo apt install strongswan strongswan-plugin-eap-mschapv2
# sudo apt install strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins
# systemctl status strongswan-starter.service ; systemctl is-enabled strongswan-starter.service ???
    echo -e "${blanc}Modifications à faire dans:"
    echo -e "${jaune} sudo nano /etc/ipsec.conf"
    echo -e "${blanc}Modifications à faire dans:"
    echo -e "${jaune} sudo nano /etc/ipsec.secrets"
    echo -e "${vert}@nginx @apache : PSK \"987654321\""
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} sudo ipsec statusall"
# Pour IP forwarding par passerelle: sudo sysctl -w net.ipv4.ip_forward=1
# $ sudo mv /etc/ipsec.conf /etc/ipsec.conf.bkp
# Générer clé 'openssl rand -base64 32'

}

installipsecrvpx()
{
    #Choix 27
    echo -e "${vert}========== IPsec rvpx"
    echo -e "${blanc}"
    echo -e "${jaune} sudo apt update"
    echo -e "${jaune} sudo apt install strongswan"
    echo -e "${jaune} sudo systemctl status ipsec"
# sudo apt install strongswan strongswan-plugin-eap-mschapv2
# sudo apt install strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins
    echo -e "${blanc}Modifications à faire dans:"
    echo -e "${jaune} sudo nano /etc/ipsec.conf${vert}."
        cat config.fil
    echo -e "${blanc}Modifications à faire dans:"
    echo -e "${jaune} sudo nano /etc/ipsec.secrets"
    echo -e "${vert} @nginx @apache : PSK \"987654321\""
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} sudo ipsec statusall"
    echo -e "${blanc}Dans votre config Nginx, au lieu de pointer vers une IP publique :"
    echo -e "${vert}location / {"
    echo -e "${vert}    proxy_pass http://192.168.80.139;  # IP privée du backend Apache"
    echo -e "${vert}}"
    echo -e "${blanc}Cette IP doit être celle du backend dans le sous-réseau sécurisé IPsec"
#    echo -e "${blanc}Assurez-vous que le backend écoute bien sur cette interface."
    echo -e "${blanc}Tester la connectivité"
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} ping 192.168.80.139"
    echo -e "${jaune} curl http://192.168.80.139"
    echo -e "${jaune} sudo ipsec statusall"
    echo -e "${blanc}Firewall"
    echo -e "${blanc}Ouvrez les ports UDP **500** et **4500** pour IPsec sur les deux serveurs."
    echo -e "${blanc}Autorisez le protocole **ESP** (protocol number 50)."
    echo -e "${jaune} sudo ufw allow 500,4500/udp"
    echo -e "${jaune} sudo ufw reload"
}

# DEBUT SCRIPT
echo -e "\n${rouge}========== THE CHECKER =========="
echo "========== 25/04/01 =========="
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

echo -e "${bleu}\n========== Services dans cette machine avec Ubuntu 20 =========="
echo -e "${blanc}11 -> VERSIONS présentes       12 -> Install: RESEAU                13 -> Verif FLUX"
echo -e "${gris}21 -> Install PROD: Apache2    22 -> Install: PROD A/T/PG           23 -> Install RVPX"
echo -e "${blanc}24 -> Install SS-SSL PROD      25 -> Install SS-SSL RVPX"
echo -e "${gris}26 -> Install IpSec PROD       27 -> Install IpSec RVPX"
echo -e "${blanc}31 -> Tshark                   32 -> TCPDump                        33 -> Lynx"
echo -e "${gris}41 -> Eteindre serveur         42 -> Editer ce script               43 -> MAJ Scripts?"
echo -e "${blanc} 0 -> Quitter"

read reponse

case $reponse in

  11)
      testversions
    ;;

  12)
      installreseau
    ;;

  13)
      verifflux
    ;;

  21)
      installapache
    ;;

  22)
      installtomcat
    ;;

  23)
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
        cat config.fil
    echo -e "${jaune} sudo nginx -t"
    echo -e "${jaune} sudo systemctl restart nginx"
    echo -e "${vert}--------- Tester..."
    ;;

  24)
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
        cat config.fil
#### Activation ssl
    echo -e "${jaune} sudo a2ensite prod_ssl.conf"
    echo -e "${jaune} sudo systemctl restart apache2"
#### Tester
    echo -e "${jaune} curl -k https://192.168.80.139:443"
    echo -e "${jaune} sudo mkdir /var/www/your_domain_or_ip pour index.html???"
    echo -e "${vert}--------- Résultats"
    ;;

  25)
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
    echo -e "${vert}--------- Afficher 'default' AVANT activation sur serveur PROD, attention aux \$!!"
    cat config.fil
    echo -e "${vert}--------- Vérifier/modifier dans 'default' APRES activation sur serveur PROD"
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

  26)
    installipsecprod
    ;;

  27)
    installipsecrvpx
    ;;
  32)
    echo -e "${blanc}Regarder les paquets"
    echo -e "${jaune} sudo tcpdump -i ens33 esp"
    ;;
  33)

    ;;
  41)
    sudo poweroff
    ;;
  42)
    sudo nano -l vchk.sh
    ;;
  43)
    echo -e "${jaune} scp sc12vchk.sh stage@192.168.80.139:/home/stage"
    ls -al
    mv sc12vchk.sh vchk.sch
    chmod +x vchk.sh
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
