Docs SI.md

````
Table des matières 
I.  Introduction .............................................................. 3 
II.  Objectifs ................................................................ 3 
III.  Plan de mise à jour ..................................................... 3 
1)  Séquence de mise à jour des plateformes ................................... 4
2)  Installation d’une plateforme ............................................. 6 
3)  Mise en production ........................................................ 12 
IV.  Les stratégies ........................................................... 13 
1)  Sauvegarde ................................................................ 13 
2)  Restauration .............................................................. 18 
V.  Liens : ................................................................... 20 
````
## I. Introduction 
Le Système d’Information de France Volontaires est constitué de 3 applications :
 - Système d’information Métier
 - le Suivi des actions
 - le Suivi des demandes. 

Ces applications sont hébergées sur une plateforme Linux Ubuntu constituée par :
 - 1 serveur de production
 - 1 serveur de secours
 - 1 serveur de pré‐production

Ces serveurs présentent des caractéristiques systèmes et applicatives différentes, différentes versions de système d’exploitations, différentes versions de bases de données, … 

##  II. Objectifs 
L’objectif est donc de fournir une plateforme homogène (système et applications serveurs) pour les 5 années à venir. Cette plateforme doit permettent d’évaluer:
- les nouvelles versions des applications
- le serveur de pré‐production,
- d’assurer une récupération après sinistre rapide du serveur de production vers le serveur de secours.

Voici les caractéristiques techniques retenues pour la mise en production :
- Système d’exploitation : Linux Ubuntu 16.04.3 LTS
- Serveur Apache Tomcat : 8.5.9
- Machine Virtuelle Java (JVM) : 1.7.0_95
- Base de données PostGreSQL : 9.5

Le serveur de production est une machine physique, les serveurs de pré‐production et secours sont des machines  virtuelles.
En  conséquence,  les  caractéristiques  physiques  (RAM,  CPU,  …)  ne  sont  pas identiques (en nombre de CPU et en quantité de RAM). 

## III. Plan de mise à jour 
Les différentes opérations de mises à jour interviennent sur le dernier trimestre 2017 avec une date  d’échéance à la fin de ce dernier trimestre. 
- Un serveur physique Dell PowerEdge R530 Server a été livré en juin 2017 et installé durant l’été 2017. Le  système  d’exploitation  est  à  jour  au  16/10/2017,  ainsi  que  les  logiciels  serveurs  (Apache 
Tomcat/JVM/PostGreSQL). Son rôle est de servir de serveur de production. 
- Une machine virtuelle disposant des caractéristiques systèmes et logiciels serveurs identique au futur serveur de production a été mise en place précédemment (à l’exception d’Apache Tomcat). Son rôle est de servir de serveur de pré‐production. 
- Le serveur de secours n’est pas installé (machine virtuelle).

## 1) Séquence de mise à jour des plateformes 
### 1) Le serveur de production est installé.
Il reste cependant à « downgrader » la version de JVM de 1.8 à 1.7. En effet, la principale application SI Métier est incompatible avec la version JVM 1.8. 
Deux options sont offertes, downgradé en JVM 1.7 ou assurer les modifications et les tests de l’application. La seconde option étant plus lourde (en temps, en coût), l’installation de la JVM en 1.7 est retenue. 
````
voir schema 1
````
### 2) Le serveur de pré‐production est installé.
Cependant, pour des raisons de commodités, l’ancien serveur va évoluer et ne plus servir à la pré production. A la place, une copie de la machine virtuelle hébergeant le serveur de secours est mise en place. 
````
voir schema 2
````
### 3) Le serveur de production de secours n’est pas installé.
L’installation est faite dans une machine virtuelle. Cette machine servira de modèle pour SRVSIPREPROD
````
voir schema 3
````
 
### 4)  Planning indicatif
````
Semaine  42 43 44 45  46  47  48  49 50 51 52
SRVSIPROD  1  Downgrader la JVM  42 43
SRVSIPREPROD  1  Mettre à jour Tomcat  42 43 44     
SRVSIBKP  1  Créer la VM  42 43 44
SRVSIBKP  2  Installer l'OS  42 43 44     
SRVSIBKP  3  Installer les composants serveurs  42 43 44     
SRVSIBKP  4  Installer les applications  42 43 44     
Tâches Communes  1  Mettre en place la sauvegarde  42 43 44 45  46     
Tâches Communes  2  Tests  42 43 44 45  46  47  48  49
Tâches Communes  3  Mises en production          49
````
**Mise en production : 07/12/2017**

### 5) Arborescence 
````
/opt/tomcat8/      <‐ Dossier d’installation de Tomcat 
/opt/tomcat8/webapps/    <‐ Dossier d’installation des applications Web 
/usr/local/documents_si    <‐ Dossier de l’application Web afvp 
/home/admfv/Scripts    <‐ Dossier contenant les scripts de sauvegarde 
/home/admfv/backup    <‐ Dossier contenant le log de sauvegarde 
/home/admfv/backup/files    <‐ Dossier contenant les fichiers de sauvegarde 
/home/admfv/backup    <‐ Dossier contenant le log de sauvegarde 
/var/lib/postgres      <‐ Dossier contenant le SGBDR
````

