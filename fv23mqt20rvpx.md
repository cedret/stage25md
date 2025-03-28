fv23mqt20rvpx.md

# Reproduction reverse proxy minimaliste et ajout de chiffrement
Mars 2025 - Stage CP - IPREC

## I - Config FV/ Ubuntu 16

### Configuration des serveurs

STGSIPROD      192.168.80.39
STGSIBKP       192.168.80.100
STGSIPREPROD   192.168.80.101
STGSIRVPX      192.168.80.102

### Procédure SI d'Aurélien R. 

Ubuntu server 16.04.3 LTS
0. script de versions

1. postgresql par défaut: (10)

2. Nginx 1.10.3
``sudo apt install nginx-full``

3. php-pfm: ok v 7.0.33
``sudo apt install php-fpm``

4. Cerbot:
````
stage@STGRVPX:~$ sudo add-apt-repository ppa:certbot/certbot
[sudo] Mot de passe de stage:
 The PPA has been DEPRECATED.

To get up to date instructions on how to get certbot for your systems, please see https://certbot.eff.org/docs/install.html.
 Plus d’info:https://launchpad.net/~certbot/+archive/ubuntu/certbot
Appuyez sur [ENTRÉE] pour continuer ou Ctrl-C pour annuler l’ajout
Traceback (most recent call last):
  File "/usr/bin/add-apt-repository", line 143, in <module>
    sys.stdin.readline()
KeyboardInterrupt
````
sudo apt-get install python-certbot-nginx
à remplacer par
````
sudo apt update
sudo apt upgrade
sudo apt install certbot python3-certbot-nginx -y
````

## II - Config FV/ Ubuntu 20
Ubuntu server 20.04.3 LTS -2025- Procédure Aurélien

### A - Outil réseau: Netplan

https://www.golinuxcloud.com/etc-network-interfaces-missing-ubuntu/
https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-20-04/
https://www.cyberciti.biz/faq/ubuntu-20-04-lts-change-hostname-permanently/

``stage@srv20test:~$ ip link``

``stage@srv20test:~$ sudo nano /etc/netplan/01-netcfg.yaml``
``stage@srv20test:~$ cat /etc/netplan/01-netcfg.yaml``
````
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.80.101/24
      gateway4: 192.168.80.2
      nameservers:
          addresses: [192.168.80.2]
````

``stage@tst20prod:~$ sudo nano /etc/hosts``

````
stage@tst20prod:~$ cat /etc/hostname
tst20prod
stage@tst20prod:~$ hostnamectl
   Static hostname: tst20prod
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 85faa907a4a14a7ba13258231d0092fe
           Boot ID: a70fff6d8a4e4940b7e176dc20a610aa
    Virtualization: vmware
  Operating System: Ubuntu 20.04.6 LTS
            Kernel: Linux 5.4.0-208-generic
      Architecture: x86-64
stage@tst20prod:~$ sudo hostnamectl set-hostname tst20rvpx
````


``stage@srv20test:~$ sudo netplan apply``
**CHANGEMENT D'IP**
````
stage@srv20test:~$ ip addr show dev ens33
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:31:15:69 brd ff:ff:ff:ff:ff:ff
    inet 192.168.80.101/24 brd 192.168.80.255 scope global ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe31:1569/64 scope link
       valid_lft forever preferred_lft forever
````
### B - Config rvpx selon LLTV (proxy direct)  - NEGATIF -
https://www.youtube.com/watch?v=B62QSbPhh1s
https://medium.com/adrixus/beginners-guide-to-nginx-configuration-files-527fcd6d5efd

