---
name: verify-feature-end2end
description: >
  Pipeline de vérification bout en bout : démarre l'app, exerce la feature via HTTP ou navigateur,
  exécute la CI locale, puis ouvre la PR uniquement si toutes les gates sont PASS.
  Anti-hallucination : chaque étape est prouvée par Bash + exit code.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - verify
    - e2e
    - ci
    - feature
    - playwright
    - curl
    - anti-hallucination
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🔁 Skill `verify-feature-end2end`

Skill de vérification bout-en-bout pour une feature web ou API. Il s'assure que la feature fonctionne **dans un vrai navigateur ou via HTTP** avant d'autoriser le merge.

---

## ✅ Quand utiliser ce skill

Utilise `/verify-feature-end2end` quand :

- Tu ajoutes une feature à une app web, API REST ou Discord bot.
- Tu veux bloquer le `git push` / la PR tant que la feature n'est pas vérifiée en conditions réelles.
- Tu travailles avec Playwright, Puppeteer, cURL ou un client HTTP.

Ne pas utiliser pour :

- Projets sans serveur ou sans point d'entrée HTTP.
- Vérifications uniquement de librairies ou utilitaires purs.

---

## 🔧 Pré-requis

- Une commande de démarrage de l'app (`npm start`, `python app.py`, etc.).
- Une commande de test ou de smoke-test HTTP (`curl`, `playwright`, `pytest`, etc.).
- Une commande de CI locale (`npm test`, `npm run lint`, etc.).
- Optionnel : Playwright CLI ou équivalent installé pour les tests navigateur.

Si une commande manque, demander à l'utilisateur avant d'agir.

---

## 🧱 Pipeline de vérification

```text
User → Claude Code + Skill verify-feature-end2end
         ↓
   1. Démarrer l'app (Bash)
   2. Exercer la feature (HTTP / navigateur)
         ↓
   3. CI locale (tests + lint)
         ↓
   4. Verdict PASS → proposer git push + PR
      Verdict ECHEC → corriger et reboucler
         ↓
   .verify/<timestamp>/feature-e2e-report.md
```

---

## 📜 Procédure détaillée

### 1. Cadrage

1. Identifier la feature à vérifier (route, action, comportement attendu).
2. Identifier la commande de démarrage du serveur/app.
3. Définir le scénario de smoke-test : URL, méthode, payload, réponse attendue.

### 2. Démarrage de l'app

1. Exécuter la commande de démarrage via Bash (en background si nécessaire).
2. Vérifier que le serveur répond (health check HTTP / ping).
3. Si le démarrage échoue → gate BLOQUÉ, afficher les logs.

### 3. Exercer la feature

Option A – HTTP (cURL / fetch) :

```bash
curl -s -o /tmp/response.json -w "%{http_code}" http://localhost:3000/api/your-endpoint
```

Option B – Playwright CLI :

```bash
npx playwright test tests/feature.spec.ts --reporter=line
```

- Capturer l'exit code et la sortie dans `.verify/<ts>/e2e.log`.
- Gate PASS si exit code 0 et réponse conforme. Gate ECHEC sinon.

### 4. CI locale

1. Lancer les tests unitaires + lint.
2. Capturer exit codes + logs dans `.verify/<ts>/ci.log`.
3. Gate PASS si tout est 0.

### 5. Verdict et livraison

1. Si toutes les gates sont PASS :
   - Écrire `.verify/<ts>/feature-e2e-report.md` avec le résumé.
   - Proposer : `git add . && git commit -m "feat: ..." && git push && gh pr create`.
2. Si une gate ECHEC :
   - Afficher les erreurs.
   - Proposer une correction.
   - Reboucler depuis l'étape concernée.

---

## 📄 Format du rapport

```markdown
MODE: VERIFY-FEATURE-END2END

## Contexte
- Feature: <description>
- App démarrée: <commande>
- Scénario e2e: <URL ou test>

## Gates
- ✅/❌ Démarrage app → <exit code>
- ✅/❌ Smoke-test HTTP/navigateur → <résultat>
- ✅/❌ CI locale (tests + lint) → <exit code>

## Logs
- .verify/<ts>/e2e.log
- .verify/<ts>/ci.log

## Verdict
**PASS** – Tous les critères sont remplis. PR autorisée.
# ou
**ECHEC** – <gate échouée> : <description de l'erreur>.
```

---

## 🛡️ Règles anti-hallucination

- Toujours exécuter les commandes via Bash, jamais simuler les résultats.
- Toujours capturer et logguer les exit codes.
- Ne jamais déclarer PASS sans log prouvable.
- Ne pas lancer de `git push` sans verdict PASS explicite.
