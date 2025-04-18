## IPSEC / Strongswan

## 16/07/2022
https://www.thibautprobst.fr/fr/posts/ipsec/

Sommaire

    Introduction
    IPsec : la théorie
        AH et ESP
        Mode transport et mode tunnel
        ISAKMP et IKE
        NAT-T
    IPsec : la pratique avec strongSwan sur Debian
        Installation de strongSwan
        Configuration d’IPsec
        Etablissement du tunnel
        Transfert de données dans le tunnel
    Conclusion
    Sources

Dans cet article, je vous propose de décortiquer le concept de réseau privé virtuel ou **Virtual Private Network (VPN)** avec le protocole **Internet Protocol Security (IPsec)**. L’objectif est de vous aider à mieux comprendre les différentes étapes de mise en place d’un tunnel IPsec qui s’appuie sur différents protocoles ainsi que de vous montrer un exemple concret pas-à-pas sur le système d’exploitation Debian GNU/Linux à l’aide de la solution **strongSwan**.

### Introduction

Les tunnels, dans le contexte des réseaux, permettent de faire communiquer des informations d’un réseau sur un autre réseau par encapsulation des données, un peu comme si vous empruntiez un tunnel pour traverser une montagne difficile à franchir autrement afin de vous rendre d’une vallée à une autre. Généralement, cela permet de faire communiquer entre eux deux réseaux privés (les vallées), c’est-à-dire non routés sur Internet, en utilisant un réseau public comme Internet (la montagne) comme transport sous-jacent. Dans ce cas, cela s’appelle un VPN. Il existe d’autres intérêts à mettre en place des tunnels et différents type de protocoles réseaux permettant la réalisation de ces derniers. Nous allons nous intéresser ici à IPsec, un protocole permettant la mise en place de VPN client-à-site (un hôte vers un réseau distant, par exemple des employés en télétravail connectés à leur réseau d’entreprise) ou site-à-site (un réseau vers un autre réseau distant, par exemple le réseau d’un site d’entreprise satellite connecté au réseau du site principal de l’entreprise).
De mon expérience, j’ai croisé IPsec dans de nombreuses implémentations et il est parfois mal compris dans sa mise en place. Au-delà de se contenter de le “faire marcher”, il est primordial de comprendre les différents mécanismes mis en jeu afin d’effectuer les bons choix de configuration et faciliter la maintenance et le dépannage.

### IPsec : la théorie

IPsec est en réalité une suite de protocoles permettant le transfert des données de manières sécurisées et permettant la négociation des paramètres de sécurité nécessaires. IPsec propose en outre différents modes de fonctionnement définissant la manière d’acheminer les données.

### AH et ESP

Deux protocoles opérant au-dessus du protocole Internet Protocol (IP) permettent de proposer des fonctionnalités différentes pour le transfert des données transmises dans le cadre d’IPsec :

> Authentication Header (AH) offre
> - l’intégrité des données (les données n’ont pas été altérées)
> - l’authentification des données (les données proviennent bien de l’adresse source du paquet) pour le paquet IP entier.

> Encapsulating Security Payload (ESP) offre
> - l’intégrité des données
> - la confidentialité des données (les données n’ont pas été divulguées)
> - l'authentification des données pour les données (ou payload) du paquet IP.

Il est à noter que les deux protocoles ci-dessous ont un mécanisme d’anti-rejeu ou anti-replay afin d’éviter le rejeu ou l’injection malveillante de paquets à l’aide de numéros de séquences. Aussi, AH et ESP peuvent éventuellement être combinés.

### Mode transport et mode tunnel

IPsec peut opérer en mode transport ou en mode tunnel selon le besoin.


**En-têtes AH et ESP en mode transport**
> En mode transport, la payload originelle est conservée dans le paquet IP originel auquel on ajoute un en-tête ESP et/ou AH. Ce mode est utilisé pour sécuriser le transfert d’information sans établir un VPN. 
![alt ipsec1](mdimages/ipsec01.png)


