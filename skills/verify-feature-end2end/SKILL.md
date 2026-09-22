---
name: verify-feature-end2end
description: >
  Pipeline de vérification de feature de bout en bout : démarre l'app, exerce la route via HTTP
  ou navigateur (playwright/cURL), exécute la CI locale (tests + lint + build), puis propose
  l'ouverture de PR uniquement si toutes les étapes sont PASS. Anti-hallucination : chaque étape
  est prouvée par exit code et log réel. Rapport .verify/<timestamp>/report.md produit à chaque session.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  category: verification
  tags:
    - verify
    - e2e
    - ci
    - feature
    - playwright
    - http
    - pr-gate
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🎯 Rôle du skill `verify-feature-end2end`

Skill de vérification de feature de bout en bout avant ouverture de PR.

Ce skill encapsule un pipeline complet :

1. **Démarrage de l'app** (serveur local, conteneur, ou processus de dev).
2. **Exercice de la feature** via HTTP (cURL / fetch) ou navigateur (Playwright CLI).
3. **CI locale** : tests unitaires + intégration + lint + build.
4. **Gate PR** : le `git push` et la suggestion d'ouverture de PR ne sont proposés que si toutes les étapes sont PASS.

**Anti-hallucination** : aucune étape n'est validée sans preuve exécutable (exit code réel, log capturé).

---

## ✅ Quand utiliser ce skill

Utilise `/verify-feature-end2end` quand :

- Tu viens de terminer l'implémentation d'une feature (API, UI, script, bot Discord, etc.).
- Tu veux prouver que la feature fonctionne réellement dans un contexte app en cours d'exécution.
- Tu veux bloquer le push/PR tant que le pipeline e2e n'est pas entièrement PASS.
- Tu travailles avec `project-build` ou `gauntlet-loop-dev` et tu veux une couche de validation avant livraison.

Ne pas utiliser pour :

- Des projets sans serveur local ou sans commande de démarrage définissable.
- Des vérifications purement statiques (utilise `/verify` à la place).
- Des projets Unity (utilise `/verify-unity-playmode`).

---

## 🔧 Pré-requis projet

Avant d'utiliser ce skill, le projet doit disposer de :

- Une commande de démarrage de l'app (ex. `npm run dev`, `python app.py`, `flask run`, `node server.js`, `docker-compose up`).
- Au moins une route ou fonctionnalité testable via HTTP (endpoint, page, WebSocket, etc.).
- Une commande de test (ex. `npm test`, `pytest`, `go test`).
- Optionnel : Playwright CLI (`npx playwright test`) ou cURL disponible.
- Optionnel : une commande de lint et de build.

Si une commande manque, l'agent demande à l'utilisateur de préciser avant d'agir.

---

## 🧱 Architecture du pipeline

```text
User → Claude Code + Skill verify-feature-end2end
         ↓
   1. Analyze (feature, project type, routes)
         ↓
   2. Start App (Bash → serveur local)
         ↓
   3. Exercise Feature (cURL / Playwright → HTTP assertions)
         ↓
   4. CI Locale (tests + lint + build → exit codes)
         ↓
   5. Collect Logs → .verify/<timestamp>/
         ↓
   6. Verdict (PASS / ECHEC / PARTIEL / BLOQUE)
         ↓
   7. Gate PR → git push + ouverture PR seulement si PASS
```

---

## 📋 Procédure détaillée

### Étape 1 — Analyse et cadrage

1. Lire la description de la feature à vérifier.
2. Identifier :
   - Le type de projet (Node/Express, Python/Flask, Go, etc.).
   - La ou les routes/fonctionnalités à exercer.
   - Les commandes disponibles (start, test, lint, build).
3. Si des éléments manquent, poser les questions de clarification avant d'agir.

### Étape 2 — Démarrage de l'app

1. Lancer la commande de démarrage via Bash en arrière-plan.

   ```bash
   npm run dev &
   APP_PID=$!
   sleep 3  # attendre que le serveur soit prêt
   ```

2. Vérifier que le serveur répond (health check basique) :
   ```bash
   curl -sf http://localhost:3000/health || curl -sf http://localhost:3000/
   ```