## II) Installation d’une plateforme 
### 1) Selon les cas, l’installation peut être réalisé à l’aide d’une clé USB ou un cd/dvd gravé contenant 
le système Ubuntu 16.04.3 LTS. Dans le cas de machine virtuelle, l’ISO du système est présentée directement à la VM. 
### 2) Les paramètres de noms et adresses IP dépendent de la machine à installer. 
#### a. Modification du nom (modifier le fichier hosts et hostname) 
````
admfv@SRVSIPROD:~$ sudo cat /etc/hosts 
127.0.0.1       localhost 
127.0.1.1       SRVSIPROD 
# The following lines are desirable for IPv6 capable hosts 
::1     localhost ip6‐localhost ip6‐loopback 
ff02::1 ip6‐allnodes 
ff02::2 ip6‐allrouters 
admfv@SRVSIPROD:~$ sudo cat /etc/hostname 
SRVSIPROD
````
#### b. Modification de l’IP
````
admfv@SRVSIPROD:~$ sudo nano /etc/network/interfaces 
# This file describes the network interfaces available on your system 
# and how to activate them. For more information, see interfaces(5). 
source /etc/network/interfaces.d/* 
# The loopback network interface 
auto lo 
iface lo inet loopback 
# The primary network interface 
auto eno1 
iface eno1 inet static 
        address 120.121.2.49 
        netmask 255.255.255.0 
        network 120.121.2.0 
        broadcast 120.121.2.255 
        gateway 120.121.2.22 
        dns‐nameservers 120.121.2.45 
        dns‐search fv.local 
CTRL<o|x> 
admfv@SRVSIPROD:~$ sudo service networking start
````
### 3) Installation des composants serveurs :  
#### a. Installation de la JVM :
````
sudo add‐apt‐repository ppa:openjdk‐r/ppa 
sudo apt‐get update 
sudo apt‐get install openjdk‐7‐jdk 
````
#### b. Installation de PostGreSQL
````
sudo apt‐get install postgresql‐9.5 
````
#### c. Installation des polices Microsoft 
````
sudo apt‐get ‐y install ttf‐mscorefonts‐installer 
````
**/!\   L’installation des polices requiert l’acception de l’EULA Microsoft**
#### d. Installation manuelle d’apache Tomcat sans apt : 
Tomcat est installé manuellement à l’aide des sources présentes sur les serveurs Apache. 
En effet, l’installation à l’aide de package fourni par l’éditeur de l’OS induit des erreurs de compatibilité entre Tomcat et Java (Tomcat7 a été compilé avec une version JVM 1.8 et non 1.7). Par la suite, des tests ont permis de démontrer que l’installation de Tomcat8 ne posait pas de soucis. 
````
cd /tmp 
wget https://archive.apache.org/dist/tomcat/tomcat‐8/v8.5.9/bin/apache‐tomcat‐8.5.9.tar.gz 
sudo mkdir /opt/tomcat8 
sudo tar xvfz apache‐tomcat‐8.5.9.tar.gz ‐C /opt/tomcat8  ‐‐strip‐components=1 
````
Ajout d’un compte utilisateur tomcat8 et d’un groupe tomcat8 
 ````
sudo groupadd tomcat8 
sudo useradd ‐s /bin/false ‐g tomcat8 ‐d /opt/tomcat8 tomcat8 
````
Changement de propriétaire sur /opt/tomcat8/ et mise en place de permissions 
 ````
cd /opt 
sudo chown ‐R tomcat8:tomcat8 tomcat8/ 
sudo chmod ‐R 755 tomcat8/ 
````
Création du fichier de service 
 ````
sudo nano /etc/systemd/system/tomcat8.service 
````
Puis coller le contenu suivant en veillant à adapter le cas échéant les chemins (java, …)
 ````
[Unit] 
Description=Apache Tomcat Web Application Container 
After=network.target 
[Service] 
Type=forking 
Environment=JAVA_HOME=/usr/lib/jvm/java‐1.7.0‐openjdk‐amd64 
Environment=CATALINA_PID=/opt/tomcat8/temp/tomcat.pid 
Environment=CATALINA_HOME=/opt/tomcat8 
Environment=CATALINA_BASE=/opt/tomcat8 
Environment='CATALINA_OPTS=‐Xmx8G ‐Xms4G ‐XX:PermSize=512m ‐XX:MaxPermSize=512m ‐
XX:NewSize=256m ‐server ‐XX:+UseParallelGC ‐Dcom.uniclick.fv.production=false' 
Environment='JAVA_OPTS=‐Djava.awt.headless=true ‐Djava.security.egd=file:/dev/./urandom' 
ExecStart=/opt/tomcat8/bin/startup.sh 
ExecStop=/opt/tomcat8/bin/shutdown.sh 
User=tomcat8 
Group=tomcat8 
UMask=0007 
RestartSec=10 
Restart=always 
[Install] 
WantedBy=multi‐user.target 
````
Le service est testé : 
 ````
systemctl daemon‐reload 
sudo systemctl start tomcat8 
sudo systemctl status tomcat8 
sudo systemctl stop tomcat8 
````
Le service est défini en démarrage automatique : 
 ````
systemctl enable tomcat8
````
Vérification de l’ouverture des ports : 
````
sudo systemctl start tomcat8 
sudo netstat ‐tulpn
````
### 4) Paramétrage des composants serveurs : 
#### a. Postgres 
 ````
sudo su ‐ postgres 
postgres@SRVSIBKP:~$ psql postgres 
psql (9.5.9) 
Type "help" for help. 
postgres=# \password postgres  <‐ Nouveau mot de passe (??????????)  
Enter new password: 
Enter it again: 
postgres=# CREATE ROLE afvp LOGIN 
  ENCRYPTED PASSWORD 'md56a5d91a5a56fe0d0463ee9989a6e06c8'     <‐ (???????) 
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION; 
CREATE ROLE 
postgres=# CREATE DATABASE afvp WITH OWNER = afvp; 
CREATE DATABASE 
postgres=# CREATE DATABASE plan WITH OWNER = afvp; 
CREATE DATABASE 
postgres=# CREATE DATABASE fv_request WITH OWNER = afvp; 
CREATE DATABASE 
psql (9.5.9) 
Type "help" for help. 
````
 ````
postgres=# \list 
                                  List of databases 
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges 
‐‐‐‐‐‐‐‐‐‐‐+‐‐‐‐‐‐‐‐‐‐+‐‐‐‐‐‐‐‐‐‐+‐‐‐‐‐‐‐‐‐‐‐‐‐+‐‐‐‐‐‐‐‐‐‐‐‐‐+‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ 
 afvp      | afvp     | UTF8     | fr_FR.UTF‐8 | fr_FR.UTF‐8 | 
 plan      | afvp     | UTF8     | fr_FR.UTF‐8 | fr_FR.UTF‐8 | 
 postgres  | postgres | UTF8     | fr_FR.UTF‐8 | fr_FR.UTF‐8 | 
 fv_request| afvp     | UTF8     | fr_FR.UTF‐8 | fr_FR.UTF‐8 | 
 template0 | postgres | UTF8     | fr_FR.UTF‐8 | fr_FR.UTF‐8 | =c/postgres          + 
           |          |          |             |             | postgres=CTc/postgres 
 template1 | postgres | UTF8     | fr_FR.UTF‐8 | fr_FR.UTF‐8 | =c/postgres          + 
           |          |          |             |             | postgres=CTc/postgres 
