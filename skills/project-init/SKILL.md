---
name: project-init
description: >
  Initialise un nouveau projet de zéro : brainstorming guidé, rédaction du PRD (Product Requirements Doc),
  découpage en issues GitHub, scaffold de l'architecture, git init et configuration des outils de qualité
  (lint, husky, pre-commit). Utiliser quand l'utilisateur démarre un nouveau projet ou une nouvelle feature majeure.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
  tags:
    - project
    - init
    - prd
    - scaffold
    - planning
    - matt-pocock
    - gsd
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🚀 Rôle du skill `project-init`

Ce skill transforme une idée brute en projet structuré, prêt à coder.
Inspiré de Matt Pocock's `/to-prd` + `/to-issues` + Superpowers `/brainstorming` + GSD `/gsd-new-project`.

Flux : **Idée → PRD → Issues → Scaffold → Git → Outils qualité**

---

## ✅ Quand utiliser ce skill

Utilise `/project-init` quand :

- Tu démarres un nouveau projet (SaaS, API, CLI, Discord bot, jeu Unity, etc.).
- Tu veux structurer une idée avant de coder (éviter le "vibe coding").
- Tu veux des issues GitHub prêtes avec des critères d'acceptation.
- Tu veux une architecture initiale et des outils de qualité configurés.

**Ne pas utiliser pour :**

- Ajouter une feature à un projet existant (utiliser `/project-build`).
- Quand le projet est déjà initialisé et scaffoldé.

---

## 🔧 Pré-requis

- Git installé.
- Node, Python, Go, ou autre runtime selon le type de projet.
- Optionnel : accès à l'API GitHub pour créer les issues automatiquement.

---

## 🧱 Pipeline d'initialisation

```text
Idée utilisateur
    ↓
[PHASE 1] Brainstorming guidé (questions socratiques)
    ↓
[PHASE 2] Rédaction du PRD (Product Requirements Doc)
    → docs/prd.md
    ↓
[PHASE 3] Découpage en issues (acceptance criteria)
    → docs/issues.md
    ↓
[PHASE 4] Scaffold de l'architecture
    → structure de fichiers, README, .gitignore
    ↓
[PHASE 5] Git init + configuration qualité
    → lint, typecheck, pre-commit hooks
    ↓
Projet prêt pour /project-build
```

---

## 🔁 Procédure pour l'agent

### Phase 1 : Brainstorming guidé (Mode Socratique)

Poser ces questions UNE par UNE (ne pas toutes les poser d'un coup) :

1. **Quel problème ce projet résout-il ?** (en 1 phrase)
2. **Qui sont les utilisateurs cibles ?** (persona principal)
3. **Quelle est la feature #1 qui doit absolument marcher ?** (le cœur du produit)
4. **Quel stack technique utilises-tu ?** (ou lequel veux-tu recommander ?)
5. **Quelle est ta définition du succès à J+30 ?** (métrique concrète)

Après chaque réponse, reformuler pour confirmer la compréhension.

### Phase 2 : Rédaction du PRD

Générer `docs/prd.md` avec la structure suivante :

```markdown
# PRD — <Nom du projet>

## Résumé
- Problème : <une phrase>
- Solution : <une phrase>
- Utilisateurs cibles : <persona>

## Objectifs (SMART)
1. <Objectif 1 avec métrique>
2. <Objectif 2 avec métrique>

## Features prioritaires (MoSCoW)
### Must Have
- <feature 1>
- <feature 2>
### Should Have
- <feature 3>
### Could Have
- <feature 4>
### Won't Have (v1)
- <feature 5>

## Architecture technique
- Stack : <liste>
- Structure : <arborescence>
- APIs externes : <liste>

## Critères de succès
- <métrique 1>
- <métrique 2>

## Risques identifiés
- <risque 1 + mitigation>
```

### Phase 3 : Découpage en issues

Générer `docs/issues.md` avec :

```markdown
## Issue #1 — <titre court>
**Type:** feat / fix / chore
**Priorité:** P0 / P1 / P2
**Estimation:** S (< 2h) / M (2-8h) / L (> 8h)

**Description:**
<contexte et objectif>

**Acceptance Criteria:**
- [ ] <critère 1>
- [ ] <critère 2>
- [ ] <critère 3>

**Dépendances:** <issues précédentes si applicable>
```

### Phase 4 : Scaffold de l'architecture

1. Créer la structure de fichiers selon le stack détecté.
2. Générer le `README.md` avec : description, installation, usage, contribution.
3. Créer le `.gitignore` adapté au stack.
4. Créer le fichier de configuration principal (ex. `package.json`, `pyproject.toml`, `go.mod`).

### Phase 5 : Git init + outils qualité

```bash
# Git
git init
git add .
git commit -m "chore: initial project scaffold"

# Node : lint + pre-commit
npm install --save-dev eslint prettier husky lint-staged
npx husky init

# Python : lint + pre-commit
pip install flake8 black pre-commit
pre-commit install

# Go : lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

5. Créer le fichier `.verify/pending-task` pour déclencher le hook verify au prochain Stop.

---

## 📄 Livrables

- `docs/prd.md` — Product Requirements Doc
- `docs/issues.md` — Liste des issues avec acceptance criteria
- Structure de fichiers scaffoldée
- `README.md` du projet
- `.gitignore`
- Outils de qualité configurés (lint, pre-commit)
- Premier commit Git propre

---

## 🔗 Prochaine étape

Une fois le projet initialisé : utiliser `/project-build` pour implémenter les features.
