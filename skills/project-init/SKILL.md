---
name: project-init
description: >-
  Initialise un nouveau projet de zéro : brainstorm structuré, PRD, découpage en issues,
  scaffold du dépôt, git init et configuration de base. Utiliser en tout début de projet
  avant project-build. Produit un dossier prêt à coder avec structure, README et issues.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - project
    - init
    - prd
    - scaffold
    - git
    - brainstorm
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🚀 Skill `project-init`

Skill d'initialisation de projet. Il structure le brainstorm, produit un PRD actionnable,
découpe en issues et scaffold le dépôt Git prêt à coder.

---

## ✅ Quand utiliser

Utilise `/project-init` quand :

- Tu démares un nouveau projet (SaaS, bot, CLI, jeu, API, etc.) de zéro.
- Tu veux un PRD structuré avant de commencer à coder.
- Tu veux que le dépôt soit scaffoldé et versionné dès le départ.

Ne pas utiliser pour :

- Un projet déjà existant (utilise `project-build` ou `project-review` à la place).
- Des tâches d'une feature isolée (utilise `project-build`).

**Suivant dans la suite :** `project-build`

---

## 🔧 Pré-requis

- Une idée ou un énoncé de départ (même vague).
- Git installé localement.
- Optionnel : stack et contraintes techniques connues.

---

## 🔁 Pipeline

```text
User → Skill project-init
         ↓
   1. Brainstorm guidé (5 questions clés)
   2. PRD : objectif, utilisateurs, features prioritaires, hors-scope
         ↓
   3. Découpage en issues/tâches
   4. Scaffold (structure de dossiers + fichiers de base)
         ↓
   5. git init + premier commit
         ↓
   Livraison : README.md + PRD.md + issues listées + dépôt initialisé
```

---

## 📝 Procédure détaillée

### 1. Brainstorm guidé

Poser 5 questions clés à l'utilisateur :

1. Quel problème ce projet résout-il ?
2. Qui sont les utilisateurs cibles ?
3. Quelles sont les 3 features minimum pour que ça soit utile ?
4. Quelle stack/langage/framework ?
5. Quelles sont les contraintes (deadline, budget, équipe) ?

Si l'utilisateur donne peu de détails, inférer raisonnablement et valider avant de continuer.

### 2. PRD (Product Requirements Document)

Produire `docs/PRD.md` avec :

```markdown
# PRD — <nom du projet>

## Objectif
<problème résolu en 2 phrases>

## Utilisateurs cibles
<description>

## Features prioritaires (MVP)
1. <feature 1>
2. <feature 2>
3. <feature 3>

## Hors-scope (v1)
- <ce qui est exclu volontairement>

## Stack
- Langage : <>
- Framework : <>
- Infra : <>

## Critères de succès
- <mesurable 1>
- <mesurable 2>
```

### 3. Découpage en issues

Produire `docs/ISSUES.md` ou les afficher en console avec :

- Titre, description courte, critères d'acceptation, priorité (P0/P1/P2).
- Une issue = une feature ou tâche livrable et testable.

### 4. Scaffold du projet

Créer la structure de base via Bash :

```bash
mkdir -p src tests docs .github/workflows
touch README.md .gitignore .env.example
```

Contenu minimal de `README.md` :
- Nom du projet, description, installation, usage, licence.

Contenu minimal de `.gitignore` adapté à la stack détectée.

### 5. Git init et premier commit

```bash
git init
git add .
git commit -m "chore: initial scaffold — <nom du projet>"
```

Si un remote est fourni par l'utilisateur :

```bash
git remote add origin <url>
git push -u origin main
```

---

## 📋 Output attendu

```
## Projet initialisé : <nom>

### Fichiers créés
- README.md
- docs/PRD.md
- docs/ISSUES.md
- .gitignore
- .env.example
- src/ tests/ docs/ .github/workflows/

### Issues (MVP)
1. [P0] <feature 1> — <critères>
2. [P0] <feature 2> — <critères>
3. [P1] <feature 3> — <critères>

### Git
- ✅ git init → OK
- ✅ Premier commit : chore: initial scaffold

### Prochaine étape
Lancer /project-build pour implémenter la première feature.
```

---

## 🛡️ Règles

- Ne jamais créer de fichiers hors du dossier projet sans confirmation.
- Ne jamais pousser sur un remote sans confirmation explicite.
- Si la stack est inconnue, proposer 2-3 options et attendre le choix de l'utilisateur.
