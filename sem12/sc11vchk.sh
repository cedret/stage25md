#!/bin/bash
#Variables pour la coloration syntaxique
# set -x 
blanc="\033[0m"
noir="\033[30m"
rouge="\033[31m"
vert="\033[32m"
orange="\033[33m"
jaune="\033[1;33m"

echo -e "\n${rouge}========== THE CHECKER =========="
echo "========== =========== =========="
echo -e "${jaune}chmod +x script.sh, localisé dans"
pwd

echo -e "\n${rouge}=== Système d'exploitation ===${jaune}"
OS_NAME=$(lsb_release -d | cut -f2-)
OS_VERSION=$(lsb_release -r | cut -f2-)
ARCHITECTURE=$(uname -m)
echo "Nom de l'OS: $OS_NAME"
echo "Version de l'OS: $OS_VERSION"
echo "Architecture: $ARCHITECTURE"

echo -e "${rouge}\n=== Adresse IP v4 ===${jaune}"
ip -4 a
echo -e "\n${rouge}=== Hostname ===${jaune}"
hostname

echo -e "${rouge}\n=== Configurer cette machine avec Ubuntu 20 ==="
echo -e "${vert}11 -> VERSIONS actuelles  12 -> Paramètres RESEAU  13 -> Installations SERVEURS"
echo -e "${vert}14 -> Config RVPX   15 -> Installation SSL-self signed   16 -> Installation IpSec"
echo -e "${vert}17 -> Mode promiscuité   18 ->                     19 ->"
echo -e "${jaune}sinon autre valeur"

read reponse

case $reponse in

    11)
    echo -e "\n${rouge}=== CONFIG PRODUCTION ==="
    # Vérifier la version d'Apache Tomcat
    echo -e "\n${jaune}=== Apache Tomcat Version ==="
    curl -s http://localhost:8080 | grep 'Server version' || echo "Tomcat absent/ inaccessible"

    echo -e "\n=== Apache Version ==="
    APACHE_VERSION=$(apache2 -v 2>/dev/null || httpd -v 2>/dev/null || echo "Apache2 absent")
    echo "$APACHE_VERSION"

    echo -e "\n=== Version de la JVM ==="
    JVM_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    JVM_VENDOR=$(java -version 2>&1 | awk -F '"' '/version/ {getline; print $0}')
    echo "JVM Version: $JVM_VERSION"
    echo "JVM Vendor: $JVM_VENDOR"

    echo -e "\n=== PostgreSQL Version ==="
    POSTGRES_VERSION=$(psql --version 2>/dev/null || echo "PostgreSQL absent")
    echo "$POSTGRES_VERSION"

    echo -e "\n${rouge}=== CONFIG REVERSE PROXY ==="
    echo -e "\n${jaune}=== Nginx Version ==="
    NGINX_VERSION=$(nginx -v 2>&1 | awk -F '/' '{print $2}' || echo "Nginx absent")
    echo "Nginx Version: $NGINX_VERSION"

    echo -e "\n=== PHP Version ==="
    PHP_VERSION=$(php -v 2>/dev/null | head -n 1 || echo "PHP absent")
    echo "PHP Version: $PHP_VERSION"

    echo -e "\n=== Certbot Version ==="
    CERTBOT_VERSION=$(certbot --version 2>/dev/null || echo "Certbot absent")
    echo "$CERTBOT_VERSION"

    openssl version
    ;;

  12)
    echo -e "${rouge}sudo nano /etc/netplan/01-netcfg.yaml"
    echo -e "${jaune}network:"
    echo -e "${jaune}  version: 2"
    echo -e "${jaune}  renderer: networkd"
    echo -e "${jaune}  ethernets:"
    echo -e "${jaune}    ens33:"
    echo -e "${jaune}      dhcp4: no"
    echo -e "${jaune}      addresses:"
    echo -e "${jaune}        - 192.168.80.10?/24"
    echo -e "${jaune}      gateway4: 192.168.80.2"
    echo -e "${jaune}      nameservers:"
    echo -e "${jaune}          addresses: [192.168.80.2]"
    echo -e "${rouge}sudo netplan apply"
    echo -e "${jaune}hostnamectl set-hostname <new hostname>"
    echo -e "${jaune}sudo nano /etc/hosts"
    cat /etc/netplan/01-netcfg.yaml
    ;;

  13)
    echo -e "${rouge}========== PROD =================="
    echo -e "${vert}>IP .(1)39 +JVM +PostgreSQL +Apache (+Tomcat) +Police MS"
    echo -e "${vert}sudo apt-get install openjdk-8-jre"
    echo -e "${vert}sudo apt install postgresql-12"
    echo -e "${vert}sudo apt install apache2"
    echo -e "${vert}sudo ufw allow 'Apache'"
    echo -e "${vert}sudo apt install lynx"
    echo -e "${vert}>Installation Apache-Tomcat"
    echo -e "${vert}cd /tmp"
    echo -e "${vert}wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz"
    echo -e "${vert}sudo mkdir /opt/tomcat8"
    echo -e "${vert}sudo tar xvfz apache-tomcat-8.5.50.tar.gz -C /opt/tomcat8/ --strip-components=1"
    echo -e "${vert}sudo groupadd tomcat8"
    echo -e "${vert}sudo useradd -s /bin/false -g tomcat8 -d /opt/tomcat8 tomcat8"
    echo -e "${vert}>Installer Font à compléter"
    echo -e "${rouge}========== RVPX =================="
    echo -e "${vert}>IP .102 +Nginx +Php +Certbot"
    echo -e "${vert}sudo apt install nginx-full"
    echo -e "${vert}sudo apt install php-fpm"
    echo -e "${vert}sudo apt install certbot python3-certbot-nginx -y"
    ;;

  14)
    echo -e "${rouge}========== RVPX =================="
    echo -e "${vert}>Verif prod + "
    echo -e "${vert}curl http://192.168.80.xx"

esac
echo -e "${blanc}sudo apt update"
echo -e "$ATTENTION aux identations et aux vm clonées"
echo -e "${blanc}Fin de script"