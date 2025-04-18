## Comment mettre en place un tunnel VPN IPsec Site-à-Site sur Linux en utilisant Strongswan ?

https://theko2fi.medium.com/comment-mettre-en-place-un-tunnel-vpn-ipsec-site-%C3%A0-site-sur-linux-en-utilisant-strongswan-1cafddd24053

Administrateur systèmes avec une appétence pour le Cloud et le DevOps
Kenneth KOFFI - Aug 15, 2022

L’intérêt de mettre en place un tunnel VPN pour le transit de données d’un appareil à un autre n’est plus à démontrer. Et si vous êtes là, c’est simplement parce que vous avez à cœur la sécurité de vos données. Alors je ne vous ferai pas perdre plus de temps. Ici, je vous montrerai comment mettre en place un tunnel VPN IPSec site-à-site entre des serveurs Linux via le package Strongswan.

### Pré-requis
Pour suivre ce tutoriel, vous aurez besoin de:

    2 réseaux privés dans le cloud (Virtual Private Cloud Network)
    d’au moins 2 serveurs Linux Ubuntu

Pour ma part, je vais utiliser 4 serveurs Ubuntu 22.04 LTS. Pourquoi 4 ? Parce que la volonté de rédiger cet article est aussi née de la frustration de ne pas trouver de tutoriels sur le net qui vont jusqu’au bout. Voilà donc ce à quoi devrait ressembler notre architecture finale.

### Architecture
![Markdown image](mdimages/kkoffi01.png)

### Inventaire
#### Site A: 10.116.0.0/24

    Serveur VPN A
    - adresse IP publique: 137.184.216.2
    - adresse IP privée: 10.116.0.3
    Client A
    - adresse IP privée: 10.116.0.4

#### Site B: 10.114.0.0/24

    Serveur VPN B
    - adresse IP publique: 167.172.166.94
    - adresse IP privée: 10.114.0.2
    Client B
    - adresse IP privée: 10.114.0.3

### Configuration des serveurs VPN
#### Serveur VPN A

1. Installer le package strongswan :
````
	apt update
	apt upgrade -y
	apt install -y strongswan
````
2. Configurer le serveur VPN afin qu’il fonctionne comme un routeur. C’est-à-dire qu’il laisse passer les paquets d’une interface à l’autre et les transfère aux machines clientes de son réseau VPC :
````
	sysctl -w net.ipv4.ip_forward=1
	echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
````
3. Remplacer le contenu du fichier */etc/ipsec.conf* avec le contenu suivant :
````
# ipsec.conf - strongSwan IPsec configuration file
# basic configuration
config setup
   # strictcrlpolicy=yes
   # uniqueids = no
# Add connections here.conn %default
   ikelifetime=60m
   keylife=20m
   rekeymargin=3m
   keyingtries=1
   keyexchange=ikev2
   authby=secret
conn A-B
   left=137.184.216.2 #adresse IP publique du serveur VPN A
   leftsubnet=10.116.0.0/24 #adresse réseau du site A
   leftid=137.184.216.2
   right=167.172.166.94 #adresse IP publique du serveur VPN B
   rightsubnet=10.114.0.0/24 #adresse réseau du site B
   rightid=167.172.166.94
   auto=start
   leftupdown=/etc/strongswan.d/updown.sh
   ike=aes256-sha256-modp2048
   esp=aes256-sha256-modp2048
````

Veuillez consulter la documentation très riche de strongswan pour en savoir plus sur les différents paramètres et algorithmes disponibles.
https://docs.strongswan.org/docs/5.9/index.html

4. Créer et éditer le fichier */etc/strongswan.d/updown.sh* avec le contenu suivant :
````
#!/bin/bash
case "${PLUTO_VERB}" in
        up-client)
           ip route add 10.116.0.4 dev eth1 src 10.116.0.3 table 220 
         ;;
esac
````

5. Rendre le fichier ci-dessus exécutable :

``chmod +x /etc/strongswan.d/updown.sh``

Ce script s’exécutera chaque fois que le tunnel se mettra en place. Il permet d’ajouter une route vers la machine cliente A dans la table 220, table utilisée par strongswan.

6. Éditer le fichier */etc/ipsec.secrets* avec le contenu suivant :
````
137.184.216.2 167.172.166.94 : PSK "LaClePartage1234"
````

