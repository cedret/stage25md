## Configurer un VPN IPSec/ikev2 rapidement (Debian/Ubuntu)
https://le-guide-du-secops.fr/2021/09/02/installation-et-configuration-dun-vpn-ikev2-debian-ubuntu-demo-avec-un-appareil-ios/
Publié par Geoffrey Sauvageot-Berland le 2 septembre 2021

Bonjour à tous ! Aujourd’hui nous allons découvrir comment mettre en place un VPN IPSec/Ikev2. Pour cela, nous utiliserons plusieurs scripts bash réalisés par Lin Song. Je le remercie d’avance pour son travail et sa contribution auprès de l’open source world, ainsi que pour la granularité de ses scripts qui vont grandement nous faciliter la tâche ci-dessous. Pour plus d’informations concernant son projet, je vous invite à consulter son repository github en question.

Petit rappel néamoins avant de commencer :
````
Internet Key Exchange est un protocole développé par Microsoft et Cisco en 1998.
Techniquement, ce n’est pas un protocole VPN. IKE est utilisé pour configurer une association de sécurité dans la suite de protocoles IPSec.
L’association de sécurité comprend des attributs tels que le chiffrement et la clé de cryptage du trafic.
Néanmoins, il est souvent traité comme un protocole VPN, appelé IKEv2, qui est simplement la deuxième version d’IKE, ou IKEv2/IPSec.
Contrairement à L2TP/IPSec, qui n’utilise IPSec que pour le cryptage, IKE utilise IPSec pour le transport des données.
IKEv2 utilise par ailleurs le port UDP 500.
````
https://github.com/hwdsl2/setup-ipsec-vpn/

Toutes les commandes ci-dessous seront exécutés « as root ». C’est parti ! 

**Table des matières**

    1. Rassemblement des dépendances requises
        Ouvrez les ports de votre routeur/box pour accéder à votre VPN depuis l’extérieur.
    2. Configuration du service VPN avec Ikev2
    3. Importation du certificat depuis un appareil IOS et test !
        En savoir plus sur Le Guide Du SecOps • LGDS

## 1. Rassemblement des dépendances requises 

Nous allons commencer par exécuter le script d’auto installation qui va nous permettre de tout mettre en place automatiquement.

``wget https://git.io/vpnsetup -O vpn.sh && sudo sh vpn.sh``

Sinon, si-vous souhaitez définir vos propres identifiants de connexion, exécutez plutôt cette commande (Optionnelle) :

````
wget https://git.io/vpnsetup -O vpn.sh
nano -w vpn.sh
[Replace with your own values: YOUR_IPSEC_PSK, YOUR_USERNAME and YOUR_PASSWORD]
sudo sh vpn.sh
````
Cette auto-installateur va s’occuper un VPN L2TP/IPsec (à l’origine son script mettait en place un VPN L2TP/IPSec). On est obligé de passer par la afin de réunir un ensemble de dépendances pour la suite.

gsb01.png

Les identifiants ci-dessus, vous permettent d’initier une connexion VPN L2TP/IPSec, même si ce n’est pas ce que nous souhaitons in fine, notez les biens, notamment si-vous souhaitez garder un accès à ce service au cas où votre VPN Ikev2 ne fonctionnerait plus pour une quelconque raison.

### Ouvrez les ports de votre routeur/box pour accéder à votre VPN depuis l’extérieur.

Ensuite, afin de rendre votre VPN accessible depuis l’extérieur, il faut obligatoirement ouvrir les ports suivants de votre box/routeur. Pour cela, renseignez-vous en consultant la documentation de votre box. Dans notre cas, il faut ouvrir deux port le 500 (ikev2) et le 4500 (ipsec) en mode TCP/UDP, et faire pointer cette règle vers l’adresse ip privé de votre machine. 



| IP source | Port source | IP destination | Port destination |
|-----|-----|------|-----|
|<ip privée de votre serveur>|500 (tcp,udp)|<votre ip publique>|500 (tcp,udp)|
|<ip privée de votre serveur>|4500 (tcp,udp)|<votre ip publique>|4500 (tcp,udp)|

Table NAT/PAT « générique », vous permettant de réaliser la redirection de ports sur votre routeur.
### 2. Configuration du service VPN avec Ikev2

Rien de plus simple, Lin Song a encore tout prévu (https://github.com/hwdsl2), grâce un script d’auto installation et de configuration. Elle n’est pas belle la vie (quand les choses sont bien faite dans l’open source ? ^^)


````
wget https://git.io/ikev2setup -O ikev2.sh && sudo bash ikev2.sh --auto
````
Notez bien le mot de passe qui vous est présenté. Vous ne pourrez pas le réafficher par la suite. Celui-ci nous permettra de pouvoir « déverrouiller » un certificat virtuelle pour la connexion du VPN depuis le client. 

### 3. Importation du certificat depuis un appareil IOS et test !

Dans le cas de ce tutoriel, je vais présenter uniquement la connexion au VPN depuis un appareil IOS, car Lin Song à une documentation très bien détaillée en fonction de chaque OS. Je vous encourage vivement à la consulter, notamment pour le paramétrage du VPN depuis un PC windows/linux. (Clairement je ne ferrai pas mieux que lui – La doc est très détaillé [pas à pas])

https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto.md

Pour ce faire, connectez-vous en FTP/SFTP à un serveur web, puis uploader le profil .mobileconfig à la racine d’un serveur WEB (temporairement bien sur) sinon renseignez-vous sur comment importer un certificat sur un appareil IOS autrement.
gsb03.png

````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````


````
vide
````







