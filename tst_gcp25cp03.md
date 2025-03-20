## TP Google Cloud platform - Iprec / ASRS27

<p align="right">Cédric Pourret - Mars 2025</p>

### Objectif
Servir via une machine virtuelle du service Compute Engine et plus précisement via Nginx, serveur et proxy, avec l’application Django.

Voici les commandes et les retours de commandes obtenues pour aboutir au résultat, visible depuis cette adresse publique, au moment de la rédaction de ce document:

http://34.38.101.75/


### Mise en place d'une app web avec Django
Sources d'information:
> partie-1-venv-django-templates.mp4
> https://docs.djangoproject.com/en/5.1/topics/install/
> https://docs.djangoproject.com/en/5.1/intro/tutorial01/
> https://about.gitlab.com/fr-fr/blog/2024/10/24/git-bash/
>https://www.freecodecamp.org/news/html-starter-template-a-basic-html5-boilerplate-for-index-html/
>https://bulma.io/documentation/start/installation/
>https://docs.djangoproject.com/fr/5.1/howto/deployment/
>https://www.geeksforgeeks.org/how-to-create-an-app-in-django/

#### Avec une machine Windows 10 pro ou plus.
Préparation de l'arborescence pour le site et de l'environnement virtuel avec **Gitbash**

```
access@DESKTOP-4E2R2LH MINGW64 ~
$ python -m django version
5.1.5

access@DESKTOP-4E2R2LH MINGW64 ~
$ pwd
/c/Users/access

access@DESKTOP-4E2R2LH MINGW64 ~
$ mkdir artroom

access@DESKTOP-4E2R2LH MINGW64 ~
$ cd artroom

access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ python --version
Python 3.13.0

access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ python -m venv .vev

access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ ls -al
total 24
drwxr-xr-x 1 access 197121 0 Mar 11 21:08 ./
drwxr-xr-x 1 access 197121 0 Mar 11 20:58 ../
drwxr-xr-x 1 access 197121 0 Mar 11 21:08 .vev/

access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ cd .vev/

access@DESKTOP-4E2R2LH MINGW64 ~/artroom/.vev
$ ls -al
total 10
drwxr-xr-x 1 access 197121   0 Mar 11 21:08 ./
drwxr-xr-x 1 access 197121   0 Mar 11 21:08 ../
-rw-r--r-- 1 access 197121  71 Mar 11 21:08 .gitignore
drwxr-xr-x 1 access 197121   0 Mar 11 21:08 Include/
drwxr-xr-x 1 access 197121   0 Mar 11 21:08 Lib/
drwxr-xr-x 1 access 197121   0 Mar 11 21:08 Scripts/
-rw-r--r-- 1 access 197121 316 Mar 11 21:08 pyvenv.cfg

access@DESKTOP-4E2R2LH MINGW64 ~/artroom/.vev
$ cd Scripts/
````
`/Scripts` est spécifique à WINDOWS!!

### Activation de l'environnement et création du site avec Django.
```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom/.vev/Scripts
$ ls
Activate.ps1  activate  activate.bat  activate.fish  deactivate.bat  pip.exe*  pip3.13.exe*  pip3.exe*  python.exe*  pythonw.exe*

access@DESKTOP-4E2R2LH MINGW64 ~/artroom/.vev/Scripts
$ source activate
(.vev)

access@DESKTOP-4E2R2LH MINGW64 ~/artroom/.vev/Scripts
$ cd ..
(.vev)
access@DESKTOP-4E2R2LH MINGW64 ~/artroom/.vev
$ cd ..
(.vev)
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ python -m pip install Django
.....

access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ pip freeze > requirements.txt
(.vev)
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ cat requirements.txt
asgiref==3.8.1
Django==5.1.7
sqlparse==0.5.3
tzdata==2025.1
(.vev)

access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ python -m django version
5.1.7
(.vev)

access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ django-admin startproject mysite .
(.vev)
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ ls
manage.py*  mysite/  requirements.txt
(.vev)
````
### Passage sous Vs Code: 
Depuis un terminal dans Vscode, mise en service du site qui vient d'être créé.

