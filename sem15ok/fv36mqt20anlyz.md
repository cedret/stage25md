
## Wireshark
hafnium 2024-19'
https://www.youtube.com/watch?v=uEa1HLQRsfQ

Anson Alexander -2024 -20'
https://www.youtube.com/watch?v=qTaOZrDnMzQ

## Tshark

https://blog.atomicnetworks.co/cloud/comparisons/tshark-vs-tcpdump
https://synay.net/fr/support/kb/monitoring-network-linux-using-tshark-utility-command-line


``sudo apt update``
``sudo apt install tshark``

### Exemples
````
tshark -D
tshark -i 1 -c 8 test_tshark.pcap
tshark -i enp3s0 udp
tshark -i enp3s0 host 192.zzz.1.zzz
tshark -nnSX port 443
# en mode HEX
tshark -i enp3s0 -x host 192.zzz.1.zzz
# Capture journalisation
tshark -w /tmp/tshark-log.pcap -i enp3s0 -x host 192.zzz.1.zzz
# Affichage journalisation
tshark -r /tmp/tshark-log.pcap 
````
## TCPdump
Xavki
https://www.youtube.com/watch?v=eSiUFQavH7k

howtonetwork-6:20-2021-
https://www.youtube.com/watch?v=e45Kt1IYdCI
Rajneesh Gupta -2024 -30' -
https://www.youtube.com/watch?v=Ueiv3VxQd4k


``sudo apt install tcpdump``

## Test IPSEC
mistral
stage@srv20prod:~$ cat testipsec.sh
````
#!/bin/bash

blanc="\033[0m"
jaune="\033[1;33m"

# Variables
REMOTE_IP=192.168.80.139
PRE_SHARED_KEY=987654321

echo -e "\n${jaune}0-IP de cette machine${blanc}"
hostname -I

# Vérification de la connectivité réseau
echo -e "\n${jaune}1-Vérification de la connectivité réseau avec $REMOTE_IP...${blanc}"
ping -c 4 $REMOTE_IP
if [ $? -ne 0 ]; then
    echo "Échec de la connectivité réseau avec $REMOTE_IP."
    exit 1
fi

# Vérification des configurations de pare-feu
echo -e "\n2${jaune}-Vérification des configurations de pare-feu...${blanc}"
sudo iptables -L -v -n | grep $REMOTE_IP
if [ $? -ne 0 ]; then
    echo "Aucune règle de pare-feu trouvée pour $REMOTE_IP. Assurez-vous que les ports UDP 500 et 4500 sont ouverts."
#    exit 1
fi

# Vérification des clés pré-partagées
echo -e "\n${jaune}3-Vérification des clés pré-partagées...${blanc}"
if [ "$PRE_SHARED_KEY" == "<CLÉ_PRÉ-PARTAGÉE>" ]; then
    echo "Veuillez définir la clé pré-partagée dans le script."
    exit 1
fi

# Vérification des associations de sécurité (SA)
echo -e "\n${jaune}4-Vérification des associations de sécurité (SA)...${blanc}"
sudo ipsec statusall | grep "$REMOTE_IP"
if [ $? -ne 0 ]; then
    echo "Aucune association de sécurité (SA) trouvée pour $REMOTE_IP."
    exit 1
fi

# Vérification des journaux IPsec
echo -e "\n${jaune}5-Vérification des journaux IPsec...${blanc}"
sudo tail -n 50 /var/log/syslog | grep ipsec

echo -e "\n${jaune}Tous les tests ont été complétés avec succès.${blanc}"
````