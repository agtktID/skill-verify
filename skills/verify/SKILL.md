---
name: verify
description: >
  Mode de vérification persistant pour projets de code : définit des gates (tests, build, lint,
  type-checking), les exécute réellement via Bash, collecte les logs, et génère un rapport
  .verify/<timestamp>/report.md avec verdict PASS / ECHEC / PARTIEL / BLOQUE.
  Anti-hallucination : aucune étape n'est validée sans preuve exécutable.
license: MIT
version: 1.1.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - verify
    - gauntlet-loop
    - ci
    - tests
    - report
    - anti-hallucination
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🎯 Rôle du skill `verify`

Skill de vérification persistante pour projets de code :

- Définit une **boucle de vérification** avec des gates (tests, build, lint, type-checking, scripts custom).
- Exige des **preuves exécutables** (exit codes, logs, artefacts) avant de valider une feature.
- Génère un rapport structuré dans `.verify/<timestamp>/report.md` avec verdict clair.
- Reste actif tant que l'utilisateur ne le désactive (mode persistant).

Ce skill reste **court et auto-contenu** : les scripts lourds vivent dans `skills/verify/scripts/`
et les docs détaillées dans `skills/verify/assets/`.
Le runtime applique une **progressive disclosure** : seule la description est en contexte
tant que le skill n'est pas invoqué.

---

## ✅ Quand utiliser ce skill

Utilise `/verify` quand :

- Tu ajoutes ou refactores une feature dans un projet (web, backend, CLI, Unity, etc.).
- Tu veux bloquer les merges tant que les gates ne sont pas tous PASS.
- Tu veux un **rapport de vérification traçable** dans `.verify/<timestamp>/report.md`.
- Tu travailles avec d'autres skills (`gauntlet-loop-dev`, `unity-gamedev`, `indagis-feature-builder`)
  et tu veux une couche de QA au-dessus.

**Ne pas utiliser pour :**

- Questions simples de documentation ou de syntaxe.
- Tâches triviales sans risque (moins de 3 étapes, pas de production).

---

## 🔧 Pré-requis projet

Avant d'utiliser ce skill, le projet doit disposer d'au moins :

- Une commande de test (ex. `npm test`, `pytest`, `go test`, `dotnet test`, `unity -runTests`).
- Une commande de build ou de vérification de types (ex. `npm run build`, `tsc --noEmit`, `dotnet build`).
- Optionnel : une commande de lint (`npm run lint`, `flake8`, etc.).
- Optionnel : des scripts dans `skills/verify/scripts/` (ex. `check.sh`, `ci.sh`, `unity-verify.sh`).

Si une commande manque, le skill doit demander à l'utilisateur de préciser :

- Les commandes à exécuter.
- Les dossiers à surveiller pour la feature (ex. `src/`, `tests/`).

---

## 🧱 Architecture de la boucle de vérification

```text
User → Claude Code + Skill verify
         ↓
   Analyze → Plan → Gauntlet (liste de gates)
         ↓
   Action (Bash) → Collecte des logs → Verify
         ↓
   .verify/<timestamp>/report.md
         ↓
   Verdict: PASS / ECHEC / PARTIEL / BLOQUE
```

Principes :

- **Anti-hallucination** : aucune étape n'est considérée PASS sans exécution réelle via Bash
  et inspection de l'exit code.
- **Progressive disclosure** : les scripts et assets sont chargés à la demande, pas au boot.
- **Token budget** : ce SKILL.md reste concis, les détails vivent dans `assets/reference.md`
  ou dans les scripts.

---

## 📜 Contrat de session verify

À chaque session `verify`, l'agent doit produire :

- Un dossier `.verify/<timestamp>/` (timestamp ISO ou UNIX).
- Un fichier `report.md` avec contexte, commandes exécutées, logs et verdict global.
- Des logs pour chaque gate (ex. `.verify/<ts>/tests.log`, `.verify/<ts>/build.log`).

### Format minimal de `report.md`