(6 rows)  
````
````
Postgres=# \q 
postgres@SRVSIBKP:~$ logout
````
Autorisation  de  l’administration  à  distance  de  PostGres  pour  quelques  machines 
(120.121.2.203/32 et 120.121.2.142/32) : 
Dans le fichier : /etc/postgresql/9.5/main/pg_hba.conf 
````
postgres@SRVSIBKP:~$ nano /etc/postgresql/9.5/main/pg_hba.conf 
````
Ajouter la ligne suivante
````
host    all             all             120.121.2.203/32        trust 
host    all             all             120.121.2.142/32        trust 
````
Modification de l’adresse IP d’écoute : 
````
postgres@SRVSIBKP:~$ nano /etc/postgresql/9.5/main/postgresql.conf
````
Il faut localiser l’option #listen_addresses='localhost' et la remplacer par listen_addresses='\*'. 
Pour finir, il faut redémarrer le serveur : 
````
postgres@SRVSIBKP:~$ /etc/init.d/postgresql restart
````
source : https://www.postgresql.org/docs/9.6/static/runtime‐config‐client.html
    Pour terminer, les données des bases sont injectées depuis les archives : 
````
postgres@SRVSIBKP:~$ pg_restore ‐‐dbname "fv_request" ‐‐verbose
/home/admfv/backup/files/backup_2017_MM_DD_fv_request_db.backup
postgres@SRVSIBKP:~$ pg_restore ‐‐dbname "plan" ‐‐verbose 
/home/admfv/backup/files/backup_2017_MM_DD_plan_db.backup 
postgres@SRVSIBKP:~$ pg_restore ‐‐dbname "afvp" ‐–verbose 
/home/admfv/backup/files/backup_2017_MM_DD_afvp_db.backup 
````
#### b. Copie des données vers le serveur

Plusieurs solutions existent : 
- A l’aide de Bitvise SFTP Tunnelier
Après avoir ouvert une session ssh/sftp à destination du serveur, il faut copier les fichiers dans un dossier : 
---
**Voir capture d'écran**
---

#### c. Paramétrage d’Apache Tomcat 
Afin de procéder au paramétrage d’Apache Tomcat, le service est arrêté :
````
sudo service tomcat8 stop 
sudo service tomcat8 status
````
**/!\   Il est nécessaire de copier la sauvegarde réalisée sur le serveur.**
Pour cela, plusieurs méthodes existent. Voir point b.

