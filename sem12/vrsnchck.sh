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
echo -e "\n${jaune}chmod +x script.sh"
echo "./script.sh"
echo -e "\n=== Localisé ==="
pwd

echo -e "\n=== Système d'exploitation ==="
OS_NAME=$(lsb_release -d | cut -f2-)
OS_VERSION=$(lsb_release -r | cut -f2-)
ARCHITECTURE=$(uname -m)
echo "Nom de l'OS: $OS_NAME"
echo "Version de l'OS: $OS_VERSION"
echo "Architecture: $ARCHITECTURE"

echo -e "\n${rouge}=== CONFIG PRODUCTION ==="
# Vérifier la version d'Apache Tomcat
echo -e "\n${jaune}=== Apache Tomcat Version ==="
curl -s http://localhost:8080 | grep 'Server version' || echo "Tomcat absent/ inaccessible"

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

echo -e "${rouge}\n=== Adresse IP v4 ==="
echo -e "${jaune}."
ip -4 a
echo -e "\n=== Hostname ==="
hostname

echo -e "${rouge}\n=== Configurer cette machine à partir d'Ubuntu 20 ==="
echo -e "${vert}CHOISIR 11 -> Config RESEAU ou 12 -> Config SERVEUR"
echo -e "${jaune}sinon autre valeur"
echo -e "${orange}sudo apt update"

read reponse
if [ $reponse -eq 11 ]
then
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
else
    if  [ $reponse -eq 12 ]
    then
    echo -e "${rouge}========== PROD =================="
    echo -e "${vert}IP .(1)39 +JVM +PostgreSQL +Apache Tomcat +Police MS"
    echo -e "${vert}sudo apt-get install openjdk-8-jre"
    echo -e "${vert}sudo apt install postgresql-12"
    echo -e "${vert}cd /tmp"
    echo -e "${vert}wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz"
    echo -e "${vert}sudo mkdir /opt/tomcat8"
    echo -e "${vert}sudo tar xvfz apache-tomcat-8.5.50.tar.gz -C /opt/tomcat8/ --strip-components=1"
    echo -e "${vert}sudo groupadd tomcat8"
    echo -e "${vert}sudo useradd -s /bin/false -g tomcat8 -d /opt/tomcat8 tomcat8"
    echo -e "${vert}Installer Font"
    echo -e "${rouge}========== RVPX =================="
    echo -e "${vert}IP .102 +Nginx +Php +Certbot"
    echo -e "${vert}sudo apt install nginx-full"
    echo -e "${vert}sudo apt install php-fpm"
    echo -e "${vert}sudo apt install certbot python3-certbot-nginx -y"
    fi
fi
echo -e "${blanc}Fin de script - ATTENTION aux identations!!!"