```markdown
MODE: VERIFY ARMÉ

## Contexte
- Task: <description de la tâche>
- Constraints:
  - <contrainte 1>
  - <contrainte 2>
- Gates définis:
  - tests: <commande>
  - build: <commande>
  - lint: <commande>
  - extra: <scripts custom>

## Artefacts
- Code modifié: <liste de fichiers>
- Logs:
  - .verify/<ts>/tests.log
  - .verify/<ts>/build.log
  - .verify/<ts>/lint.log

## Vérifications exécutées
- ✅ <commande tests> → PASS (exit code 0)
- ✅ <commande build> → PASS (exit code 0)
- ⚠️ <commande lint> → PARTIEL (warnings présents)
- ❌ <commande extra> → ECHEC (exit code non nul)

## Verdict
**PASS** – Tous les critères critiques sont remplis.

## Prochaines étapes
- <liste des corrections ou actions à mener>
```

---

## 🔁 Procédure détaillée pour l'agent

### 1. Analyse et cadrage

1. Lire la demande de l'utilisateur (Task, contraintes, contexte projet).
2. Extraire le type de projet (Node, Python, .NET, Unity, etc.) et les commandes disponibles.
3. Si des éléments manquent, poser 3–5 questions de clarification (mode socratique) avant d'agir.

### 2. Définition des gates

1. Lister les gates (tests unitaires, build/type-check, lint, scripts custom).
2. Pour chaque gate, associer une commande directe **ou** un script dans `skills/verify/scripts/`.
3. Documenter les gates dans le plan de vérification.

### 3. Initialisation du dossier `.verify/<timestamp>/`

1. Générer un timestamp (format ISO ou UNIX).
2. Créer `.verify/<ts>/` et `report.md` avec le squelette initial.

### 4. Exécution des gates via Bash

Pour chaque gate :

1. Exécuter la commande via l'outil Bash.
2. Capturer l'exit code et les logs dans un fichier dédié.
3. Attribuer un statut : PASS / ECHEC / PARTIEL.
4. **Jamais déclarer PASS sans log et exit code vérifiés.**

### 5. Synthèse et verdict

1. Calculer le verdict global :
   - **PASS** : toutes les vérifications critiques sont PASS.
   - **ECHEC** : au moins une vérification critique est ECHEC.
   - **PARTIEL** : critiques PASS mais warnings ou gaps présents.
   - **BLOQUÉ** : impossible d'exécuter les commandes (config manquante).
2. Compléter `report.md` avec les artefacts, logs, verdict et prochaines étapes.

### 6. Livraison à l'utilisateur

1. Résumer dans la réponse : ce qui a été vérifié, les commandes exécutées, le verdict global.
2. Indiquer l'emplacement de `.verify/<ts>/report.md` et des logs individuels.
3. Proposer les prochaines actions (corrections, PR, merge, déploiement).

---

## 🛡️ Anti-hallucination et sécurité

- Toujours utiliser Bash pour exécuter les commandes, jamais simuler les résultats.
- Si une commande échoue, afficher l'erreur et proposer une correction.
- Ne jamais masquer un échec dans le verdict.
- Les secrets (env, tokens) ne doivent jamais apparaître en clair dans les logs.
- Ne jamais lancer de commandes destructrices sans confirmation explicite de l'utilisateur.

---

## 🔗 Intégration avec les autres skills

| Skill | Rôle dans le pipeline |
|-------|----------------------|
| `gauntlet-loop-dev` | Orchestre ou génère la liste de gates |
| `unity-gamedev` | Définit les gates spécifiques Unity |
| `indagis-feature-builder` | Génère les features à vérifier |
| `verify-feature-end2end` | Extension e2e (playwright, CI, PR gate) |
| `verify-context-health` | Audit santé du contexte agent |
| `verify-unity-playmode` | Gates spécifiques Unity CLI + playmode |

---

## 📚 Changelog

- **v1.1.0** (2026-09-22) : Refonte progressive disclosure, ajout mode socratique,
  intégration context engineering, sécurité renforcée, tableau d'intégration des skills.
- **v1.0.0** : Version initiale (Gauntlet Loop, rapport `.verify/`, verdicts).
