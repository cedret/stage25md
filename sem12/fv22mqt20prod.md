stage12exp_prod

## SOS commandes
````
lsb_release -a
cat /etc/os-release
echo $PATH
cat /etc/passwd
cat /etc/passwd | wc -l
awk -F':' '{ print $1}' /etc/passwd
getent passwd
grep -E '^UID_MIN|^UID_MAX' /etc/login.defs
````
https://endoflife.date/tomcat

## Création maquettes

┌──(stage㉿kali01)-[~]
└─$ nmap -sP 111.111.2.0/24
pour vérifier occupation/ disponibilité des IP

Des adresses restent disponibles entre 215 et 219 pour monter la maquette en bridge, si besoin.

Connexion en ssh sur 192.168.80.128 pour modifier IP fixe
En NAT avec vmware, on obtient:
````
stage@u16prod:~$ cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

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
        dns-search FV.local
CTRL<o|x>

stage@u16prod:~$ sudo service networking start
````
### Installer JVM

Galère avec la commande car
stage@srv20test:~$ sudo apt search jdk
**test si ok** avec
sudo add-apt-repository ppa:jonathonf/ffmpeg-4

*sudo apt install software-properties-common*

*sudo add‐apt‐repository ppa:openjdk‐r/ppa 
sudo apt‐get update 
sudo apt‐get install openjdk‐7‐jdk*

remplacé par?
sudo apt-get install openjdk-8-jre

### Installer Postgresql
https://www.postgresql.org/download/linux/ubuntu/

*sudo apt‐get install postgresql‐9.5*
*apt install postgresql*
Aujourd'hui v12 minimum
https://computingforgeeks.com/install-postgresql-12-on-ubuntu/
*sudo apt install postgresql-12*11


### Polices microsoft - VOIR PLUS TARD ? -
*sudo apt‐get ‐y install ttf‐mscorefonts‐installer*

### Installation Tomcat

````
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat‐8/v8.5.9/bin/apache‐tomcat‐8.5.9.tar.gz
sudo mkdir /opt/tomcat8
sudo tar xvfz apache‐tomcat‐8.5.9.tar.gz ‐C /opt/tomcat8  ‐‐strip‐components=1 
````
remplacer par
````
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz
sudo mkdir /opt/tomcat8
sudo tar xvfz apache-tomcat-8.5.50.tar.gz -C /opt/tomcat8/ --strip-components=1
sudo groupadd tomcat8
sudo useradd -s /bin/false -g tomcat8 -d /opt/tomcat8 tomcat8
````
Attention aux tirets longs (U+2010 ou U+2011) au lieu des tirets courts (-, U+002D)!!!!
Vérifications: Utilisateur, groupe, puis répertoire.
````
stage@u16prod:/tmp$ cat /etc/passwd | grep tomcat8
tomcat8:x:1001:1001::/opt/tomcat8:/bin/false

stage@u16prod:/tmp$ cat /etc/group | grep tomcat8
tomcat8:x:1001:

stage@u16prod:/tmp$ ls -ld /opt/tomcat8
drwxr-xr-x 9 root root 4096 mars  13 13:10 /opt/tomcat8
````
Propriétaire, permissions et fichier de service
````
cd /opt
stage@u16prod:/opt$ sudo chown -R tomcat8:tomcat8 tomcat8/
stage@u16prod:/opt$ sudo chmod -R 755 tomcat8/
stage@u16prod:/opt$ sudo nano /etc/systemd/system/tomcat8.service
````

Fichier de service corrigé (2025/03)
````
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
PIDFile=/opt/tomcat8/temp/tomcat.pid
Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat8/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat8
Environment=CATALINA_BASE=/opt/tomcat8
Environment='CATALINA_OPTS=-Xmx8G -Xms4G -XX:PermSize=512m -XX:MaxPermSize=512m \
-XX:NewSize=256m -server -XX:+UseParallelGC -Dcom.uniclick.fv.production=false'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat8/bin/startup.sh
ExecStop=/opt/tomcat8/bin/shutdown.sh