3. Si le serveur ne répond pas après 10 secondes, marquer ce gate BLOQUÉ et arrêter la boucle.

### Étape 3 — Exercice de la feature

**Option A — cURL (API / JSON)**

```bash
curl -sf -X POST http://localhost:3000/api/feature \
  -H "Content-Type: application/json" \
  -d '{"input": "test"}' \
  | tee .verify/<ts>/e2e-response.log
echo "Exit: $?"
```

Vérifier :
- Exit code 0.
- La réponse contient les champs attendus.
- Le statut HTTP est dans la plage 2xx.

**Option B — Playwright CLI (UI / navigateur)**

```bash
npx playwright test --reporter=line 2>&1 | tee .verify/<ts>/playwright.log
echo "Exit: $?"
```

Vérifier :
- Exit code 0.
- Tous les tests sont PASS dans le log.

### Étape 4 — CI locale

Exécuter dans l'ordre :

```bash
# Tests
npm test 2>&1 | tee .verify/<ts>/tests.log
echo "Tests exit: $?"

# Lint (optionnel)
npm run lint 2>&1 | tee .verify/<ts>/lint.log
echo "Lint exit: $?"

# Build
npm run build 2>&1 | tee .verify/<ts>/build.log
echo "Build exit: $?"
```

Capturer l'exit code de chaque commande. Une commande avec exit code non nul = gate ECHEC.

### Étape 5 — Arrêt de l'app

```bash
kill $APP_PID 2>/dev/null || true
```

### Étape 6 — Synthèse et verdict

| Condition | Verdict |
|---|---|
| Toutes les étapes critiques PASS | **PASS** |
| Au moins une étape critique ECHEC | **ECHEC** |
| Critiques PASS, warnings/gaps | **PARTIEL** |
| App non démarrable ou config manquante | **BLOQUE** |

### Étape 7 — Gate PR

- Si verdict **PASS** ou **PARTIEL** : proposer `git add`, `git commit`, `git push`, puis suggérer l'ouverture de PR.
- Si verdict **ECHEC** ou **BLOQUE** : ne pas pousser. Afficher les erreurs et les pistes de correction.

---

## 📜 Format du rapport `.verify/<timestamp>/report.md`

```markdown
MODE: VERIFY-FEATURE-END2END ARMÉ

## Contexte
- Feature: <description>
- Type de projet: <node/python/go/...>
- Routes exercées: <liste>

## Pipeline exécuté
- App start: <commande> → <statut>
- E2E (cURL/Playwright): <commande> → <statut>
- Tests: <commande> → <statut>
- Lint: <commande> → <statut>
- Build: <commande> → <statut>

## Logs
- .verify/<ts>/e2e-response.log
- .verify/<ts>/tests.log
- .verify/<ts>/lint.log
- .verify/<ts>/build.log

## Verdict
**PASS** – Pipeline complet réussi. PR gate ouvert.
# ou
**ECHEC** – <étape(s) échouée(s)>. PR bloquée.
# ou
**PARTIEL** – Critiques PASS, warnings: <liste>.
# ou
**BLOQUE** – <raison> (app non démarrable, config manquante...).

## Prochaines étapes
- <corrections ou actions>
```

---

## 🛡️ Anti-hallucination et sécurité

- **Jamais de PASS sans exit code réel** capturé via Bash.
- **Jamais de push si verdict ECHEC ou BLOQUE**.
- Les secrets (tokens, API keys) ne doivent pas apparaître dans les logs. Si détectés, noter dans le rapport : "⚠️ Nettoyer les logs avant commit."
- Ne lancer aucune commande destructrice (DROP TABLE, rm -rf, etc.) sans confirmation explicite.
- Si l'app démarre sur un port déjà occupé, signaler le conflit et proposer un port alternatif.

---

## 🔗 Intégration avec les autres skills

| Skill | Rôle dans le pipeline |
|---|---|
| `project-build` | Génère la feature → `verify-feature-end2end` la valide |
| `gauntlet-loop-dev` | Itère sur la qualité → `verify-feature-end2end` valide avant PR |
| `verify` | Vérification locale sans app démarrée (complémentaire) |
| `project-ship` | Lance la livraison après que `verify-feature-end2end` a rendu PASS |
