
# 🧠 Exemples de diagrammes Mermaid

---

## 1. Diagramme de flux (Flowchart)

```mermaid
graph TD
  Start --> Decision{Fichier modifié ?}
  Decision -- Oui --> Stage[git add]
  Stage --> Commit[git commit]
  Commit --> Push[git push]
  Decision -- Non --> End[Attente]
```

---

## 2. Diagramme de séquence (Sequence Diagram)

```mermaid
sequenceDiagram
  participant Dev as Développeur
  participant Git as Dépôt Git
  participant CI as CI/CD

  Dev->>Git: push code
  Git->>CI: trigger pipeline
  CI->>Git: build + test + deploy
```

---

## 3. Diagramme Gantt (Gantt Chart)

```mermaid
gantt
  title Roadmap Projet

  section Conception
  Spécifications      :done,    des1, 2024-03-01, 5d
  Prototype           :active,  des2, 2024-03-06, 7d

  section Développement
  Backend             :         dev1, after des2, 10d
  Frontend            :         dev2, after dev1, 8d

  section Tests & Déploiement
  Tests unitaires     :         test1, after dev2, 5d
  Déploiement         :         dep1, after test1, 2d
```

---

## 4. Diagramme de classes (Class Diagram)

```mermaid
classDiagram
  class Utilisateur {
    +String nom
    +String email
    +login()
  }

  class Admin {
    +banUser()
  }

  Utilisateur <|-- Admin
```

---

## 5. Diagramme d’états (State Diagram)

```mermaid
stateDiagram-v2
  [*] --> NonConnecté
  NonConnecté --> Connecté : login
  Connecté --> NonConnecté : logout
  Connecté --> Inactif : timeout
  Inactif --> Connecté : activité détectée
```

---

## 6. Diagramme ERD (Entity Relationship Diagram)

```mermaid
erDiagram
  CLIENT ||--o{ COMMANDE : passe
  COMMANDE ||--|{ LIGNE_COMMANDE : contient
  PRODUIT ||--o{ LIGNE_COMMANDE : référencé
```
