Parfait ! Voici les **éléments complets pour un dépôt Git** que tu peux cloner et utiliser immédiatement avec Ansible pour déployer une **infrastructure sécurisée avec CA interne, Apache backend, et Nginx reverse proxy**.

---

## 📦 Structure du dépôt Git

```
reverse-proxy-ssl-ansible/
├── ansible.cfg
├── inventory.ini
├── playbook.yml
├── roles/
│   ├── ca/
│   │   └── tasks/
│   │       └── main.yml
│   ├── backend/
│   │   └── tasks/
│   │       └── main.yml
│   └── reverse_proxy/
│       └── tasks/
│           └── main.yml
├── files/
│   └── (vide pour l'instant)
```

---

## 📁 Fichiers et contenu

### `ansible.cfg`

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
```

---

### `inventory.ini`

```ini
[backend]
192.168.1.50 ansible_user=ubuntu

[reverse_proxy]
192.168.1.100 ansible_user=ubuntu
```

🔁 Remplace les IPs et utilisateurs selon ta config.

---

### `playbook.yml`

```yaml
---
- name: Create CA and sign backend cert
  hosts: localhost
  gather_facts: false
  roles:
    - ca

- name: Deploy backend cert and configure Apache
  hosts: backend
  become: true
  roles:
    - backend

- name: Configure reverse proxy Nginx
  hosts: reverse_proxy
  become: true
  roles:
    - reverse_proxy
```

---

### `roles/ca/tasks/main.yml`

*(exécuté localement, génère CA + signe cert backend)*

```yaml
- name: Create cert directories
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

- name: Generate CA certificate
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

- name: Generate CSR
  command: >
    openssl req -new -key certs/backend/backend.key
    -out certs/backend/backend.csr
    -subj "/C=FR/ST=Local/L=Network/O=Backend/OU=Web/CN=192.168.1.50"
  args:
    creates: certs/backend/backend.csr

- name: Sign backend cert
  command: >
    openssl x509 -req -in certs/backend/backend.csr
    -CA certs/ca/my-ca.crt -CAkey certs/ca/my-ca.key -CAcreateserial
    -out certs/backend/backend.crt -days 825 -sha256
  args:
    creates: certs/backend/backend.crt
```

---

### `roles/backend/tasks/main.yml`

```yaml
- name: Copy backend cert and key
  copy:
    src: "{{ item.src }}"
    dest: "/etc/ssl/backend/{{ item.dest }}"
  loop:
    - { src: "../../certs/backend/backend.crt", dest: "backend.crt" }
    - { src: "../../certs/backend/backend.key", dest: "backend.key" }

- name: Enable Apache SSL module
  command: a2enmod ssl
  register: ssl_mod
  changed_when: "'already enabled' not in ssl_mod.stdout"

- name: Create Apache HTTPS site
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
  register: site_enabled
  changed_when: "'already enabled' not in site_enabled.stdout"

- name: Reload Apache
  service:
    name: apache2
    state: reloaded
```

---

### `roles/reverse_proxy/tasks/main.yml`

```yaml
- name: Copy CA cert to reverse proxy
  copy:
    src: "../../certs/ca/my-ca.crt"
    dest: /etc/nginx/ssl/my-ca.crt

- name: Configure Nginx reverse proxy block
  blockinfile:
    path: /etc/nginx/sites-available/default
    marker: "# {mark} Backend SSL Config"
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

## 🚀 Lancer le projet :

```bash
git clone <URL à venir>
cd reverse-proxy-ssl-ansible
ansible-playbook playbook.yml
```

---

## 💡 Prochaine étape :

Je peux te :
- Générer un vrai dépôt Git (ex: sur GitHub ou GitLab)
- Ou t’envoyer une archive `.zip` prête à l’emploi

👉 Tu préfères que je te crée un **GitHub repo public/privé**, ou je te donne un **.zip** à télécharger ?