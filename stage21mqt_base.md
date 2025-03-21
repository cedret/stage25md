stage.md
http://cedrik.chez-alice.fr/portail/index.htm
# Regarder les emails
## A faire !!!!!!
---
## Progression du stage

### Semaine 1: Découverte
- Découverte site et infra
- Mise en place VMware pour reproduire maquette de l'existant
- Intégration des documents de mise en place su SI
- Début de construction de la maquette
- Difficultés des versions existantes et compatibles aujourd'hui.
- Exploration de Nginx comme reverse proxy

### Semaine 2: Finir maquette proche de l'existant
- Exercice sur vm: nginx + SSL certbot
Refaire TP ItConnect sur vm locale?
- Exercice sur vm locale: reverse proxy

Jour 3: refaire un reverse proxy avec ubuntu 16.04 pour tenter d'installer nginx et php-pfm proprement????
jour 4: apache 2 sur prod + host only sur réseau + let's encrypt + nomdedomaine ??
https://www.youtube.com/watch?v=dokcsaT9Q9k

 TOMCAT AUTHENTICATION COMPLETE à continuer
 
jour 5:


### Semaine 3: Ajouter le chiffrement
- Backup préalable des certificats
- renforcer les sécurités?
- Boîte mail IMG?
- promiscious vm workstation (espionnage flux réseau)

### Semaine 4: Tests de stabilité et réponse aux objectifs
- Commandes de chiffrement existantes sur les serveurs actuels
- Listes des modifications à effectuer
- Captures de proxy et serveur de backup en étape intermédiaire

### Semaine 5: Tests de remplacement de la solution existante

### Semaine 6:

### Semaine 7:

### Semaine 8:

## Démarche
### 1 - Infra: Construction
Mise en place d'une maquette avec vmware pour refaire le système actuel:
- 1 serveur prod (Ubuntu 16.04 LTS de 2017)
- 1 serveur reverse proxy nginx avec chiffrement vers l'extérieur

STGSIPROD      222.168.80.139   111.121.2.139
STGSIBKP       222.168.80.100   111.121.2.100
STGSIPREPROD   222.168.80.101   111.121.2.101
STGSIRVPX      222.168.80.102   111.121.2.102
GATEWAY        222.168.80.2     111.121.2.2
dns-nameservers 222.168.80.2    111.121.2.2
dns-search     FV.locale        FV.local

#### Le serveur de prod: Rôle et composants .39
Dell (R530)
##### Ubuntu 16.04.3 LTS - 2018 -
> Config réseau
> postgresql 9.5
> openjdk 7 (JVM 1.7.0_95)
> polices microsoft
> Apache Tomcat 8.5.9
##### Ubuntu 20.04.x LTS - 2025 -
> Config réseau Netplan (Yaml)


##### Ubuntu 24.04.x LTS - 2025 -
> Config réseau



#### Le serveur reverse proxy: Rôle et composants .102
> Config réseau

> Nginx reverse proxy
> PHP
> Certbot

#### Le serveur de préprod: Rôle et composants (VM) .101
> Ubuntu 16.04.3 LTS
> Config réseau
> ~~Apache Tomcat 8.5.9~~
> postgresql 9.5
> openjdk 7 (JVM 1.7.0_95)
> polices microsoft


#### Le serveur de backup:  Rôle et composants (VM) .100



### 2 - Objectif du stage:
- Installer un chiffrement vers l'intérieur entre serveur prod et serveur reverse proxy
- Avec IpSec?
- Avec tunnel ssh?
Certificat (PKI, très sensible) ou mot de passe (Plus fiable)
- Service  Système d'information Métier
https://si.france-volontaires.org/afvp/login.html
- Service suivi des demandes
https://si.france-volontaires.org/task/

Sources d'information:
- Procédures d'exploitation SI

### 3 - Mise en oeuvre
Installation d'une maquette identique à l'existant avec VMware
Si Ubuntu 16.04 LTS est encore disponible, des difficultés sont rencontrées pour ajouter les composants:
openjdk7, postrsql 9.5, microsoft fonts

Construction:

Arborescence
> /opt/tomcat8/      <‐ Dossier d’installation de Tomcat 
> /opt/tomcat8/webapps/    <‐ Dossier d’installation des applications Web 
> /usr/local/documents_si    <‐ Dossier de l’application Web afvp 
> /home/admfv/Scripts    <‐ Dossier contenant les scripts de sauvegarde 
> /home/admfv/backup    <‐ Dossier contenant le log de sauvegarde 
> /home/admfv/backup/files    <‐ Dossier contenant les fichiers de sauvegarde 
> /home/admfv/backup    <‐ Dossier contenant le log de sauvegarde 
> /var/lib/postgres      <‐ Dossier contenant le SGBDR

#### Reproduction/ Evolutions
Ubuntu 16.04 LTS n'est plus supporté depuis avril 2021
Ubuntu 16.04 utilise Python 2, qui n'est plus supporté par Certbot?

