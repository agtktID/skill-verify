![Banner](docs/banner.png "Skill verify – Mode de vérification persistant")

# Skill `verify` – Mode de vérification persistant pour agents IA

[![License](https://img.shields.io/github/license/agtktID/skill-verify.svg)](https://github.com/agtktID/skill-verify/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/agtktID/skill-verify.svg?style=social)](https://github.com/agtktID/skill-verify)

> Collection de skills Claude Code qui forcent les agents à **prouver** que ce qu'ils font fonctionne, pas juste à le dire.

## 🎯 Objectif

Ce dépôt fournit un catalogue de skills de vérification pour Claude Code, Hermes et decode.
Chaque skill encode une boucle de qualité avec des gates exécutables, des logs traçables
et un rapport structuré avec verdict clair.

Principes communs :

- **Anti-hallucination** : l'agent doit exécuter les commandes, pas juste les décrire.
- **Progressive disclosure** : les SKILL.md restent concis ; les scripts lourds vivent dans `scripts/`.
- **Context Engineering 2026** : token budget maîtrisé, descriptions claires, triggers précis.
- **Verdicts standardisés** : `PASS`, `ECHEC`, `PARTIEL`, `BLOQUÉ`.

---

## 📦 Catalogue des skills

| Skill | Description | Usage |
|-------|-------------|-------|
| [`verify`](./skills/verify/) | Mode de vérification persistant — tests, build, lint, rapport | `/verify` |
| [`verify-feature-end2end`](./skills/verify-feature-end2end/) | Pipeline e2e — démarrage app, Playwright/cURL, CI locale, PR gate | `/verify-feature-end2end` |
| [`verify-context-health`](./skills/verify-context-health/) | Audit santé du contexte agent — token budget, progressive disclosure | `/verify-context-health` |
| [`verify-unity-playmode`](./skills/verify-unity-playmode/) | Vérification Unity CLI — tests EditMode/PlayMode, build batchmode | `/verify-unity-playmode` |
| [`skill-architect`](./skills/skill-architect/) | Conception et documentation de nouveaux skills | `/skill-architect` |
| [`gauntlet-loop-dev`](./skills/gauntlet-loop-dev/) | Orchestration de gates de qualité (Gauntlet Loop) | `/gauntlet-loop-dev` |
| [`indagis-feature-builder`](./skills/indagis-feature-builder/) | Générateur de features pour projets Indagis | `/indagis-feature-builder` |
| [`unity-gamedev`](./skills/unity-gamedev/) | Développement Unity complet (workflow, scripts, gamedev) | `/unity-gamedev` |

---

## 🚀 Quick-start

### 1. Installer un skill dans ton projet

```bash
# Cloner le dépôt
git clone https://github.com/agtktID/skill-verify.git

# Copier le skill souhaité dans ton projet
mkdir -p .claude/skills
cp skill-verify/skills/verify/SKILL.md .claude/skills/verify.md

# Ou copier plusieurs skills d'un coup
cp -r skill-verify/skills/verify .claude/skills/
cp -r skill-verify/skills/verify-feature-end2end .claude/skills/
cp -r skill-verify/skills/verify-unity-playmode .claude/skills/
```

### 2. Activer un skill dans Claude Code

```bash
claude
/verify
# ou
/verify-feature-end2end
# ou
/verify-unity-playmode
```

### 3. Exemple d'usage avec `/verify`

```text
/verify

Task: Ajoute une fonction `calculateTotal()` qui somme les prix d'un panier.

Constraints:
- Écris le test unitaire AVANT l'implémentation.
- Lance les tests après chaque modification.
- Si un test échoue, corrige et relance jusqu'à PASS.

Deliverables:
- src/calculateTotal.js
- tests/calculateTotal.test.js
- .verify/<ts>/report.md avec verdict PASS
```

---

## 📋 Fonctionnalités communes

| Feature | Description |
|---------|-------------|
| **Mode persistant** | Le skill reste actif jusqu'à ce que tu le désactives. |
| **Gates de vérification** | Tests, builds, lint, type-checking, scripts custom. |
| **Rapport structuré** | `.verify/<ts>/report.md` avec contexte, artefacts, verdict. |
| **Verdict clair** | `PASS`, `ECHEC`, `PARTIEL`, `BLOQUÉ`. |
| **Anti-hallucination** | L'agent doit exécuter les commandes, pas juste les décrire. |
| **Progressive disclosure** | SKILL.md concis ; scripts et assets dans des sous-dossiers. |

---

## 🔧 Architecture générale

```text
User → Claude Code + Skill verify
         ↓
   Boucle interne
   Analyze → Gauntlet → Action → Verify → Verdict
         ↓
   .verify/<ts>/report.md
         ↓
   Verdict: PASS / ECHEC / PARTIEL / BLOQUÉ
```

### Structure du dépôt

```text
skill-verify/
├── skills/
│   ├── verify/                     ← Skill de vérification principal
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   ├── hooks/
│   │   ├── evals/
│   │   └── assets/
│   ├── verify-feature-end2end/     ← Pipeline e2e (Playwright, CI, PR gate)
│   │   └── SKILL.md
│   ├── verify-context-health/      ← Audit santé contexte agent
│   │   └── SKILL.md
│   ├── verify-unity-playmode/      ← Vérification Unity CLI
│   │   └── SKILL.md
│   ├── skill-architect/
│   ├── gauntlet-loop-dev/
│   ├── indagis-feature-builder/
│   ├── unity-gamedev/
│   └── manifest.yml
├── assets/
├── .github/
├── CHANGELOG.md
├── CONTRIBUTING.md
└── README.md
```

---

## 📄 Format du rapport de sortie

Chaque session produit un rapport dans `.verify/<timestamp>/report.md` :

```markdown
MODE: VERIFY ARMÉ

## Contexte
- Task: <description>
- Constraints: <liste>

## Artefacts
- src/calculateTotal.js
- tests/calculateTotal.test.js

## Vérifications exécutées
- ✅ npm test → PASS
- ✅ npm run build → PASS

## Verdict
**PASS** – Tous les critères sont remplis.
```

---

## 🤝 Contribuer

Voir [CONTRIBUTING.md](./CONTRIBUTING.md).

## 📜 Licence

MIT – Voir [LICENSE](./LICENSE).