7. Lancer la connexion du tunnel :
````
ipsec restart
ipsec up A-B
````
Ici A-B représente le nom de la connexion précisée dans le fichier */etc/ipsec.conf*

#### Serveur VPN B

Pour la configuration du Serveur VPN B, répéter les étapes 1 et 2 précédentes.
3. Inverser le nom de la connexion et les adresses IP comme suit :
````
# ipsec.conf - strongSwan IPsec configuration file
# basic configurationconfig setup
   # strictcrlpolicy=yes
   # uniqueids = no
# Add connections here.
conn %default
   ikelifetime=60m
   keylife=20m
   rekeymargin=3m
   keyingtries=1
   keyexchange=ikev2
   authby=secret
conn B-A
   left=167.172.166.94 #adresse IP publique du serveur VPN B
   leftsubnet=10.114.0.0/24 #adresse réseau du site B
   leftid=167.172.166.94
   right=137.184.216.2 #adresse IP publique du serveur VPN A
   rightsubnet=10.116.0.0/24 #adresse réseau du site A
   rightid=137.184.216.2
   auto=start
   leftupdown=/etc/strongswan.d/updown.sh
   ike=aes256-sha256-modp2048
   esp=aes256-sha256-modp2048
````

4. Remplacer les adresses IP privées par celles du serveur client B et du serveur VPN B, comme suit :
````

#!/bin/bashcase "${PLUTO_VERB}" in
        up-client)
           ip route add 10.114.0.3 dev eth1 src 10.114.0.2 table 220 
         ;;
esac
````

5. Identique
``chmod +x /etc/strongswan.d/updown.sh``

6. Inverser les adresses IP comme suit :
````
167.172.166.94 137.184.216.2 : PSK "LaClePartage1234"
````

7. Lancer la connexion du tunnel :
````
ipsec restart
ipsec up B-A
````

Et voilà ! Vous avez connecté vos deux sites via VPN.
L’exécution de la commande ``ipsec status`` devrait fournir une sortie similaire :

![Markdown image](mdimages/kkoffi02.png)

### Configuration des machines clients

Maintenant nous allons introduire les machines clientes de chaque Site. Sur chaque machine cliente, nous allons simplement indiquer que la route vers le réseau distant doit passer par l’adresse IP privée du serveur VPN.
#### Client A

Exécuter la commande suivante :

``ip route add 10.114.0.0/24 via 10.116.0.3 dev eth1 src 10.116.0.4``

Cette commande indique à la machine cliente A, de router les paquets à destination du réseau du *site B (10.114.0.0/24)* via l’adresse IP privée du serveur *VPN A (10.116.0.3)* en passant par son interface privée (eth1) à partir de la source 10.116.0.4 (qui est l’adresse IP privée de la machine cliente A elle-même)
#### Client B

Exécuter la commande suivante :

``ip route add 10.116.0.0/24 via 10.114.0.2 dev eth1 src 10.114.0.3``
#### Résultat

Tout est terminé. Maintenant, toutes nos machines peuvent communiquer entre elles via leurs adresses IP privées. Ce qui n’était pas possible avant la mise en place du tunnel VPN.

Ici, j’essaie un ping depuis le client B vers le client A et voilà !

![Markdown image](mdimages/kkoffi03.png)

---
---

## Bonus

La route ajoutée par la commande ip route add n’est pas persistante. Au prochain redémarrage de l’appareil ou du service réseau, elle disparaitra. Pour la rendre persistante, il faut éditer sur les machines clientes, le fichier de configuration présent dans le dossier /etc/netplan/. De mon côté, le nom du fichier est 50-cloud-init.yaml. *Cela peut varier en fonction de la manière dont le système d’exploitation a été installé.*

Dans le fichier, il faut ajouter la section routes au niveau de l’interface privée (eth1 dans mon cas)
````
routes:
-   to: <réseau distant>
    via: <adresse IP privée du serveur VPN>
````
Par exemple, sur ma machine “client B” le fichier mis à jour ressemble à ceci :

![Markdown image](mdimages/kkoffi04.png)

Pour finir, exécuter la commande ``netplan apply`` afin d’appliquer le changement effectué.
Perspectives

Dans un prochain article, je vous montrerai comment automatiser le déploiement du tunnel VPN IPSec grâce à **Ansible**. Nous obtiendrons le même résultat qu’à la fin de ce tuto sans saisir la moindre commande sur nos serveurs et cela en moins de temps.