### 4 - Evolution à court terme:
- Virtualisation
- Conteneurisation

### 5 - Exploration à prévoir

#### Trello ou autre?

#### Informations sur clé de sécurité (https)

### 6 - Etapes

- stage01evol.md
- stage12prtq.md
- stage22ref_si.md

> Sublime text
> Moba Xterm
> Vs Code?

### 7 - Compléments ou annexes

**récupérer script benrider**
Copier coller kali propre ??

## Bonus
---
*nslookup pour vérifier si ip utlisée sur le réseau.*
CGTMJJK8c8
do4aDx9
pjfnjcac*
---
## Liens et infos

\\Srvnas\administration_finances\SI_ET_MOYGE\ADM_INFORMATIQUE\Adresse_IP_New.xlsx

\\srvnas\ADMINISTRATION_FINANCES\SI_ET_MOYGE\ADM_INFORMATIQUE\Documentations\Procédures Exploitation\SI

\\Srvnas\administration_finances\SI_ET_MOYGE\ADM_INFORMATIQUE\Logiciel d'installation

#### Nginx reverse proxy TOP

#### Informations sur services
https://nginx.org/en/
https://blog.containerize.com/how-to-setup-and-configure-nginx-as-reverse-proxy/
https://www.lecoindunet.com/difference-apt-update-upgrade-full-upgrade

https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/
https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-as-a-reverse-proxy-on-ubuntu-22-04
https://nginxtutorials.com/nginx-reverse-proxy/
https://www.hostinger.com/tutorials/how-to-set-up-nginx-reverse-proxy/
https://thesmartbug.com/blog/how-to-configure-nginx-as-reverse-proxy-with-tls/
https://medium.com/@m.fareed607/how-to-set-up-an-nginx-reverse-proxy-server-and-enable-https-with-certbot-bbab9feb6338
````
sudo apt update
sudo apt install nginx
sudo nano /etc/nginx/sites-available/my-reverse-proxy.conf


````
add
````
server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    server_name example.com;
````

and
````
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    location / {
        proxy_pass http://backend-server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
````

and
````
sudo apt update
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d example.com
sudo nginx -t
````
and
````
#Below Command only reloads the nginx configuration file
sudo systemctl reload nginx 
#or to start the whole nginx server
sudo systemctl restart nginx
````

and
````
`test
````
and
````
`test
````
and
````
`test
````
https://linuxize.com/post/nginx-reverse-proxy/
https://phoenixnap.com/kb/nginx-reverse-proxy
https://www.redelijkheid.com/blog/2017/1/29/configure-nginx-as-a-secure-reverse-proxy
https://www.vodien.com/learn/a-guide-on-configuring-nginx-reverse-proxy/
https://www.freecodecamp.org/news/docker-nginx-letsencrypt-easy-secure-reverse-proxy-40165ba3aee2/


#### Nginx reverse proxy BOF
https://go.lightnode.com/tech/how-to-configure-nginx-reverse-proxy
https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/How-to-setup-Nginx-reverse-proxy-servers-by-example

#### IPsec or SSL tunnel
https://www.cloudflare.com/fr-fr/learning/network-layer/ipsec-vs-ssl-vpn/
https://www.techtarget.com/searchsecurity/tip/IPSec-VPN-vs-SSL-VPN-Comparing-respective-VPN-security-risks
https://www.geeksforgeeks.org/difference-between-ipsec-and-ssl/


#### Archives FV 2017 
https://itx‐technologies.com/fr/blog/2259‐executer‐un‐script‐recurrent‐avec‐cron‐exemples‐sous‐linux
http://www.quennec.fr/trucs‐astuces/syst%C3%A8mes/gnulinux/utilisation/connexion‐%C3%A0‐une‐machine‐distante‐ssh‐scp‐sftp‐sans‐saisir‐le‐mot‐de‐passe 
https://techarea.fr/tuto‐ssh‐cle‐nas‐synology/
https://releases.ubuntu.com/xenial/?_ga=2.222723923.973636296.1741702081-761716020.1741702081

#### Divers
https://www.alsacreations.com/astuce/lire/1932-Mermaid--diagrammes-schemas-et-graphiques-dans-markdown.html

https://chromewebstore.google.com/detail/markdown-reader/medapdbncneneejhbgcjceippjlfkmkg

https://www.it-connect.fr/chapitres/nmap-pourquoi-utiliser-cet-outil/

https://sysreseau.net/nmap-les-12-commandes-que-vous-devez-connaitre/

https://www.cyberly.org/en/how-do-you-use-nmap-to-detect-a-router-or-gateway/index.html

https://linuxize.com/post/how-to-add-apt-repository-in-ubuntu/


OPP2016  NP4GX-KCBYD-77BGG-BDQ29-8QKYB

