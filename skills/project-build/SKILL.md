---
name: project-build
description: >
  Implémente une feature ou une phase de développement avec la boucle TDD de Matt Pocock :
  écrire le test d'abord, implémenter jusqu'au PASS, refactorer, puis valider avec les gates verify.
  Utiliser quand l'utilisateur veut coder une feature, résoudre une issue ou avancer sur une phase du PRD.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
  tags:
    - project
    - build
    - tdd
    - implementation
    - gauntlet-loop
    - matt-pocock
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🔨 Rôle du skill `project-build`

Ce skill encode la boucle TDD de Matt Pocock (**Red → Green → Refactor**) combinée
avec le **Gauntlet Loop** pour garantir que chaque feature est testée et validée
avant de passer à la suivante.

Inspiré de : Matt Pocock's `/tdd`, Superpowers `/test-driven-development`,
Gauntlet Loop (Matt Shumer), GSD `/gsd-build`.

Flux : **Issue → Test (RED) → Implémentation (GREEN) → Refactor → Verify (PASS)**

---

## ✅ Quand utiliser ce skill

Utilise `/project-build` quand :

- Tu implémentes une issue ou une feature du PRD.
- Tu veux forcer la discipline TDD (test avant code).
- Tu veux une boucle de qualité automatique après chaque implémentation.

**Ne pas utiliser pour :**

- Initialiser un projet (utiliser `/project-init`).
- Écrire des tests en masse sans implémentation (utiliser `/project-test`).
- Déployer (utiliser `/project-ship`).

---

## 🧱 Boucle TDD + Gauntlet

```text
/project-build <issue>
    ↓
[ÉTAPE 1] Analyse de l'issue
    → Lire docs/prd.md + docs/issues.md
    → Identifier les acceptance criteria
    ↓
[ÉTAPE 2] RED — Écrire le test AVANT
    → tests/<feature>.test.{js,ts,py,go}
    → Lancer : npm test (doit ÉCHOUER)
    ↓
[ÉTAPE 3] GREEN — Implémenter
    → src/<feature>.{js,ts,py,go}
    → Lancer les tests en boucle jusqu'à PASS
    ↓
[ÉTAPE 4] REFACTOR
    → Améliorer la lisibilité, supprimer la duplication
    → Lancer les tests → doivent rester PASS
    ↓
[ÉTAPE 5] GAUNTLET
    → Lint, typecheck, build
    → Revue auto du code (anti-patterns)
    ↓
[ÉTAPE 6] VERIFY
    → bash skills/verify/scripts/check.sh --all
    → Rapport .verify/<ts>/report.md
    ↓
Feature DONE → commit atomique
```

---

## 🔁 Procédure pour l'agent

### Étape 1 : Analyse

1. Lire `docs/prd.md` (si présent) pour le contexte du projet.
2. Lire `docs/issues.md` ou l'issue spécifiée.
3. Extraire les acceptance criteria.
4. Identifier les fichiers à créer ou modifier.

### Étape 2 : RED — Test d'abord

1. Écrire le fichier de test **avant** toute implémentation.
2. Nommer le fichier : `tests/<feature>.test.<ext>` ou `<feature>_test.<ext>`.
3. Le test doit couvrir :
   - Le cas nominal (happy path).
   - Au moins 1 cas d'erreur (edge case).
   - Les acceptance criteria de l'issue.
4. Lancer les tests → **doit échouer** (RED confirmé).

```bash
# Exemple Node/TypeScript
npm test -- --testPathPattern="<feature>"

# Exemple Python
pytest tests/test_<feature>.py -v

# Exemple Go
go test ./... -run Test<Feature>
```

### Étape 3 : GREEN — Implémentation minimale

1. Écrire le code **minimal** pour faire passer les tests.
2. Ne pas sur-ingénier à cette étape.
3. Relancer les tests après chaque modification.
4. Boucler jusqu'à GREEN (tous les tests PASS).

**Règle anti-hallucination :** ne jamais déclarer GREEN sans voir le résultat de `npm test` (ou équivalent).

### Étape 4 : REFACTOR

1. Améliorer le code sans changer son comportement :
   - Supprimer la duplication.
   - Améliorer les noms de variables et fonctions.
   - Extraire des fonctions si > 20 lignes.
2. Relancer les tests → doivent rester PASS.

### Étape 5 : Gauntlet

```bash
# Lint
npm run lint  # ou flake8 / golangci-lint

# Typecheck (TypeScript)
npx tsc --noEmit

# Build
npm run build
```

Revue auto du code :
- [ ] Pas de `any` (TypeScript) / pas de `*` import non justifié.
- [ ] Pas de `console.log` de debug laissé.
- [ ] Gestion des erreurs présente (try/catch, error return).
- [ ] Pas de secrets en dur.

### Étape 6 : Verify

```bash
bash .claude/skills/verify/scripts/check.sh --all
# ou depuis la racine du dépôt skill-verify :
bash skills/verify/scripts/check.sh --all
```

Si PASS → commit atomique :

```bash
git add .
git commit -m "feat(<scope>): <description courte>"
```

Si ECHEC → corriger et reboucler depuis l'étape 3.

---

## 📄 Livrables par feature

- `src/<feature>.<ext>` — implémentation
- `tests/<feature>.test.<ext>` — tests
- `.verify/<ts>/report.md` — rapport verify
- 1 commit atomique (`feat:`, `fix:`, `refactor:`)

---

## 🔗 Prochaines étapes

- Feature terminée → utiliser `/project-test` pour la suite de tests complète.
- Toutes les features terminées → utiliser `/project-ship` pour déployer.
