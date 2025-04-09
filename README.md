# Notes techniques pour stage FV 2025

**Historique des étapes**

14/03/25: Exploration, hyperviseur, recherche configuration réseau

21/03/25: Exploration, Mise en place maquette Ubuntu 20, début script

28/03/25: Présentation solution avec SSL (et wireshark)

04/04/25: Présentation solution avec ipsec (et wireshark)
 -----> AJOUTER ssl entre client et rp?

08/04/25: màj de la gateway avec netplan !!!!

11/08

18/04

25/04

02/05

09/05

TESTS:
- ICMP?
- FTP?
## Github
https://www.youtube.com/@edutechional/playlists

### project
https://m.youtube.com/watch?v=YVFa5VljCDY

### Actions
https://www.youtube.com/watch?v=mFFXuXjVgkU

## Cloud/ nas
https://rclone.org/
https://www.youtube.com/watch?v=YvhYruBlDPU
https://www.youtube.com/watch?v=cPvqMNiq8qI

## Linux
### Commandes
https://www.youtube.com/watch?v=3nQI60toL7Q&list=PLjAHiXDnp3JnBxylj-d4CgUHJSL9Q8kOb

### IPsec
https://www.youtube.com/watch?v=V9bTy0gbXIQ&list=PLOapGKeH_KhFBC39ltMDhkEx1aI3hlwSK

https://theko2fi.medium.com/comment-mettre-en-place-un-tunnel-vpn-ipsec-site-%C3%A0-site-sur-linux-en-utilisant-strongswan-1cafddd24053

https://www.thibautprobst.fr/fr/posts/ipsec/

https://le-guide-du-secops.fr/2021/09/02/installation-et-configuration-dun-vpn-ikev2-debian-ubuntu-demo-avec-un-appareil-ios/

https://vincent.bernat.ch/fr/blog/2017-vpn-ipsec-route

https://wiki.csnu.org/index.php/IPsec_sous_debian_avec_strongswan

https://docs.logrhythm.com/lrsiem/docs/configure-ipsec-on-linux-machine

https://linuxfr.org/forums/linux-debian-ubuntu/posts/configuration-ipsec


## Menu while/do avec bash

````
#!/bin/bash
echo -n "

1. healthchk
2. bpipwd
3. cust_usage_check
4. other scripts automatic

enter choice [1 | 2 | 3 | 4 ]: "
read numchoice

while [ !($numchoice -ge 1) && !($numchoice -le 4) ]
do
echo -n "you entered incorrect, try again: "
read numchoice
done
````
