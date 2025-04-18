Parfait 👨‍💻 ! Voici un **`gitlab-ci.yml` complet** pour :

✅ Déployer l’infra avec **Ansible**  
✅ Lancer le **test d’intégration SSL complet**  
✅ Failer le pipeline si les tests échouent  
✅ Compatible avec GitLab CI/CD en mode **Self-Hosted** ou SaaS

---

## 🚀 `gitlab-ci.yml` – Pipeline complet

```yaml
stages:
  - deploy
  - test

variables:
  ANSIBLE_HOST_KEY_CHECKING: "False"

before_script:
  - apt-get update -qq
  - apt-get install -y openssl curl ansible sshpass

# === STAGE 1: DEPLOY ===
deploy_ssl_stack:
  stage: deploy
  script:
    - echo "🔧 Déploiement de l'infrastructure SSL avec Ansible"
    - ansible-playbook playbook.yml
  only:
    - main
    - master

# === STAGE 2: TEST ===
test_ssl_integration:
  stage: test
  script:
    - echo "🧪 Lancement des tests SSL"
    - chmod +x full-ssl-integration-test.sh
    - ./full-ssl-integration-test.sh --quiet
  artifacts:
    paths:
      - integration-test.log
  allow_failure: false
```

---

## ✅ Résultat :

| Étape          | Action |
|----------------|--------|
| `deploy_ssl_stack` | Lance Ansible pour : créer la CA, déployer les certs, configurer Apache & Nginx |
| `test_ssl_integration` | Lance les tests d'intégration automatisés (`full-ssl-integration-test.sh`) |
| Artifacts | Tu récupères `integration-test.log` dans l'interface GitLab |
| `allow_failure: false` | Le pipeline **échoue si les tests SSL échouent** |

---

### 💡 Astuces :

- Tu peux adapter pour un **runner Docker** ou **shell** selon ton GitLab.
- Ajoute une **clé SSH privée dans GitLab CI** si tes machines cibles demandent une auth SSH.

---

Tu veux que je t’inclue ce pipeline directement dans le `.zip` du projet précédent pour que tout soit prêt à l’emploi ?