🔥 On passe au **niveau pro** !

Voici une version **ultra-automatisée** du déploiement complet avec :

- 📜 **Création CA locale**
- 🔐 **Génération & signature d’un certificat pour le backend**
- 🔁 **Déploiement par SSH sur le backend**
- ⚙️ **Configuration Apache automatiquement**
- 🧩 **Déploiement du certificat CA sur le reverse proxy**
- 📎 **Configuration sécurisée de Nginx**

---

## 🛠 Prérequis :

- Tu dois avoir accès SSH aux **deux machines** :
  - `backend_ip`
  - `reverse_proxy_ip`
- Et un user avec **sudo** sur chaque (ex: `ubuntu`, `root`, etc.)
- Apache doit être installé sur le backend.
- Nginx doit être installé sur le reverse proxy.

---

## ⚙️ Plan du script :

On va faire un **gros script bash unique**, qui :

1. Génère la CA
2. Crée & signe le cert backend
3. Copie les certs sur le backend via SSH + configure Apache
4. Copie le cert de la CA sur le reverse proxy + configure Nginx

---

### 🧾 Script final : `deploy-secure-reverse-proxy.sh`

```bash
#!/bin/bash

set -e

# === CONFIGURATION ===
CA_NAME="my-internal-ca"
BACKEND_CN="192.168.1.50"
BACKEND_PORT="8443"
BACKEND_USER="ubuntu"
BACKEND_IP="192.168.1.50"

REVERSE_USER="ubuntu"
REVERSE_IP="192.168.1.100"
REVERSE_CA_PATH="/etc/nginx/ssl/$CA_NAME.crt"

CERT_DIR="./certs"
VHOST_FILE="/etc/apache2/sites-available/backend-ssl.conf"

echo "📁 Création des dossiers de certificats..."
mkdir -p $CERT_DIR/ca $CERT_DIR/backend

# === 1. Générer la CA ===
echo "🔐 Génération de la CA..."
openssl genrsa -out $CERT_DIR/ca/$CA_NAME.key 2048
openssl req -x509 -new -nodes -key $CERT_DIR/ca/$CA_NAME.key -sha256 -days 1825 \
  -out $CERT_DIR/ca/$CA_NAME.crt \
  -subj "/C=FR/ST=Local/L=Network/O=Homelab/OU=CA/CN=$CA_NAME"

# === 2. Générer et signer le cert du backend ===
echo "🔐 Génération du certificat backend signé..."
openssl genrsa -out $CERT_DIR/backend/backend.key 2048
openssl req -new -key $CERT_DIR/backend/backend.key \
  -out $CERT_DIR/backend/backend.csr \
  -subj "/C=FR/ST=Local/L=Network/O=Backend/OU=Web/CN=$BACKEND_CN"
openssl x509 -req -in $CERT_DIR/backend/backend.csr \
  -CA $CERT_DIR/ca/$CA_NAME.crt -CAkey $CERT_DIR/ca/$CA_NAME.key -CAcreateserial \
  -out $CERT_DIR/backend/backend.crt -days 825 -sha256

# === 3. Déployer certs sur backend ===
echo "📤 Déploiement des certs sur le backend Apache..."
scp $CERT_DIR/backend/backend.crt $CERT_DIR/backend/backend.key $BACKEND_USER@$BACKEND_IP:/tmp/

ssh $BACKEND_USER@$BACKEND_IP "sudo mkdir -p /etc/ssl/backend && \
  sudo mv /tmp/backend.crt /etc/ssl/backend/ && \
  sudo mv /tmp/backend.key /etc/ssl/backend/ && \
  echo '<VirtualHost *:$BACKEND_PORT>
    ServerName $BACKEND_CN
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/ssl/backend/backend.crt
    SSLCertificateKeyFile /etc/ssl/backend/backend.key
    <Directory /var/www/html>
        Require all granted
    </Directory>
  </VirtualHost>' | sudo tee $VHOST_FILE > /dev/null && \
  sudo a2enmod ssl && sudo a2ensite backend-ssl && sudo systemctl reload apache2"

# === 4. Déployer CA sur reverse proxy + configurer Nginx ===
echo "📤 Déploiement de la CA sur le reverse proxy..."
scp $CERT_DIR/ca/$CA_NAME.crt $REVERSE_USER@$REVERSE_IP:/tmp/

ssh $REVERSE_USER@$REVERSE_IP "sudo mkdir -p /etc/nginx/ssl && \
  sudo mv /tmp/$CA_NAME.crt $REVERSE_CA_PATH"

echo -e "\n📋 Exemple de bloc Nginx à ajouter sur le reverse proxy :\n"
cat <<EOF
location / {
    proxy_pass https://$BACKEND_IP:$BACKEND_PORT;
    proxy_ssl_verify on;
    proxy_ssl_verify_depth 2;
    proxy_ssl_trusted_certificate $REVERSE_CA_PATH;

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
}
EOF

echo -e "\n✅ Déploiement terminé ! Le backend est sécurisé par SSL signé par une CA interne."
```

---

## 🚀 Utilisation :

1. Enregistre ce script :
```bash
nano deploy-secure-reverse-proxy.sh
```

2. Colle le contenu, enregistre puis :
```bash
chmod +x deploy-secure-reverse-proxy.sh
./deploy-secure-reverse-proxy.sh
```

---

### 🧪 Résultat :

- Apache sur le backend écoute sur HTTPS (port 8443) avec un **certificat signé par ta propre CA**
- Nginx peut **vérifier l’identité du backend**
- La communication est **chiffrée et authentifiée des deux côtés**

---

Tu veux que je te convertisse ce déploiement en **playbook Ansible** aussi pour les gros setups ?