Ensuite,  on  procède  à  la  restauration  des  WebApps (ici  le  ~  correspond  au  dossier /home/admfv):
````
cd /opt/tomcat8/webapps/ 
sudo tar xvfz ~/backup/backup_2017_MM_DD_appli_afvp.tar.gz 
sudo tar xvfz ~/backup/backup_2017_MM_DD_appli_plan.tar.gz  
sudo tar xvfz ~/backup/backup_2017_MM_DD_appli_task.tar.gz
````
On vérifie et on supprime les dossiers inutiles : 
````
ls 
sudo rm ‐rf docs/ examples/ host‐manager/ manager/ 
ls
````
Modification des propriétaires : 
````
sudo chown ‐R tomcat8:tomcat8 task/ plan/ afvp/
````
Restauration des fichiers du SI avec changement de propriétaires :
````
sudo mkdir /usr/local/documents_si 
cd /usr/local/documents_si/ 
sudo tar xvfz ~/backup/backup_2017_MM_DD_documents_si.tar.gz 
cd .. 
ls 
sudo chown ‐R tomcat8:tomcat8 documents_si/
````
Copie de fichiers bibliothèque : 
````
cd /opt/tomcat8/lib/ 
sudo cp ~/backup/*.jar ./ 
sudo chmod 777 mail.jar postgresql.jar  
ls –la 
````
Pour finir, le service est démarré :
````
sudo service tomcat8 start 
cd /opt/tomcat8/logs/ 
cat catalina.out |more 
ps ‐aux | grep java 
sudo service tomcat8 status
````
### 5) Vérification 
Suite au paramétrage du serveur, il faut vérifier son fonctionnement. Voici une liste des points de contrôle à vérifier : 
#### a. Fonctionnement des services :   
````
admfv@SRVSIPROD:~$ sudo apt list ‐‐installed | grep java 
WARNING: apt does not have a stable CLI interface. Use with caution in scripts. 
ca‐certificates‐java/xenial,xenial,now 20160321 all  [installé, automatique] 
java‐common/xenial,xenial,now 0.56ubuntu2 all  [installé, automatique] 
libatk‐wrapper‐java/xenial,xenial,now 0.33.3‐6 all  [installé, automatique] 
libatk‐wrapper‐java‐jni/xenial,now 0.33.3‐6 amd64  [installé, automatique] 
admfv@SRVSIPROD:~$ sudo apt list ‐‐installed | grep postgres 
WARNING: apt does not have a stable CLI interface. Use with caution in scripts. 
postgresql/xenial‐updates,xenial‐updates,xenial‐security,xenial‐security,now 9.5+173ubuntu0.1 all  [installé] 
postgresql‐9.5/xenial‐updates,xenial‐security,now 9.5.10‐0ubuntu0.16.04 amd64  [installé] 
postgresql‐client/xenial‐updates,xenial‐updates,xenial‐security,xenial‐security,now 9.5+173ubuntu0.1 all  [installé] 
postgresql‐client‐9.5/xenial‐updates,xenial‐security,now 9.5.10‐0ubuntu0.16.04 amd64  [installé] 
postgresql‐client‐common/xenial‐updates,xenial‐updates,xenial‐security,xenial‐security,now 173ubuntu0.1 all  [installé] 
postgresql‐common/xenial‐updates,xenial‐updates,xenial‐security,xenial‐security,now 173ubuntu0.1 all  [installé] 
postgresql‐contrib/xenial‐updates,xenial‐updates,xenial‐security,xenial‐security,now 9.5+173ubuntu0.1 all  [installé] 
postgresql‐contrib‐9.5/xenial‐updates,xenial‐security,now 9.5.10‐0ubuntu0.16.04 amd64  [installé] 
postgresql‐doc/xenial‐updates,xenial‐updates,xenial‐security,xenial‐security,now 9.5+173ubuntu0.1 all  [installé] 
postgresql‐doc‐9.5/xenial‐updates,xenial‐updates,xenial‐security,xenial‐security,now 9.5.10‐0ubuntu0.16.04 all  [installé] 
admfv@SRVSIPROD:~$ ps ‐aux | grep tomcat 
tomcat8    3908  0.3  3.5 14864000 2347208 ?    Sl   nov.14   5:04 /usr/lib/jvm/java‐1.7.0‐openjdk‐amd64/bin/java ‐
Djava.util.logging.config.file=/opt/tomcat8/conf/logging.properties ‐
Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager ‐Djava.awt.headless=true ‐
Djava.security.egd=file:/dev/./urandom ‐Djdk.tls.ephemeralDHKeySize=2048 ‐
Djava.protocol.handler.pkgs=org.apache.catalina.webresources ‐Xmx8G ‐Xms4G ‐XX:PermSize=512m ‐
XX:MaxPermSize=512m ‐XX:NewSize=256m ‐server ‐XX:+UseParallelGC ‐Dcom.uniclick.fv.production=false ‐classpath 
/opt/tomcat8/bin/bootstrap.jar:/opt/tomcat8/bin/tomcat‐juli.jar ‐Dcatalina.base=/opt/tomcat8 ‐
Dcatalina.home=/opt/tomcat8 ‐Djava.io.tmpdir=/opt/tomcat8/temp org.apache.catalina.startup.Bootstrap start
admfv     14194  0.0  0.0  14264   964 pts/0    R+   13:36   0:00 grep ‐‐color=auto tomcat

````
#### b. Ouverture des ports : 
````
admfv@SRVSIPROD:~$ netstat ‐tulpn 
(Tous les processus ne peuvent être identifiés, les infos sur les processus 
non possédés ne seront pas affichées, vous devez être root pour les voir toutes.) 
Connexions Internet actives (seulement serveurs) 
Proto Recv‐Q Send‐Q Adresse locale          Adresse distante        Etat       PID/Program name 
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      ‐ 
tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      ‐ 
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      ‐ 
tcp6       0      0 :::8009                 :::*                    LISTEN      ‐ 
tcp6       0      0 :::8080                 :::*                    LISTEN      ‐ 
tcp6       0      0 :::22                   :::*                    LISTEN      ‐ 
tcp6       0      0 ::1:5432                :::*                    LISTEN      ‐

````
#### c. Test de fonctionnement depuis un navigateur :

#### d. Test de fonctionnement à l’aide du script Powershell accessible dans sys_tasks.ps1 

## III) Mise en production

### 1) Prévenir les utilisateurs en amont de l’intervention (1 semaine avant, puis rappel la veille)

### 2) Tâches :
#### a. Couper l’accès au serveur SERVEUR07, en arrêtant le service TOMCAT
*sudo systemctl stop*
*tomcat7.service*
#### b. Réaliser une sauvegarde des SI (webapp+base) sur le serveur SERVEUR07 à l’aide du 
script prévu (veiller à renommer les dernieres sauvegardes base pour être sûr…) 
#### c. Copier  la  sauvegarde  sur  le  serveur  SRVSIPROD  dans  le  dossier  vide  (!) 
/home/admfv/migration_data  à  l’aide  de  la  commande : 
*scp ‐r /home/admfv/backup/files/\* admfv@120.121.2.49:/home/admfv/*
#### d. Restaurer  la  sauvegarde  sur  le  serveur  SRVSIPROD  à  l’aide  du  script  de  migration 
*migration.sh : admfv@SRVSIPROD:~/Scripts$ sudo ./migration.sh*
#### e. Changer  l’adresse  IP  du  serveur  SRVSIPROD  en  modifiant  le  fichier 
*/etc/networking/interfaces pour indiquer l’adresse 120.121.2.39*
#### f. Arrêter le serveur SERVEUR07, SERVEUR06 et SRVSIPREPROD (l’ancien) 
#### g. Dans  le  fichier  tomcat8.service,  passer  le  flag  –Dcom.uniclick.fv.production  à  true : 
*admfv@SRVSIPROD:~/Scripts$ sudo nano /etc/systemd/system/tomcat8.service*
#### h. Redémarrer le serveur SRVSIPROD 
#### i. Modifier les @IP dans le script send_si_backup.sh présent sur le serveur SRVSIPROD 
#### j. Modifier les IP des serveurs SRVSIBKP et SRVSIPREPROD (nouveau),
puis redémarrer le service  réseau.  Pour  la  preprod,  le  faire  dans  un  second  temps  en  raison  de l’hébergement d’applications supplémentaires. 
#### k. Vérifier le bon fonctionnement des serveurs 
### 3) Tâches annexes : 
Suite à la migration, il faudra s’assurer que seul les bases PostGres des serveurs SRVSIBKP et 
SRVSIPREPROD puisse être utilisable à distance. Voir le point III/B/4)a.

## IV. Les stratégies 
### 1) Sauvegarde 
La  sauvegarde  des  bases  et  des  applications  Web  est  réalisée  sur  le  serveur  de  production 
SRVSIPROD. La solution combine 5 scripts : 
‐ backup_db.sh 
‐ clean_backup_db.sh 
‐ backup_si.sh 
‐ send_backup_si.sh 
‐ cp_backup_nas.sh 
#### a. backup_db.sh et clean_backup_db.sh 
Ces scripts sont hébergés dans le dossier /var/lib/postgresql. Le premier est appelé par cron à 03h00 
quotidiennement. Le second est appelé à 02h55 quotidiennement. Les fichiers sauvegardés sont 
stockés dans /var/lib/postgresql/backup_db. Chaque base est sauvegardée dans un fichier .backup 
(à l’aide de pg_dump et horodaté) et .sql (à l’aide de pgdump).

