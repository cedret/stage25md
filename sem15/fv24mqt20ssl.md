
## Création de chiffrement

-20250324-

| Mac dest.| Mac src. | IP dest. | IP src.| port dest.| port src.|SEQ |ACK | |
|--|--|--|
|AF-04-...|11-B3-...|4.8.0.3|1.1.3.7|443|4000|8|26|Message TLS|

### Procédure 1 POSITIF ??

---
cg
## I - NGINX avec un certificat auto-signé

### A - Sur le reverse proxy
1. Générer le certificat SSL auto-signé
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt
```
Informations impératives, ou pas:
- Pays, organisation, etc.
- Pour `Common Name (CN)`, mettre nom de domaine (`rp.test.fv`) ou l'IP du rvpx!

2. (Facultatif mais recommandé) Générer des paramètres Diffie-Hellman
```bash
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

3.  Créer ou modifier le fichier de configuration NGINX dans
*/etc/nginx/sites-available/default*

```nginx
server {
    listen 80;
    server_rp.test.fv;

    # Redirection HTTP -> HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_rp.test.fv;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
# Activr selon Diffie-Hellman précédent ou pas?
#    ssl_dhparam /etc/ssl/certs/dhparam.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Reverse proxy vers Apache
    location / {
        proxy_pass http://192.168.80.139:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
>BLOCAGE``stage@tst20rvpx:~$ sudo nginx -t`` selon Diffie-Hellman
>nginx: [emerg] BIO_new_file("/etc/ssl/certs/dhparam.pem") failed
> (SSL: error:02001002:system library:fopen:No such file or directory:fopen('/etc/ssl/>certs/dhparam.pem','r')
> error:2006D080:BIO routines:BIO_new_file:no such file)
>nginx: configuration file /etc/nginx/nginx.conf test failed

4. Relancer NGINX
```bash
sudo nginx -t && sudo systemctl reload nginx
```

5. Test de connexion
Dans un navigateur, apparaît une **alerte de sécurité** (car le certificat n’est pas reconnu comme "fiable"):
- L’accepter temporairement pour tester.
- Ou l’importer manuellement comme "certificat approuvé" dans l'OS pour ne plus voir l’avertissement (utile en intranet).

### B - Sur le backend (prod)
https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04-fr

https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04-fr
https://syskb.com/installer-certificat-ssl-apache-2-debian-ubuntu/
https://www.certificat-ssl.info/tutoriels/installer-certificat-ssl-apache-2-debian-ubuntu
https://www.howtogeek.com/devops/how-to-create-and-use-self-signed-ssl-on-apache/

#### openssl
https://www.geeksforgeeks.org/how-to-install-an-ssl-certificate-on-apache/
https://www.it-connect.fr/configurer-le-ssl-avec-apache-2%EF%BB%BF/

>Si besoin d'ajouter HTS?
````
a2enmod headers
sudo systemctl restart apache2
sudo a2enmod ssl
sudo ufw allow "Apache Full"
sudo mkdir -p /etc/ssl/prod
cd /etc/ssl/prod
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout prod.key \
-out prod.crt
````
**Où l'on rentre l'IP du backend!!!!!**

``sudo nano /etc/apache2/sites-available/prod_ssl.conf``
#### Création du VirtualHost
Par défaut?
````
<VirtualHost *:443>
   ServerName 192.168.80.139
# ServerName pr.test.fv

# ???
   DocumentRoot /var/www/pr.test.fv

   SSLEngine on
   SSLCertificateFile /etc/ssl/prod/prod.crt
   SSLCertificateKeyFile /etc/ssl/prod/prod.key
</VirtualHost>
````
ou fiable
````
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName 192.168.80.139  # ou prod.local

    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /etc/ssl/prod/prod.crt
    SSLCertificateKeyFile /etc/ssl/prod/prod.key

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
````

#### Activation ssl
``sudo a2ensite prod_ssl.conf``
``sudo systemctl restart apache2``

#### Tester
``curl -k https://192.168.80.139:443``

>Création de l'index.html pour test?
>``sudo mkdir /var/www/your_domain_or_ip``

#### Vérifier/ modifier côté Nginx
``sudo nano /etc/nginx/sites-available/default ``
````
location / {
    proxy_pass https://192.168.80.139:443;
    proxy_ssl_verify off;  # car cert self-signed
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
````

``curl -k https://rp.test.fv`` ou avec IP


## II - Promiscuous_mode
https://www.youtube.com/watch?v=OT-QNHL7KOw
https://en.wikipedia.org/wiki/Promiscuous_mode
https://techantidote.com/promiscuous-mode-vmware-workstation/
https://exchangetimes.net/?p=762
https://www.malekal.com/quest-ce-que-promiscuous-mode-mode-de-promiscuite/
https://knowledge.broadcom.com/external/article/315331/using-virtual-ethernet-adapters-in-pomis.html
https://www.quora.com/How-do-you-enable-promiscuous-mode-in-Linux
http://shaarli.guiguishow.info/?uTSqHg

### Procédure 1
https://superuser.com/questions/1209497/how-do-you-enable-promiscuous-mode-in-vmware-workstation

Shut down the VMWare host. Locate the VMX file associated with it. Edit the file and locate the Ethernet section. Add a new entry for each Ethernet you want to be in promiscuous mode:

``ethernet%d.noPromisc = "FALSE"`` (replace %d with the ethernet number)
Start the machine and the interface will now operate in promiscuous mode.

### Procédure 2 (suite1)
https://techantidote.com/promiscuous-mode-vmware-workstation/

Below are the steps to enable promiscuous mode for a VM in Vmware Workstation.
Shutdown the VM and edit the .vmx file. This is in the directory where your VM’s hard disks were configured to be sure.
``vim /home/extr3me/vmware/pfsense/pfsense.vmx``
Tip:

You can right click on the VM and select option “Open VM Directory” that will take you to the directory where the .vmx file is located.

Add the below line to the file: ``ethernet0.noPromisc = "FALSE"``

-If you have multiple interfaces, then add another line and replace the value 0 with 1 etc. Below is an example for two interfaces:

``ethernet0.noPromisc = "FALSE"``
``ethernet1.noPromisc = "FALSE"``

### Procédure 3 (Ubuntu/Netplan)
https://forum.suricata.io/t/ubuntu-20-04-netplan-does-not-support-promiscuous-mode/830/2
Here is what I did with 18.04 which also uses netplan:
``rful011@secmonprd10:~$ cat /etc/netplan/01-netcfg.yaml``
**This file describes the network interfaces available on your system**
For more information, see netplan(5).
````
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      addresses: [ 130.216.x.yy/23 ]
      gateway4: 130.216.x.254
      nameservers:
          search: [ its.auckland.ac.nz, insec.auckland.ac.nz ]
          addresses: [130.216.190.1,130.216.191.1]
    enp5s0f1:
     addresses: [ ]
````
I had to fiddle something to get the interface “UP”
`` ifconfig enp5s0f1 up``
and that works on my 18.04 boxes

### Procédure 4 (Kali)
cg
````
┌──(stage㉿kali01)-[~]
└─$ sudo ip link set eth0 promisc on
[sudo] Mot de passe de stage : 
                                                                                                               
┌──(stage㉿kali01)-[~]
└─$ ip link show eth0
2: eth0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 00:0c:29:85:89:b6 brd ff:ff:ff:ff:ff:ff

┌──(stage㉿kali01)-[~]
└─$ sudo wireshark         
````
Filtrer avec Wireshark
``ip.addr == 192.168.80.102 && ip.addr==192.168.80.139`` ou ``tcp.port == 443``
ou avec tcdump
``sudo tcpdump -i eth0 host [IP_REVERSE_PROXY] and host [IP_BACKEND] and port 443 -w ssl_traffic.pcap``


---
---
## V - NGINX en reverse proxy avec HTTPS via Let's Encrypt et serveur Apache distant.

1. Utiliser **Certbot**, l'outil officiel recommandé par Let's Encrypt.

Sur Ubuntu/Debian :

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
```

