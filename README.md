# Notes techniques pour stage FV 2025

**Historique des étapes**

- 14/03/25: Exploration, hyperviseur, recherche configuration réseau
> Contournement domaine
- 21/03/25: Exploration, Mise en place maquette Ubuntu 20, début script
- 28/03/25: Présentation solution avec SSL (et wireshark) ubuntu20
- 04/04/25: Présentation solution avec ipsec (et wireshark) ubuntu20
> AJOUTER ssl entre client et rp.
Passage sur Ubuntu24
- 08/04/25: màj de la gateway avec netplan !!!!
> Améliorer le script
> testé avec ubuntu 24: rvpx, liens ssl
> bloqué liens ipsec
- 11/08 Finaliser script avec ubuntu 20 ok (ipsec+ssl ok) et 24.
- 18/04 Progression et rédaction
- 25/04 Résultat test de mise en production ?
- 02/05 Fin des progressions
- 09/05 Soutenance

Tests ou renforcements: +TROUBLESHOUTING?
- TCP Dump
- ICMP?
- FTP?
- Diffie Helmann
- Firewall
- logs
- Ajout pr.test.fv, rp.test.fv dans hosts linux
- décomposition IPsec: C, I , A?
- AH et ESP ???

Schémas
- Flux de données dans le SI, et autour de la BDD.
- Ensemble du système (placer le pare-feu)
- Piles réseau? Interconnexions et dialogues selon protocoles

Comparatif SSL/IPSEC
- service de copie quotidienne de données avec ssh pour la liste des volontaires
- Avantage et inconvénients respectifs ou dans le SI actuel?

Niveaux de progression:
- Reproduction de la config au plus proche?
- Disponibilité ou compatibilité des versions?
- Solution simplifiée et stabilisée (reproductible)
- Exploration des axes de sécurité: SSL/ Ipsec +++ Options
- Solution plus proche du système existant
- Etapes vers la mise en production

Questions autour du service de production
- Impication de la bdd.
- restriction des adresses IP autorisées.

## Explorer en priorité
- https://www.instagram.com/dan_nanni/p/C-Fa8PjOX0D/?locale=es_ES
- https://medium.com/@alexandre_43174/exploring-the-best-diagram-as-code-tools-for-software-architecture-66a63b850075
- https://icepanel.medium.com/top-7-diagrams-as-code-tools-for-software-architecture-1a9dd0df1815
- https://blog.stephane-robert.info/post/devops-diagram-as-code/
- https://seifrajhi.github.io/blog/python-diagrams-as-code-architecture/
- https://dev.to/r0mymendez/diagram-as-code-creating-dynamic-and-interactive-documentation-for-visual-content-2p93

## Github
- https://www.youtube.com/@edutechional/playlists

### project
- https://m.youtube.com/watch?v=YVFa5VljCDY

### Actions
- https://www.youtube.com/watch?v=mFFXuXjVgkU

## Cloud/ nas
- https://rclone.org/
- https://www.youtube.com/watch?v=YvhYruBlDPU
- https://www.youtube.com/watch?v=cPvqMNiq8qI

## Linux
### Commandes
- https://www.youtube.com/watch?v=3nQI60toL7Q&list=PLjAHiXDnp3JnBxylj-d4CgUHJSL9Q8kOb

### IPsec
- https://www.youtube.com/watch?v=fW1TUByQqk8
- https://www.youtube.com/watch?v=V9bTy0gbXIQ&list=PLOapGKeH_KhFBC39ltMDhkEx1aI3hlwSK
- https://theko2fi.medium.com/comment-mettre-en-place-un-tunnel-vpn-ipsec-site-%C3%A0-site-sur-linux-en-utilisant-strongswan-1cafddd24053
- https://www.thibautprobst.fr/fr/posts/ipsec/
- https://le-guide-du-secops.fr/2021/09/02/installation-et-configuration-dun-vpn-ikev2-debian-ubuntu-demo-avec-un-appareil-ios/
- https://vincent.bernat.ch/fr/blog/2017-vpn-ipsec-route
- https://wiki.csnu.org/index.php/IPsec_sous_debian_avec_strongswan
- https://docs.logrhythm.com/lrsiem/docs/configure-ipsec-on-linux-machine
- https://linuxfr.org/forums/linux-debian-ubuntu/posts/configuration-ipsec

- https://www.hostinger.com/fr/tutoriels/reverse-proxy-nginx

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
