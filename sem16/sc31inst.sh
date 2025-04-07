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

installreseau()
{
    #Choix 11
    while true;
    do
    echo -e "${vert}========== Config IP fixe de base"
    echo -e "${jaune} sudo nano -l /etc/netplan/01-netcfg.yaml${vert} exemple"
    sed -n '/res/p' repere.lst
    echo -e "${jaune} sudo hostnamectl set-hostname <new hostname>"
    echo -e "${bleu}========== Config sur cette machine"
    cat /etc/netplan/01-netcfg.yaml
    echo -e "${vert}11 pour (re)faire le fichier 01-netcfg (prod.139) + hostname"
    echo -e "${vert}12 pour (re)faire le fichier 01-netcfg (rvpx.102) + hostname"
    echo -e "${vert}13 pour sudo nano /etc/hosts"
    echo -e "${vert}14 pour sudo netplan apply - CHANGEMENT D'IP -"
    echo -e "${vert}0 pour sortir${blanc}"
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
        echo "          dhcp4: no" | sudo tee -a "$cible2"
        echo "          addresses:" | sudo tee -a "$cible2"
        echo "              - 192.168.80.139/24" | sudo tee -a "$cible2"
#        echo "            gateway4: 192.168.80.2" | sudo tee -a "$cible2"
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
        echo "          dhcp4: no" | sudo tee -a "$cible2"
        echo "          addresses:" | sudo tee -a "$cible2"
        echo "              - 192.168.80.102/24" | sudo tee -a "$cible2"
#        echo "            gateway4: 192.168.80.2" | sudo tee -a "$cible2"
        echo "          nameservers:" | sudo tee -a "$cible2"
        echo "              addresses:" | sudo tee -a "$cible2"
        echo "                  - 192.168.80.2" | sudo tee -a "$cible2"
        sudo hostnamectl set-hostname srv20rvpx
        echo -e "${vert} Vérifier et appliquer ATTENTION CHANGEMENT IP !!!"
        echo -e "${jaune} sudo nano /etc/hosts"
        echo -e "${jaune} sudo netplan apply"
        ;;
    13)
        sudo nano /etc/hosts
        ;;
    14)
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

testversions()
{
    #Choix 12
    echo -e "\n${vert}=== CONFIG PRODUCTION ======================"
    # Vérifier la version d'Apache Tomcat
    echo -e "${gris}=== Apache Tomcat Version ==="
    curl -s http://localhost:8080 | grep 'Server version' || echo -e "${blanc}Tomcat absent/ inaccessible"

    echo -e "${gris}=== Apache Version ==="
    APACHE_VERSION=$(apache2 -v 2>/dev/null || httpd -v 2>/dev/null || echo -e "${blanc}Apache2 absent")
    echo -e "${blanc}Apache Version: $APACHE_VERSION"

    echo -e "${gris}=== Version de la JVM ==="
    JVM_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    JVM_VENDOR=$(java -version 2>&1 | awk -F '"' '/version/ {getline; print $0}')
    echo -e "${blanc}JVM Version: $JVM_VERSION"
    echo -e "${blanc}JVM Vendor: $JVM_VENDOR"

    echo -e "${gris}=== PostgreSQL Version ==="
    POSTGRES_VERSION=$(psql --version 2>/dev/null || echo -e "${blanc}PostgreSQL absent")
    echo -e "${blanc}Postrgres Version: $POSTGRES_VERSION"

    echo -e "\n${vert}=== CONFIG REVERSE PROXY ======================"
    echo -e "${gris}=== Nginx Version ==="
    NGINX_VERSION=$(nginx -v 2>&1 | awk -F '/' '{print $2}' || echo -e "${blanc}Nginx absent")
    echo -e "${blanc}Nginx Version: $NGINX_VERSION"

    echo -e "${gris}=== PHP Version ==="
    PHP_VERSION=$(php -v 2>/dev/null | head -n 1 || echo -e "${blanc}PHP absent")
    echo -e "${blanc}PHP Version: $PHP_VERSION"

    echo -e "\n${vert}=== CONFIG SECURITE ======================"
    echo -e "${gris}=== Certbot Version ==="
    CERTBOT_VERSION=$(certbot --version 2>/dev/null || echo -e "${blanc}Certbot absent")
    echo -e "${blanc}Certbot Version: $CERTBOT_VERSION"

    echo -e "${gris}=== Openssl Version ==="
    OPENSSL_VERSION=$(openssl version 2>/dev/null || echo -e "${blanc}Openssl absent")
    echo -e "${blanc}Openssl Version: $OPENSSL_VERSION"
#    openssl version
    echo -e "${gris}=== IPsec Version ==="
    IPSEC_VERSION=$(ipsec version 2>/dev/null || echo -e "${blanc}IPsec absent")
    echo -e "${blanc}IPsec Version: $IPSEC_VERSION"

    echo -e "\n${gris}=== Chiffrement ? ==="
    echo -e "${jaune} ipsec stop/ start?"
    echo -e "${blanc}Utiliser le choix suivant (13)"
}