**En-têtes AH et ESP en mode tunnel**
> En mode tunnel, le paquet IP originel (en-tête IP et données sous-jacentes, à savoir la payload) est encapsulé dans un nouveau paquet IP avec un en-tête ESP et/ou AH. Ce mode est utilisé pour établir des VPN.

![alt ipsec1](mdimages/ipsec02.png)


ISAKMP et IKE

Un autre protocole est utilisé pour l’établissement du tunnel de manière sécurisée : Internet Security Association and Key Management Protocol (ISAKMP) qui permet l’échange de clés de chiffrement et l’authentification des membres. ISAKMP est en fait plus un cadre qui est implémenté via différents protocoles possibles : Internet Key Exchange (IKE), Kerberized Internet Negociation of Keys (KINK)…

L’objectif de ces protocoles est de construire des **associations de sécurité** ou **Security Associations (SA)** qui sont des ensembles d’attributs (algorithme de chiffrement, clés de chiffrement, fonction de hachage, fonction pseudo-aléatoire, identifiants, etc.) rendant possible une communication sécurisée via AH ou ESP.

IKE est très largement employé et repose sur le protocole *User Datagram Protocol (UDP)* avec le port 500. Il permet la réalisation de différentes opérations :

- Authentification à base de certificats numériques ou de clés prédéfinies et partagées ou pre-shared key (PSK).
- Echange de clés de chiffrement à base de la méthode d’échange de clés Diffie-Hellman (DH).
- Cela permet la définition d’un secret partagé via l’envoi d’informations en clair sur le réseau alors non sécurisé, en reposant sur le principe mathématique que pour un attaquant qui intercepterait ces informations, l’exponentiation est extrêmement difficile à inverser via le logarithme discret.
- La valeur du module arithmétique utilisée est spécifiée via des groupes numérotés (plus la valeur du groupe est grande, plus la taille du module est grande ce qui renforce l’échange de clés).

Je vous invite à lire cette page pour plus de détails.
https://fr.wikipedia.org/wiki/%C3%89change_de_cl%C3%A9s_Diffie-Hellman

IKE existe en deux versions : IKEv1 et IKEv2. Cette dernière est plus performante et plus sécurisée que sa prédécésseur, c’est pourquoi je ne vais m’intéresser ici qu’à IKEv2. Le protocole IKEv2 est un ensemble d’échange de requêtes et réponses structurés et visant à définir des SA d’abord pour chiffrer l’échange IKE puis pour chiffrer l’échange de données via ESP et/ou AH :

- IKE_SA_INIT : échange pour négocier les paramètres de sécurité (algorithme de chiffrement pour la confidentialité, fonction de hachage pour l’intégrité, fonction pseudo-aléatoire ou Pseudo-Random Function pour dériver les clés de chiffrement à partir de la négociation initiale, groupe et valeur DH pour l’échange de clés initial, nonce pour éviter le rejeu des valeurs cryptographiques calculées).
- IKE_AUTH : échange pour transmettre les identités et création de la première SA ESP et/ou AH.
- INFORMATIONAL : échange pour vérifier la continuitié d’une SA, supprimer des SA, reporter des erreurs, etc.
- CREATE_CHILD_SA : échange pour créer des SA ESP et/ou AH supplémentaires.

**Echanges IKEv2**
![alt ipsec3](mdimages/ipsec03.png)

IPsec permet d’obtenir de la **confidentialité persistente ou Forward Secrecy (FS)** ou encore **Perfect Forward Secrecy (PFS)** en négociant des clés de chiffrements différentes via un nouvel échange DH et ce pour chaque nouvelle SA avec IKE. Ainsi, si les secrets utilisés pour la génération de clés étaient compromis par un attaquant, les communications passées ne sont pas compromises.

### NAT-T

