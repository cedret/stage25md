#### TP_Linux Iprec 2024
15/12
## PROJET SERVICES LINUX / UNIX

Les captures d’écrans fournies dans ce travail doivent portées le nom du
stagiaire (nom de la machine virtuelle portant le nom du stagiaire)

### 1 Présentation :
1. Création d'un serveur linux (Fedora, Alma ou Ubuntu)
permettant de réaliser les installations passives, sur les machines
neuves démarrant depuis le réseau, d’un os linux à partir du
réseau.
2. Développer un script shell permettant d’effectuer les tâches
suivantes :
  * Automatiser la configuration du réseau en mode bridge et
host only .
  * Installer les services DHCP, TFTP, NFS et SELINUX
  * Configurer les services précédemment installés
  * Monter le lecteur de DVD avec l’iso
  * Copier et modifier un fichier existant et permettant
l’installation passive

Il est impératif que votre script interagisse avec l’utilisateur
chaque fois qu’une information doit être fournie au script.

### 2 Réalisation :

- [ ] Réaliser le script
- [ ] Exécuter votre script en prenant des captures d’écran de toute
l’exécution
- [ ] Démarrer le poste sur lequel l’installation sera effectuée en
prenant des captures d’écran
- [ ] Produire un support au format pdf expliquant l’exécution du
script et contenant votre script shell
- [ ] Vous devez expliquer le fonctionnement de 4 fonctions Shell
de votre choix et créer une fonction réseau qui permet de
gérer le réseau.
- [ ] Création d’une fonction réseau qui permet de configurer le
réseau

**Merci de vous référer à la grille d’évaluation ci-jointe pour vérifier les attentes de l’évaluation**

---

### 3 TP du cours: Services Alma linux pour boot PXE
Faire un "full clone" de la vm à chaque étape réussie
#### ----- Etape 1 ----- Mises à jour OS -----
***Connecter la carte réseau en bridge avec les paramètres adaptés***
On se connecte en tant que stagiaire, ou selon votre compte, puis on ouvre un terminal et on change l’utilisateur pour devenir root. Vérifier la connexion réseau avec pings.
```
$ su -

# ip a
# ping -c4 192.168.a.254 (a=10 ou a=20 ou a=30 ….selon la salle occupée)
# ping -c4 iprec.fr
````
On met à jour le système installé, puis on ajoute les packages suivants:

vim peut manquer dans certaines distributions. Et *selinux* ?
```
# yum update

# yum -y install dhcp-server.x86_64
# yum -y install tftp-server.x86_64
# yum -y install syslinux.x86_64
# yum -y install nfs4-acl-tools.x86_64
# yum -y install nfs-utils
# dnf -y install vim
# dnf -y install selinux

# rpm -q dhcp-server
# rpm -q tftp-server
# rpm -q syslinux
# rpm -q nfs-utils
# rpm -q vim
# rpm -q selinux

```
#### ----- Etape 2 ----- Bascule en DHCP -----
1. Basculer votre carte réseau en host only depuis VMware
2. N'oubliez pas d'arrêter le serveur DHCP de VMWARE s’il est activé.
3. Dans le linux, configurer la carte réseau avec les valeurs suivantes, où C est votre année de naissance (uniquement les deux derniers chiffres). Puis vérifier la configuration.
```
IP=192.168.C.254
MASQUE=255.255.255.0
PASSERELLE=192.168.C.254
DNS= 192.168.C.254
````

```
ip a
````
#### ----- Etape 3 ----- Modification dhcpd.conf -----

Une machine vierge peut être mise en route sur ce réseau dhcp pour vérifier en parallèle l'évolution des étapes en fonction de ses réponses.

On va chercher un exemplaire du fichier de configuration du service DHCP,
puis editer le fichier de configuration du service DHCP, le fichier *dhcpd.conf*
```
find / -name 'dhcpd.conf*'

