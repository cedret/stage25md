test.md
https://lecrabeinfo.net/tutoriels/4-methodes-pour-faire-une-capture-decran-sur-pc-windows/

sudo nano /etc/nanorc
set linenumbers
````
PS C:\Users\POURRET> Get-PhysicalDisk
Number FriendlyName        SerialNumber MediaType CanPool OperationalStatus HealthStatus Usage            Size
------ ------------        ------------ --------- ------- ----------------- ------------ -----            ----
0      Intel Raid 0 Volume Volume1      SSD       False   OK                Healthy      Auto-Select 476.95 GB
PS C:\Users\POURRET> Get-ComputerInfo
````
``diskmgmt.msc``
``resmon``
``msinfo32``
``systeminfo``


VPS
https://www.ionos.com/help/server-cloud-infrastructure/dedicated-server-for-servers-purchased-before-102818/servers/reimaging-your-server/
https://www.ionos.com/help/server-cloud-infrastructure/virtual-server-for-servers-acquired-before-2017/reset-your-virtual-server-to-a-previous-state/
https://www.hostinger.fr/vps/hebergement-nextcloud
https://support.hostinger.com/en/articles/8794598-how-to-use-the-nextcloud-vps-template
https://support.hostinger.com/fr/articles/6990738-quelles-applications-pouvez-vous-installer-automatiquement-chez-hostinger

### Github project:
https://www.youtube.com/watch?v=oPQgFxHcjAw

### Bash
https://www.warp.dev/terminus/bash-while-loop

### A faire
ajouter au portail
>- whatsapp
>- mistral
>- markdown
> GCP
https://www.markdownguide.org/cheat-sheet/
https://github.com/im-luka/markdown-cheatsheet
https://www.markdown-cheatsheet.com/
https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

### Publish markdown
https://dev.to/ar2pi/publish-your-markdown-docs-on-github-pages-6pe
https://towshif.github.io/site/04.Organizing-Reporting/markdown_publishing/
https://github.com/compiiile/compiiile

https://www.jekyllpad.com/tools/markdown-to-pdf-converter
https://md2pdf.netlify.app/
https://2markdown.com/pdf-to-markdown-api
https://www.wordize.app/markdown-to-pdf/

## Zautres
https://www.mesbienfaits.com/antispasmodiques-naturels/
https://docteurbonnebouffe.com/liste-eaux-riches-en-magnesium/
https://www.vogue.fr/article/meilleurs-films-de-tous-les-temps-liste-classement
https://madame.lefigaro.fr/bien-etre/forme-detente/ces-6-mouvements-d-un-osteopathe-qui-vont-tout-changer-dans-votre-endormissement-20250310?

- Test nextcloud ubuntu server 20 ????
> acces stockage publique ????
> A explorer
https://www.markdownguide.org/tools/wiki-js/
A git based wiki
https://github.com/gollum/gollum
FIle based wiki
https://github.com/Linbreux/wikmd

## Linux
*Boron update*
bl-welcome
https://techantidote.com/install-macos-ventura-on-proxmox-8-x/

### Programmer dessins avec code
https://www.youtube.com/watch?v=Oa-_EUg44cQ
https://www.youtube.com/watch?v=JRwTCKjc37o
https://www.youtube.com/watch?v=jCd6XfWLZsg
https://www.youtube.com/watch?v=28ltI8GUXi0

### Léo Firefox
https://www.mycomputertips.co.uk/304
Lubuntu quicklaunch
https://manual.lubuntu.me/stable/5/5.1/lxqt-panel.html?highlight=quicklaunch
https://www.mycomputertips.co.uk/304
https://askubuntu.com/questions/466395/how-can-i-create-a-quick-launcher-in-lubuntu
https://askubuntu.com/questions/1085371/is-the-only-way-to-add-a-quicklaunch-in-lxqt-by-mouse
---
---
### autres
https://www.youtube.com/@ByteByteGo/videos
https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu

Korben: Dockeriser une app
https://www.youtube.com/watch?v=0v3JXxuyF7Y

