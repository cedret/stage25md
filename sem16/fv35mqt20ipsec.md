## IPsec linux avec strongswan

https://libreswan.org/
https://strongswan.org/

---
## A - Tunnel chiffré IPsec dans un réseau local
cg

Ah, parfait, si **Nginx (192.168.10.20)** et **Apache (192.168.10.93)** sont **déjà dans le même réseau local**, la donne change un peu. Voici les points importants :

- Tu veux **chiffrer** le trafic même en LAN (ex : environnement sensible, données critiques)
- Tu veux **segmenter la communication** (ex : éviter qu’un autre hôte sur le LAN sniffe les paquets)

** Inutile, si :**
- Tu fais confiance à ton LAN (ex : réseau isolé, aucune exposition, VLAN bien cloisonné)

###  1. Installer StrongSwan

Sur **les deux serveurs** (Nginx et Apache2) :

```bash
sudo apt update
sudo apt install strongswan
```
###  2. Configuration de StrongSwan

###  2. Configuration de StrongSwan

#### Sur **Nginx (192.168.10.20)** :

`/etc/ipsec.conf`

```conf
config setup
  charondebug="ike 2, knl 2, cfg 2"

conn nginx-to-apache
  left=192.168.10.20
  leftid=@nginx
  leftsubnet=192.168.10.20/32
  right=192.168.10.93
  rightid=@apache
  rightsubnet=192.168.10.93/32
  auto=start
  authby=secret
  ike=aes256-sha256-modp1024
  esp=aes256-sha256
```

>Utiliser `leftsubnet=0.0.0.0/0` ou `leftsubnet=192.168.10.0/24` si tu veux faire un **tunnel entre plusieurs services** dans les deux machines et pas juste un one-to-one.

#### Sur **Apache (192.168.10.93)** :

`/etc/ipsec.conf`

```conf
config setup
  charondebug="ike 2, knl 2, cfg 2"

conn nginx-to-apache
  left=192.168.10.93
  leftid=@apache
  leftsubnet=192.168.10.93/32
  right=192.168.10.20
  rightid=@nginx
  rightsubnet=192.168.10.20/32
  auto=start
  authby=secret
  ike=aes256-sha256-modp1024
  esp=aes256-sha256
```
>Utiliser `leftsubnet=0.0.0.0/0` ou `leftsubnet=192.168.10.0/24` si tu veux faire un **tunnel entre plusieurs services** dans les deux machines et pas juste un one-to-one.

### 3. Clé `/etc/ipsec.secrets` sur les deux :

```conf
@nginx @apache : PSK "clefSuperSecrete123"
```

### 4. Nginx vers Apache via IPsec

Dans ta conf Nginx :

```nginx
location / {
    proxy_pass http://192.168.10.93;
}
```

Ce trafic passera par le tunnel, donc **chiffré IPsec**, même s’il traverse le même LAN.

### 5. Vérification

Après avoir redémarré IPsec (`sudo ipsec restart`), teste :

```bash
ping 192.168.10.93
curl http://192.168.10.93
sudo ipsec statusall
```
Et tu peux regarder les paquets IPsec avec `tcpdump` :

```bash
sudo tcpdump -i eth0 esp
```

---
## B - Tunnel chiffré IPsec entre 2 réseaux différents
cg
- **Serveur 1 (Nginx - Reverse Proxy)** : IP publique `A.A.A.A`
- **Serveur 2 (Apache2 - Backend)** : IP publique `B.B.B.B`
- But : Tout le trafic entre Nginx et Apache2 passe dans un **tunnel IPsec sécurisé**

**Étapes pour créer un tunnel IPsec**

Un VPN ipsec c'est 2 etapes qui sont grosso modo :
- identification sur remote et du local via leurs IPs publiques
- definition des reseaux disponibles de chaque coté (le routage)

###  1. Installer StrongSwan

Sur **les deux serveurs** (Nginx et Apache2) :

```bash
sudo apt update
sudo apt install strongswan
```
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
###  5. Adapter Nginx pour utiliser le tunnel

Dans votre config Nginx, au lieu de pointer vers une IP publique :

```nginx
location / {
    proxy_pass http://192.168.100.10;  # IP privée du backend Apache
}
```

- Cette IP doit être celle du backend dans le sous-réseau sécurisé IPsec (ex : `192.168.100.10`)
- Assurez-vous que le backend écoute bien sur cette interface.

###  6. Tester la connectivité

Depuis le serveur Nginx :

```bash
ping 192.168.100.10
curl http://192.168.100.10
```

###  Bonus : Firewall

- Ouvrez les ports UDP **500** et **4500** pour IPsec sur les deux serveurs.
- Autorisez le protocole **ESP** (protocol number 50).