Voici leur contenu 
````
admfv@SRVSIPROD:~$ sudo su ‐ postgres 
[sudo] Mot de passe de admfv : 
postgres@SRVSIPROD:~$ cat backup_db.sh 
#!/bin/bash 
# 
DATE_BACKUP=`date "+%Y_%m_%d"` 
DB_LOG_FILE="/var/lib/postgresql/log/backup_db.log" 
TEE_A="tee ‐a $DB_LOG_FILE" 
echo "Sauvegardes des bases" |tee $DB_LOG_FILE 
echo "" |$TEE_A 
pg_dump ‐‐username=postgres ‐w ‐‐format=c ‐‐blobs ‐‐verbose ‐‐file=backup_db/afvp_${DATE_BACKUP}.backup afvp 
pg_dump ‐‐username=postgres ‐w ‐‐format=c ‐‐blobs ‐‐verbose ‐‐file=backup_db/fv_request_${DATE_BACKUP}.backup 
fv_request 
pg_dump ‐‐username=postgres ‐w ‐‐format=c ‐‐blobs ‐‐verbose ‐‐file=backup_db/plan_${DATE_BACKUP}.backup plan 
pg_dump ‐‐username=postgres ‐w ‐‐format=p ‐‐file=backup_db/afvp.sql afvp 
pg_dump ‐‐username=postgres ‐w ‐‐format=p ‐‐file=backup_db/fv_request.sql fv_request 
pg_dump ‐‐username=postgres ‐w ‐‐format=p ‐‐file=backup_db/plan.sql plan 
echo "[FIN]"|$TEE_A 

````

````
postgres@SRVSIPROD:~$ cat clean_backup_db.sh 
#!/bin/bash 
# 
find backup_db/ ‐mtime +7 ‐exec rm {} \; 
postgres@SRVSIPROD:~$ 

````
Voici le contenu du cron : 
````
postgres@SRVSIPROD:~$ crontab –e    <‐ Pour l’édition du cron
postgres@SRVSIPROD:~$ crontab ‐l 
# Edit this file to introduce tasks to be run by cron. 
# 
# Each task to run has to be defined through a single line 
# indicating with different fields when the task will be run 
# and what command to run for the task 
# 
# To define the time you can provide concrete values for 
# minute (m), hour (h), day of month (dom), month (mon), 
# and day of week (dow) or use '*' in these fields (for 'any').# 
# Notice that tasks will be started based on the cron's system 
# daemon's notion of time and timezones. 
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected). 
# 
# For example, you can run a backup of all your user accounts 
# at 5 a.m every week with: 
# 0 5 * * 1 tar ‐zcf /var/backups/home.tgz /home/ 
# 
# For more information see the manual pages of crontab(5) and cron(8) 
# 
# m h  dom mon dow   command 
0 3 * * * ~/backup_db.sh 
55 2 * * * ~/clean_backup_db.sh 
0 12 * * * ~/backup_db.sh 
55 11 * * * ~/clean_backup_db.sh 

````
#### b. backup_si.sh et send_backup_si.sh 
Ces scripts sont hébergés dans le dossier /home/admfv/Scripts. Le premier est appelé par tâche cron à 
03h30 quotidiennement. Le second est appelé à 3h45 quotidiennement. Les fichiers de sauvegardes 
sont placés dans /home/admfv/backup/files. Chaque dossier de Webapp (/opt/tomcat8/webapps) est placé 
dans une archive tar.gz. Les sauvegardes de bases sont dupliquées dans le répertoire de backup. 
Une archive des fichiers documents du SI (/usr/local/documents_si) est générée. 
Le script send_backup.sh utilise la commande scp. Afin de ne pas stocker de mot de passe dans le 
script, une paire de clé RSA est générée : 
Génération des clés (appuyer sur Entrée pour valider les propositions): 
###### manquant

Affichage des clés : 
###### manquant

Copie de la clé publique sur les serveurs distants : 
###### manquant

Test : 
###### manquant

