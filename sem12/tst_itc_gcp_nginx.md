Serveurs NGinx /ITconnect

Partie 1
https://www.youtube.com/watch?v=gZ6uwd2ki4s
https://www.it-connect.fr/debian-comment-installer-nginx-en-tant-que-serveur-web/

Partie 2
https://www.it-connect.fr/configurer-nginx-en-tant-que-reverse-proxy/

## Partie 1

Sur GCP avec debian 11

hote: nginx.cedret
````
sudo apt update -y
sudo apt upgrade -y
sudo apt install nginx -y
sudo nginx -v
sudo systemctl status nginx
````

#### Site visible depuis 127.0.0.1 ou depuis ip publique en http:
````
cedret3@nginx:~$ cd /var/www/html/
cedret3@nginx:/var/www/html$ ls 
index.nginx-debian.html
````

#### Contenu site par défaut
``cedret3@nginx:/var/www/html$ cat index.nginx-debian.html``
````
<!DOCTYPE html>
<html>
<head>
<title>Installer nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
````
#### Aiguillage site par défaut
``cedret3@nginx:/var/www/html$ sudo nano /etc/nginx/sites-enabled/default ``

#### Fichier de configuration globale
``sudo nano /etc/nginx/nginx.conf``

avec même utilisateur *www-data* que apache2
````
cedret3@nginx:/var/www/html$ ls -al /etc/nginx/
total 72
drwxr-xr-x  8 root root 4096 Mar 17 10:55 .
drwxr-xr-x 75 root root 4096 Mar 17 10:54 ..
.....
drwxr-xr-x  2 root root 4096 Mar 17 10:33 sites-available
drwxr-xr-x  2 root root 4096 Mar 17 10:50 sites-enabled
.....
````
#### Pour les sites en création
``drwxr-xr-x  2 root root 4096 Mar 17 10:33 sites-available``

#### Pour les sites en diffusion
``drwxr-xr-x  2 root root 4096 Mar 17 10:50 sites-enabled``

#### Création d'un nouveau site
````
cedret3@nginx:/$ sudo mkdir /var/www/sitest.org
cedret3@nginx:/$ sudo chown -R www-data:www-data /var/www/sitest.org/
cedret3@nginx:/$ sudo chmod 755 /var/www/sitest.org/
cedret3@nginx:/$ sudo nano /var/www/sitest.org/index.html
cedret3@nginx:/$ cat /var/www/sitest.org/index.html
````
````
<!DOCTYPE html>
<html>
<head></head>
<body>

<h1>My First Heading</h1>
<p>My first paragraph.</p>

</body>
</html>
````

cedret3@nginx:/$ sudo nano /etc/nginx/sites-available/sitest.org
cedret3@nginx:/$ cat /etc/nginx/sites-available/sitest.org
````
server {

    listen 80;
    listen [::]:80;

    root /var/www/sitest.org;

    index index.html;
    server_name sitest.org www.sitest.org;

    location / {
        try_files $uri $uri/ =404;
    }
}
````
#### Création du lien symbolique
````
cedret3@nginx:/$ sudo ln -s /etc/nginx/sites-available/sitest.org /etc/nginx/sites-enabled/sitest.org
cedret3@nginx:/$ ls -l /etc/nginx/sites-enabled/
total 0
lrwxrwxrwx 1 root root 34 Mar 17 10:33 default -> /etc/nginx/sites-available/default
lrwxrwxrwx 1 root root 37 Mar 17 11:21 sitest.org -> /etc/nginx/sites-available/sitest.org
````
#### Vérification des fichiers des sites
````
cedret3@nginx:/$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
cedret3@nginx:/$ sudo systemctl restart nginx
````
#### Pour contourner l'absence de nom de domaine pour l'exercice:   
cedret3@nginx:/$ sudo nano /etc/hosts
cedret3@nginx:/$ cat /etc/hosts
````
127.0.0.1       localhost
0.0.0.0 sitest.org www.sitest.org
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