verifflux()
{
    #Choix 13
    echo -e "${vert}========== 13.1 Filtrer avec Wireshark${blanc}."
    echo -e "${jaune} ip.addr == 192.168.80.102 && ip.addr==192.168.80.139 ou tcp.port == 443"
    echo -e "${vert}========== 13.2 Vérfier avec TCPdump${blanc}."
    echo -e "${jaune} sudo tcpdump -i eth0 host [IP_REVERSE_PROXY] and host [IP_BACKEND] and port 443 -w ssl_traffic.pcap"
    echo -e "${vert}========== 13.3 Ports Firewall${blanc}."
    sudo ss -ltnp
    echo -e "${vert}========== 13.4 Status IPsec${blanc}."
    sudo ipsec statusall
}

installapache()
{
    #Choix 21
    echo -e "${vert}========== 21.0 Installation PROD (Apache2 only) [...139]"
    echo -e "${blanc}>IP .(1)39  +Apache (+Tomcat)"
    echo -e "\n${jaune}----- update${blanc}"
    sudo apt update
    echo -e "\n${jaune}----- openjdk-8-jre${blanc}"
    sudo apt-get install openjdk-8-jre
    echo -e "\n${jaune}----- postgresql-12${blanc}"
    sudo apt install postgresql-12
    echo -e "\n${jaune}----- apache2${blanc}"
    sudo apt install apache2
    echo -e "\n${jaune}----- ufw${blanc}"
    sudo ufw allow 'Apache'
#    sudo ufw allow "Apache Full"
    sudo ufw status

#    sudo systemctl enable apache2
#    hostname -I
    echo -e "${vert}========== Vérfier depuis navigateur [...139]"
}

installtomcat()
{
  # choix22
    echo -e "${vert}========== 22.0 Install PROD (Tomcat) [...139]"
    echo -e "${blanc}>Installation Apache-Tomcat"
    echo -e "${jaune} cd /tmp"
    echo -e "${jaune} wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz"
    echo -e "${jaune} sudo mkdir /opt/tomcat8"
    echo -e "${jaune} sudo tar xvfz apache-tomcat-8.5.50.tar.gz -C /opt/tomcat8/ --strip-components=1"
    echo -e "${jaune} sudo groupadd tomcat8"
    echo -e "${jaune} sudo useradd -s /bin/false -g tomcat8 -d /opt/tomcat8 tomcat8"
    echo -e "${vert}---------A compléter"
    echo -e "${blanc}--------- Fichier de service corrigé (2025/03)"
    echo -e "${blanc}..."
}

