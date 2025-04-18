Comment créer et utiliser un SSL auto-signé dans Nginx

https://allinfo.space/2021/07/21/comment-creer-et-utiliser-un-ssl-auto-signe-dans-nginx/

Si vous n'avez besoin que du chiffrement pour les connexions internes au serveur ou les sites non destinés aux utilisateurs, la signature de vos propres un moyen facile d'éviter de traiter avec une autorité de certification externe. Voici comment le configurer dans nginx.

Si vous êtes plus intéressé par l'obtention de certificats SSL gratuits, vous pouvez toujours utiliser LetsEncrypt, qui est plus adapté aux serveurs publics avec des sites Web destinés aux utilisateurs, car il apparaîtra comme provenant d'une autorité de certification reconnue dans les navigateurs des utilisateurs. Cependant, il ne peut pas être utilisé pour chiffrer des adresses IP privées, c'est pourquoi vous devez signer un certificat vous-même.

### Générer et auto-signer un certificat SSL
Pour ce faire, nous utiliserons l'utilitaire openssl. Vous l'avez probablement déjà installé, car il s'agit d'une dépendance de Nginx. Mais s'il manque d'une manière ou d'une autre, vous pouvez l'installer à partir du gestionnaire de paquets de votre distribution. Pour les systèmes basés sur Debian comme Ubuntu, ce serait :

``sudo apt-get install openssl``

Une fois openssl installé, vous pouvez générer le certificat avec la commande suivante :

``sudo openssl req -x509 – nœuds -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt``

On vous demandera des informations sur votre organisation. Parce qu'il est auto-signé, le seul qui compte vraiment est le “Nom commun,” qui doit être défini sur votre nom de domaine ou l'adresse IP de votre serveur.

- Nom du pays (code à 2 lettres) [] :
- Nom de l'État ou de la province (nom complet) [] :
- Nom de la localité (par exemple, ville) [] :
- nom de l'organisation (par exemple, société) [] :
- nom de l'unité organisationnelle (par exemple, section) [] :
- nom commun (par exemple, nom d'hôte complet) [] : VOTRE ADRESSE IP
- votre_adresse_ip Adresse e-mail [] :

Cela prendra une seconde pour générer une nouvelle clé privée RSA, utilisée pour signer le certificat, et la stocker dans */etc/ssl/private/nginx.key*. Le certificat lui-même est stocké dans */etc/ssl/certs/nginx.crt*, et est valide pour une année entière.

Nous souhaitons également générer un groupe Diffie-Hellman. Ceci est utilisé pour une confidentialité de transmission parfaite, qui génère des clés de session éphémères pour garantir que les communications passées ne peuvent pas être déchiffrées si la clé de session est compromise. Ce n'est pas entièrement nécessaire pour les communications internes, mais si vous voulez être aussi sécurisé que possible, vous ne devriez pas sauter cette étape.

``sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096``

Cela prend un certain temps—environ une heure selon la vitesse de votre serveur. Prenez un déjeuner et revenez un peu sur votre terminal pour configurer Nginx.

CONNEXION : Qu'est-ce qu'un fichier PEM et comment l'utilisez-vous ?

### Configurez Nginx pour utiliser votre clé privée et votre certificat SSL
Pour faciliter les choses, nous allons mettre toute la configuration dans un fichier d'extrait de code que nous pouvons inclure dans nos blocs de serveur nginx. Créez un nouvel extrait de configuration dans le répertoire d'extraits de nginx’s :

``touch /etc/nginx/snippets/self-signed.conf``

Ouvrez-le dans votre éditeur de texte préféré et collez ce qui suit dans :
````
< /p>certificat_ssl /etc/ssl/certs/nginx.crt; ssl_certificate_key /etc/ssl/private/nginx.key ; protocoles ssl_TLSv1.2 ; ssl_prefer_server_ciphers activé ; ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384; ssl_session_timeout 10 m ; ssl_session_cache partagé:SSL:10m; ssl_session_tickets désactivés ; ssl_stapling activé ; ssl_stapling_verify activé ; résolveur 8.8.8.8 8.8.4.4 valide=300s ; resolver_timeout 5s ; add_header X-Frame-Options DENY; add_header X-Content-Type-Options nosniff ; add_header X-XSS-Protection “1; mode=block” ; ssl_dhparam /etc/nginx/dhparam.pem; ssl_ecdh_curve secp384r1;
````
Les deux premières lignes de cet extrait configurent nginx pour utiliser notre propre certificat et notre propre clé privée. Le bloc suivant est les paramètres SSL généraux, et enfin les deux dernières lignes configurent nginx pour utiliser notre groupe Diffie-Hellman pour la sécurité en aval. Vous pouvez omettre ceci si vous n'avez pas envie d'attendre.

La seule autre chose à activer serait HTTP Strict Transport Security, qui configure votre site pour toujours utiliser SSL. Cela nécessiterait une redirection permanente de HTTP vers HTTPS, vous devez donc vérifier que SSL fonctionne avant de l'activer.

Maintenant, modifiez votre configuration principale de nginx (généralement située dans /etc/nginx/nginx.conf pour un seul sites, ou sous votre nom de domaine dans /etc/nginx/sites-available pour les serveurs multi-sites), et sourcez l'extrait :
````
server { listen 443 ssl; écouter [::]:443 ssl; inclure des extraits de code/self-signed.conf ; nom_serveur example.com www.example.com; . . . }
````
Vous souhaiterez également configurer une redirection de HTTP vers HTTPS, ce que vous pouvez faire avec un bloc de serveur supplémentaire à l'écoute sur le port 80 :
````
server { listen 80; écoutez [::]:80; nom_serveur example.com www.example.com; renvoie 302 https://$server_name$request_uri; }
````
Il s'agit d'une redirection 302, qui n'est que temporaire. Vous voudrez passer à 301 si tout fonctionne correctement.

Testez votre configuration en redémarrant nginx :

``sudo service nginx restart``

Étant donné que le trafic HTTPS utilise le port 443, vous devrez configurer vos pare-feu pour autoriser le transport sur ce port. Si vous utilisez iptables ou UFW, vous devrez ouvrir les ports à partir de la ligne de commande. Si vous utilisez un service d'hébergement comme AWS doté d'un pare-feu intégré, vous devrez également l'ouvrir à partir de son interface Web.

Si votre service fonctionne entièrement dans votre réseau local, vous souhaiterez peut-être ajouter à la liste blanche votre sous-réseau spécifique d'adresses IP pour désactiver l'accès depuis l'extérieur du réseau local et accéder à vos serveurs via une connexion VPN.

Si tout fonctionne correctement, vous devriez maintenant pouvoir accéder à votre serveur via HTTPS. Votre navigateur Web peut afficher un avertissement comme celui-ci :


Ne vous inquiétez pas, ceci est attendu, et la raison pour laquelle vous ne pouvez pas utiliser ces certificats pour les sites Web destinés aux clients. Vous devrez confirmer manuellement que vous faites confiance au serveur pour y accéder.

L'avertissement affiché ici est légèrement trompeur—votre site est sécurisé tant que la clé privée n'est pas compromise , et c'est parfaitement sécurisé si vous configurez le secret de transmission Diffie-Hellman. Le problème réside dans l'identité, car Chrome ne peut pas vérifier que votre serveur est bien celui qu'il prétend être, car vous avez signé le certificat vous-même.

Une fois que vous avez vérifié qu'il n'y a aucun problème avec SSL, vous pouvez basculer la redirection HTTP vers une redirection 301 :

``return 301 https://$server_name$request_uri ;``

Et redémarrez nginx pour appliquer les modifications.