https://www.it-connect.fr/le-protocole-nfs-pour-les-debutants/
https://chromewebstore.google.com/detail/markdown-reader/medapdbncneneejhbgcjceippjlfkmkg
https://www.alsacreations.com/astuce/lire/1932-Mermaid--diagrammes-schemas-et-graphiques-dans-markdown.html
https://itx‐technologies.com/fr/blog/2259‐executer‐un‐script‐recurrent‐avec‐cron‐exemples‐sous‐linux
http://www.quennec.fr/trucs‐astuces/syst%C3%A8mes/gnulinux/utilisation/connexion‐%C3%A0‐une‐machine‐distante‐ssh‐scp‐sftp‐sans‐saisir‐le‐mot‐de‐passe 
https://techarea.fr/tuto‐ssh‐cle‐nas‐synology/
https://releases.ubuntu.com/xenial/?_ga=2.222723923.973636296.1741702081-761716020.1741702081

#### Divers
https://www.alsacreations.com/astuce/lire/1932-Mermaid--diagrammes-schemas-et-graphiques-dans-markdown.html
https://chromewebstore.google.com/detail/markdown-reader/medapdbncneneejhbgcjceippjlfkmkg
https://www.it-connect.fr/chapitres/nmap-pourquoi-utiliser-cet-outil/
https://sysreseau.net/nmap-les-12-commandes-que-vous-devez-connaitre/
https://www.cyberly.org/en/how-do-you-use-nmap-to-detect-a-router-or-gateway/index.html
https://linuxize.com/post/how-to-add-apt-repository-in-ubuntu/
office
OPP2016  NP4GX-KCBYD-77BGG-BDQ29-8QKYB

### Explication bash du test de version des composants FV

Bonne question ! Décomposons cette commande ligne par ligne pour bien comprendre ce qu’elle fait :

---

```bash
echo -e "\n=== PostgreSQL Version ==="
```
➡️ Affiche un titre avec un retour à la ligne (`\n`) :

```
=== PostgreSQL Version ===
```

---

```bash
POSTGRES_VERSION=$(psql --version 2>/dev/null || echo "PostgreSQL absent")
```

➡️ Cette ligne tente de récupérer la version de PostgreSQL :

- `psql --version` : affiche la version du client PostgreSQL s’il est installé.
- `2>/dev/null` : redirige les erreurs vers `/dev/null` (donc les cache).
- `|| echo "PostgreSQL absent"` : si la commande `psql --version` échoue (par exemple, si `psql` n’est pas installé), on affiche à la place : `"PostgreSQL absent"`.

📦 Le résultat (qu'il vienne de `psql --version` ou de `echo`) est stocké dans la variable `POSTGRES_VERSION`.

---

```bash
echo "$POSTGRES_VERSION"
```

➡️ Affiche le contenu de la variable, donc :

- Soit quelque chose comme : `psql (PostgreSQL) 14.9 (Ubuntu 14.9-1.pgdg22.04+1)`
- Soit : `PostgreSQL absent`

---

### ✅ Résumé

Cette séquence affiche la version de PostgreSQL **si le client `psql` est installé**, sinon elle affiche qu’il est absent. Très pratique dans un script de diagnostic ou d'installation.

Bien sûr ! Voici l’équivalent de la commande pour vérifier la version d’**Apache2** (serveur HTTP) dans un script bash :

---

### 🧾 Script pour Apache2

```bash
echo -e "\n=== Apache Version ==="
APACHE_VERSION=$(apache2 -v 2>/dev/null || httpd -v 2>/dev/null || echo "Apache2 absent")
echo "$APACHE_VERSION"
```

---

### 🔍 Explication

- `apache2 -v` : commande utilisée sur la plupart des systèmes **Debian/Ubuntu**.
- `httpd -v` : alternative utilisée sur **CentOS/RHEL/Fedora**.
- `2>/dev/null` : redirige les erreurs pour éviter d'afficher des messages si le binaire n'existe pas.
- `||` : si la première commande échoue, essaie la suivante. Si aucune ne fonctionne, affiche `"Apache2 absent"`.

---

### ✅ Exemple de sortie possible

```bash
=== Apache Version ===
Server version: Apache/2.4.57 (Ubuntu)
Server built:   2023-06-20T14:21:53
```

Ou bien, si Apache n’est pas installé :

```bash
=== Apache Version ===
Apache2 absent
```

---

Tu veux une version plus compacte ou qui retourne seulement le numéro de version (`2.4.57`) ?