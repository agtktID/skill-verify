---
name: project-ship
description: >
  Prépare et exécute la livraison d'un projet ou d'une release : mise à jour du CHANGELOG,
  bumping de version, build de production, tag Git, déploiement (Vercel/Railway/Docker/npm),
  et ouverture de la PR ou release GitHub. Utiliser quand l'utilisateur est prêt à livrer.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
  tags:
    - project
    - ship
    - deploy
    - release
    - changelog
    - semver
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🚢 Rôle du skill `project-ship`

Ce skill orchestre la livraison complète d'un projet :
depuis la mise à jour du CHANGELOG jusqu'au déploiement en production.
Inspiré de Superpowers `/writing-plans` + GSD `/gsd-verify` + Matt Pocock `/git-guardrails-claude-code`.

Flux : **Verify → CHANGELOG → Version → Build → Tag → Deploy → PR/Release**

---

## ✅ Quand utiliser ce skill

Utilise `/project-ship` quand :

- Toutes les features sont implémentées et les tests passent.
- Tu veux créer une release (v1.0.0, v1.1.0, patch, etc.).
- Tu veux déployer sur Vercel, Railway, Fly.io, npm, Docker Hub, etc.
- Tu veux une PR propre avec un changelog et un tag Git.

**Ne pas utiliser pour :**

- Des features incomplètes (utiliser `/project-build` d'abord).
- Des tests qui échouent (utiliser `/project-test` d'abord).

---

## 🧱 Pipeline de livraison

```text
/project-ship [version]
    ↓
[PRÉ-REQUIS] Verify final
    → bash skills/verify/scripts/ci.sh
    → Doit être PASS avant de continuer
    ↓
[ÉTAPE 1] Mise à jour du CHANGELOG
    → CHANGELOG.md (format Keep a Changelog)
    ↓
[ÉTAPE 2] Bump de version
    → package.json / pyproject.toml / go.mod
    ↓
[ÉTAPE 3] Build de production
    → npm run build / python build / go build
    ↓
[ÉTAPE 4] Tag Git + commit
    → git tag v<version>
    → git push origin main --tags
    ↓
[ÉTAPE 5] Déploiement
    → Vercel / Railway / Docker / npm publish
    ↓
[ÉTAPE 6] PR ou Release GitHub
    → Corps de release avec CHANGELOG
```

---

## 🔁 Procédure pour l'agent

### Pré-requis : Verify final OBLIGATOIRE

```bash
bash .claude/skills/verify/scripts/ci.sh
```

**Si le résultat n'est pas PASS, NE PAS continuer.**
Afficher le verdict et demander à l'utilisateur de corriger d'abord.

### Étape 1 : Mise à jour du CHANGELOG

Mettre à jour `CHANGELOG.md` avec le format Keep a Changelog :

```markdown
## [<version>] — <date YYYY-MM-DD>

### Ajouté
- <feature 1>
- <feature 2>

### Modifié
- <changement 1>

### Corrigé
- <bug fix 1>

### Supprimé
- <suppression si applicable>
```

Les informations viennent de :
- `git log --oneline` depuis le dernier tag.
- `docs/issues.md` (issues fermées).

### Étape 2 : Bump de version (SemVer)

```bash
# Node
npm version patch   # 1.0.0 → 1.0.1 (bug fix)
npm version minor   # 1.0.0 → 1.1.0 (nouvelle feature)
npm version major   # 1.0.0 → 2.0.0 (breaking change)

# Python (pyproject.toml)
# Modifier manuellement la version dans pyproject.toml

# Demander à l'utilisateur si incertain :
# Patch = bug fix, Minor = feature, Major = breaking change
```

### Étape 3 : Build de production

```bash
# Node
npm run build

# Python
python -m build

# Go
go build -ldflags="-s -w" -o dist/app ./cmd/...

# Docker
docker build -t <image>:<version> .
```

### Étape 4 : Tag Git + push

```bash
# Commit final
git add CHANGELOG.md package.json  # + autres fichiers de version
git commit -m "chore: release v<version>"

# Tag annoté
git tag -a v<version> -m "Release v<version>"

# Push
git push origin main
git push origin v<version>
```

**Git guardrails (règles non négociables) :**
- Ne jamais forcer un push sur main (`git push --force`).
- Ne jamais tagger une version sans que la CI soit PASS.
- Ne jamais publier sans avoir demandé confirmation à l'utilisateur.

### Étape 5 : Déploiement

```bash
# Vercel
vercel --prod

# Railway
railway up

# Fly.io
fly deploy

# npm
npm publish --access public

# Docker Hub
docker push <image>:<version>

# GitHub Pages
gh workflow run deploy.yml
```

### Étape 6 : Release GitHub

Générer le corps de release :

```markdown
## 🚀 v<version> — <date>

<résumé en 1-2 phrases>

### ✨ Nouvelles features
- <feature 1>
- <feature 2>

### 🐛 Bugs corrigés
- <bug fix>

### 📦 Installation
```bash
npm install <package>@<version>
```

### 📄 Changelog complet
Voir [CHANGELOG.md](./CHANGELOG.md)
```

---

## 📄 Livrables

- `CHANGELOG.md` mis à jour
- Version bumpée dans les fichiers de config
- Tag Git `v<version>` poussé
- Build de production
- Release GitHub (si applicable)
- URL de déploiement

---

## 🔗 Après le ship

- Utiliser `/project-review` pour analyser la qualité du code livré.
- Ouvrir les issues de la prochaine itération.
- Utiliser `/project-init` pour le prochain projet.
