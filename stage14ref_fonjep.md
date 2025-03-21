France Volontaires

# Mise en place de l’espace de Synchronisation - 2022
---
Table des matières
I.	Introduction
II.	Création de l’espace d’hébergement
III.	Reconfiguration de NGINX

## I.	Introduction

En lien avec le développement de l’application métier du FONJEP, il est prévu de mettre à disposition une partie de nos données dans le but de consolider les informations sur les volontaires actifs.
La synchronisation se fera par échange de fichier. France Volontaires met à disposition un fichier plat quotidiennement. La solution du FONJEP vient récupérer ce document.
Afin de protéger les données, l’espace est accessible via authentification et l’usage du protocole HTTPS est de rigueur.

## II.	Création de l’espace d’hébergement

L’espace d’hébergement est placé sur le Reverse Proxy doté de NGINX. 
Dans un 1er temps, un dossier FSync est créé sur le serveur (mkdir /var/www/FSync):
![alt fonjep1](mdimages/fonjep1.png)

Pour des raisons de test et de sécurité, 2 fichiers sont mis en place : 
![alt fonjep2](mdimages/fonjep2.png)

## III.	Reconfiguration de NGINX

1. Afin de configurer NGINX, les commandes suivantes ont été entrées :

````
admfv@SRVRP:/var/www$ sudo nano /etc/nginx/sites-available/default
````

2. Il faut ensuite ajouter la section :

````
 ####################################################################################
        # Espace data FONJEP
        #
        ########################

        location ^~ /FSync {
                alias /var/www/FSync;
                index index.htm;
                #add_header Content-disposition "attachment";

                auth_basic "Restricted Content";
                auth_basic_user_file /etc/nginx/.htpasswd;
        }
````
3. Ensuite, le fichier est testé :
````
admfv@SRVRP:~$ sudo nginx -t
[sudo] Mot de passe de admfv :
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
admfv@SRVRP:~$
````
4. Le service est redémarré :
````
admfv@SRVRP:~$ sudo systemctl reload nginx
````
Une vérification du fonctionnement de l’application via l’URL https://si.france-volontaires.org/FSync est faite.
Cependant, le fichier /etc/nginx/.htpasswd n’est pas encore défini.
![alt fonjep3](mdimages/fonjep3.png)

5. Pour créer le fichier .htpasswd, entrez les commandes suivantes :
````
admfv@SRVRP:/var/www$ sudo sh -c "echo -n 'FonjepSync:' >> /etc/nginx/.htpasswd"
admfv@SRVRP:/var/www$ sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
Password:
Verifying - Password:
admfv@SRVRP:/var/www$ cat /etc/nginx/.htpasswd
FonjepSync:$apr1$/Rd9G56N$P9xiiXFH7.9NjR0.xvkiz/
admfv@SRVRP:/var/www$

````
6. Le test en se connectant sur le fichier https://si.france-volontaires.org/FSync/data.txt est OK : 
![alt fonjep4](mdimages/fonjep4.png)