```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ python manage.py runserver
....
Django version 5.1.7, using settings 'mysite.settin
Starting development server at http://127.0.0.1:8000
````
Résultat visible depuis http://127.0.0.1:8000
 ou bien page d'administration à http://127.0.0.1:8000/admin

#### Depuis un second terminal
Création de l'app avec *Django*.
````
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ python manage.py startapp core
````
#### Création du fichier *landing.html* dans
`C:\Users\access\artroom\core\templates\core\landing.html`
et création de
`C:\Users\access\artroom\core\static\core\`

````
<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>artroom</title>
    <link rel="stylesheet" href="./style.css">
    <link rel="icon" href="./favicon.ico" type="image/x-icon">
  </head>
  <body>
    <main>
        <h1>Landing on Djangoooooo</h1>  
    </main>
    <script src="index.js"></script>
  </body>
</html>
````
Créer/modifier dans
`C:\Users\access\artroom\core\`
````
from django.shortcuts import render

# Create your views here.

def index(request):
    return render(request, 'core/landing.html', {})
````
Créer/modifier dans
`C:\Users\access\artroom\core`

````
from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='landing')
]
````
Créer/modifier dans
`C:\Users\access\artroom\mysite`

````
"""
URL configuration for mysite project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('', include('core.urls')),
    path('admin/', admin.site.urls),
]
````
#### Ajout de style css
Créer/modifier dans `settings.py`
````
INSTALLED_APPS = [
    'core.apps.CoreConfig',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]
````
Créer/modifier dans
`C:\Users\access\artroom\core\static\core\css\`
````
.landing-main {
    display: flex;
    flex-direction: column;
}
````
Créer/modifier dans *landing.html*
````
  <body>
    <main class="landing-main">
        <h1 class="title">Landing to Djangoooooo</h1>  
....
....
<link
  rel="stylesheet"
  href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css"
>
````
### Utilisation de *Waitress*
Serveur HTTP conçu pour exécuter des applications Python basées sur WSGI, compatible windows.
Sources d'information:
> partie-2-waitress.mp4
>https://pypi.org/project/waitress/
>https://docs.pylonsproject.org/projects/waitress/en/latest/usage.html

####  **Différence avec d’autres serveurs WSGI**
| Serveur WSGI  | Compatible Windows | Léger | Facile à configurer | Performant |
|--------------|----------------|------|------------------|------------|
| **Waitress** |  Oui          |  Oui  |  Oui            |  Bon |
| **Gunicorn** |  Non (Linux only) |  Oui  |  Oui            |  Très performant |
| **uWSGI**   |  Oui (complexe) |  Non |  Non (config avancée) |  Très performant |


````
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ pip install waitress
Collecting waitress
  Downloading waitress-3.0.2-py3-none-any.whl.metadata (5.8 kB)
Downloading waitress-3.0.2-py3-none-any.whl (56 kB)
Installing collected packages: waitress
Successfully installed waitress-3.0.2

[notice] A new release of pip is available: 24.2 -> 25.0.1
[notice] To update, run: python.exe -m pip install --upgrade pip
(.vev)
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ pip freeze > requirements.txt 
(.vev) 
````
Créer/modifier dans `C:\Users\access\artroom\run_waitress.py:`
```
from waitress import serve
from mysite.wsgi import application