vim /etc/dhcp/dhcpd.conf
````
On se met sur la dernière ligne du fichier avec la commande **:$**,
puis insérer une ligne vide avec la commande **o** supprimer le caractère **\#** en début de ligne (suppr)
**Maj I** puis **Retour Arrière**, et ajouter les lignes suivantes :
```
:$
o
[SUPP]
I

authoritative;
subnet 192.168.C.0 netmask 255.255.255.0 {
  range 192.168.C.100 192.168.C.110;
  option routers 192.168.C.254;
  option domain-name-servers 192.168.C.254;
  option broadcast-address 192.168.C.255;
  next-server 192.168.C.254;
  option subnet-mask 255.255.255.0;
  filename "pxelinux.0";
}
```
ATTENTION à *filename "pxelinux.0";*
- Appuyer sur la touche echap pour sortir du mode insertion de texte.
- On change la lettre C par le 3ième octet de votre adresse ip **:%s/C/la valeur/g**
- Pour indenter le fichier (le mettre en forme) on se met sur la première ligne **:1 et Enter**
- Puis on se met en mode visual avec **Maj V**
- Et on sélectionne tout le fichier avec **Maj G** puis on indente avec **=**
- on écrit et on quitte le fichier **:wq**
```
:%s/C/la valeur/g
:1 [Enter]
Maj V
Maj G
=
:wq
````
#### ----- Etape 4 ----- Activation des services -----
- Activer le DHCP avec les commandes suivantes
- Merci de ne pas tout saisir et d’utiliser la complétion avec **tab**
```
# systemctl enable dhcpd.service
# systemctl restart dhcpd.service
# systemctl status dhcpd.service
````
- Appuyer sur q pour quiter le status
- Si le serveur dhcp ne fonctionne pas exécuter la commande suivante pour diagnostiquer le problème.

```
# /usr/sbin/dhcpd -cf /etc/dhcp/dhcpd.conf
````
- Puis déclencher le tftp
- Appuyer sur q pour quitter le status
```
# systemctl enable tftp.socket
# systemctl restart tftp.socket
# systemctl status tftp.socket
# firewall-cmd --permanent --add-service=tftp
# systemctl restart firewalld.service
````
#### ----- Etape 5 ----- Préparation des fichiers pour boot réseau
- Recherche et copie des fichiers *pxelinux.0 ldlinux.c32* dans */var/lib/tftpboot/*
```
# find / -name pxelinux.0
# cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
# find / -name 'ldl*'
# cp /usr/share/syslinux/ldlinux.c32 /var/lib/tftpboot/
# cd /var/lib/tftpboot/
````
Après création du répertoire *pxelinux.cfg*, appuyer sur la touche **i** pour se mettre en insertion et copier-coller les lignes suivantes dans le fichier *default*.
```
# mkdir pxelinux.cfg
# vim pxelinux.cfg/default
i

PROMPT 0
DEFAULT linux
LABEL linux
KERNEL vmlinuz
APPEND initrd=initrd.img inst.ks=nfs:192.168.C.254:/reponses/ks.cfg
````
Appuyer sur la touche **ESC** pour sortir du mode insertion de texte.

On change la lettre C par le 3ième octet de votre adresse ip, avec la commande suivante, avant de quitter et sauver.
```
:%s/C/la valeur/
:wq
````
#### ----- Etape 6 ----- Montage des images ?
Création des répertoires */SrcAlma /reponses* ou selon autres distributions

Vérifier que le lecteur de cdrom/dvd est connecté et l’iso Alma sélectionné puis taper la commande suivante pour monter le lecteur cdrom/dvd dans le répertoire */SrcAlma*
```
# mkdir /SrcAlma /reponses
# mount /dev/sr0 /SrcAlma/
# df -h
# ls -l /SrcAlma/
# find /SrcAlma/ -name vmlinuz
# cd /SrcAlma/images/pxeboot
# ls
# cp vmlinuz initrd.img /var/lib/tftpboot/
# cd

# vim /etc/exports
````
- Appuyer sur la touche **i** pour se mettre en insertion et copier-coller les lignes suivantes dans votre fichier.
- Modifier la valeur C, selon votre choix.
- Appuyer sur la touche **ESC** pour sortir du mode insertion de texte. Puis on écrit et on quitte le fichier.
````
i

/SrcAlma 192.168.C.0/24(ro,sync,no_root_squash,no_subtree_check)
/reponses 192.168.C.0/24(ro,sync,no_root_squash,no_subtree_check)

:%s/C/la valeur/
:wq
````
#### ----- Etape 7 ----- Relancement des services ?
```
# systemctl enable --now nfs-server.service
# systemctl restart nfs-server.service
# systemctl status nfs-server.service
````
Appuyer sur **q** pour quiter le status
https://www.linuxtricks.fr/wiki/nfs-parametrer-les-partages-avec-le-fichier-exports
```
## Vérification des partages nfs
# exportfs -v
# firewall-cmd --permanent --add-service=nfs
# firewall-cmd --permanent --add-service=rpc-bind
# firewall-cmd --permanent --add-service=mountd
# systemctl restart firewalld.service
````
#### ----- Etape 8 ----- Modifications du ks.cfg ?
1. Trouvez *ks.cfg*, copiez dans */reponses* et modifiez le fichier 
2. On numérote les lignes du fichier avec la commande **:se nu**
````
# find / -name '*ks.cfg'
# cp /root/anaconda-ks.cfg /reponses/ks.cfg
# vim /reponses/ks.cfg

:se nu
````
3. La commande **:17,18d** sert à supprimer les lignes suivantes si elles figurent dans cette version.
```
# Use CDROM installation media
Cdrom