installrvpx()
{
  #Choix 24
    echo -e "${vert}========== 23.0 Install Reverse proxy [...102]"
    echo -e "\n${jaune}----- update${blanc}"
    sudo apt update
    echo -e "\n${jaune}----- nginx-full${blanc}"
    sudo apt install nginx-full
    echo -e "\n${jaune}----- php-fm${blanc}"
    sudo apt install php-fpm
    echo -e "\n${jaune}----- certbot${blanc}"
    sudo apt install certbot python3-certbot-nginx -y
    echo -e "${jaune}========== Paramètres"
#    curl http://192.168.80.139
    echo -e "${jaune}----- Contenu /sites-available/default -----"
    sed -n '/dfrvpx/p' repere.lst
    echo -e "${jaune} sudo nano -l/etc/nginx/sites-available/default"
    echo -e "\n${jaune}----- nginx -t${blanc}"
    echo -e "${jaune} sudo nginx -t"
    echo -e "\n${jaune}----- nginx restart${blanc}"
    echo -e "${jaune} sudo systemctl restart nginx"
    echo -e "${vert}----- Tester depuis navigateur !!!!"
}

installssprod ()
{
    #Choix 31
    echo -e "${vert}========== 24.0 Install SS-SSL PROD (self-signed SSL)"
    echo -e "${blanc}>Verif serveur prod +SS-SSL +..."
#    curl http://192.168.80.139

#    sudo a2enmod ssl
#    sudo systemctl restart apache2
#    sudo systemctl status apache2

    sudo a2enmod headers
    sudo systemctl restart apache2
    sudo a2enmod ssl
    sudo ufw allow "Apache Full"
    sudo mkdir -p /etc/ssl/prod
    cd /etc/ssl/prod
    pwd
    echo -e "${vert}--------- Création certificat/ clé"
    echo -e "${jaune} sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
    echo -e "${jaune}  -keyout prod.key \\"
    echo -e "${jaune}  -out prod.crt"
    echo -e "${vert}--------- + Ip du serveur PROD !!!${blanc}"
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/prod/prod.key -out /etc/ssl/prod/prod.crt -subj "/C=FR/ST=IDF/L=IVRY/O=FV/CN=192.168.80.139"
#    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
    echo -e "${vert}--------- Si Option Diffie-Hellman sur serveur prod???"
    echo -e "${jaune} sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048"
    echo -e "${vert}--------- Création VirtualHost (attention aux $ manquants?)"
    echo -e "${jaune} sudo nano /etc/apache2/sites-available/prod_ssl.conf${blanc24}"
    sed -n '/vhssprod/p' repere.lst
    sudo nano /etc/apache2/sites-available/prod_ssl.conf
#### Activation ssl
    sudo a2ensite prod_ssl.conf
    sudo systemctl restart apache2
#### Tester
    echo -e "${jaune} curl -k https://192.168.80.139:443"
    echo -e "${jaune} sudo mkdir /var/www/your_domain_or_ip pour index.html???"
    echo -e "${vert}--------- Ajout HTS ?"

}

installssrvpx ()
{
#Choix 32
    echo -e "${vert}========== 25.0 Install SS-SSL RVPX (self-signed SSL)"
    echo -e "${blanc}>Verif prod en http, puis +SS-SSL +..."
    echo -e "${jaune} curl http://...139"
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/nginx-selfsigned.key \
      -out /etc/ssl/certs/nginx-selfsigned.crt \
      -subj "/C=FR/ST=IDF/L=IVRY/O=FV/CN=192.168.80.102"
    echo -e "${vert}--------- + Ip du RVPX !!!"
    echo -e "${vert}--------- Option Diffie-Hellman"
    echo -e "${jaune}}......... sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048"
    echo -e "${jaune} sudo nano -l /etc/nginx/sites-available/default"
    echo -e "${vert}--------- SS-SSL NGINX (sans REVERSE Proxy)"
    sed -n '/sngx/p' repere.lst
    echo -e "${vert}--------- ou afficher 'default' AVANT activation sur serveur PROD"
    sed -n '/ssrvpx/p' repere.lst
    echo -e "${vert}--------- Vérifier/modifier dans 'default' APRES activation sur serveur PROD"
    echo -e "${jaune} sudo nano /etc/nginx/sites-available/default "
    echo -e "${vert} location / {"
    echo -e "${vert}     proxy_pass https://192.168.80.139:443;"
    echo -e "${vert}     proxy_ssl_verify off;  # car cert self-signed"
    echo -e "${vert}     proxy_set_header Host $host;"
    echo -e "${vert}     proxy_set_header X-Real-IP $remote_addr;"
    echo -e "${vert} }"
    echo -e "${jaune} sudo nginx -t && sudo systemctl reload nginx"
    echo -e "${vert}--------- Tester... (verif rvpx)"
    echo -e "${jaune} curl -k https://rp.test.fv"
}