Voici le contenu des scripts : 
````
admfv@SRVSIPROD:~/Scripts$ cat backup_si.sh 
#!/bin/bash 
# 
# Script de backup d'application web (tomcat+postgresql) 
# Dépendance avec le script de dump des bases POSTGRES 
# Dependance avec send_backup_si.sh 
DATE_BACKUP=`date "+%Y_%m_%d"` 
WEBAPPS_HOME="/opt/tomcat8/webapps" 
DOCUMENTS_SI_HOME="/usr/local/documents_si" 
BACKUP_DIR="/home/admfv/backup" 
BACKUP_FILES_DIR="${BACKUP_DIR}/files" 
DB_BACKUP_DIR="/var/lib/postgresql/backup_db" 
LOG_FILE="${BACKUP_DIR}/backup.log" 
TEE="tee $LOG_FILE" 
TEE_A="tee ‐a $LOG_FILE" 
# Suppresion de l'ancienne sauvegarde 
rm ‐rf $BACKUP_FILES_DIR/* 
echo "Script de backup en date du $DATE_BACKUP." |$TEE 
# Sauvegarde des documents PDF du SI 
echo "Sauvegarde des documents PDF du SI dans $BACKUP_FILES_DIR/ ." |$TEE_A 
find $DOCUMENTS_SI_HOME ‐name "*" | tar cvzf $BACKUP_FILES_DIR/backup_${DATE_BACKUP}_documents_si.tar.gz 
‐‐files‐from ‐  |$TEE_A 
# Sauvegardes des Applications Web 
cd $WEBAPPS_HOME 
echo "Sauvegarde du contexte AFVP dans $BACKUP_FILES_DIR/ ." |$TEE_A 
tar cvzf $BACKUP_FILES_DIR/backup_${DATE_BACKUP}_appli_afvp.tar.gz afvp  |$TEE_A 
echo "Sauvegarde du contexte TASK dans $BACKUP_FILES_DIR/ ." |$TEE_A 
tar cvzf $BACKUP_FILES_DIR/backup_${DATE_BACKUP}_appli_task.tar.gz task  |$TEE_A 
echo "Sauvegarde du contexte PLAN dans $BACKUP_FILES_DIR/ ." |$TEE_A 
tar cvzf $BACKUP_FILES_DIR/backup_${DATE_BACKUP}_appli_plan.tar.gz plan  |$TEE_A 
# Sauvegarde des dumps des bases 
echo "Copie de la base de données AFVP" 
cp $DB_BACKUP_DIR/afvp_${DATE_BACKUP}.backup $BACKUP_FILES_DIR/backup_${DATE_BACKUP}_afvp_db.backup 
cp $DB_BACKUP_DIR/afvp.sql $BACKUP_FILES_DIR/backup_afvp_db.sql
echo "Copie de la base de données FV_REQUEST" 
cp $DB_BACKUP_DIR/fv_request_${DATE_BACKUP}.backup 
$BACKUP_FILES_DIR/backup_${DATE_BACKUP}_fv_request_db.backup 
cp $DB_BACKUP_DIR/fv_request.sql $BACKUP_FILES_DIR/backup_fv_request_db.sql 
echo "Copie de la base de données PLAN" 
cp $DB_BACKUP_DIR/plan_${DATE_BACKUP}.backup $BACKUP_FILES_DIR/backup_${DATE_BACKUP}_plan_db.backup 
cp $DB_BACKUP_DIR/plan.sql $BACKUP_FILES_DIR/backup_plan_db.sql
####### 
# FIN # 
####### 
admfv@SRVSIPROD:~/Scripts$ cat send_si_backup.sh 
#!/bin/bash 
# 
# Script d'envoi des sauvegardes 
# 
# 
SRVBKP="120.121.2.XXX" 
SRVPP="120.121.2.YYY" 
RESTORE_DIR="/home/admfv/backup/files" 
# Suppression à distance des anciennes sauvegardes 
ssh admfv@$SRVBKP "rm ‐rf $RESTORE_DIR/*" 
ssh admfv@$SRVPP "rm ‐rf $RESTORE_DIR/*" 
# Copie des sauvegardes 
scp ‐r /home/admfv/backup/files/* admfv@$SRVBKP:$RESTORE_DIR 
scp ‐r /home/admfv/backup/files/* admfv@$SRVPP:$RESTORE_DIR 

````
Voici le contenu du cron : 
````
admfv@SRVSIPROD:~$ crontab –e    <‐ Pour l’édition du cron 
admfv@SRVSIPROD:~/Scripts$ crontab ‐l 
# Edit this file to introduce tasks to be run by cron. 
# 
# Each task to run has to be defined through a single line 
# indicating with different fields when the task will be run 
# and what command to run for the task 
# 
# To define the time you can provide concrete values for 
# minute (m), hour (h), day of month (dom), month (mon), 
# and day of week (dow) or use '*' in these fields (for 'any').# 
# Notice that tasks will be started based on the cron's system 
# daemon's notion of time and timezones. 
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected). 
# 
# For example, you can run a backup of all your user accounts 
# at 5 a.m every week with: 
# 0 5 * * 1 tar ‐zcf /var/backups/home.tgz /home/ 
# 
# For more information see the manual pages of crontab(5) and cron(8) 
# 
# m h  dom mon dow   command 
30 3 * * * ~/Scripts/backup_si.sh 
45 3 * * * ~/Scripts/send_si_backup.sh 
46 3 * * * /home/admfv/Scripts/cp_backup_nas.sh 
30 12 * * * ~/Scripts/backup_si.sh 
45 12 * * * ~/Scripts/send_si_backup.sh 
46 12 * * * /home/admfv/Scripts/cp_backup_nas.sh 

````
#### c. cp_backup_nas.sh 
Un compte SINAS a été créé sur le Synology avec un accès Shell SSH. Les clés RSA admfv du 
serveur SRVSIPROD ont été déposées sur le NAS.
````
admfv@SRVSIPROD:~$ cat Scripts/cp_backup_nas.sh 
#!/bin/bash 
# 
# Copie des sauvegardes vers SRVNAS 
# 
NAS_PATH="/home/admfv/nas/files/" 
BKP_PATH="/home/admfv/backup/files/" 
SRVNAS="120.121.2.55" 
CP_DIR="/volume1/SAUVEGARDE_INFO/SauvegardeSITest/" 
rm ‐rf $NAS_PATH* 
cp ‐a $BKP_PATH* $NAS_PATH 
# Traitement des archives WebApps 
for f in `ls $NAS_PATH*.tar.gz` 
do 
        FILEN1=$(echo $f |cut ‐d_ ‐f1) 
        FILEN2=$(echo $f |cut ‐d_ ‐f5) 
        FILEN3=$(echo $f |cut ‐d_ ‐f6) 
        HM=$(date ‐r $f +%Y_%m_%d_%H_%M) 
        FULLN=$FILEN1"_"$HM"_"$FILEN2"_"$FILEN3 
        mv $f $FULLN 
done 
# Traitement des backups SQL 
for f in `ls $NAS_PATH*.backup` 
do 
        FILEN1=$(echo $f |cut ‐d_ ‐f1) 
        FILEN2=$(echo $f |cut ‐d_ ‐f5) 
        FILEN3=$(echo $f |cut ‐d_ ‐f6) 
        # Traitement de l'exception du nom fv_request (2 partie alors que les autres 1 seule partie) 
        if [ `echo $f|grep ‐c request` ‐eq 1 ] 
        then 
                FILEN3=$FILEN3"_"$(echo $f |cut ‐d_ ‐f7) 
        fi 
        HM=$(date ‐r $f +%Y_%m_%d_%H_%M) 
        FULLN=$FILEN1"_"$HM"_"$FILEN2"_"$FILEN3 
        mv $f $FULLN 
done 
# Traitement des dumps SQL 
for f in `ls $NAS_PATH*.sql` 
do 
        FILEN1=$(echo $f |cut ‐d_ ‐f1) 
        FILEN2=$(echo $f |cut ‐d_ ‐f2) 
        FILEN3=$(echo $f |cut ‐d_ ‐f3) 
        # Traitement de l'exception du nom fv_request (2 partie alors que les autres 1 seule$ 
        if [ `echo $f|grep ‐c request` ‐eq 1 ] 
        then 
                FILEN3=$FILEN3"_"$(echo $f |cut ‐d_ ‐f4) 
        fi 
        HM=$(date ‐r $f +%Y_%m_%d_%H_%M) 
        FULLN=$FILEN1"_"$HM"_"$FILEN2"_"$FILEN3 
        mv $f $FULLN 
done 
# Copie des sauvegardes vers le NAS 
scp ‐r $NAS_PATH* SINAS@$SRVNAS:$CP_DIR

````

#### d. Planification des scripts 
Nom du script    Quand ?    Quoi ?    Qui ? 
clean_backup_db.sh   02h55 et 11h55 Nettoyage des dumps de bases  postgres 
Aurélien ROUX  Mise à jour de l’infrastructure des Systèmes d’Informations  18 
backup_db.sh  03h00 et 12h00 Dump des bases  postgres 
backup_si.sh  03h30 et 12h30 Archivage Webapps, Documents_si et dump  admfv 
send_si_backup.sh  03h45 et 12h45 Envoi des archives vers les autres serveurs  admfv 
cp_backup_nas.sh  03h46 et 12h46 Envoi des archives vers le NAS  admfv 
  Exécuter avec l’identité admfv et postgres. 

### 2) Restauration 
La  restauration  des  bases  et  des  applications  Web  est  réalisée  sur  le  serveur  de  secours 
SRVSIBACKUP. La solution s’appuie sur un script : restore.sh. Les fichiers à restaurer sont stockés dans 
le dossier /home/admfv/backup/files, le script est dans /home/admfv/Scripts. Des logs sont stockés dans 
/home/admfv/Scripts/log restore_db.log et restore.log. 
#### a. Restore.sh 
Voici le contenu du script : 

````
admfv@SRVSIBKP:~$ cd Scripts/ 
admfv@SRVSIBKP:~/Scripts$ cat restore.sh 
#!/bin/bash 
# 
# Script de restauration 
# 
#set ‐x 
DATE_START_RESTORE=`date "+%d/%m/%Y %H:%M"` 
RESTORE_DIR="/home/admfv/backup/files" 
DOCUMENTS_SI_HOME="/usr/local/documents_si" 
WEBAPPS_HOME="/opt/tomcat8/webapps" 
LOG_FILE="/home/admfv/Scripts/log/restore.log" 
DB_LOG_FILE="/home/admfv/Scripts/log/restore_db.log" 
TEE="tee $LOG_FILE" 
TEE_A="tee ‐a $LOG_FILE" 
# On arrete Tomcat pour qu'il n'y est plus de lien avec Postgresql 
echo "Debut de la restauration le $DATE_START_RESTORE" |$TEE 
echo " " |$TEE_A 
sudo systemctl stop tomcat8.service 
sleep 5 
# Partie POSTGRESQL 
su ‐ postgres ‐c "dropdb afvp" |$TEE_A 
su ‐ postgres ‐c "dropdb fv_request" |$TEE_A 
su ‐ postgres ‐c "dropdb plan" |$TEE_A 
sleep 2 
su ‐ postgres ‐c "createdb ‐‐owner=afvp ‐‐encoding=UTF8 afvp" |$TEE_A 
su ‐ postgres ‐c "createdb ‐‐owner=afvp ‐‐encoding=UTF8 fv_request" |$TEE_A 
su ‐ postgres ‐c "createdb ‐‐owner=afvp ‐‐encoding=UTF8 plan" |$TEE_A 
sleep 2 
echo "Restauration de la base AFVP" |$TEE_A 
su ‐ postgres ‐c "psql ‐d afvp ‐f ${RESTORE_DIR}/*afvp_db.sql 2> ${DB_LOG_FILE}" |$TEE_A 
sleep 20 
echo "Restauration de la base FV_REQUEST" |$TEE_A 
su ‐ postgres ‐c "psql ‐d fv_request ‐f ${RESTORE_DIR}/*fv_request_db.sql 2>> ${DB_LOG_FILE}" |$TEE_A 
sleep 5 
echo "Restauration de la base PLAN" |$TEE_A 
su ‐ postgres ‐c "psql ‐d plan ‐f ${RESTORE_DIR}/*plan_db.sql 2>> ${DB_LOG_FILE}" |$TEE_A 
sleep 5 
# Partie documents 
echo "Restauration des documents SI" |$TEE_A 
cd $DOCUMENTS_SI_HOME 
rm ‐rf * 
tar xzvf $RESTORE_DIR/*documents_si.tar.gz 
# Partie Tomcat 
cd $WEBAPPS_HOME 
echo "Suppression du contexte afvp" |$TEE_A 
rm ‐fr afvp 
echo "Suppression du contexte afvp‐annuaire" |$TEE_A 
rm ‐fr task 
echo "Suppression du contexte plan" |$TEE_A 
rm ‐fr plan 
echo "Installation du nouveau contexte afvp" |$TEE_A 
tar xzfC $RESTORE_DIR/*appli_afvp.tar.gz $WEBAPPS_HOME 
echo "Installation du nouveau contexte task" |$TEE_A 
tar xzfC $RESTORE_DIR/*appli_task.tar.gz $WEBAPPS_HOME 
echo "Installation du nouveau contexte plan" |$TEE_A 
tar xzfC $RESTORE_DIR/*appli_plan.tar.gz $WEBAPPS_HOME 
cd ../logs 
sudo systemctl start tomcat8.service 
DATE_END_RESTORE=`date "+%d/%m/%Y %H:%M"` 
echo "Fin de la restauration le $DATE_END_RESTORE" |$TEE_A 

````


Voici le contenu du cron root :
````
admfv@SRVSIBKP:~$ sudo crontab –e    <‐ pour editer le crontab 
admfv@SRVSIBKP:~$ sudo crontab ‐l 
[sudo] Mot de passe de admfv : 
# Edit this file to introduce tasks to be run by cron. 
# 
# Each task to run has to be defined through a single line 
# indicating with different fields when the task will be run 
# and what command to run for the task 
# 
# To define the time you can provide concrete values for 
# minute (m), hour (h), day of month (dom), month (mon), 
# and day of week (dow) or use '*' in these fields (for 'any').# 
# Notice that tasks will be started based on the cron's system 
# daem
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected). 
# 
# For example, you can run a backup of all your user accounts 
# at 5 a.m every week with: 
# 0 5 * * 1 tar ‐zcf /var/backups/home.tgz /home/ 
# 
# For more information see the manual pages of crontab(5) and cron(8) 
# 
# m h  dom mon dow   command 
0 4 * * * /home/admfv/Scripts/restore.sh 
50 12 * * * /home/admfv/Scripts/restore.sh 
````
#### b.   Send_si_to_nas.sh 

Un compte SINAS a été créé sur le Synology avec un accès Shell SSH. Les clés RSA admfv du serveur 
SRVBKP ont été déposées sur le NAS.
````
admfv@SRVSIBKP:~$ cat Scripts/send_si_to_nas.sh 
#!/bin/bash 
# 
# Script d'envoi des sauvegardes vers le NAS 
# 
# 
SRVNAS="120.121.2.55" 
CP_DIR="/volume1/SAUVEGARDE_INFO/SauvegardeSI/" 
# Copie des sauvegardes vers le NAS 
scp ‐r /home/admfv/backup/files/* SINAS@$SRVNAS:$CP_DIR
````

---
---
## Mise à jour de l’application des Systèmes d’Informations afvp
Aurélien ROUX - 02/01/2018

Table des matières
I. Introduction .................................... 3
II. Instruction de mise à jour ..................... 3
III. Reconfiguration du service TOMCAT par ajout d’extension .................... 3
IV. Reconfiguration du service Postgres ............ 4


### I. Introduction
En prévision de la mise à jour de l’application SI afvp, des modifications des services TOMCAT et
POSTGRES doivent être réalisé sur l’ensemble de plateforme (Production, Préproduction/recette et
Backup).
Les instructions ont été données par Richard Hallier par email.
Les serveurs vont être mis à jour dans l’ordre suivant : SRVSIPREPROD, SRVSIPROD et SRVSIBKP, avec
un jour d’intervalle afin de procéder à des tests sommaires.

### III. Reconfiguration du service TOMCAT par ajout d’extension
Afin de configurer TOMCAT, les commandes suivantes ont été entrées :
````
admfv@SRVSIPREPROD:~$ admfv@SRVSIPREPROD:~$ cd /opt/tomcat8/conf
admfv@SRVSIPREPROD:/opt/tomcat8/conf$ sudo nano server.xml
````
Il faut ensuite remplacer la section
````
<Connector port="8080" protocol="HTTP/1.1"
connectionTimeout="20000"
redirectPort="8443"/>
````
Par:
````
<Connector port="8080" protocol="HTTP/1.1"
connectionTimeout="20000"
redirectPort="8443"
URIEncoding="UTF-8"/>
````
Ensuite, le service est redémarré 
````
admfv@SRVSIPREPROD:/opt/tomcat8/conf$ sudo systemctl stop tomcat8.service
admfv@SRVSIPREPROD:/opt/tomcat8/conf$ sudo systemctl start tomcat8.service
admfv@SRVSIPREPROD:/opt/tomcat8/conf$ sudo systemctl status tomcat8.service
● tomcat8.service - Apache Tomcat Web Application Container
Loaded: loaded (/etc/systemd/system/tomcat8.service; enabled; vendor preset: enabled)
Active: active (running) since mar. 2018-01-02 10:44:41 CET; 30min ago
Process: 2743 ExecStop=/opt/tomcat8/bin/shutdown.sh (code=exited, status=0/SUCCESS)
Process: 2779 ExecStart=/opt/tomcat8/bin/startup.sh (code=exited, status=0/SUCCESS)
Main PID: 2788 (java)
Tasks: 57
Memory: 1000.5M
CPU: 52.841s
CGroup: /system.slice/tomcat8.service
└─2788 /usr/lib/jvm/java-1.7.0-openjdk-amd64/bin/java -
Djava.util.logging.config.file=/opt/tomcat8/conf/logging.properties -Dja
janv. 02 10:44:41 SRVSIPREPROD systemd[1]: Starting Apache Tomcat Web Application
Container...
janv. 02 10:44:41 SRVSIPREPROD startup.sh[2779]: Using CATALINA_BASE: /opt/tomcat8
janv. 02 10:44:41 SRVSIPREPROD startup.sh[2779]: Using CATALINA_HOME: /opt/tomcat8
janv. 02 10:44:41 SRVSIPREPROD startup.sh[2779]: Using CATALINA_TMPDIR: /opt/tomcat8/temp
janv. 02 10:44:41 SRVSIPREPROD startup.sh[2779]: Using JRE_HOME: /usr/lib/jvm/java-
1.7.0-openjdk-amd64
janv. 02 10:44:41 SRVSIPREPROD startup.sh[2779]: Using CLASSPATH:
/opt/tomcat8/bin/bootstrap.jar:/opt/tomcat8/bin/tomcat-juli.jar
janv. 02 10:44:41 SRVSIPREPROD startup.sh[2779]: Using CATALINA_PID:
/opt/tomcat8/temp/tomcat.pid
janv. 02 10:44:41 SRVSIPREPROD startup.sh[2779]: Tomcat started.
janv. 02 10:44:41 SRVSIPREPROD systemd[1]: Started Apache Tomcat Web Application Container.
````
Une vérification du fonctionnement de l’application via l’URL
http://120.121.2.XXX:8080/afvp/login.html est faite

### IV. Reconfiguration du service Postgres
Afin d’activer l’extension « unaccent », les commandes suivantes ont été entrées :
````
admfv@SRVSIPREPROD:/opt/tomcat8/conf$ sudo su - postgres
postgres@SRVSIPREPROD:~$ psql
psql (9.5.10)
Type "help" for help.
postgres=# CREATE EXTENSION unaccent;
CREATE EXTENSION
postgres-# \c afvp
You are now connected to database "afvp" as user "postgres".
afvp=# CREATE EXTENSION unaccent;
CREATE EXTENSION
afvp=# select name, unaccent(name) from partner;
afvp=# \q

````
L’extension est créée dans la base afvp, puis on teste son fonctionnement à la fois avec l’utilisateur
postgres, puis l’utilisateur afvp:
````
postgres@SRVSIPREPROD:~$ psql -h 127.0.0.1 -d afvp -U afvp -W
Password for user afvp: (<- ?????)
psql (9.5.10)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256,
compression: off)
Type "help" for help.
afvp=> \conninfo
You are connected to database "afvp" as user "afvp" on host "127.0.0.1" at port "5432".
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256,
compression: off)
afvp=> select name, unaccent(name) from partner;
afvp=> \q
postgres@SRVSIPREPROD:~$ exit
````
Pour valider l’ajout d’extension, un test de connexion est réalisé sur le serveur
(http://120.121.2.XXX:8080/afvp/login.html).


````
test
````
info
````
test
````
info
````
test
````