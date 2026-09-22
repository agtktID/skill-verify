---
name: project-ship
description: >-
  Prépare et exécute la livraison complète d'un projet ou d'une version :
  CHANGELOG, versioning sémantique, build de production, tag Git et déploiement.
  Utiliser après project-test quand tous les tests sont PASS.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - project
    - ship
    - deploy
    - changelog
    - versioning
    - release
    - git-tag
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🚢 Skill `project-ship`

Skill de livraison complète. Il orchestre le CHANGELOG, le versioning sémantique,
le build de production, le tag Git et le déploiement.

---

## ✅ Quand utiliser

Utilise `/project-ship` quand :

- Tous les tests sont PASS (après `project-test`).
- Tu veux livrer une nouvelle version (patch, minor ou major).
- Tu enchaînes dans la suite : `project-test → project-ship → project-review`.

Ne pas utiliser pour :

- Livrer si les tests ne sont pas PASS (lancer `project-test` d'abord).
- Des déploiements en production sans confirmation explicite de l'utilisateur.

**Précédent :** `project-test` | **Suivant :** `project-review`

---

## 🔧 Pré-requis

- Tests PASS (rapport `project-test` ou `verify`).
- Un `CHANGELOG.md` existant ou à créer.
- Un `package.json`, `pyproject.toml` ou équivalent pour le versioning.
- Accès Git avec droits de push et de tag.
- Optionnel : commande de build prod (`npm run build`, `go build`, etc.).
- Optionnel : cible de déploiement (Vercel, Railway, Fly.io, etc.).

---

## 🔁 Pipeline

```text
User → Skill project-ship
         ↓
   1. Vérifier que les tests sont PASS
   2. Déterminer le type de release (patch / minor / major)
         ↓
   3. Mettre à jour la version dans les fichiers
   4. Mettre à jour CHANGELOG.md
         ↓
   5. Build de production
   6. Commit + tag Git
         ↓
   7. Push + déploiement (avec confirmation)
         ↓
   Verdict : LIVRÉ / ECHEC / EN ATTENTE
```

---

## 📝 Procédure détaillée

### 1. Vérification des prérequis

- Confirmer que les tests sont PASS (lire le dernier rapport ou lancer `npm test`).
- Demander à l'utilisateur le type de release :
  - **patch** : bug fix, aucun breaking change.
  - **minor** : nouvelle feature rétro-compatible.
  - **major** : breaking change.

### 2. Versioning

```bash
# Node (npm version patch/minor/major -- --no-git-tag-version)
npm version patch --no-git-tag-version

# Python (mise à jour manuelle dans pyproject.toml ou setup.cfg)
sed -i 's/version = "X.Y.Z"/version = "X.Y.Z+1"/' pyproject.toml
```

### 3. Mise à jour CHANGELOG.md

Format [Keep a Changelog](https://keepachangelog.com/) :

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- <nouvelle feature>

### Fixed
- <bug corrigé>

### Changed
- <modification>

### Breaking
- <breaking change si applicable>
```

### 4. Build de production

```bash
npm run build
# ou
go build ./...
# ou
python -m build
```

Capturer exit code. Si ECHEC → STOP, ne pas continuer le ship.

### 5. Commit + tag Git

```bash
git add CHANGELOG.md package.json  # ou les fichiers de version
git commit -m "chore(release): v<version>"
git tag -a v<version> -m "Release v<version>"
```

### 6. Push + déploiement (avec confirmation)

**Toujours demander confirmation avant de pusher ou déployer.**

```bash
# Push
git push origin main --tags

# Déploiement (exemples)
vercel --prod
railway up
fly deploy
```

---

## 📋 Output attendu

```
## Ship — v<version>

### Version
- Type : patch / minor / major
- Nouvelle version : <X.Y.Z>

### CHANGELOG
- ✅ Mis à jour pour v<version>

### Build prod
- ✅/❌ <commande> → exit code <N>

### Git
- ✅ Commit : chore(release): v<version>
- ✅ Tag : v<version>
- ✅/⏳ Push : effectué / en attente de confirmation

### Déploiement
- ✅/⏳ <cible> → déployé / en attente de confirmation

### Verdict
**LIVRÉ** – v<version> disponible.
# ou
**EN ATTENTE** – Confirmation utilisateur requise pour push/deploy.
# ou
**ECHEC** – <étape échouée : description>.
```

---

## 🛡️ Règles

- Ne jamais pusher ou déployer sans confirmation explicite de l'utilisateur.
- Ne jamais shipper si les tests ne sont pas PASS.
- Ne jamais modifier la version dans plusieurs fichiers sans les lister tous.
- Si le build échoue, STOP — ne pas continuer vers le tag ou le push.