10.200.0.13 nginx.cedret nginx  # Added by Google
169.254.169.254 metadata.google.internal  # Added by Google
````
#### Vérifier sitest.org depuis un navigateur de la même vm...

#### Vérifier les logs de connexion
````
cedret3@nginx:/$ sudo tail -f /var/log/nginx/access.log 
94.247.164.57 - - [17/Mar/2025:10:48:40 +0000] "GET / HTTP/1.1" 200 399 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0"
````
#### Vérifier les logs d'erreur (debuggage)
````
cedret3@nginx:/$ sudo tail -f /var/log/nginx/error.log 
2025/03/17 10:33:57 [notice] 4059#4059: using inherited sockets from "6;7;"
````
### Ajout PHP

#### Ajouts de clé GPG du dépôt utilisé et paquets
````
cedret3@nginx:/$ sudo apt -y install lsb-release apt-transport-https ca-certificates 
Reading package lists... Done

cedret3@nginx:/$ sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
--2025-03-17 11:41:22--  https://packages.sury.org/php/apt.gpg

cedret3@nginx:/$ echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
deb https://packages.sury.org/php/ bullseye main
cedret3@nginx:/$ sudo apt update
Hit:1 https://deb.debian.org/debian bullseye InRelease
````
#### Installation php7.4-fpm
Pour communication entre nginx et moteur php
````
cedret3@nginx:/$ sudo apt install php7.4-fpm
Reading package lists... Done
....
edret3@nginx:/$ sudo nano /etc/nginx/sites-enabled/sitest.org 
cedret3@nginx:/$ cat /etc/nginx/sites-enabled/sitest.org
````
````
server {

    listen 80;
    listen [::]:80;

    root /var/www/sitest.org;

    index index.html;
    server_name sitest.org www.sitest.org;

    location / {
        try_files $uri $uri/ =404;
    }
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        }
}
````
````
cedret3@nginx:/$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
cedret3@nginx:/$ sudo systemctl restart nginx
cedret3@nginx:/$ sudo nano /var/www/sitest.org/info.php
cedret3@nginx:/$ cat /var/www/sitest.org/info.php
````
````
<?php
phpinfo();
?>
````
#### Vérifier à l'adresse du site le retour de info.php
Echec avec vm GCP sur IP publique ,pourquoi?????

### Ajout d'un certificat SSL
````
cedret3@nginx:/$ sudo apt install certbot python3-certbot-nginx
....
Reading package lists... Done

cedret3@nginx:/$ sudo certbot --nginx -d www.sitest.org
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): c
An e-mail address or --register-unsafely-without-email must be provided.
````
NON APPLIQUE !!

### SI OK, voir changements dans:
``cedret3@nginx:/$ sudo nano /etc/nginx/sites-available/sitest.org``

### Vérifier si renouvelement automatique du certificat
``cedret3@nginx:/$ sudo nano /etc/cron.d/certbot``

### Test de renouvlement de certificat (inactif car non valisé plus tôt)
``cedret3@nginx:/$ sudo certbot renew --dry-run``
````
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
No simulated renewals were attempted.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
````
### Complément sécurité
Pour éviter d'afficher le numéro de version de serveur Nginx
````
cedret3@nginx:/$ sudo nano /etc/nginx/nginx.conf 
cedret3@nginx:/$ cat /etc/nginx/nginx.conf
````
Changer
``         server_tokens off;``
## Partie 2: reverse proxy

Un reverse proxy sous Nginx, qui dispose d'une interface réseau avec l'adresse IP "192.168.1.3" et d'une interface réseau avec l'adresse IP "192.168.56.101"

Deux serveurs web Apache2 sous Debian avec les adresses 192.168.56.102 et 192.168.56.103 qui hébergent respectivement "monsite1.com" et "monsite2.com". Dans le cadre d'un RP, on peut appeler ces serveurs les "proxied server"