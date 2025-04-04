
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