serve (application, host="0.0.0.0", port=8080)
````
Depuis le site de waitress, on récupère
`waitress-serve --listen=\*:8041 myapp:wsgifunc`
Créer/modifier dans
```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ waitress-serve --listen=*:8080 mysite.wsgi:application
INFO:waitress:Serving on http://[::]:8080
INFO:waitress:Serving on http://0.0.0.0:8080
````
### Utilisation de Nginx
Nginx est un serveur web open-source, initialement dédié à la gestion de 10k connexions ou plus.
Il est maintenant aussi utilisé comme reverse proxy, cache HTTP et load balancer.
>https://datascientest.com/nginx-tout-savoir

Avec Windows, installer l'executable *nginx.exe* près de la racine de C:

Commande de secours pour stopper NGINX
`taskkill /f /IM nginx.exe`

Créer/modifier dans *nginx.conf*
```
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    upstream django_waitress {
        server 127.0.0.1:8080;
    }

    server {
        listen       80;
        server_name  localhost;

        location / {
            proxy_pass http://django_waitress;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
````
### Depuis Gitbash, pour tester nginx.

`access@DESKTOP-4E2R2LH MINGW64 /c/nginx-1.26.3
$ start nginx`

Résultats visibles en parallèle en localhost:8080 (waitress) et en localhost (nginx)

Avant passage sur github, conseillé de stopper l'environnement virtuel?

`access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ deactivate`

Depuis cmd, stopper nginx.
````
C:\Users\access>taskkill /f /IM nginx.exe
Opération réussie : le processus "nginx.exe" de PID 12948 a été arrêté.
Opération réussie : le processus "nginx.exe" de PID 13464 a été arrêté.
````
Depuis un terminal dans *Vscode*, établir connexion vers repository *github*.
```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom
$ git init
Initialized empty Git repository in C:/Users/access/artroom/.git/

git remote add origin git@github.com:éèùçàéèùçà/artroom.git

access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ git remote -v
origin  git@github.com:éèùçàéèùçà/artroom.git (fetch)
origin  git@github.com:éèùçàéèùçà/artroom.git (push)

access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ touch .gitignore
````
Créer/modifier dans *.gitignore* pour délester des variables d'environnement virtuel
`.vev`
```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)     
        .gitignore
        core/
        db.sqlite3
        manage.py
        mysite/
        requirements.txt
        run_waitress.py

nothing added to commit but untracked files present (use "git add" to track)

access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ git add .

access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ git commit -m'modif/v1'
[master (root-commit) 2c918bd] modif/v1
 31 files changed, 264 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 core/__init__.py
````
Pour diagnostiquer Github, si un problème survient:
```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ git config user.name
éèùçàéèùçà

access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ git config user.email
éèùçàéèùçà@mail.fr
````
### Génération de clé SSH pour transfert vers *Github*
> partie-3-git-ssh.mp4
> https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
Après génération de la clé, la reporter dans Github.
`ssh-keygen -t ed25519 -C "éèùçàéèùçà@mail.fr"`

```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ ssh-keygen -t ed25519 -C "éèùçàéèùçà@mail.fr"
Generating public/private ed25519 key pair.
....

access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILOLd0lzLNXIlmuhX61g0XtHlx246lKbv1HSJvMbB05Y éèùçàéèùçà@mail.fr
````

### Transfert de l'app vers *Github*
```
access@DESKTOP-4E2R2LH MINGW64 ~/artroom (master)
$ git push origin master
Enumerating objects: 41, done.
Counting objects: 100% (41/41), done.
Delta compression using up to 12 threads
Compressing objects: 100% (34/34), done.
Writing objects: 100% (41/41), 9.07 KiB | 1.13 MiB/s, done.
Total 41 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)       
remote: Resolving deltas: 100% (2/2), done.
To github.com:éèùçàéèùçà/artroom.git
 * [new branch]      master -> master
````
## Passage sur GCP

### Création d'une instance vm E2 debian standard:
Sources d'information:
> partie-4-venv-sur-mv.mp4

Opérations
> En Belgique
> http et https ouverts
> Création d'une seconde clé ssh pour connexion avec *Github*

Commandes possibles pour opérations:
`sudo apt update`
`sudo apt upgrade`
`sudo apt-get install nginx ???`
`sudo apt install nginx`
`sudo nginx`
`sudo nginx -s stop ???`
`sudo systemctl stop nginx ???`
`sudo apt install git python3`
`sudo apt install python3.11-venv`
`python3 -m venv .vev`
`source .vev/bin/activate`
`pip install -r requirements.txt`
`pip freeze > requirements.txt`
`ps aux | grep "python"`

````
cedret3@artroom25:~$ curl -I 127.0.0.1
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Thu, 13 Mar 2025 19:33:41 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Thu, 13 Mar 2025 19:28:55 GMT
Connection: keep-alive
ETag: "67d331f7-267"
Accept-Ranges: bytes

cedret3@artroom25:~$ ssh-keygen -t ed25519 -C "éèùçàéèùçà@mail.fr"
Generating public/private ed25519 key pair.

cat ~/.ssh/id_ed25519.pub
+++ copier

cedret3@artroom25:~$ cat /home/cedret3/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTzEA3pZ3eP5B6ndUlwZCDSYaEajU3uWB9Au6rlQcmg éèùçàéèùçà@mail.fr
````
Après ajout de la clé dans Github, puis rapatriement du site créé aved Django depuis Github, vers la vm dans GCP.

````
cedret3@artroom25:~$ git clone git@github.com:éèùçàéèùçà/artroom.git
Cloning into 'artroom'...
The authenticity of host 'github.com (140.82.121.3)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
remote: Enumerating objects: 41, done.
remote: Counting objects: 100% (41/41), done.
remote: Compressing objects: 100% (32/32), done.
remote: Total 41 (delta 2), reused 41 (delta 2), pack-reused 0 (from 0)
Receiving objects: 100% (41/41), 9.07 KiB | 1.81 MiB/s, done.
Resolving deltas: 100% (2/2), done.
````
#### Activation d'un environnement virtuel dans la vm depuis GCP.
```
cedret3@artroom25:~/artroom$ python3 -m venv .vev
cedret3@artroom25:~/artroom$ ls -al
total 40
drwxr-xr-x 6 cedret3 cedret3 4096 Mar 13 19:49 .
drwxr-xr-x 4 cedret3 cedret3 4096 Mar 13 19:44 ..
drwxr-xr-x 8 cedret3 cedret3 4096 Mar 13 19:44 .git
-rw-r--r-- 1 cedret3 cedret3    4 Mar 13 19:44 .gitignore
drwxr-xr-x 5 cedret3 cedret3 4096 Mar 13 19:49 .vev
drwxr-xr-x 6 cedret3 cedret3 4096 Mar 13 19:44 core
-rw-r--r-- 1 cedret3 cedret3    0 Mar 13 19:44 db.sqlite3
-rw-r--r-- 1 cedret3 cedret3  662 Mar 13 19:44 manage.py
drwxr-xr-x 3 cedret3 cedret3 4096 Mar 13 19:44 mysite
-rw-r--r-- 1 cedret3 cedret3   76 Mar 13 19:44 requirements.txt
-rw-r--r-- 1 cedret3 cedret3  112 Mar 13 19:44 run_waitress.py
cedret3@artroom25:~/artroom$ source .vev/bin/activate
(.vev) cedret3@artroom25:~/artroom$ pip install -r requirements.txt
Collecting asgiref==3.8.1
  Downloading asgiref-3.8.1-py3-none-any.whl (23 kB)
Collecting Django==5.1.7
  Downloading Django-5.1.7-py3-none-any.whl (8.3 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 8.3/8.3 MB 28.4 MB/s eta 0:00:00
Collecting sqlparse==0.5.3
  Downloading sqlparse-0.5.3-py3-none-any.whl (44 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 44.4/44.4 kB 8.6 MB/s eta 0:00:00
Collecting tzdata==2025.1
  Downloading tzdata-2025.1-py2.py3-none-any.whl (346 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 346.8/346.8 kB 40.5 MB/s eta 0:00:00
Collecting waitress==3.0.2
  Downloading waitress-3.0.2-py3-none-any.whl (56 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 56.2/56.2 kB 10.8 MB/s eta 0:00:00
Installing collected packages: waitress, tzdata, sqlparse, asgiref, Django
Successfully installed Django-5.1.7 asgiref-3.8.1 sqlparse-0.5.3 tzdata-2025.1 waitress-3.0.2
(.vev) cedret3@artroom25:~/artroom$ cat requirements.txt 
asgiref==3.8.1
Django==5.1.7
packaging==24.2
sqlparse==0.5.3
tzdata==2025.1
waitress==3.0.2
````
**??? Non identifié: *packaging\==24.2* dans le requirements.txt**

### Diffusion de l'App dans la VM depuis GCP.

Sources d'information:
> partie-5-sites-available-enabled-gunicorn.mp4

> https://gunicorn.org/

> https://pypi.org/project/packaging/

Obtenir IP publique de la vm:
`(.vev) cedret3@artroom25:~/artroom$ wget -qO- https://api.ipify.org`
`34.38.101.75`
Démarrage de Nginx dans la vm.
````
cedret3@artroom25:~/artroom/mysite$
(.vev) cedret3@artroom25:~/artroom$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful      
(.vev) cedret3@artroom25:~/artroom$ sudo systemctl restart nginx
(.vev) cedret3@artroom25:~/artroom$ deactivate

cedret3@artroom25:~/artroom$ cd mysite/
cedret3@artroom25:~/artroom/mysite$ ls -al
total 28
drwxr-xr-x 3 cedret3 cedret3 4096 Mar 13 19:44 .
drwxr-xr-x 6 cedret3 cedret3 4096 Mar 13 19:49 ..
-rw-r--r-- 1 cedret3 cedret3    0 Mar 13 19:44 __init__.py
drwxr-xr-x 2 cedret3 cedret3 4096 Mar 13 19:44 __pycache__
-rw-r--r-- 1 cedret3 cedret3  389 Mar 13 19:44 asgi.py
-rw-r--r-- 1 cedret3 cedret3 3249 Mar 13 19:44 settings.py
-rw-r--r-- 1 cedret3 cedret3  807 Mar 13 19:44 urls.py
-rw-r--r-- 1 cedret3 cedret3  389 Mar 13 19:44 wsgi.py
cedret3@artroom25:~/artroom/mysite$ nano settings.py
````
#### Modifications dans *settings.py*
`DEBUG = False`
`ALLOWED_HOSTS = ["34.38.101.75","127.0.0.1"]`

Modifications dans les répertoires pour que nginx renvoie l'app créée par le fichier *django*.
```
cedret3@artroom25:/etc/nginx$ cd sites-available/
cedret3@artroom25:/etc/nginx/sites-available$ ls -al
total 12
drwxr-xr-x 2 root root 4096 Mar 13 19:28 .
drwxr-xr-x 8 root root 4096 Mar 13 19:28 ..
-rw-r--r-- 1 root root 2412 Mar 14  2023 default
cedret3@artroom25:/etc/nginx/sites-available$ sudo touch django
cedret3@artroom25:/etc/nginx/sites-available$ sudo nano django
cedret3@artroom25:/etc/nginx/sites-available$ cat django
server {
        listen 80;
        server_name 34.38.101.75;

        location / {
                proxy_pass http://127.0.0.1:8000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
        }
}
````
#### Création du lien symbolique vers le fichier *django*
````
cedret3@artroom25:/etc/nginx/sites-enabled$ sudo ln -s /etc/nginx/sites-available/django django
cedret3@artroom25:/etc/nginx/sites-enabled$ ls -al
total 8
drwxr-xr-x 2 root root 4096 Mar 13 20:22 .
drwxr-xr-x 8 root root 4096 Mar 13 19:28 ..
lrwxrwxrwx 1 root root   34 Mar 13 19:28 default -> /etc/nginx/sites-available/default
lrwxrwxrwx 1 root root   33 Mar 13 20:22 django -> /etc/nginx/sites-available/django

cedret3@artroom25:/etc/nginx/sites-enabled$ sudo mv default /etc/nginx/sites-available/default_enabled
cedret3@artroom25:/etc/nginx/sites-enabled$ ls -al
total 8
drwxr-xr-x 2 root root 4096 Mar 13 20:24 .
drwxr-xr-x 8 root root 4096 Mar 13 19:28 ..
lrwxrwxrwx 1 root root   33 Mar 13 20:22 django -> /etc/nginx/sites-available/django
cedret3@artroom25:/etc/nginx/sites-enabled$ sudo systemctl restart nginx
cedret3@artroom25:/etc/nginx/sites-enabled$ ps aux | grep 'nginx'
root        8794  0.0  0.0  10364   984 ?        Ss   20:24   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data    8795  0.0  0.0  10700  2484 ?        S    20:24   0:00 nginx: worker process
www-data    8796  0.0  0.0  10700  2484 ?        S    20:24   0:00 nginx: worker process
cedret3     8838  0.0  0.0   3744  1848 pts/0    S+   20:25   0:00 grep nginx
````
### Installation de Gunicorn dans Linux (remplace Waitress dans Windows)
```
cedret3@artroom25:/etc/nginx/sites-enabled$ cd
cedret3@artroom25:~$ cd artroom/
cedret3@artroom25:~/artroom$ source .vev/bin/activate
(.vev) cedret3@artroom25:~/artroom$ pip install gunicorn
Collecting gunicorn
  Downloading gunicorn-23.0.0-py3-none-any.whl (85 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 85.0/85.0 kB 3.5 MB/s eta 0:00:00
Collecting packaging
  Downloading packaging-24.2-py3-none-any.whl (65 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 65.5/65.5 kB 11.0 MB/s eta 0:00:00
Installing collected packages: packaging, gunicorn
Successfully installed gunicorn-23.0.0 packaging-24.2

(.vev) cedret3@artroom25:~/artroom$ pip freeze > requirements.txt 
(.vev) cedret3@artroom25:~/artroom$ cat requirements.txt 
asgiref==3.8.1
Django==5.1.7
gunicorn==23.0.0
packaging==24.2
sqlparse==0.5.3
tzdata==2025.1
waitress==3.0.2
````
### Déclenchement de Gunicorn pour diffuser l'App consultable depuis l'IP publique.
````
(.vev) cedret3@artroom25:~/artroom$ gunicorn mysite.wsgi:application
[2025-03-13 20:34:54 +0000] [10046] [INFO] Starting gunicorn 23.0.0
[2025-03-13 20:34:54 +0000] [10046] [INFO] Listening at: http://127.0.0.1:8000 (10046)
[2025-03-13 20:34:54 +0000] [10046] [INFO] Using worker: sync
[2025-03-13 20:34:54 +0000] [10047] [INFO] Booting worker with pid: 10047
````

gcp23.md