En utilisant IPsec, plusieurs problèmes peuvent apparaitre à cause d’une éventuelle utilisation de la *traduction d’adresse* ou *Network Address Translation (NAT)*. En effet, si une traduction d’adresse source dans l’en-tête IP est effectuée sur le chemin entre les deux passerelles essayant de négocier l’établissement du tunnel, l’adresse d’une passerelle étant modifiée, l’authenticité de cette dernière ne peut pas être vérifiée par son homologue ce qui empêche la mise en place du tunnel avec IKE. De plus, avec le protocole ESP, il n’y a pas d’en-tête TCP ou UDP qui offrent des sommes de contrôles (checksum) et des numéros de ports permettant le multiplexage de paquets via la modification des ports destination avec du Port Address Translation (PAT).

Pour résoudre ces problèmes, IKE est ainsi capable de détecter la présence de NAT appliqué entre les deux passerelles et de déclencher l’encapsulation des paquets IKE puis ESP dans un segment UDP avec le port (source et destination) 4500. Cela s’appelle le **NAT-Traversal (NAT-T)**. On peut alors réussir la négociation du tunnel puis effectuer du PAT sur le chemin si besoin grâce au nouvel en-tête UDP offrant des numéros de port.

Notez que AH n’est pas supporté par le NAT-T, car l’authentification AH repose justement sur le fait de ne pas modifier l’en-tête IP (ce qui n’est pas le cas pour ESP). L’utilisation de NAT-T est très répandue de par l’intense utilisation de NAT sur Internet. L’emploi d’AH se retrouve alors restreinte.

**En-tête ESP en mode tunnel avec NAT-T**
![alt ipsec1](mdimages/ipsec04.png)

Dans la suite de cet article, nous allons voir concrètement la mise en place d’un VPN IPsec par un exemple et creuser encore un peu plus certains aspects techniques.

## IPsec : la pratique avec strongSwan sur Debian

Lorsqu’on monte un tunnel VPN, il y a donc plusieurs éléments principaux à choisir dans sa conception :

- Le protocole : AH ou ESP, qui dépend des propriétés de sécurité souhaitées et de l’utilisation de NAT.
- L’utilisation de NAT-T ou non.
- Le mode : transport ou tunnel.
- Les différents algorithmes de chiffrement, fonction de hachage, fonction pseudo-aléatoire et le groupe DH.
- La méthode utilisée pour l’authentification : certificats numériques ou PSK.

Pour aller plus loin, je vous propose un exemple d’implémentation d’IPsec ESP avec IKEv2 par authentification PSK en mode tunnel sur la plateforme Debian grâce à la solution strongSwan. Cette dernière est une solution open source supportant de nombreux protocoles et modes de fonctionnement pour réaliser des VPN IPsec.
https://www.strongswan.org/

Le schéma ci-dessous illustre la maquette utilisée qui est composée de 2 passerelles (Gateway 1 et Gateway 2) établissant un VPN IPsec pour interconnecter un client et un serveur distant.

**Maquette IPsec**
![alt ipsec5](mdimages/ipsec05.png)


### Installation de strongSwan

Sur chaque passerelle, installez le paquet ou package strongSwan : 
``$ sudo -- sh -c 'apt-get update && apt-get install -y strongswan'``

