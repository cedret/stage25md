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
echo -e "\n=== Hostname ==="
hostname

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

echo -e "${rouge}\n=== Configurer cette machine à partir d'Ubuntu 20 ==="
echo -e "${vert}Entrez 11 -> Serveur prod ou 12 -> Reverse proxy"
echo -e "${jaune}sinon autre valeur"
echo -e "${orange}sudo apt update"

read reponse
if [ $reponse -eq 11 ]
then
    echo -e "${vert}Installer JVM: sudo apt-get install openjdk-8-jre"
    echo -e "${vert}Installer PostgreSQL: sudo apt install postgresql-12"
    echo -e "${vert}Installer Font"
    echo -e "${vert}Installer Apache"
else
    if  [ $reponse -eq 12 ]
    then
        echo -e "${vert}Installer Nginx: sudo apt install nginx-full"
        echo -e "${vert}Installer Php: sudo apt install php-fpm"
	    echo -e "${vert}Installer Certbot: sudo apt install certbot python3-certbot-nginx -y"
    fi
fi
echo -e "${blanc}Fin de script"