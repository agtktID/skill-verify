---
name: project-build
description: >-
  Implémente une feature avec TDD strict (Red→Green→Refactor) + Gauntlet Loop.
  Utiliser pour coder une feature issue du PRD après project-init,
  ou pour implémenter n'importe quelle tâche avec une boucle builder-critic vérifiée.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - project
    - build
    - tdd
    - gauntlet
    - feature
    - red-green-refactor
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🔨 Skill `project-build`

Skill d'implémentation de feature avec TDD strict et Gauntlet Loop.
Chaque feature passe par Red → Green → Refactor, avec preuves exécutables avant de continuer.

---

## ✅ Quand utiliser

Utilise `/project-build` quand :

- Tu implémentes une feature issue du PRD ou d'une issue.
- Tu veux un cycle TDD forcé avec boucle builder-critic.
- Tu enchaînes après `project-init`.

Ne pas utiliser pour :

- Initialiser un projet (utilise `project-init`).
- Tester / livrer / reviewer (utilise `project-test`, `project-ship`, `project-review`).

**Précédent :** `project-init` | **Suivant :** `project-test`

---

## 🔧 Pré-requis

- Un projet initialisé avec `project-init` ou un dépôt existant.
- Une feature ou une issue clairement définie (titre + critères d'acceptation).
- Une commande de test disponible (`npm test`, `pytest`, etc.).

---

## 🔁 Pipeline TDD + Gauntlet

```text
User → Skill project-build
         ↓
   1. Spec de la feature (quoi, critères, scope)
   2. RED : écrire le test qui échoue
         ↓
   3. GREEN : implémenter le minimum pour passer
   4. Lancer les tests → PASS obligatoire
         ↓
   5. REFACTOR : nettoyer sans casser
   6. Critic → identifier les écarts
         ↓
   7. Corriger le plus gros écart → reboucler
   8. Combiner avec /verify avant de conclure
```

---

## 📝 Procédure détaillée

### 1. Spec de la feature

- Nom de la feature, issue associée, critères d'acceptation.
- Scope : quels fichiers sont touchés, quels fichiers sont interdits.

### 2. Phase RED

1. Écrire le(s) test(s) unitaire(s) AVANT le code.
2. Lancer les tests → ils doivent **échouer** (confirme que le test est réel).

```bash
# Exemple Node
npm test -- --testPathPattern=<feature>
```

### 3. Phase GREEN

1. Implémenter le minimum de code pour faire passer les tests.
2. Lancer les tests → ils doivent **passer**.
3. Jamais de code supplémentaire à ce stade.

### 4. Phase REFACTOR

1. Nettoyer le code (nommage, duplication, lisibilité) sans modifier le comportement.
2. Lancer les tests à nouveau → toujours PASS.

### 5. Gauntlet Critic

- Comparer l'implémentation aux critères d'acceptation.
- Identifier les écarts concrets et actionnables.
- Corriger le plus gros écart → reboucler depuis GREEN si nécessaire.

### 6. Validation finale

- Lancer `/verify` ou vérifier manuellement :
  - Tests PASS.
  - Build PASS.
  - Lint PASS.
- Commit uniquement si tout est PASS.

```bash
git add <fichiers>
git commit -m "feat(<scope>): <description>"
```

---

## 📋 Output attendu

```
## Build — <nom de la feature>

### Spec
- Feature : <description>
- Critères : <liste>
- Fichiers touchés : <liste>

### TDD
- ✅ RED : test écrit et échoue
- ✅ GREEN : tests passent
- ✅ REFACTOR : nettoyage appliqué

### Gauntlet
- Écarts identifiés : <liste>
- Correction appliquée : <description>

### Vérification finale
- ✅ Tests : PASS
- ✅ Build : PASS
- ✅ Lint : PASS

### Commit
git commit -m "feat(<scope>): <description>"

### Prochaine étape
Lancer /project-test pour la suite de tests complète.
```

---

## 🛡️ Règles

- Toujours écrire le test avant le code (TDD strict).
- Ne jamais déclarer GREEN sans avoir lancé les tests via Bash.
- Ne jamais modifier des fichiers hors scope sans accord explicite.
- Ne pas commit si un test est ECHEC.
