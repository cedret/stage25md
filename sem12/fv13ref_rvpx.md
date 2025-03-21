France Volontaires

# Mise en place d’un Reverse Proxy – Système d’information - 2018
---
Table des matières
I.	Introduction
II.	Objectifs
III.	Plan de mise à jour
1)	Installation d’une nouvelle VM SRVRP
2)	Détail du fichier de configuration SRVRP
3)	Mise en production
IV.	Liens
V.	Les Sauvegardes
VI.	Schéma de la nouvelle infrastructure et matrice des flux


## I.	Introduction

Le Système d’Information de France Volontaires est constitué de 3 applications web : Système d’information Métier, le Suivi des actions et le Suivi des demandes.
Ces applications sont hébergées sur une plateforme Linux Ubuntu constituée par :
-	1 serveur de production : SRVSIPROD
-	1 serveur de secours : SRVSIBKP (VM)
-	1 serveur de préproduction : SRVSIPREPROD (VM)
Ces serveurs présentes des caractéristiques systèmes et applicatives proches. Ils sont tous équipés d’un OS Linux Ubuntu 16.04, d’un serveur apache Tomcat 8.5.9 et de java 1.7.0_95.
Voici la sortie obtenue sur le serveur principal : 
````
admfv@SRVSIPROD:~/Scripts$ ./get_info.sh
 ___        __
|_ _|_ __  / _| ___
 | || '_ \| |_ / _ \
 | || | | |  _| (_) |
|___|_| |_|_|  \___/

***************************************************
*** Informations sur les versions d'Apache et Java:

Server version: Apache Tomcat/8.5.9
Server built:   Dec 5 2016 20:18:12 UTC
Server number:  8.5.9.0
OS Name:        Linux
OS Version:     4.4.0-109-generic
Architecture:   amd64
JVM Version:    1.7.0_95-b00
JVM Vendor:     Oracle Corporation

***************************************
***Informations de version de Postgres:

postgres (PostgreSQL) 9.5.12

************************
*** 2018 - Aurélien ROUX
````
Courant mars 2018, une mise à jour de la webapp SI Métier a été réalisé par notre prestataire. Au moment de la rédaction du cahier des charges, la sécurisation via SSL/TLS a été évoqué.

## II.	Objectifs

L’objectif est donc de sécuriser les échanges entre les utilisateurs des webapps et les serveurs qui les héberge. Afin de répondre à cet objectif, notre prestataire nous a conseillé d’utiliser une solution de type proxy (NGINX) qui accueillerait les connexions sécurisées en HTTPS.

## III.	Plan de mise à jour

L’installation de la solution s’est faite « à vue ».

### 1 Installation d’une nouvelle VM SRVRP

1)	Un nouveau serveur virtuel SRVRP (pour Reverse Proxy) a été réalisé sur un de nos hyperviseurs.
Le système d’exploitation Ubuntu 16.04 LTS a été retenu. Nginx a été installé (version 1.10.3).
Le temps de l’installation et des tests, SRVRP devait être accessible via une adresse IP publique dédiée (37.26.180.139). 

2)	Initialement, le portail devait rester sur SRVSIBKP.

3)	Le certificat LetsEncrypt devait être généré sur le serveur SRVRP. Cependant, pour fonctionner, LetsEncrypt requiert qu’un nom de domaine publique soit associé à l’IP publique. La configuration retenue ne permettant pas cela, le certificat a été généré sur SRVSIBKP (pas le meilleur choix). 
En conséquence, il fallut procéder à la migration du certificat entre SRVSIBKP et SRVRP. Une archive du service LetsEncrypt a été réalisée afin de récupérer les fichiers sur SRVRP (voir commande en point). L’adresse IP 37.26.180.139 associée à si.france-volontaires.org a dû être redirigé vers SRVRP (configuration sur le parefeu Sonicwall). Par commodité, le portail France Volontaires a été migré vers SRVRP. Le serveur NGINX sert alors la page portail et a permis la reconfiguration du certificat.

4)	À la suite de la récupération du certificat, à la désinstallation/réinstallation de NGINX, le serveur proxy a pu être configuré.

5)	Pour finir, la phase de test et le redéveloppement de la page portail ont été réalisé.


### 2 Détail du fichier de configuration SRVRP

1)	Les paramètres de noms et adresses IP
a.	Modification du nom (modifier le fichier hosts et hostname)
````
admfv@SRVRP:~$ sudo cat /etc/hosts
127.0.0.1       localhost
127.0.1.1       SRVRP

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
admfv@SRVRP:~$ sudo cat /etc/hostname
SRVRP
````
b.	Modification de l’IP
````
admfv@SRVRP:~$ sudo nano /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address 120.121.2.102
        netmask 255.255.255.0
        gateway 120.121.2.22
        dns-nameservers 208.67.220.220