1. Clé facultative ?
````
stage@tst20rvpx:~$ wget http://nginx.org/keys/nginx_signing.key
stage@tst20rvpx:~$ sudo apt-key add nginx_signing.key
stage@tst20rvpx:~$ sudo nano /etc/apt/sources.list.d/nginx.list
stage@tst20rvpx:~$ cat /etc/apt/sources.list.d/nginx.list
deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ focal nginx
````
````
stage@tst20rvpx:~$ sudo apt update
stage@tst20rvpx:~$ sudo apt install nginx
stage@tst20rvpx:~$ systemctl status nginx
stage@tst20rvpx:~$ systemctl enable nginx
````
**Vérifier avec l'IP du rvpx depuis un navigateur** http://192.168.80.102/
Il peut-être nécessaire de modifier le fichier host de poste client pour atteindre par le "domaine privé":
*rp.test.fv*
````
stage@tst20rvpx:~$ cd /etc/nginx/conf.d/
stage@tst20rvpx:~$ mv default.conf default.disable
stage@tst20rvpx:~$ sudo nano prod.conf
stage@tst20rvpx:~$ cat /etc/nginx/conf.d/prod.conf
````
2. Pour une application disponible par localhost
````
server {
    listen 80;
    listen [::]:80;
    server_name 192.168.80.139;
    location / {
        proxy_pass http://localhost:3000/;
     }
}
````
````
stage@tst20rvpx:~$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
stage@tst20rvpx:~$ sudo nginx -s reload
````
**FIN DE L'ETAPE**

3. Pour une application disponible par autre serveur ???
Selon medium.com
````
server {
    listen 80 default_server;
    listen [::]:80 default_server; 
    root /var/www/html;  
    index index.html; 
    server_name _;  
    location / {
       try_files $uri $uri/ =404;
     }
}
````
Version pour FV
````
server {
        listen 80 default_server;
        #listen [::]:80 default_server;
        server_name pr.test.fv;
        #return 301 https://$server_name$request_uri;
# Désactivation du service sur IPv6

…
        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.php index.html index.htm;

location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #return 301 https://$server_name$request_uri;
                try_files $uri $uri/ =404;
        }

        location ^~ /afvp {
                proxy_set_header    Host $host;
                proxy_set_header    X-Real-IP $remote_addr;
                proxy_set_header    X-Forwarded-Proto https;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_redirect      http:// https://;
                proxy_pass          http://SRVSIPROD;
        }
````
### C - Config rvpx selon C.McK et C.G - POSITIF -

1. Sur le reverse proxy
https://www.youtube.com/watch?v=7jNhZrtckhA

Vérifier serveur source avec ``curl http://192.168.80.139``

Modifier dans *etc/nginx/sites-available* avec ``sudo nano default`` ou autre fichier de configuration si plusieurs sites.

``stage@tst20rvpx:~$ sudo nano /etc/nginx/sites-available/default``

A TESTER
```` 
        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }
        location /prod {
          proxy_pass          http://192.168.80.139:80;
#          proxy_pass          http://pr.test.fv;
          proxy_set_header    Host $host;
          proxy_set_header    X-Real-IP $remote_addr;
          proxy_set_header    X-Forwarded-Host $host;
          proxy_set_header    X-Forwarded-Port $server_port;
        }
````
ou
**FIABLE**
````
        server_name rp.test.fv;

#       location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
#               try_files $uri $uri/ =404;
#       }
        location / {
                proxy_pass http://192.168.80.139:80;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
        }
````
>Pour forcer en https:
>````
>server {
>    listen 80;
>    server_name rp.test.fv;
>
>    return 301 https://$host$request_uri;
>}
>````

``sudo nginx -t``
````
stage@tst20rvpx:~$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

stage@tst20rvpx:~$ ls -al /etc/nginx/sites-enabled/
total 8
drwxr-xr-x 2 root root 4096 mars  21 13:53 .
drwxr-xr-x 8 root root 4096 mars  21 13:53 ..
lrwxrwxrwx 1 root root   34 mars  21 13:53 default -> /etc/nginx/sites-available/default
````
>A ajouter si besoin???
>``sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/``

``sudo systemctl restart nginx``

Et consulter l'url ``rp.test.fv``

**RESULTAT OK ????**
