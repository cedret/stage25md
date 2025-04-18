🔥 Let’s go full DevOps!

Voici une **version Ansible** complète pour :

1. 📜 Créer une **CA locale**  
2. 🔐 Générer + signer un **certificat backend**  
3. 🚀 Déployer et configurer **Apache sur le backend**  
4. 🛡 Déployer le **certificat CA sur le reverse proxy**  
5. 🔧 Configurer **Nginx** pour vérifier l’identité du backend

---

## 📁 Structure du projet Ansible

```bash
reverse-proxy-ssl/
├── ansible.cfg
├── inventory.ini
├── playbook.yml
├── roles/
│   ├── ca/
│   │   └── tasks/main.yml
│   ├── backend/
│   │   └── tasks/main.yml
│   └── reverse_proxy/
│       └── tasks/main.yml
└── files/
    ├── openssl.cnf
```

---

## 1. 📋 `ansible.cfg`

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
```

---

## 2. 🗺️ `inventory.ini`

```ini
[backend]
192.168.1.50 ansible_user=ubuntu

[reverse_proxy]
192.168.1.100 ansible_user=ubuntu
```

---

## 3. 🧠 `playbook.yml`

```yaml
---
- name: Secure reverse proxy with internal CA
  hosts: localhost
  gather_facts: false
  roles:
    - ca

- name: Deploy SSL cert and configure Apache on backend
  hosts: backend
  become: true
  roles:
    - backend

- name: Configure Nginx reverse proxy with CA trust
  hosts: reverse_proxy
  become: true
  roles:
    - reverse_proxy
```

---

## 4. 📜 `roles/ca/tasks/main.yml` (CA local sur machine de contrôle)

```yaml
- name: Create directories
  file:
    path: "{{ item }}"
    state: directory
  loop:
    - certs/ca
    - certs/backend

- name: Generate CA key
  command: openssl genrsa -out certs/ca/my-ca.key 2048
  args:
    creates: certs/ca/my-ca.key

- name: Generate CA cert
  command: >
    openssl req -x509 -new -nodes -key certs/ca/my-ca.key
    -sha256 -days 1825 -out certs/ca/my-ca.crt
    -subj "/C=FR/ST=Local/L=Network/O=Homelab/OU=CA/CN=my-internal-ca"
  args:
    creates: certs/ca/my-ca.crt

- name: Generate backend private key
  command: openssl genrsa -out certs/backend/backend.key 2048
  args:
    creates: certs/backend/backend.key

- name: Generate CSR for backend
  command: >
    openssl req -new -key certs/backend/backend.key
    -out certs/backend/backend.csr
    -subj "/C=FR/ST=Local/L=Network/O=Backend/OU=Web/CN=192.168.1.50"
  args:
    creates: certs/backend/backend.csr

- name: Sign backend certificate with CA
  command: >
    openssl x509 -req -in certs/backend/backend.csr
    -CA certs/ca/my-ca.crt -CAkey certs/ca/my-ca.key -CAcreateserial
    -out certs/backend/backend.crt -days 825 -sha256
  args:
    creates: certs/backend/backend.crt
```

---

## 5. 🧱 `roles/backend/tasks/main.yml`

```yaml
- name: Copy certs to backend
  copy:
    src: "{{ item.src }}"
    dest: "/etc/ssl/backend/{{ item.dest }}"
  loop:
    - { src: "../../certs/backend/backend.crt", dest: "backend.crt" }
    - { src: "../../certs/backend/backend.key", dest: "backend.key" }

- name: Enable SSL mod
  command: a2enmod ssl
  register: ssl_mod
  changed_when: "'already enabled' not in ssl_mod.stdout"

- name: Create Apache SSL virtual host
  copy:
    dest: /etc/apache2/sites-available/backend-ssl.conf
    content: |
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

- name: Enable SSL site
  command: a2ensite backend-ssl
  register: site_enable
  changed_when: "'already enabled' not in site_enable.stdout"

- name: Reload Apache
  service:
    name: apache2
    state: reloaded
```

---

## 6. 🌐 `roles/reverse_proxy/tasks/main.yml`

```yaml
- name: Copy CA cert to Nginx
  copy:
    src: "../../certs/ca/my-ca.crt"
    dest: /etc/nginx/ssl/my-ca.crt

- name: Ensure Nginx config includes SSL verification
  blockinfile:
    path: /etc/nginx/sites-available/default
    marker: "# {mark} SSL Backend Config"
    block: |
      location / {
          proxy_pass https://192.168.1.50:8443;
          proxy_ssl_verify on;
          proxy_ssl_verify_depth 2;
          proxy_ssl_trusted_certificate /etc/nginx/ssl/my-ca.crt;

          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
      }

- name: Reload Nginx
  service:
    name: nginx
    state: reloaded
```

---

## 🚀 Pour exécuter :

1. Clone ou copie la structure.
2. Lance :

```bash
ansible-playbook playbook.yml
```

---

## ✅ Résultat :

- 🔐 Backend Apache est chiffré en HTTPS avec un cert signé par une CA locale
- 🛡 Nginx reverse proxy vérifie le certificat backend
- 💼 Le tout est déployé automatiquement via Ansible

---

Tu veux que je te fasse un dépôt Git tout prêt à cloner et lancer ?