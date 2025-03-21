
https://www.youtube.com/watch?v=fpr37FJSgrw

ubuntu 24.04 LTS sur GCP

ssh root...
sudo adduser access
sudo usermod -aG sudo access
groups access
nano /etc/hostname
pour remplacer par le nom de domaine ex: nc.learnlinux.tv

nano /etc/hosts
127.0.1.1 nc.learnlinux.tv nc
pour ajouter ce domaine aussi

apt update && apt dist-upgrade

ping nc.learnlinux.tv nc

ssh access...

sudo wget https://download.nextcloud.com/server/releases/latest.zip

sudo apt install mariadb-server

systemctl status mariadb

sudo mysql_secure_installation
si pas de mot depasse mariadb, enter suffit

no unix socket authentication

change root password !!!!

remove anonymous user !!

disallow root login remotely !!!

remove database and access to it yes!!!

reload the privilege tables: yes !!!

## Création d'une database

sudo mariadb

CREATE DATABASE nextcloud;

SHOW DATABASES;

GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'mypassword';

FLUSH PRIVILEGES;

CTRL D

sudo apt install php php-acpu php-cli php-common php-gd php-curl php-zip php-xml php-mbstring php-intl php-bcmath php-gmp php-imagick php-mysql

sudo apt install apache ???

systemctl status apache2

## Depuis un navigateur, entrer l'IP ou l'url du site

sudo phpenmod bcmath gmp imagick intl

ls

sudo apt install unzip

command -v unzip

unzip latest.zip

ls
pour voir nextcloud

rm latest.zip

mv nextcloud nc.learnlinux.tv
ls

ls -lh

sudo chown www-data:www-data -R nc.learnlinux.tv/
ls -lh

sudo mv nc.learnlinux.tv /var/www

ls -l /var/www

sudo a2dissite 000-default

sudo nano /etc/apache2/sites-available/nc.learnlinux.tv.conf


````
<VirtualHost *:80>
	DocumentRoot "/var/www/nc.learnlinux.tv.conf"
	ServerName nc.learnlinux.tv.conf

	<Directory "/var/www/nc.learnlinux.tv.conf/">
		Options MultiViews FollowSymlinks
		AllowOverride All
		Order allow,deny
		Allow from all
	</Directory>

	TransferLog /var/log/apache2/nc.learnlinux.tv_access.log
	ErrorLog /var/log/apache2/nc.learnlinux.tv_error.log

</VirtualHost>
````
sudo a2ensite nc.learnlinux.tv.conf

sudo nano /etc/php/8.3/apache2/php.ini

memory_limit = 512 M

upload_max_filesize = 200M

max_execution_time = 360

post_max_size = 200M

date


23 minutes