installipsecprod()
{
    #Choix 34
    echo -e "${vert}========== 26.0 Install IPsec serveur production"
    echo -e "${blanc}"
    echo -e "${jaune} sudo apt update"
    echo -e "${jaune} sudo apt install strongswan"
    echo -e "${jaune} sudo systemctl status ipsec"
# sudo apt install strongswan strongswan-plugin-eap-mschapv2
# sudo apt install strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins
# systemctl status strongswan-starter.service ; systemctl is-enabled strongswan-starter.service ???
    echo -e "${blanc}Modifications à faire dans:"
    echo -e "${jaune} sudo nano /etc/ipsec.conf${jaune}."
    sed -n '/^isprod/,/^$/p' repere.lst
    echo -e "${blanc}Modifications/ ajout à faire sur @nginx @apache:"
    echo -e "${jaune} sudo nano /etc/ipsec.secrets"
    echo -e "${vert}: PSK \"987654321\""
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} sudo ipsec statusall"
# Pour IP forwarding par passerelle: sudo sysctl -w net.ipv4.ip_forward=1
# $ sudo mv /etc/ipsec.conf /etc/ipsec.conf.bkp
# Générer clé 'openssl rand -base64 32'
}

installipsecrvpx()
{
    #Choix 35
    echo -e "${vert}========== 27.0 Install IPsec reverse proxy"
    echo -e "${blanc}"
    echo -e "${jaune} sudo apt update"
    echo -e "${jaune} sudo apt install strongswan"
    echo -e "${jaune} sudo systemctl status ipsec"
# sudo apt install strongswan strongswan-plugin-eap-mschapv2
# sudo apt install strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins
    echo -e "${blanc}Modifications à faire dans:"
    echo -e "${jaune} sudo nano /etc/ipsec.conf${jaune}."
#    cat config.fil
    sed -n '/^isrvpx/,/^$/p' repere.lst
    echo -e "${blanc}Modifications/ ajout à faire sur @nginx @apache:"
    echo -e "${jaune} sudo nano /etc/ipsec.secrets"
    echo -e "${vert}: PSK \"987654321\""
    echo -e "${jaune} sudo ipsec restart"
    echo -e "${jaune} sudo ipsec statusall"
    echo -e "${blanc}Dans config Nginx, vérifier le pointage du proxy_pass:"
    echo -e "${jaune} sudo nano /etc/nginx/sites-available/default"
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
    echo -e "${blanc}Attention au Firewall"
    echo -e "${blanc}Ouvrez les ports UDP **500** et **4500** pour IPsec sur les deux serveurs."
    echo -e "${blanc}Autorisez le protocole **ESP** (protocol number 50)."
    echo -e "${jaune} sudo ufw allow 500,4500/udp"
    echo -e "${jaune} sudo ufw reload"
}

