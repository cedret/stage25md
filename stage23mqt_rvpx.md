stage23evol_rvpx

## 1 Exercice avec
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



## Exploration config FV

### Configuration des serveurs

STGSIPROD      192.168.80.39
STGSIBKP       192.168.80.100
STGSIPREPROD   192.168.80.101
STGSIRVPX      192.168.80.102

### Aide 01
https://geekrewind.com/how-to-install-certbot-on-ubuntu-linux/

### Application de la préocédure d'Aurélien sur Ubuntu server 16.04.3 LTS
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

Test avec srv20: nginx 1.10???
php 7.4 ????

## Passage sur Ubuntu 20 Ubuntu server 20.04.3 LTS -2025- Procédure Aurélien

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

### Installation des applications

1. script de versions

2. postgresql par défaut: (10)

3. Nginx 1.18
``sudo apt install nginx-full``

4. php-pfm: ok v 7.4.3
``sudo apt install php-fpm``

5. Cerbot: 0.40.0
``sudo apt install certbot python3-certbot-nginx``