CTRL<o|x>
admfv@SRVSIPROD:~$ sudo service networking start
````
2)	Installation des composants serveurs : 

a.	Installation de NGINX et PHP:
````
sudo apt-get install nginx-full
sudo apt-get install php-fpm
````
b.	Installation de Certbot (letsencrypt)
````
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx
````
c.	Copie des fichiers Certbot provenant de SRVSIBKP (suppose que l’archive LetsEncrypt se trouve dans le home, voir point XXX)
````
Cd ~
Tar xvf letse.tar
cd letsencrypt/
sudo mv  archive/ /etc/letsencrypt/
sudo mv  live/ /etc/letsencrypt/
sudo mv  renewal/ /etc/letsencrypt/
sudo certbot
````
**/!\   La dernière commande permet de reconfigurer Certbot afin d’associer le certificat si.france-volontaires.org au service.**
Il suffit de se laisser guider par l’assistant.

3)	Paramétrage des composants serveurs :
a.	nginx
````
sudo nano /etc/nginx/sites-available/default
…
##
# Création d'une référence au server TOMCAT de production
##
upstream SRVSIPROD {
    server 120.121.2.39:8080 fail_timeout=0;
}
# === Création de serveurs Upstream hébergeant les webapps (prod et backup) ===

##
# === Création d'une référence au serveur TOMCAT de secours ===
##
upstream SRVSIBKP {
    server 120.121.2.100:8080 fail_timeout=0;
}
…
server {
        listen 80 default_server;
        #listen [::]:80 default_server;
        server_name si.france-volontaires.org;
        #return 301 https://$server_name$request_uri;
# Désactivation du service sur IPv6

…

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.php index.html index.htm;

# === Ajout de l'index.php pour le servir ===

location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #return 301 https://$server_name$request_uri;
                try_files $uri $uri/ =404;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
        #
        #       # With php7.0-cgi alone:
        #       fastcgi_pass 127.0.0.1:9000;
        #       # With php7.0-fpm:
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        }

# === Configuration du plugin PHP. Réalisé en automatique pendant l’installation ===


        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        location ~ /\.ht {
                deny all;
        }

	####################################################################################
        # Redirection du SI Métier
        #
        ##########################

        location ^~ /afvp {
                proxy_set_header    Host $host;
                proxy_set_header    X-Real-IP $remote_addr;
                proxy_set_header    X-Forwarded-Proto https;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_redirect      http:// https://;
                proxy_pass          http://SRVSIPROD;
        }

# === Configuration des redirections vers les webapps : afvp/plan/task ====

        # A décommenter si problème avec SRVSIPROD
        #location ^~ /afvp {
        #        proxy_set_header    Host $host;
        #        proxy_set_header    X-Real-IP $remote_addr;
        #        proxy_set_header    X-Forwarded-Proto https;
        #        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        #        proxy_redirect      http:// https://;
        #       proxy_pass          http://SRVSIBKP/afvp;
        #}
# === LA configuration de secours est prête, il suffira d’inverser les commentaires ===
        #
        # Fin
        #

	####################################################################################
        # Redirection du Suivi des actions
        #
        ##########################

        location ^~ /plan {
                proxy_set_header    Host $host;
                proxy_set_header    X-Real-IP $remote_addr;
                proxy_set_header    X-Forwarded-Proto https;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_redirect      http:// https://;
                proxy_pass          http://SRVSIPROD;
        }

        # A décommenter si problème avec SRVSIPROD
        #location ^~ /plan {
        #        proxy_set_header    Host $host;
        #        proxy_set_header    X-Real-IP $remote_addr;
        #        proxy_set_header    X-Forwarded-Proto https;
        #        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        #        proxy_redirect      http:// https://;
        #        proxy_pass          http://SRVSIBKP;
        #}

        #
        # Fin
        #

	####################################################################################
        # Redirection du Suivi des demandes
        #
        ##########################

        location ^~ /task {
                proxy_set_header    Host $host;
                proxy_set_header    X-Real-IP $remote_addr;
                proxy_set_header    X-Forwarded-Proto https;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_redirect      http:// https://;
                proxy_pass          http://SRVSIPROD;
        }
        #location ^~ /task {
        #        proxy_set_header    Host $host;
        #        proxy_set_header    X-Real-IP $remote_addr;
        #        proxy_set_header    X-Forwarded-Proto https;
        #        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        #        proxy_redirect      http:// https://;
        #        proxy_pass          http://SRVSIBKP;
        #}

        #
        # Fin
        #