Sur chaque passerelle, vérifiez que le service strongswan est actif : 
````
$ systemctl status strongswan-starter.service ; systemctl is-enabled strongswan-starter.service
● strongswan-starter.service - strongSwan IPsec IKEv1/IKEv2 daemon using ipsec.conf
     Loaded: loaded (/lib/systemd/system/strongswan-starter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2022-07-16 09:04:05 UTC; 20min ago
   Main PID: 3207 (starter)
      Tasks: 18 (limit: 529)
     Memory: 2.1M
        CPU: 13ms
     CGroup: /system.slice/strongswan-starter.service
             ├─3207 /usr/lib/ipsec/starter --daemon charon --nofork
             └─3211 /usr/lib/ipsec/charon
enabled
````
Les passerelles devant être en capacité d’effectuer du routage de paquet, activez le routage de paquet (ou IP Forwarding) sur chaque passerelle :

``$ sudo sysctl -w net.ipv4.ip_forward=1``

### Configuration d’IPsec

Sur chaque passerelle, sauvegardez le fichier configuration IPsec par défaut : 

``$ sudo mv /etc/ipsec.conf /etc/ipsec.conf.bkp``

Sur chaque passerelle, créez un nouveau fichier de configuration IPsec :

``$ sudo vim /etc/ipsec.conf``

Sur la passerelle *Gateway 1*, insérez-y la configuration suivante : 
````
config setup
        charondebug="all"
        uniqueids=yes
conn ipsec-example
        type=tunnel
        auto=start
        keyexchange=ikev2
        authby=psk
        left=193.167.10.14
        leftsubnet=10.10.1.0/24
        right=193.167.10.13
        rightsubnet=10.10.2.0/24
        ike=aes256gcm16-sha256-modp1024!
        esp=aes256gcm16-sha256-modp1024!
        keyingtries=%forever
        ikelifetime=60s
        lifetime=30s
        dpddelay=10s
        dpdaction=restart
````

Sur la passerelle *Gateway 2*, insérez-y la configuration suivante : 

````
config setup
        charondebug="all"
        uniqueids=yes
conn ipsec-example
        type=tunnel
        auto=start
        keyexchange=ikev2
        authby=psk
        left=193.167.10.13
        leftsubnet=10.10.2.0/24
        right=193.167.10.14
        rightsubnet=10.10.1.0/24
        ike=aes256gcm16-sha256-modp1024!
        esp=aes256gcm16-sha256-modp1024!
        keyingtries=%forever
        ikelifetime=60s
        lifetime=30s
        dpddelay=10s
        dpdaction=restart
````

Détaillons chacun de ces paramètres (je vous invite aussi à lire la documentation officielle) :
https://wiki.strongswan.org/projects/strongswan/wiki/ConfigurationFiles

- config setup : section définissant les paramètres généraux
> - charondebug="all" : défini le niveau d’information de logging (où généralement le fichier /var/log/syslog est utilisé) par le démon charon en charge d’implémenter IKEv2 pour strongSwan. Ici nous choisissons de logguer tous les messages.
> - uniqueids=yes: défini si un identifiant unique doit être utilisé par chaque SA. Ici nous choisissons que oui.
- conn ipsec-example : section définissant les paramètres de connexion IPsec. Ici nous nommons la section ipsec-example.
> - type=tunnel: défini le mode IPsec. Ici nous choisissons le mode tunnel.
> - auto=start: défini l’action à effectuer au démarrage du démon. Ici nous choisissons de charger les paramètres et de démarrer la connexion IPsec.
        keyexchange=ikev2: défini le protocole pour l’établissement du tunnel sécurisé. Ici nous choisissons IKEv2.
        authby=psk: défini la méthode d’authentification. Ici nous choisissons PSK.
        left=193.167.10.13 : défini l’adresse IP externe (utilisée pour monter le tunnel) de la première passerelle. Ici il s’agit de l’adresse de l’interface eth2 de la passerelle Gateway 1 ou Gateway 2 (à inverser selon que la configuration est celle de Gateway 1 ou Gateway 2).
        leftsubnet=10.10.2.0/24 : défini l’adresse du réseau interne associé à la première passerelle. Ici il s’agit du réseau associé à la passerelle Gateway 1 ou Gateway 2 (à inverser selon que la configuration est celle de Gateway 1 ou Gateway 2).
        right=193.167.10.14 : défini l’adresse IP externe (utilisée pour monter le tunnel) de la deuxième passerelle. Ici il s’agit de l’adresse de l’interface eth2 de la passerelle Gateway 2 ou Gateway 1 (à inverser selon que la configuration est celle de Gateway 2 ou Gateway 1).
        rightsubnet=10.10.1.0/24 : défini l’adresse du réseau interne associé à la deuxième passerelle. Ici il s’agit du réseau associé à la passerelle Gateway 2 ou Gateway 1 (à inverser selon que la configuration est celle de Gateway 2 ou Gateway 1).
        ike=aes256gcm16-sha256-modp1024! : défini la suite cryptographique ou cipher suite (algorithme de chiffrement, fonction de hachage et groupe DH qui contient ici la longueur du module arithmétique) pour les SA IKE. Ici nous choisissons l’algorithme Advanced Encryption Standard (AES) avec une longueur de clé de chiffrement de 256 bits et le mode d’opération Galois/Counter Mode (GCM) qui permet d’ajouter une fonction d’authentification supplémentaire ; la fonction de hachage Secure Hash Algorithm 256 (SHA-256) permettant de générer une empreinte de 256 bits pour le contrôle d’intégrité des données et en tant que fonction pseudo-aléatoire ; le groupe 2 DH utilisant un module arithmétique de 1024 bits. Vous pouvez consulter ici l’ensemble des valeurs possibles.
        esp=aes256gcm16-sha256-modp1024!! : défini la suite cryptographique ou cipher suite (algorithme de chiffrement, fonction de hachage et groupe DH qui contient ici la longueur du module arithmétique) pour les SA ESP. Ici nous choisissons l’algorithme AES avec une longueur de clé de chiffrement de 256 bits et le mode d’opération GCM qui permet d’ajouter une fonction d’authentification supplémentaire ; la fonction de hachage SHA-256 permettant de générer une empreinte de 256 bits pour le contrôle d’intégrité des données et en tant que fonction pseudo-aléatoire ; le groupe 2 DH utilisant un module arithmétique de 1024 bits ce qui permet ici de demander un nouvel échange DH lors de la renégociation des SA. Vous pouvez consulter ici l’ensemble des valeurs possibles.
        keyingtries=%forever : défini le nombre de tentatives pour négocier une connexion. Ici nous choisissons de tenter en boucle.
        ikelifetime=60s : défini la durée de validité d’un canal de négociation IKE (donc d’une SA IKE) avant renégociation. Ici nous choisissons volontairement une valeur très basse, à savoir 60 secondes.
        lifetime=30s : défini la durée de validité d’une SA pour l’envoi des paquets de données. Ici nous choisissons volontairement une valeur très basse à savoir 30 secondes.
        dpddelay=10s : défini l’intervalle entre deux paquets IKE INFORMATIONAL si aucun trafic n’est reçu. Ici nous choisissons volontairement une valeur basse à savoir 10 secondes.
        dpdaction=restart: défini l’action à effectuer en cas de timeout à la suite de l’envoi des messages IKE INFORMATIONAL. Ici nous choisissons de relancer la négociation IKE.

Ensuite, générez une PSK sur une des passerelle (ici nous choisissons une valeur aléatoire codée en Base64 sur 32 octets, ce qui donne une entropie suffisamment élevée) :

````
$ openssl rand -base64 32
pH56SwETVACv0FaMjPv28fH3Jkq6PVqeeRCvlTZtKCk=
````
Sur la passerelle Gateway 1, ajoutez la PSK à la configuration IPsec :

``$ echo "193.167.10.14 192.167.10.13 : PSK \"pH56SwETVACv0FaMjPv28fH3Jkq6PVqeeRCvlTZtKCk=\"" | sudo tee -a /etc/ipsec.secrets``

Sur la passerelle Gateway 2, ajoutez la PSK à la configuration IPsec : 

``$ echo "193.167.10.13 192.167.10.14 : PSK \"pH56SwETVACv0FaMjPv28fH3Jkq6PVqeeRCvlTZtKCk=\"" | sudo tee -a /etc/ipsec.secrets``

### Etablissement du tunnel

Lancez l’établissement du tunnel en démarrant le démon IKE charon avec la configuration IPsec sur chaque passerelle : 

## IPsec

1. Confidentialité
2. Intégrité
3. Authentification
4. Anti play