2. Config NGINX (avant de lancer Certbot):

Créer ou modifier le fichier dans `/etc/nginx/sites-available/monsite` (ou `default`, avec un seul site) :

```nginx
server {
    listen 80;
    server_name rp.test.fv;

    location / {
        proxy_pass http://192.168.80.139:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/monsite /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```
Générer le certificat SSL avec Certbot

3. Certbot peut automatiquement configurer le HTTPS dans NGINX :

```bash
sudo certbot --nginx -d rp.test.fv
```

- Vérifier que le domaine pointe vers NGINX.
- Créer un certificat Let's Encrypt.
- Modifier le fichier NGINX pour ajouter la config HTTPS automatiquement.

4. Activer le renouvellement automatique

C’est normalement fait par défaut, tester avec :

```bash
sudo certbot renew --dry-run
```
5. Exemple final de config NGINX avec HTTPS (automatiquement généré)

```nginx
server {
    listen 80;
    server_name rp.test.fv;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name rp.test.fv;

    ssl_certificate /etc/letsencrypt/live/monsite.exemple.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/monsite.exemple.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://192.168.80.139:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## W Procédure 2

#### Succession des étapes
1. installer vm
2. ajout scripts
3. mises à jour, config réseau, installations applis
4. configuration sécurité

Cela crée un certificat (backend-cert.pem) et une clé privée (backend-key.pem) pour sécuriser la communication.

1. Installation des applications
``sudo apt update``

. Nginx 1.18
``sudo apt install nginx-full``

. php-pfm: ok v 7.4.3
``sudo apt install php-fpm``

. Cerbot: 0.40.0
``sudo apt install certbot python3-certbot-nginx``

2. Ajouter certificat SSL auto-signé sur le serveurs backend

``sudo apt-get install openssl``

``sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt``

La nouvelle clé privée RSA, utilisée pour signer le certificat est stockée dans */etc/ssl/private/nginx.key*.

Le certificat lui-même est stocké dans */etc/ssl/certs/nginx.crt* et est valable pour une année entière.

#### Autres versions
``openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/backend-key.pem -out /etc/ssl/certs/backend-cert.pem -days 365``

``sudo openssl req -x509 -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/backend-key.pem -out /etc/ssl/certs/backend-cert.pem``

3. OPTION: Générer un groupe Diffie-Hellman. ATTENTION durée importante?
Ceci est utilisé pour une parfaite confidentialité secrète, qui génère des clés de session éphémères pour garantir que les communications passées ne peuvent pas être déchiffrées si la clé de session est compromise.
Ce n'est pas entièrement nécessaire pour les communications internes, mais si vous voulez être aussi sécurisé que possible, vous ne devez pas ignorer cette étape.

``sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096``

4. Configurer Nginx pour utiliser votre clé privée et votre certificat SSL
Pour simplifier, nous allons mettre toute la configuration dans un **fichier d'extrait** que nous pouvons inclure dans *nginx server blocs*.

Créez un nouvel extrait de configuration dans *nginx snippets annuaire* puis coller le contenu qui suit

``touch /etc/nginx/snippets/self-signed.conf``

````
# Config Nginx certif auto-sign + clée privée
ssl_certificate /etc/ssl/certs/nginx.crt;
ssl_certificate_key /etc/ssl/private/nginx.key;

# Config paramètres SSL
ssl_protocols TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
ssl_session_timeout 10m;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";

# Option Diffie-Hellman
ssl_dhparam /etc/nginx/dhparam.pem;
ssl_ecdh_curve secp384r1;
````
> OPTION HTTP Strict Transport Security?

5. Modifier config nginx
Sites uniques dans: */etc/nginx/nginx.conf*
Sites multiples dans: */etc/nginx/sites-available*
> Ajouter
````
server {
    listen 443 ssl;
    listen (::):443 ssl;

    include snippets/self-signed.conf;

    server_name example.com www.example.com;
    . . .
}
````
> Pour redirection http vers https, ajouter
````
server {
    listen 80;
    listen (::):80;

    server_name example.com www.example.com;

    return 302 https://$server_name$request_uri;
}
````

Relancer Nginx
``sudo service nginx restart``


Étant donné que le trafic HTTPS utilise le port 443, vous devrez configurer vos pare-feu pour autoriser le transport sur ce port.
Si vous utilisez iptables ou UFW, modifier manuellement.

Après ces étapes d'autorisations, passer en *return 301*.
``return 301 https://$server_name$request_uri;``
``sudo service nginx restart``

## X Procédure 3
https://linuxtechlab.com/simple-guide-to-configure-nginx-reverse-proxy-with-ssl/

Simple guide to configure Nginx reverse proxy with SSL
A reverse proxy is a server that takes the requests made through web i.e. http & https, then sends them to backend server (or servers). A Backend server can be a single or group of application server like Tomcat, wildfly or Jenkins etc or it can even be another web server like Apache etc.

We have already discussed how we can configure a simple http reverse proxy with Nginx. In this tutorial, we will discuss how we can configure a Nginx reverse proxy with SSL. So let’s start with the procedure to configure Nginx reverse proxy with SSL,

Recommended Read : The (in)complete Guide To DOCKER FOR LINUX
https://linuxtechlab.com/the-incomplete-guide-to-docker-for-linux/

Also Read : Beginner’s guide to SELinux
https://linuxtechlab.com/beginners-guide-to-selinux/

Pre-requisites
- A backend server: For purpose of this tutorial we are using an tomcat server running on localhost at port 8080. If want to learn how to setup a apache tomcat server, please read this tutorial.
https://linuxtechlab.com/complete-guide-apache-tomcat-installation-linux/

Note:- Make sure that application server is up when you start proxying the requests.

- SSL cert : We would also need an SSL certificate to configure on the server. We can use let’s encrypt certificate, you can get one using the procedure mentioned HERE.
https://linuxtechlab.com/complete-guide-to-configure-ssl-on-nginx-with-lets-encrypt-ubuntu-centos-rhel/
 But for this tutorial, we will using a self signed certificates, which can be created by running the following command from terminal,

``$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/cert.key -out /etc/nginx/certs/cert.crt``

You can also read more about self signed certificates HERE.
https://linuxtechlab.com/create-ssl-certificate-apache-server/

Next step on configuring nginx reverse proxy with ssl will be nginx installation,

#### Install Nginx -Ubuntu-

Nginx is available with default Ubuntu Repositories. So simple install it using the following command,

``$ sudo apt-get update && sudo apt-get install nginx``

CentOS/RHEL:
We need to add some repos for installing nginx on CentOS & we have created a detailed ARTICLE HERE for nginx installation on CentOS/RHEL.
https://linuxtechlab.com/installing-nginx-server-configuring-virtual-hosts/


Now start the services & enable it for boot,

``# systemctl start nginx``

``# systemctl enable nginx``

Now to check the nginx installation, we can open web browser & enter the system ip as url to get a default nginx webpage, which confirms that nginx is working fine.

Configuring Nginx reverse proxy with SSL
Now we have all the things we need to configure nginx reverse proxy with ssl. We need to make configurations in nginx now, we will using the default nginx configuration file i.e. */etc/nginx/conf.d/default.conf*.

Assuming this is the first time we are making any changes to configuration, open the file & delete or comment all the old file content, then make the following entries into the file,

``# vi /etc/nginx/conf.d/default.conf``
````
server {
    listen 80;
    return 301 https://$host$request_uri;
    }

server {
    listen 443;
    server_name linuxtechlab.com;
    ssl_certificate /etc/nginx/ssl/cert.crt;
    ssl_certificate_key /etc/nginx/ssl/cert.key;
    ssl on;
    ssl_session_cache builtin:1000 shared:SSL:10m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;
    access_log /var/log/nginx/access.log;

        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_pass http://localhost:8080;
            proxy_read_timeout 90;
            proxy_redirect http://localhost:8080 https://linuxtechlab.com;
            }
}
````
Once all the changes have been made, save the file & exit. Now before we restart the nginx service to implement the changes made, we will discuss the configuration that we have made , section by section,

> Section 1
````
server {
    listen 80;
    return 301 https://$host$request_uri;
    }
````
here, we have told that we are to listen to any request made to port 80 & then redirect it to https,

> Section 2
````
    listen 443;
    server_name linuxtechlab.com;
    ssl_certificate /etc/nginx/ssl/cert.crt;
    ssl_certificate_key /etc/nginx/ssl/cert.key;
    ssl on;
    ssl_session_cache builtin:1000 shared:SSL:10m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;
````
Now these are some of the default nginx ssl options that we are using, which tells what kind of protocol version, SSL ciphers to support by nginx web server,

> Section 3
````
location / {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://localhost:8080;
    proxy_read_timeout 90;
    proxy_redirect http://localhost:8080 https://linuxtechlab.com;
    }
}
````

Now this section tells about proxy & where the incoming requests are sent once they come in. Now that we have discussed all the configurations, we will check & then restart the nginx service,

To check the nginx , run the following command,

``# nginx -t``

Once we have configuration file as OKAY, we will restart the nginx service,

``# systemctl restart nginx``

That’s it, our nginx reverse proxy with ssl is now ready. Now to test the setup, all you have to do is to open web browser & enter the URL.
We should now be redirected to the apache tomcat webpage.
This completes our tutorial on how we can configure nginx reverse proxy with ssl, please do send in any questions or queries regarding this tutorial using the comment box below.

---
---

Activation du site ????
``sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/``

Création du certificat
``sudo certbot --nginx -d rp.test.fv``

## Y - Annexes
### Exercice 250315 avec Ubuntu 16
https://thesmartbug.com/blog/how-to-configure-nginx-as-reverse-proxy-with-tls/

Ajout de ssh si manquant:
````
sudo apt install ssh
sudo systemctl enable sshd && sudo systemctl start ssh
systemctl status ssh.service
sudo nano /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo apt-get install openssh-server
sudo service ssh status

sudo nano /etc/ssh/sshd_config
sudo service ssh restart
````
Ajout de Nginx, vérification
````
sudo apt install nginx
sudo systemctl start nginx
stage@srv16rvpx:~$ sudo systemctl enable nginx
Synchronizing state of nginx.service with SysV init with /lib/systemd/systemd-sysv-install...
Executing /lib/systemd/systemd-sysv-install enable nginx

stage@srv16rvpx:~$ sudo systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since jeu. 2025-03-13 16:20:53 CET; 49min ago

sudo apt install certbot python3-certbot-nginx
sudo nano /etc/nginx/conf.d/nginx.conf

````
stage@u16prod:~$ cat /etc/network/interfaces
````
# This file describes the network interfaces available on your system and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto ens33
# iface ens33 inet dhcp
iface ens33 inet static
        address 192.168.80.39
        netmask 255.255.255.0
        network 192.168.80.0
        broadcast 192.168.80.255
        gateway 192.168.80.2
        dns-nameservers 192.168.80.2
        dns-search fv.local
CTRL<o|x>
````
``
stage@u16prod:~$ sudo service networking start
``

---
---

## Z Surplus
default config nginx self-signed
````
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        # SSL configuration
        #
        # listen 443 ssl default_server;
        # listen [::]:443 ssl default_server;
        #
        # Note: You should disable gzip for SSL traffic.
        # See: https://bugs.debian.org/773332
        #
        # Read up on ssl_ciphers to ensure a secure configuration.
        # See: https://bugs.debian.org/765782
        #
        # Self signed certs generated by the ssl-cert package
        # Don't use them in a production server!
        #
        # include snippets/snakeoil.conf;

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        server_name rp.test.fv;

        # Redirection HTTP -> HTTPS
        return 301 https://$host$request_uri;
        }

server {
        listen 443 ssl;
        server_rp.test.fv;

        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
        ssl_dhparam /etc/ssl/certs/dhparam.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

# Reverse proxy vers Apache
        location / {
                proxy_pass http://192.168.80.139:80;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }
        }
````