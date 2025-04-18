Parfait ! Voici **la commande unique** pour générer rapidement un **certificat SSL auto-signé** en ligne de commande, sans aucun outil externe :

---

## 🛠 Commande pour générer un certificat SSL auto-signé

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=MonOrganisation/CN=monsite.local"
```

---

### 🔍 Détails des options

- `-x509` : génère un certificat auto-signé
- `-nodes` : pas de mot de passe sur la clé privée
- `-days 365` : valide pendant 1 an
- `-newkey rsa:2048` : génère une nouvelle clé RSA 2048 bits
- `-keyout` : chemin vers la clé privée générée
- `-out` : chemin vers le certificat
- `-subj` : informations du certificat (remplace les questions interactives)

---

## 📂 Fichiers générés

- `/etc/ssl/private/selfsigned.key` → Clé privée
- `/etc/ssl/certs/selfsigned.crt` → Certificat SSL

---

## 🔗 Exemple minimal de config NGINX avec ce certificat

```nginx
server {
    listen 443 ssl;
    server_name monsite.local;

    ssl_certificate /etc/ssl/certs/selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/selfsigned.key;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}
```

Puis :

```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

Tu veux que je te prépare un script qui génère le cert, configure NGINX et reload tout d’un coup ?