verifssl()
{
    #Choix 38
    # Adresse IP ou nom d'hôte du destinataire
    DEST_HOST="192.168.80.139"
    DEST_PORT=443
    echo -e "${vert}========== Vérification SSL vers $DEST_HOST:$DEST_PORT"
    echo -e "${blanc}"
    
    # Connexion SSL avec openssl
    OUTPUT=$(echo | openssl s_client -connect "$DEST_HOST:$DEST_PORT" -servername "$DEST_HOST" 2>/dev/null)
    
    # Vérifie si le certificat a été récupéré
    if echo "$OUTPUT" | grep -q "BEGIN CERTIFICATE"; then
        SUBJECT=$(echo "$OUTPUT" | grep "subject=" | sed 's/^.*CN=//')
        ISSUER=$(echo "$OUTPUT" | grep "issuer=" | sed 's/^.*CN=//')
        VALID=$(echo "$OUTPUT" | grep "Verify return code: 0 (ok)")
    
        echo "Connexion SSL établie avec succès."
        echo "   Certificat CN : $SUBJECT"
        echo "   Émis par      : $ISSUER"
        echo "   Vérification  : ${VALID:-Échec de la validation}"
    else
        echo "Échec de la connexion SSL au destinataire."
    fi
    # TEST VERS NGINX
    # Adresse IP ou nom d'hôte du destinataire
    DEST_HOST="192.168.80.102"
    DEST_PORT=443
    
    echo -e "${vert}========== Vérification SSL vers $DEST_HOST:$DEST_PORT"
    echo -e "${blanc}"
    
    # Connexion SSL avec openssl
    OUTPUT=$(echo | openssl s_client -connect "$DEST_HOST:$DEST_PORT" -servername "$DEST_HOST" 2>/dev/null)
    
    # Vérifie si le certificat a été récupéré
    if echo "$OUTPUT" | grep -q "BEGIN CERTIFICATE"; then
        SUBJECT=$(echo "$OUTPUT" | grep "subject=" | sed 's/^.*CN=//')
        ISSUER=$(echo "$OUTPUT" | grep "issuer=" | sed 's/^.*CN=//')
        VALID=$(echo "$OUTPUT" | grep "Verify return code: 0 (ok)")
    
        echo "Connexion SSL établie avec succès."
        echo "   Certificat CN : $SUBJECT"
        echo "   Émis par      : $ISSUER"
        echo "   Vérification  : ${VALID:-Échec de la validation}"
    else
        echo "Échec de la connexion SSL au destinataire."
    fi
}

verifipsec()
{
    #Choix 39
    echo -e "${vert}========== Vérification IPsec"
    echo -e "${blanc}"

    echo -e "\n[1] État du tunnel IPsec :"
    sudo ipsec status | grep -E 'ESTABLISHED|INSTALLED' || echo " Aucun tunnel établi"
    
    echo -e "\n[2] Compteurs de paquets IPsec (XFRM) :"
    sudo ip -s xfrm state | awk '/src | packets| bytes/'
    
    echo -e "\n[3] Paquets ESP captés (protocole IPsec) :"
    sudo timeout 5 tcpdump -ni any esp 2>/dev/null | head -n 10 || echo " Aucun paquet ESP détecté"
    
    echo -e "\n[4] Test de connectivité vers le backend (HTTP via tunnel) :"
    read -p "Entrez l'IP du backend (ex: 192.168.10.93): " backend_ip
    curl -s -o /dev/null -w "Code HTTP: %{http_code}\n" http://$backend_ip
    
    echo -e "\n[5] Derniers logs StrongSwan :"
    sudo journalctl -u strongswan --no-pager -n 10
    
    echo -e "\n Vérification terminée."
}

