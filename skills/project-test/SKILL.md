---
name: project-test
description: >-
  Lance la suite de tests complète du projet : unitaires, intégration, e2e, couverture.
  Utiliser après project-build pour valider qu'une feature ou un ensemble de features
  est prêt pour le ship. Produit un rapport de couverture et un verdict PASS/ECHEC.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - project
    - test
    - coverage
    - integration
    - e2e
    - ci
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🧪 Skill `project-test`

Skill de tests complets pour un projet. Lance tous les niveaux de tests, mesure la couverture
et produit un rapport de verdict avant le ship.

---

## ✅ Quand utiliser

Utilise `/project-test` quand :

- Tu as implémenté une ou plusieurs features avec `project-build` et tu veux valider l'ensemble.
- Tu veux mesurer la couverture de tests avant de livrer.
- Tu enchaînes dans la suite : `project-init → project-build → project-test → project-ship`.

Ne pas utiliser pour :

- Tests unitaires d'une seule feature en cours de dev (utilise `project-build` avec TDD).
- Vérification d'une feature spécifique en bout de pipeline (utilise `verify`).

**Précédent :** `project-build` | **Suivant :** `project-ship`

---

## 🔧 Pré-requis

- Un projet avec des tests existants (unitaires, intégration ou e2e).
- Une commande de test + couverture disponible (`npm test -- --coverage`, `pytest --cov`, etc.).
- Optionnel : une commande e2e (Playwright, Cypress, pytest-e2e).

---

## 🔁 Pipeline

```text
User → Skill project-test
         ↓
   1. Tests unitaires
   2. Tests d'intégration
   3. Tests e2e (si disponibles)
         ↓
   4. Rapport de couverture
   5. Verdict global PASS / ECHEC / PARTIEL
         ↓
   .verify/<timestamp>/test-report.md
```

---

## 📝 Procédure détaillée

### 1. Tests unitaires

```bash
# Node / Jest
npm test -- --coverage --passWithNoTests

# Python
pytest --cov=src --cov-report=term-missing

# .NET
dotnet test --collect:"XPlat Code Coverage"

# Go
go test ./... -cover
```

Capturer exit code + sortie dans `.verify/<ts>/unit.log`.

### 2. Tests d'intégration (si présents)

```bash
npm run test:integration
# ou
pytest tests/integration/
```

Capturer dans `.verify/<ts>/integration.log`.

### 3. Tests e2e (si présents)

```bash
npx playwright test
# ou
cypress run
```

Capturer dans `.verify/<ts>/e2e.log`. Si non disponibles → gate SKIP.

### 4. Rapport de couverture

- Lire le résumé de couverture (lignes, branches, fonctions).
- Seuil recommandé : ≥ 70% de couverture lignes pour un PASS.
- Identifier les modules non couverts et les signaler.

### 5. Verdict global

- **PASS** : tous les tests passent + couverture ≥ seuil.
- **PARTIEL** : tests passent mais couverture insuffisante ou warnings.
- **ECHEC** : au moins un test échoue.
- **BLOQUÉ** : impossible de lancer les tests (config manquante).

---

## 📋 Output attendu

```
## Rapport de tests — <nom du projet>

### Niveaux testés
- ✅/❌ Unitaires : <X tests, Y PASS, Z FAIL>
- ✅/❌/⏭️ Intégration : <résultat ou SKIP>
- ✅/❌/⏭️ e2e : <résultat ou SKIP>

### Couverture
- Lignes : X%
- Branches : X%
- Fonctions : X%
- Modules non couverts : <liste>

### Verdict
**PASS** – Prêt pour /project-ship.
# ou
**ECHEC** – <test(s) échoué(s) : description>.
# ou
**PARTIEL** – Tests OK mais couverture < seuil.
```

---

## 🛡️ Règles

- Ne jamais déclarer PASS sans avoir lu l'exit code des commandes de test.
- Toujours capturer les logs dans `.verify/<ts>/`.
- Si les tests sont absents, déclarer BLOQUÉ et proposer d'en créer.
- Ne pas modifier les tests pour les faire passer — corriger le code.
