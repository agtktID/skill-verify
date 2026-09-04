![Banner](docs/banner.png "Skill verify – Mode de vérification persistant")

# Skill `verify` – Mode de vérification persistant pour agents IA

[![License](https://img.shields.io/github/license/agtktID/skill-verify.svg)](https://github.com/agtktID/skill-verify/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/agtktID/skill-verify.svg?style=social)](https://github.com/agtktID/skill-verify)

> Skill Claude Code qui force les agents à **prouver** que ce qu'ils font marche, pas juste à le dire.

![Architecture](docs/architecture.png "Flux de vérification : User → Claude Code + verify → gates → artefacts → verdict")

## 🎯 Objectif

Le skill `verify` transforme Claude Code en un **agent auto-v érifiant** qui :

- **Exige des preuves exé´´cutables** (tests, builds, logs) avant de valider une feature.
- **Bloque les merges** tant que les critères de vérification ne sont pas remplis.
- **Produit un rapport structuré´´** dans `.verify/<timestamp>/report.md` avec verdict clair.

## 🚀 Quick-start

### 1. Installer le skill

```bash
# Dans ton projet
mkdir -p .claude/skills
cp skill-verify/SKILL.md .claude/skills/verify.md
```

### 2. Activer le mode verify

```bash
claude
/verify
```

### 3. Exemple d'usage

```text
/verify

Task: Ajoute une fonction `calculateTotal()` qui somme les prix d'un panier.

Constraints:
- Écris le test unitaire AVANT l'implé´´mentation.
- Lance les tests après chaque modification.
- Si un test échoue, corrige et relance jusqu'à´´ PASS.

Deliverables:
- src/calculateTotal.js
- tests/calculateTotal.test.js
- .verify/<ts>/report.md avec verdict PASS
```

## 📋 Fonctionnalité´´s

| Feature | Description |
|---------|-------------|
| **Mode persistant** | Le skill reste actif jusqu'à´´ ce que tu le désactives. |
| **Gates de vérification** | Tests, builds, lint, type-checking, etc. |
| **Rapport structuré´´** | `.verify/<ts>/report.md` avec contexte, artefacts, verdict. |
| **Verdict clair** | `PASS`, `ECHEC`, `PARTIEL`, `BLOQUE`. |
| **Anti-hallucination** | L'agent doit exé´´cuter les commandes, pas juste les décrire. |

## 🔧 Architecture

```
User → Claude Code + Skill verify
         ↓
   Boucle interne
   Analyze → Gauntlet → Action → Verify → Verdict
         ↓
   .verify/<ts>/report.md
         ↓
   Verdict: PASS/ECHEC/PARTIEL/BLOQUE
```

## 📄 Contrat de sortie

Chaque session `verify` produit un rapport avec :

```markdown
MODE: VERIFY ARME

## Contexte
- Task: <description>
- Constraints: <liste>

## Artefacts
- src/calculateTotal.js
- tests/calculateTotal.test.js

## Vérifications exé´´cuté´´es
- ✅ npm test → PASS
- ✅ npm run build → PASS

## Verdict
**PASS** – Tous les critères sont remplis.
```

## 🤝 Contribuer

Voir [CONTRIBUTING.md](./CONTRIBUTING.md).

## 📜 Licence

MIT – Voir [LICENSE](./LICENSE).