:17,18d
````
4. Ajouter les lignes suivantes avec la séquence.
 ```
i

# use nfs installation
nfs --server=192.168.C.254 --dir=/SrcAlma
````
5. Appuyer sur la touche **ESC** pour sortir du mode insertion de texte.
6. Et remplacer C par la bonne valeur dans l'IP précédente, si ce n'est pas fait.
```
:%s/C/la valeur/
:w
````
7. Pour réutiliser un disque contenant des données on doit supprimer toutes les partitions existantes et réinitialiser l’étiquette du disque en ajoutant la ligne suivante.
8. Appuyer sur la touche echap pour sortir du mode insertion de texte, et sauver le fichier.
```
i

clearpart --all --initlabel

:w
````
9. La taille du disque initial était de 20 Go (1 Go swap 2 go /home et 17 Go /).
10. La ligne initiale est la suivante et on voit la taille de la racine 17 Go (20 -1 Go swap -2 go /home)
````
part / --fstype="xfs" --ondisk=sda --size=17407
````
11. Pour tout disque de capacité différente ou égale il est judicieux de ne pas spécifier la capacité de la partition racine /. La remplacer par la ligne suivante, puis ESC, écriture et fermeture.
12. Attention sda, nvme...
```
part / --fstype="xfs" --ondisk=sda --grow --size=1

:wq
````
12. Neutraliser la ligne suivante qui fait référence au cdrom, remplacé par le réseau.
````
# repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-
cdrom/AppStream
````


DNS????????????????????

# Partition clearing information
clearpart --all --initlabel
sudo exportfs -ra


#### ----- Etape 10 ----- Démarrer une machine vierge, si ce n'est pas déjà fait.

**On peut vérifier avec un navigateur l'adresse du serveur tftp //192.168.C.254/???**

---
#### Rappels vim
https://devhints.io/vim
- **dd** pour cut, **yy** pour copier, **p** pour coller
- Appuyer sur **ESC** pour sortir du mode insertion de texte.
- Pour indenter le fichier (le mettre en forme) on se met sur la première ligne **:1 et Enter**
- Puis on se met en mode visual avec **Maj V**
- Et on sélectionne tout le fichier avec **Maj G** puis on indente avec **=**
- on écrit et on quitte le fichier **:wq**
- Changer valeur de C **:%s/C/la valeur/**
---
#### Rappels ssh
https://linuxconfig.org/how-to-install-start-and-connect-to-ssh-server-on-fedora-linux

Vérifier ssh, télécharger si manquant et activer.
````
rpm -qa | grep openssh-server

sudo dnf install openssh-server

sudo systemctl enable sshd

sudo systemctl start sshd

sudo ss -lt
````
---
#### Rappel Visual studio code
- **CTRL SHIFT P** pour ouvrir la palette de commande
- Choisir **Remote-SSh** pour ouvrir la session, puis définir le compte et donner le mot de passe ensuite.
---
#### Autres rappels
https://rebootinformatique.org/tutos/cours/fichiers_systeme/co/arborescence.html

````
sudo chown -R bob:bob fromroot
````
https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/7/html/networking_guide/sec-dhcp-configuring-server#config-file
https://doc.ubuntu-fr.org/isc-dhcp-server
---
#### Markdown pour prise de notes légères et formatables
https://www.markdownguide.org/getting-started/

Application
http://tvaira.free.fr/projets/activites/markdown-vscode.pdf

=========== Rocky linux minimal
OPENSSH ?
rpm -qa | grep openssh

sudo firewall-cmd --list-all
rpm
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --reload

sudo nano /etc/ssh/sshd_config

journalctl -xeu dhcpd.service

============== SELINUX

https://phoenixnap.com/kb/enable-selinux-centos

??????????????????????
https://passandsecure.fr/installation_de_almalinux_9_4

[ipv4]
# Changer en manual
method=manual
# addresses1=votre_ip/masque_CIDR,votre_passerelle
addresses1=192.168.194.50/24,192.168.194.2
# dns google
dns=8.8.8.8;8.8.4.4;

[ipv6]
# changer en ignore
method=ignore

https://blog.stephane-robert.info/docs/admin-serveurs/linux/reseaux/

https://www.it-connect.fr/chapitres/comment-configurer-le-reseau-avec-ifconfig/?utm_content=cmp-true

https://www.linuxtricks.fr/wiki/la-commande-ip-reseau-interfaces-routage-table-arp

https://www.baeldung.com/linux/clear-ip-address-no-downtime

https://www.formatux.fr/formatux-bash/module-020-mecanismes-base/index.html