# === Configuration auto du certificat ===

    #listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/si.france-volontaires.org/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/si.france-volontaires.org/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}
…
````
Suite à la modification du fichier de configuration, il faut le vérifier :
````
sudo nginx –t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
````
Puis redémarrer le service s’il n’a pas d’erreur :
````
sudo systemctl reload nginx
````
Pour finir, on durcit la configuration (en cas de fichier non trouver, php recherche le fichier dont le nom est le plus proche !)
````
sudo vi /etc/php/7.0/fpm/php.ini
…
cgi.fix_pathinfo=0
…
sudo systemctl restart php7.0-fpm
````

b.	Copie des données entre SRVSIBKP et SRVRP
Sur SRVSIBKP, on créé une 1ère archive contenant le certificat :

````
admfv@SRVSIBKP:~$ sudo tar cvf letse.tar /etc/letsencrypt/
````
Puis on l’envoie sur SRVRP :
````
sudo scp letse.tar  admfv@120.121.2.102:/home/admfv/
````
Pour finir, on copie les fichiers du portail : 
````
sudo scp -r -p /var/www/html/* admfv@120.121.2.102:/home/admfv/site/
````
Au besoin, il faut saisir le mot de passe

4)	Vérification
Les 4 URL suivantes fonctionnent :
>	https://si.france-volontaires.org
>	https://si.france-volontaires.org/afvp
>	https://si.france-volontaires.org/plan
>	https://si.france-volontaires.org/task
Le certificat peut être testé depuis le lien suivant : https://www.ssllabs.com/ssltest/analyze.html?d=si.france-volontaires.org 

### 3 Mise en production

1)	Les URL ont été configurer sur le portail le 05/04/2018, en remplacement des anciennes. 

2)	Les redirections sur le Sonicwall sont toujours en place, autrement dit, il est toujours possible depuis l’extérieur de se connecter sur les webapps en clair. De même, à l’intérieur du réseau, aucune règle n’empêche un utilisateur de se connecter directement aux serveurs avec les ports Tomcat usuels.

3)	Tâches :
a.	Couper l’accès au serveur SERVEUR07, en arrêtant le service TOMCAT ``sudo systemctl stop tomcat7.service``
b.	Réaliser une sauvegarde des SI (webapp+base) sur le serveur SERVEUR07 à l’aide du script prévu (veiller à renommer les dernieres sauvegardes base pour être sûr…)
c.	Copier la sauvegarde sur le serveur SRVSIPROD dans le dossier vide (!) */home/admfv/migration_data* à l’aide de la commande :
``scp -r /home/admfv/backup/files/* admfv@120.121.2.49:/home/admfv/``
d.	Restaurer la sauvegarde sur le serveur SRVSIPROD à l’aide du script de migration *migration.sh* : ``admfv@SRVSIPROD:~/Scripts$ sudo ./migration.sh``
e.	Changer l’adresse IP du serveur SRVSIPROD en modifiant le fichier */etc/networking/interfaces* pour indiquer l’adresse 120.121.2.39
f.	Arrêter le serveur SERVEUR07, SERVEUR06 et SRVSIPREPROD (l’ancien)
g.	Dans le fichier tomcat8.service, passer le flag *–Dcom.uniclick.fv.production* à true : ``admfv@SRVSIPROD:~/Scripts$ sudo nano /etc/systemd/system/tomcat8.service``
h.	Redémarrer le serveur SRVSIPROD
i.	Modifier les @IP dans le script *send_si_backup.sh* présent sur le serveur SRVSIPROD
j.	Modifier les IP des serveurs SRVSIBKP et SRVSIPREPROD (nouveau), puis redémarrer le service réseau. Pour la preprod, le faire dans un second temps en raison de l’hébergement d’applications supplémentaires.
k.	Vérifier le bon fonctionnement des serveurs

4)	Tâches annexes :
À la suite de la migration, il faudra s’assurer que seul les bases PostgreSQL des serveurs SRVSIBKP et SRVSIPREPROD puisse être utilisable à distance. Voir le point III/B/4)a.
IV.	Liens

https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-encrypt-tomcat-8-connections-with-apache-or-nginx-on-ubuntu-16-04

## V Les Sauvegardes

Un réplica de la VM va être mis en place.

VI.	Schéma de la nouvelle infrastructure et matrice des flux
![alt text](mdimages/fv18nginx.png)
