strongswan ipsec linux???

https://www.youtube.com/watch?v=xTH1ZA_qUvA
https://www.youtube.com/watch?v=15amNny_kKI

https://libreswan.org/
https://strongswan.org/

https://www.thibautprobst.fr/fr/posts/ipsec/
https://theko2fi.medium.com/comment-mettre-en-place-un-tunnel-vpn-ipsec-site-%C3%A0-site-sur-linux-en-utilisant-strongswan-1cafddd24053

https://le-guide-du-secops.fr/2021/09/02/installation-et-configuration-dun-vpn-ikev2-debian-ubuntu-demo-avec-un-appareil-ios/

https://vincent.bernat.ch/fr/blog/2017-vpn-ipsec-route

https://wiki.csnu.org/index.php/IPsec_sous_debian_avec_strongswan

---
##  Tunnel chiffré IPsec entre 2 serveurs
cg
- **Serveur 1 (Nginx - Reverse Proxy)** : IP publique `A.A.A.A`
- **Serveur 2 (Apache2 - Backend)** : IP publique `B.B.B.B`
- But : Tout le trafic entre Nginx et Apache2 passe dans un **tunnel IPsec sécurisé**

---
##  Étapes pour créer un tunnel IPsec

c'est peut-etre par là qu'il faut commencer,
un VPN ipsec c'est 2 etapes qui sont grosso modo :
- identification sur remote et du local via leurs IPs publiques
- definition des reseaux disponibles de chaque coté (le routage)

On va utiliser **StrongSwan**, une solution IPsec très répandue sous Linux.

---
###  1. Installer StrongSwan

Sur **les deux serveurs** (Nginx et Apache2) :

```bash
sudo apt update
sudo apt install strongswan
```

---
###  2. Configuration de StrongSwan

#### Sur le serveur **Nginx (Client IPsec)**

Fichier : `/etc/ipsec.conf`

```conf
config setup
  charondebug="ike 2, knl 2, cfg 2"

conn nginx-to-apache
  left=A.A.A.A           # IP publique du serveur Nginx
  leftid=@nginx
  leftsubnet=0.0.0.0/0
  right=B.B.B.B          # IP publique du serveur Apache
  rightid=@apache
  rightsubnet=192.168.100.0/24    # Sous-réseau privé de Apache
  auto=start
  authby=secret
  ike=aes256-sha256-modp1024
  esp=aes256-sha256
```

#### Sur le serveur **Apache (Serveur IPsec)**

Fichier : `/etc/ipsec.conf`

```conf
config setup
  charondebug="ike 2, knl 2, cfg 2"

conn nginx-to-apache
  left=B.B.B.B           # IP publique du serveur Apache
  leftid=@apache
  leftsubnet=192.168.100.0/24
  right=A.A.A.A
  rightid=@nginx
  rightsubnet=0.0.0.0/0
  auto=start
  authby=secret
  ike=aes256-sha256-modp1024
  esp=aes256-sha256
```

---
###  3. Partager une clé secrète (PSK)

Fichier commun : `/etc/ipsec.secrets`

Sur les **deux serveurs**, ajoutez :

```conf
@nginx @apache : PSK "votreclefsecreteultrasecurisee"
```

---
###  4. Redémarrer StrongSwan

```bash
sudo ipsec restart
```

Puis vérifier l'état de la connexion :

```bash
sudo ipsec statusall
```

---
##  5. Adapter Nginx pour utiliser le tunnel

Dans votre config Nginx, au lieu de pointer vers une IP publique :

```nginx
location / {
    proxy_pass http://192.168.100.10;  # IP privée du backend Apache
}
```

- Cette IP doit être celle du backend dans le sous-réseau sécurisé IPsec (ex : `192.168.100.10`)
- Assurez-vous que le backend écoute bien sur cette interface.

---
##  6. Tester la connectivité

Depuis le serveur Nginx :

```bash
ping 192.168.100.10
curl http://192.168.100.10
```

---
##  Bonus : Firewall

- Ouvrez les ports UDP **500** et **4500** pour IPsec sur les deux serveurs.
- Autorisez le protocole **ESP** (protocol number 50).

---

Un script d’installation ou une version avec certificats (IKEv2 + X.509) ?