Excellent choix 👏 ! Voici un **script complet tout-en-un** pour :

1. 🎓 Créer une **autorité de certification (CA)** locale  
2. 🔐 Générer et signer un certificat SSL pour ton **backend Apache**  
3. 📦 Déployer le certificat sur le backend  
4. ⚙️ Configurer Apache pour utiliser ce certificat  
5. 🔐 Configurer **Nginx (reverse proxy)** pour **vérifier** le certificat du backend (vérification de la chaîne via `proxy_ssl_verify`)

---

### 🧾 **Structure du script :**
Ce script est divisé en deux parties :
- Partie 1 : à exécuter sur la machine où tu veux créer la CA (typiquement Kali ou une machine de contrôle)
- Partie 2 : instructions/commandes à exécuter sur le **serveur backend** et sur le **reverse proxy Nginx**

Je vais te donner **tout le script**, **plus les transferts** à faire.

---

## 📁 Partie 1 : Script CA + signature backend (sur Kali ou poste de gestion)

### 🔧 `create-ca-and-sign-backend.sh`

```bash
#!/bin/bash

set -e

# === CONFIGURATION ===
BACKEND_CN="192.168.1.50"
BACKEND_NAME="backend"
CERT_DIR="./certs"
DAYS_VALID=825

echo "📁 Création des dossiers..."
mkdir -p $CERT_DIR/ca $CERT_DIR/backend

cd $CERT_DIR

# === 1. Créer la CA ===
echo "🔐 Création de la clé de la CA..."
openssl genrsa -out ca/my-ca.key 2048

echo "📜 Création du certificat de la CA (valide 5 ans)..."
openssl req -x509 -new -nodes -key ca/my-ca.key -sha256 -days 1825 \
  -out ca/my-ca.crt \
  -subj "/C=FR/ST=Local/L=Network/O=Homelab/OU=CA/CN=my-internal-ca"

# === 2. Générer la clé + CSR pour le backend ===
echo "🔐 Génération de la clé du backend..."
openssl genrsa -out backend/$BACKEND_NAME.key 2048

echo "📝 Génération de la CSR pour le backend..."
openssl req -new -key backend/$BACKEND_NAME.key \
  -out backend/$BACKEND_NAME.csr \
  -subj "/C=FR/ST=Local/L=Network/O=Backend/OU=Web/CN=$BACKEND_CN"

# === 3. Signer le certificat avec la CA ===
echo "✍️ Signature du certificat backend avec la CA..."
openssl x509 -req -in backend/$BACKEND_NAME.csr \
  -CA ca/my-ca.crt -CAkey ca/my-ca.key -CAcreateserial \
  -out backend/$BACKEND_NAME.crt -days $DAYS_VALID -sha256

# === Résumé ===
echo -e "\n✅ Certificats générés :"
echo "- CA : $CERT_DIR/ca/my-ca.crt"
echo "- Backend cert : $CERT_DIR/backend/$BACKEND_NAME.crt"
echo "- Backend key :  $CERT_DIR/backend/$BACKEND_NAME.key"

echo -e "\n📤 Copie les fichiers suivants vers le backend :"
echo "- backend/$BACKEND_NAME.crt"
echo "- backend/$BACKEND_NAME.key"
echo "- ca/my-ca.crt (à copier aussi sur le reverse proxy)"
```

---

## 🔁 Partie 2 : Déploiement (à faire **manuellement** ensuite)

---

### 📦 Sur le **serveur backend (Apache)** :

```bash
# Créer le dossier
sudo mkdir -p /etc/ssl/backend

# Copier les fichiers générés depuis Kali (depuis ./certs)
# backend.crt, backend.key

# Exemple avec scp :
scp backend.crt backend.key user@192.168.1.50:/tmp/
scp my-ca.crt user@192.168.1.50:/tmp/

# Puis sur le backend :
sudo mv /tmp/backend.crt /etc/ssl/backend/
sudo mv /tmp/backend.key /etc/ssl/backend/
```

### 🔧 Modifier ou créer le VirtualHost Apache (port 8443) :

```bash
sudo nano /etc/apache2/sites-available/backend-ssl.conf
```

```apache
<VirtualHost *:8443>
    ServerName 192.168.1.50

    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/ssl/backend/backend.crt
    SSLCertificateKeyFile /etc/ssl/backend/backend.key

    <Directory /var/www/html>
        Require all granted
    </Directory>
</VirtualHost>
```

```bash
# Activer SSL et le site
sudo a2enmod ssl
sudo a2ensite backend-ssl
sudo systemctl reload apache2
```

---

### 🛡 Sur le **reverse proxy Nginx** :

1. Copie le certificat **de la CA** (`my-ca.crt`) dans `/etc/nginx/ssl/` :
```bash
sudo mkdir -p /etc/nginx/ssl
scp my-ca.crt user@192.168.1.100:/tmp/
sudo mv /tmp/my-ca.crt /etc/nginx/ssl/
```

2. Configure ton bloc Nginx :

```nginx
location / {
    proxy_pass https://192.168.1.50:8443;

    proxy_ssl_verify on;
    proxy_ssl_verify_depth 2;
    proxy_ssl_trusted_certificate /etc/nginx/ssl/my-ca.crt;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

3. Redémarrer Nginx :
```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

### ✅ Test :

- Nginx établira **uniquement la connexion si le backend a un certificat signé par ta CA**.
- Si tu remplaces le certificat backend par un autre non signé par cette CA : **Nginx refusera de se connecter** (`502 Bad Gateway` ou erreur SSL).

---

Tu veux une version ultra-automatisée qui déploie tout par SSH ou Ansible ? 😎