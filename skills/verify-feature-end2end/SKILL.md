---
name: verify-feature-end2end
description: >
  Vérifie une feature de bout en bout : démarre l'application, exerce la route cible dans un vrai
  navigateur (Playwright) ou via HTTP (cURL), exécute la CI locale (tests + lint + build), puis
  propose d'ouvrir la PR uniquement si toutes les étapes sont PASS. Utiliser après la génération
  ou le refactor d'une feature web, API ou CLI.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
  tags:
    - verify
    - e2e
    - playwright
    - ci
    - feature
    - pr-gate
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🎯 Rôle du skill `verify-feature-end2end`

Ce skill encode un pipeline **"prove it works, then PR it"** :

1. Démarre l'application localement.
2. Exerce la feature cible (navigateur Playwright ou requêtes HTTP).
3. Exécute la CI locale (tests unitaires, lint, build).
4. Propose `git push` + ouverture de PR seulement si tout est PASS.

---

## ✅ Quand utiliser ce skill

Utilise `/verify-feature-end2end` quand :

- Tu viens d'implémenter ou de refactorer une feature web, API ou CLI.
- Tu veux valider le comportement réel de l'application (pas seulement les tests unitaires).
- Tu veux automatiser la chaîne complète : démarrage → tests → CI → PR.

**Ne pas utiliser pour :**

- Projets sans interface HTTP (ex. scripts purs, Unity, CLI sans serveur).
- Quand Playwright n'est pas installé et que l'utilisateur ne veut pas l'installer
  (utiliser `/verify` à la place).

---

## 🔧 Pré-requis

- Commande de démarrage de l'application (ex. `npm run dev`, `python app.py`, `go run main.go`).
- URL ou route à tester (ex. `http://localhost:3000/api/cart/total`).
- Playwright CLI ou cURL disponible dans l'environnement.
- Commandes de CI locale (tests, lint, build).
- Accès à `git` et à l'API GitHub (pour la PR).

---

## 🧱 Architecture du pipeline

```text
User → /verify-feature-end2end
         ↓
   1. Démarrer l'app (Bash : npm run dev / python app.py / ...)
         ↓
   2. Exercer la feature
      - Playwright : ouvrir l'URL, interagir, vérifier le résultat
      - ou cURL : requête HTTP, vérifier le code de retour et le body
         ↓
   3. CI locale
      - Tests unitaires (npm test / pytest / go test / ...)
      - Lint (npm run lint / flake8 / ...)
      - Build (npm run build / tsc / ...)
         ↓
   4. Synthèse et verdict
      - PASS → proposer git push + ouverture de PR
      - ECHEC / PARTIEL → afficher les erreurs et corriger avant PR
         ↓
   .verify/<timestamp>/feature-e2e-report.md
```

---

## 🔁 Procédure pour l'agent

### Étape 1 : Analyse et cadrage

1. Demander à l'utilisateur :
   - La commande de démarrage de l'app.
   - L'URL ou la route à tester.
   - Le comportement attendu (ex. status 200, body JSON avec `{total: 42}`).
2. Vérifier la présence de Playwright ou cURL dans l'environnement.

### Étape 2 : Démarrage de l'application

1. Exécuter la commande de démarrage via Bash (en arrière-plan si possible).
2. Attendre que l'application soit prête (ex. health check sur `/health` ou délai configuré).
3. Si le démarrage échoue, interrompre et afficher les logs.

### Étape 3 : Exercice de la feature

**Option A – Playwright :**

```bash
npx playwright test --headed --project=chromium scripts/e2e/<feature>.spec.ts
```

**Option B – cURL :**

```bash
curl -s -o /tmp/response.json -w "%{http_code}" http://localhost:3000/api/cart/total
```

1. Vérifier le code HTTP de retour (attendu : 2xx).
2. Vérifier le body de la réponse (si applicable).
3. Loguer les résultats dans `.verify/<ts>/e2e.log`.

### Étape 4 : CI locale

1. Exécuter les tests unitaires → loguer dans `.verify/<ts>/tests.log`.
2. Exécuter le lint → loguer dans `.verify/<ts>/lint.log`.
3. Exécuter le build → loguer dans `.verify/<ts>/build.log`.
4. Attribuer PASS / ECHEC / PARTIEL à chaque gate.

### Étape 5 : Synthèse et verdict

1. Calculer le verdict global :
   - **PASS** → proposer `git push origin <branch>` et ouverture de PR.
   - **ECHEC** → afficher les erreurs, proposer des corrections, ne pas pousser.
   - **PARTIEL** → avertir l'utilisateur, laisser le choix de pousser ou corriger.
2. Compléter `.verify/<ts>/feature-e2e-report.md`.

### Étape 6 : Ouverture de la PR (si PASS)

1. Proposer la commande `git push origin <branch>`.
2. Générer le titre et le corps de la PR avec :
   - Résumé de la feature.
   - Liste des gates validés.
   - Lien vers le rapport `.verify/<ts>/feature-e2e-report.md`.
3. Laisser l'utilisateur confirmer avant de pousser.

---

## 📜 Format du rapport `feature-e2e-report.md`

```markdown
MODE: VERIFY E2E

## Feature
- Description: <description>
- URL testée: <url>
- Comportement attendu: <description>

## Résultats E2E
- ✅ HTTP 200 → PASS
- ✅ Body JSON valide → PASS
- Logs: .verify/<ts>/e2e.log

## CI Locale
- ✅ npm test → PASS
- ✅ npm run lint → PASS
- ✅ npm run build → PASS

## Verdict
**PASS** – Feature validée de bout en bout.

## PR suggérée
- Branch: feature/<nom>
- Titre: feat: add <nom>
- Body: <résumé automatique>
```

---

## 🛡️ Sécurité

- Arrêter le serveur de développement après la vérification.
- Ne jamais loguer de secrets ou de tokens dans les fichiers de logs.
- Ne jamais pousser automatiquement sans confirmation explicite de l'utilisateur.
