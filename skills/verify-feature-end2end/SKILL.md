---
name: verify-feature-end2end
description: >
  Pipeline de vérification bout en bout : démarre l'app, exerce la feature via HTTP ou navigateur,
  exécute la CI locale, puis ouvre la PR uniquement si toutes les gates sont PASS.
  Anti-hallucination : chaque étape est prouvée par Bash + exit code.
license: MIT
version: "1.1.0"
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
    - pr-gate
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
- Tu veux une gate de qualité avant ouverture de PR (PR gate pattern).

Ne pas utiliser pour :

- Projets sans serveur ou sans point d'entrée HTTP.
- Vérifications uniquement de librairies ou utilitaires purs.

---

## 🔧 Pré-requis

- Une commande de démarrage de l'app (`npm start`, `python app.py`, `flask run`, etc.).
- Une commande de test ou de smoke-test HTTP (`curl`, `playwright`, `pytest`, etc.).
- Une commande de CI locale (`npm test`, `npm run lint`, `pytest`, etc.).
- Optionnel : Playwright CLI installé pour les tests navigateur.

Si une commande manque, demander à l'utilisateur avant d'agir.

---

## 🧱 Pipeline de vérification

```text
User → Claude Code + Skill verify-feature-end2end
         ↓
   1. Démarrer l'app (Bash)
   2. Health check — serveur accessible ?
         ↓
   3. Exercer la feature (HTTP / navigateur)
         ↓
   4. CI locale (tests + lint)
         ↓
   5. Verdict PASS → proposer git push + PR
      Verdict ECHEC → corriger et reboucler
         ↓
   .verify/<timestamp>/feature-e2e-report.md
```

---

## 📜 Procédure détaillée

### 1. Cadrage

1. Identifier la feature à vérifier (route, action, comportement attendu).
2. Identifier la commande de démarrage du serveur/app.
3. Définir le scénario de smoke-test : URL, méthode HTTP, payload, réponse attendue.
4. Si des éléments manquent, poser les questions de clarification avant d'agir.

### 2. Démarrage de l'app

1. Exécuter la commande de démarrage via Bash (en background si nécessaire).
2. Vérifier que le serveur répond avec un health check.
3. Si le démarrage échoue → gate **BLOQUÉ**, afficher les logs.

```bash
# Exemple health check
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health
```

### 3. Exercer la feature

**Option A – HTTP (cURL) :**

```bash
curl -s -o .verify/<ts>/response.json -w "%{http_code}" \
  -X POST http://localhost:3000/api/your-endpoint \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}' \
  >> .verify/<ts>/e2e.log 2>&1
```

**Option B – Playwright CLI :**

```bash
npx playwright test tests/feature.spec.ts \
  --reporter=line \
  2>&1 | tee .verify/<ts>/e2e.log
```

- Capturer exit code et sortie dans `.verify/<ts>/e2e.log`.
- Gate **PASS** si exit code 0 et réponse conforme. Gate **ECHEC** sinon.

### 4. CI locale

```bash
npm test 2>&1 | tee .verify/<ts>/ci-tests.log
npm run lint 2>&1 | tee .verify/<ts>/ci-lint.log
```

- Gate **PASS** si tous les exit codes sont 0.

### 5. Verdict et livraison

1. Si toutes les gates sont **PASS** :
   - Écrire `.verify/<ts>/feature-e2e-report.md` avec le résumé complet.
   - Proposer : `git add . && git commit -m "feat: ..." && git push && gh pr create`.
2. Si une gate **ECHEC** :
   - Afficher les erreurs depuis les logs.
   - Proposer une correction ciblée.
   - Reboucler depuis l'étape concernée.
   - **Ne jamais pousser avec un ECHEC non résolu.**

---

## 📄 Format du rapport

```markdown
MODE: VERIFY-FEATURE-END2END

## Contexte
- Feature: <description>
- App démarrée: <commande>
- Scénario e2e: <URL ou test Playwright>

## Gates
- ✅/❌ Démarrage app → <exit code>
- ✅/❌ Health check → <HTTP status>
- ✅/❌ Smoke-test HTTP/navigateur → <résultat>
- ✅/❌ CI locale (tests + lint) → <exit code>

## Logs
- .verify/<ts>/e2e.log
- .verify/<ts>/ci-tests.log
- .verify/<ts>/ci-lint.log

## Verdict
**PASS** – Tous les critères sont remplis. PR autorisée.
# ou
**ECHEC** – <gate échouée> : <description de l'erreur>.
# ou
**BLOQUÉ** – <raison> : corriger avant de continuer.
```

---

## 🔗 Intégration avec les autres skills

| Skill | Rôle |
|-------|------|
| `verify` | Gate de vérification générale (tests unitaires, build, lint) |
| `gauntlet-loop-dev` | Itère sur la feature jusqu'à ce qu'elle passe toutes les gates |
| `project-ship` | Enchaîne après `verify-feature-end2end` pour la livraison |
| `verify-unity-playmode` | Équivalent pour projets Unity |

---

## 🛡️ Règles anti-hallucination

- Toujours exécuter les commandes via Bash, jamais simuler les résultats.
- Toujours capturer et logguer les exit codes dans `.verify/<ts>/`.
- Ne jamais déclarer **PASS** sans log prouvable avec exit code 0.
- Ne jamais lancer `git push` ou `gh pr create` sans verdict **PASS** explicite.
- Si le serveur ne démarre pas dans un délai raisonnable, déclarer **BLOQUÉ** et afficher les logs.

---

## 📚 Changelog

- **v1.1.0** (2026-09-22) : Ajout health check, logs nommés séparément, table d'intégration, règle anti-push sans PASS, statut BLOQUÉ.
- **v1.0.0** : Version initiale.