User=tomcat8
Group=tomcat8
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

````
Test du service:
````
stage@u16prod:/opt$ systemctl daemon-reload
==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ===
Authentification requise pour recharger l'état de systemd
Authenticating as: stage,,, (stage)
Password:
==== AUTHENTICATION COMPLETE ===
stage@u16prod:/opt$ sudo systemctl start tomcat8
stage@u16prod:/opt$ sudo systemctl status tomcat8
● tomcat8.service
   Loaded: loaded (/etc/systemd/system/tomcat8.service; disabled; vendor preset: enabled)
   Active: active (running) since jeu. 2025-03-13 13:44:57 CET; 17s ago
  Process: 6759 ExecStart=/opt/tomcat8/bin/startup.sh (code=exited, status=0/SUCCESS)
 Main PID: 6770 (java)
    Tasks: 45
   Memory: 127.4M
      CPU: 2.538s
   CGroup: /system.slice/tomcat8.service
           └─6770 /usr/lib/jvm/java-1.8.0-openjdk-amd64/bin/java -Djava.util.logging.config.file=/opt/tomcat8/conf/logging.properties -Djava.

mars 13 13:44:57 u16prod systemd[1]: tomcat8.service: Service hold-off time over, scheduling restart.
mars 13 13:44:57 u16prod systemd[1]: Stopped tomcat8.service.
mars 13 13:44:57 u16prod systemd[1]: Starting tomcat8.service...
mars 13 13:44:57 u16prod startup.sh[6759]: Existing PID file found during start.
mars 13 13:44:57 u16prod startup.sh[6759]: Removing/clearing stale PID file.
mars 13 13:44:57 u16prod systemd[1]: Started tomcat8.service.
mars 13 13:45:03 u16prod systemd[1]: Started tomcat8.service.
stage@u16prod:/opt$ sudo systemctl stop tomcat8
````
Démarrage automatique
````
stage@u16prod:/opt$ systemctl enable tomcat8
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-unit-files ===
Authentification requise pour gérer le service système ou ses fichiers unités.
Authenticating as: stage,,, (stage)
Password:
==== AUTHENTICATION COMPLETE ===
==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ===
Authentification requise pour recharger l'état de systemd
Authenticating as: stage,,, (stage)
Password:
==== AUTHENTICATION COMPLETE ===
````
Ouverture des ports

````
stage@u16prod:/opt$ sudo systemctl start tomcat8
stage@u16prod:/opt$ sudo netstat ‐tulpn
Connexions Internet actives (sans serveurs)
Proto Recv-Q Send-Q Adresse locale          Adresse distante        Etat
tcp        0      0 192.168.80.39:ssh       192.168.80.1:54574      ESTABLISHED
tcp        0    200 192.168.80.39:ssh       192.168.80.1:56766      ESTABLISHED
````
## Vérifier les versions
https://www.geeksforgeeks.org/how-to-check-your-postgresql-version/
psql --version
postgres -V
nginx -v ou nginx -V
php -v


## Paramétrage des composants du serveur

## Passage sur Ubuntu 20:

### Modification de l'outil réseau: Netplan

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
### Modification host de Winwdows et de Linux pour contourner domain

#### Limitation à Apache seul comme serveur web (Tomcat évité pour tests)
https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-20-04
https://www.tech2tech.fr/installation-de-lamp-sur-ubuntu-20-04/
https://www.abonnel.fr/informatique/serveur/web-linux-apache/modifier-la-page-index-apache
````
sudo apt install apache2

sudo ufw app list
sudo ufw allow 'Apache'
sudo ufw allow "Apache Full"
sudo ufw status

sudo a2enmod ssl
sudo systemctl restart apache2

sudo systemctl status apache2
sudo systemctl enable apache2
hostname -I
````

#### Tests avec Lynx

PS C:\Windows\System32\drivers\etc> notepad hosts
# Added for stage
192.168.80.102 rp.test.fv
192.168.80.139 pr.test.fv

``ping rp.test.fv``

flush dns?