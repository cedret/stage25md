## IPsec linux avec strongswan

https://libreswan.org/
https://strongswan.org/
cg

---
## A - Tunnel chiffré IPsec dans un même réseau local

- **Chiffrer** le trafic même en LAN (ex : environnement sensible, données critiques)
- **Segmenter la communication** (ex : éviter qu’un autre hôte sur le LAN sniffe les paquets)

###  1. Installer StrongSwan

Sur **chaque serveur** Nginx et Apache2:

```bash
sudo apt update
sudo apt install strongswan
```
###  2. Configuration de StrongSwan

#### Sur Apache :

Editer `/etc/ipsec.conf`

````
# Configuration logs et comportement moteur 'charon'
config setup
  charondebug="ike 2, knl 2, cfg 2"

# Configuration connexion
conn apache-to-nginx
  left=192.168.80.139             # L’IP locale de cette machine (Apache)
  leftid=@apache                  # Identité (utilisée pour s’authentifier)
  leftsubnet=192.168.80.139/32    # Le(s) réseau(x) protégé(s) localement

  right=192.168.80.102            # L’IP de l’autre machine (Nginx)
  rightid=@nginx
  rightsubnet=192.168.80.102/32   # Réseaux à atteindre via le tunnel

  authby=secret                   # Méthode d’authentification (PSK)
  auto=start                      # Démarrer automatiquement
  ike=aes256-sha256-modp1024      # Algo phase 1
  esp=aes256-sha256               # Algo phase 2
````
>Utiliser `leftsubnet=0.0.0.0/0` ou `leftsubnet=192.168.10.0/24` pour faire un **tunnel entre plusieurs services** dans les deux machines et pas juste un one-to-one.

#### Sur Nginx

Editer `/etc/ipsec.conf`

```conf
config setup
  charondebug="ike 2, knl 2, cfg 2"

conn nginx-to-apache
  left=192.168.80.102
  leftid=@nginx
  leftsubnet=192.168.80.102/32
  right=192.168.80.139
  rightid=@apache
  rightsubnet=192.168.80.139/32
  auto=start
  authby=secret
  ike=aes256-sha256-modp1024
  esp=aes256-sha256
```

>Utiliser `leftsubnet=0.0.0.0/0` ou `leftsubnet=192.168.10.0/24` pour faire un **tunnel entre plusieurs services** dans les deux machines et pas juste un one-to-one.

### 3. Clé sur Nginx & Apache

Sur **chaque serveur**, éditer : `/etc/ipsec.secrets`
```conf
@nginx @apache : PSK "987654321"
```

### 4. Nginx vers Apache via IPsec

Dans la conf Nginx :

```nginx
location / {
    proxy_pass http://192.168.10.93;
}
```

Ce trafic passera par le tunnel, donc **chiffré IPsec**, dans le même LAN.

### 5. Vérification

Après avoir redémarré IPsec (`sudo ipsec restart`), tester:

```bash
ping 192.168.10.93
curl http://192.168.10.93
sudo ipsec statusall
```
Regarder les paquets IPsec avec `tcpdump` :

```bash
sudo tcpdump -i eth0 esp
```

---
## B - Tunnel chiffré IPsec entre 2 réseaux différents
cg
- **Serveur 1 (Nginx - Reverse Proxy)** : IP publique `A.A.A.A`
- **Serveur 2 (Apache2 - Backend)** : IP publique `B.B.B.B`

Tout le trafic entre Nginx et Apache2 passe dans un **tunnel IPsec sécurisé**

**Étapes pour créer un tunnel IPsec**

Un VPN ipsec en 2 étapes:
- identification sur remote et du local via leurs IPs publiques
- definition des reseaux disponibles de chaque coté (routage)

###  1. Installer StrongSwan

Sur **les deux serveurs** Nginx et Apache2 :

```bash
sudo apt update
sudo apt install strongswan
```
###  2. Configuration de StrongSwan

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

#### Sur le serveur **Nginx (Client IPsec)**

Editer : `/etc/ipsec.conf`

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
---
###  3. Partager une clé secrète (PSK)

Sur les **deux serveurs**, éditer :  `sudo nano /etc/ipsec.secrets`

```conf
@nginx @apache : PSK "987654321"
```

---
###  4. Redémarrer StrongSwan

```bash
sudo ipsec restart
```

Vérifier l'état de la connexion :

```bash
sudo ipsec statusall
```

---
###  5. Adapter Nginx pour utiliser le tunnel

Selon config Nginx, au lieu de pointer vers une IP publique :

```nginx
location / {
    proxy_pass http://192.168.100.10;  # IP privée du backend Apache
}
```
- Cette IP doit être celle du backend dans le sous-réseau sécurisé IPsec (ex : `192.168.100.10`)
- S'assurer que le backend écoute bien sur cette interface.

###  6. Tester la connectivité

Depuis le serveur Nginx :

```bash
ping 192.168.100.10
curl http://192.168.100.10
```

###  Extra: Firewall

- Ouvrez les ports UDP **500** et **4500** pour IPsec sur les deux serveurs.
- Autorisez le protocole **ESP** (protocol number 50).