# DEBUT SCRIPT
echo -e "\n${bleu}========== ACTIONS ========== ========== 06/04/25 =========="
#echo -e "\n${blanc}chmod +x; script localisé dans $(pwd)"
while true;
    do
    echo -e "${jaune}\n========== Services dans cette machine: $(hostname) | IP : $(hostname -I | awk '{print $1}')"
    OS_NAME=$(lsb_release -d | cut -f2-)
    OS_VERSION=$(lsb_release -r | cut -f2-)
    ARCHITECTURE=$(uname -m)
    echo "========== OS: $OS_NAME - Architecture: $ARCHITECTURE - Version: $OS_VERSION"
    echo -e "${vert}11 -> Config: RESEAU           12 -> VERSIONS actives               13 -> FLUX actifs"
    echo -e "${rouge}21 -> Install PROD: Apache2    22 -> Install: PROD A/T/PG           23 -> Afficher PROD (status)"
    echo -e "${jaune}24 -> Install RVPX                                                  26 -> Afficher RVPX (config)"
    echo -e "${rouge}31 -> Install SS-SSL PROD      32 -> Install SS-SSL dfrvpx          33 -> Afficher clé/ certificat"
    echo -e "${jaune}34 -> Install IpSec PROD       35 -> Install IpSec RVPX             36 -> Afficher IpSec (config)"
    echo -e "${gris}37 -> Afficher repere.lst"
    echo -e "${blanc}38 -> Verif SSL                39 -> Verif IPsec                    "
    echo -e "${gris}41 -> Start/ stop SSL          42 -> Start/ stop IPsec              43 -> Lynx"
    echo -e "${blanc}51 -> Eteindre serveur         52 -> Reboot"
    echo -e "${gris}55 -> SOS                      56  -> Editer ce script              57 -> MAJ Scripts???"
    echo -e "${blanc} 0 -> Quitter"
    
    read reponse
    
    case $reponse in
    
      11)
        installreseau
        ;;
    
      12)
        testversions
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
        sudo systemctl status apache2
        ;;
      24)
        installrvpx
        ;;
      26)
        echo -e "\n${jaune}----- cat /etc/nginx/sites-available/default${blanc}"
        cat /etc/nginx/sites-available/default
        ;;
      27)
        echo -e "${blanc}Regarder les paquets"
        echo -e "${jaune} sudo tcpdump -i ens33 esp"
        ;;
      31)
        installssprod
        ;;
    
      32)
        installssrvpx
        ;;
    
      34)
        installipsecprod
        ;;
    
      35)
        installipsecrvpx
        ;;
      33)
        echo -e "${vert}========== Configuration self-signed SSL"
        echo -e "\n${jaune}----- cat /etc/ssl/private/nginx-selfsigned.key${blanc}."
        sudo cat /etc/ssl/private/nginx-selfsigned.key
        echo -e "\n${jaune}----- cat /etc/ssl/certs/nginx-selfsigned.crt${blanc}."
        cat /etc/ssl/certs/nginx-selfsigned.crt
        echo -e "\n${jaune}----- cat /etc/nginx/sites-available/default${blanc}."
        cat /etc/nginx/sites-available/default    
        echo -e "\n${jaune}----- cat /etc/ssl/prod/prod.key${blanc}"
        sudo cat /etc/ssl/prod/prod.key
        echo -e "\n${jaune}----- cat /etc/ssl/prod/prod.crt${blanc}"
        cat /etc/ssl/prod/prod.crt
    
          ;;
      36)
        echo -e "${vert}========== Configuration IPsec"
        echo -e "\n${jaune}----- cat /etc/ipsec.conf${blanc}."
        cat /etc/ipsec.conf
        echo -e "\n${jaune}----- cat /etc/ipsec.secrets${blanc}."
        cat /etc/ipsec.secrets
        echo -e "\n${jaune}----- cat /etc/ipsec.d/cacerts/ca-cert.pem${blanc}."
        cat /etc/ipsec.d/cacerts/ca-cert.pem
        echo -e "\n${jaune}----- cat /etc/nginx/sites-available/default${blanc}."
        cat /etc/nginx/sites-available/default
        ;;
      37)
        cat repere.lst
        ;;
      38)
        verifssl
        ;;
      39)
        verifipsec
        ;;
      51)
        sudo poweroff
        ;;
      52)
        sudo reboot
        ;;
      56)
        sudo nano -l vchk.sh   
        ;;
      55)
        sed -n '/sos/p' repere.lst
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
echo -e "${blanc}---------- ----------"