---
name: project-review
description: >-
  Revue complète du projet après livraison : qualité du code, architecture, performance,
  sécurité et DX. Utiliser après project-ship pour identifier les dettes techniques,
  les risques et les axes d'amélioration avant la prochaine itération.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - project
    - review
    - code-quality
    - architecture
    - security
    - performance
    - dx
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🔍 Skill `project-review`

Skill de revue complète post-livraison. Il analyse la qualité du code, l'architecture,
les performances, la sécurité et la DX, puis produit un rapport d'axes d'amélioration.

---

## ✅ Quand utiliser

Utilise `/project-review` quand :

- Tu viens de shipper une version avec `project-ship`.
- Tu veux identifier les dettes techniques avant la prochaine itération.
- Tu veux un audit de sécurité ou de performance léger.

Ne pas utiliser pour :

- Revues de PR (utilise les outils natifs Git/GitHub).
- Revues en cours de développement (utilise `gauntlet-loop-dev` ou `verify`).

**Précédent :** `project-ship`

---

## 🔧 Pré-requis

- Un projet livré (version taguée ou déployée).
- Accès en lecture au code source.
- Optionnel : outils d'analyse statique installés (`eslint`, `bandit`, `semgrep`, etc.).

---

## 🔁 Pipeline

```text
User → Skill project-review
         ↓
   1. Qualité du code (lint, complexité, duplication)
   2. Architecture (cohérence, couplage, séparation des concerns)
         ↓
   3. Performance (bundle size, requêtes critiques, profil)
   4. Sécurité (secrets, dépendances vulnérables, OWASP top 10)
         ↓
   5. DX (README, onboarding, tests, CI/CD)
         ↓
   Rapport avec axes CRITIQUE / MOYEN / FAIBLE
```

---

## 📝 Procédure détaillée

### 1. Qualité du code

```bash
# Lint
npm run lint 2>&1 | head -50
# ou flake8, golangci-lint, etc.

# Complexité cyclomatique (Node)
npx complexity-report src/ 2>&1 | tail -20
```

Signaler :
- Fichiers avec trop de responsabilités (> 300 lignes).
- Fonctions trop longues ou trop complexes (complexity > 10).
- Duplication de code évidente.

### 2. Architecture

- Lire la structure des dossiers (`find . -type d -not -path '*/node_modules/*'`).
- Vérifier la séparation des concerns (routes / logique métier / data).
- Identifier le couplage fort ou les dépendances circulaires.

### 3. Performance

- Vérifier le bundle size si applicable (`du -sh dist/` ou équivalent).
- Identifier les requêtes N+1 ou les boucles coûteuses dans le code.
- Signaler les imports lourds ou les dépendances inutiles.

### 4. Sécurité

```bash
# Dépendances vulnérables (Node)
npm audit --audit-level=moderate

# Python
pip-audit

# Secrets accidentels
grep -r 'api_key\|secret\|password\|token' src/ --include='*.js' --include='*.py' | grep -v test
```

Signaler : secrets en clair, dépendances vulnérables, entrées non validées, CORS trop ouverts.

### 5. DX (Developer Experience)

- README complet (installation, usage, contribution) ?
- Tests suffisants (couverture ≥ 70%) ?
- CI/CD configuré ?
- Variables d'env documentées dans `.env.example` ?

---

## 📋 Output attendu

```
## Revue — <nom du projet> v<version>

### Qualité du code
- [CRITIQUE/MOYEN/FAIBLE] <problème>

### Architecture
- [CRITIQUE/MOYEN/FAIBLE] <observation>

### Performance
- [CRITIQUE/MOYEN/FAIBLE] <observation>

### Sécurité
- [CRITIQUE] <vulnérabilité ou secret détecté>
- [MOYEN] <dépendance vulnérable>

### DX
- [MOYEN] <documentation manquante>

### Axes d'amélioration prioritaires
1. [CRITIQUE] <action concrète>
2. [MOYEN] <action>
3. [FAIBLE] <action>

### Verdict
**SAIN** – Aucun point critique, dette technique acceptable.
# ou
**ATTENTION** – X points critiques à traiter avant la prochaine itération.
```

---

## 🛡️ Règles

- Ne signaler que des problèmes concrets et actionnables, pas des opinions.
- Ne jamais exécuter de commandes destructives lors de la revue.
- Si un secret est détecté, STOP immédiat et signaler en priorité absolue.
- Les recommandations doivent être classées par priorité (CRITIQUE / MOYEN / FAIBLE).
