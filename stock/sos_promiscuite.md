Pour activer le **mode promiscuité (Promiscuous Mode)** dans **VMware Workstation** pour une machine virtuelle Kali Linux (ou toute autre VM), voici les étapes à suivre :

---

### 🔧 Étapes pour activer le mode promiscuité :

1. **Ouvrir VMware Workstation**
   - Lance VMware Workstation en tant qu’administrateur (clic droit > "Exécuter en tant qu’administrateur").

2. **Configurer l’adaptateur réseau de la VM :**
   - Sélectionne ta machine virtuelle Kali.
   - Clique sur **Edit virtual machine settings**.
   - Dans l’onglet **Hardware**, clique sur **Network Adapter**.
   - Choisis un type de connexion réseau adapté :
     - **Bridged** (recommandé pour du sniffing sur un vrai réseau).
     - Ou **Custom: Specific virtual network (VMnetX)** si tu veux faire un réseau privé entre plusieurs VMs.

3. **Autoriser le mode promiscuité dans les paramètres de VMware :**

   - Va dans **Edit > Virtual Network Editor** (tu devras peut-être cliquer sur “Change Settings” pour l’ouvrir en mode admin).
   - Sélectionne le **VMnet** utilisé (ex: VMnet0 pour bridged, ou VMnet1/VMnet2 pour host-only ou custom).
   - Clique sur **"Change Settings"** si nécessaire.
   - Clique sur **"Advanced"**.
   - Dans la section **Promiscuous Mode**, choisis **"Allow All"**.

4. **Dans Kali, vérifier que la carte réseau autorise le mode promiscuité :**

   - Ouvre un terminal dans Kali.
   - Vérifie l’interface réseau :  
     ```bash
     ip a
     ```
   - Active le mode promiscuité :  
     ```bash
     sudo ip link set eth0 promisc on
     ```
     (remplace `eth0` par le nom réel de ton interface, souvent `eth0` ou `ens33`)

   - Vérifie que c’est bien activé :
     ```bash
     ip link show eth0
     ```

---

### 🧪 Pour tester si ça fonctionne :
Lance **Wireshark** sur Kali et commence à sniffer l’interface réseau concernée. Si tu vois du trafic qui ne t’est pas destiné directement (ARP, broadcast, ou trafic entre d'autres machines), c’est que le mode promiscuité est bien actif.

---

Tu veux faire du sniffing sur un réseau réel (genre Wi-Fi de ton ordi hôte), ou dans un réseau entre VMs ?