---
name: verify-context-health
description: >
  Audite la santé du contexte agent (Claude Code / decode / Hermes) : budget de tokens au boot,
  taux d'utilisation réelle des skills, respect des patterns de progressive disclosure,
  clarté des descriptions de skills, et recommandations de nettoyage.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - verify
    - context-engineering
    - progressive-disclosure
    - skills
    - health
    - token-budget
    - anti-hallucination
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🏥 Skill `verify-context-health`

Skill d'audit de la santé du contexte agent. Il vérifie que les skills installés sont **correctement configurés, utilisés et optimisés** pour ne pas gaspiller le budget de tokens au boot.

---

## ✅ Quand utiliser ce skill

Utilise `/verify-context-health` quand :

- Tu ajoutes ou modifies des skills et veux vérifier l'impact sur le contexte.
- Tu constates que l'agent est lent, confus ou sature son contexte.
- Tu veux un rapport d'audit des skills installés dans `.claude/skills/` ou `~/.claude/skills/`.
- Tu veux identifier les skills jamais invoquées et les désactiver (`disable-model-invocation`).

Ne pas utiliser pour :

- Vérification de code applicatif (utilise `verify` ou `verify-feature-end2end`).
- Environnements sans dossier `.claude/` ou configuration skills accessible.

---

## 🔧 Pré-requis

- Un dossier `.claude/skills/` (Claude Code) ou équivalent decode/Hermes contenant des fichiers `SKILL.md`.
- Accès en lecture aux fichiers de configuration de l'agent.
- Optionnel : logs de sessions précédentes pour analyser l'utilisation réelle des skills.

---

## 🧱 Pipeline d'audit

```text
User → Claude Code + Skill verify-context-health
         ↓
   1. Lister les skills installées (Bash / Read)
   2. Analyser chaque SKILL.md : frontmatter + description + taille
         ↓
   3. Estimer le coût token au boot
   4. Identifier les skills inutilisées / mal configurées
         ↓
   5. Recommandations de nettoyage et d'optimisation
         ↓
   .verify/<timestamp>/context-health-report.md
```

---

## 📜 Procédure détaillée

### 1. Inventaire des skills

1. Lister tous les fichiers `SKILL.md` dans `.claude/skills/` (ou le dossier configuré).
2. Pour chaque skill, lire :
   - Le frontmatter YAML (name, description, version, allowed-tools).
   - La longueur totale du fichier (en lignes et en tokens estimés).
   - La présence ou absence de pattern progressive disclosure.

```bash
find .claude/skills -name 'SKILL.md' | xargs wc -l
```

### 2. Analyse des descriptions

Pour chaque skill, évaluer :

- **Clarté du trigger** : la description est-elle précise pour que le modèle sache quand l'invoquer ?
- **Anti-trigger** : y a-t-il une section "Ne pas utiliser pour" pour limiter les faux positifs ?
- **Longueur** : si le SKILL.md dépasse 200 lignes, vérifier si la progressive disclosure est en place (le corps est court, les détails sont dans des assets ou des scripts).
- **allowed-tools** : les outils sont-ils limités au strict nécessaire ?

### 3. Estimation du coût token au boot

1. Estimer ~0.75 tokens par mot pour chaque description de skill chargée au boot.
2. Identifier les skills avec `disable-model-invocation: false` (ou absent) → elles sont toutes chargées.
3. Identifier les skills avec `disable-model-invocation: true` → elles ne coûtent rien au boot.
4. Calculer le budget total estimé au boot et comparer avec la limite de la fenêtre de contexte.

### 4. Détection des anomalies

Signaler :

- Skills avec description vide ou générique (< 10 mots).
- Skills avec corps > 500 lignes sans progressive disclosure.
- Skills avec `allowed-tools` incluant des outils dangereux non nécessaires.
- Skills en doublon ou chevauchement de périmètre.
- Skills sans champ `version` ou `metadata.author`.

### 5. Recommandations

Produire une liste de recommandations classées par priorité :

- CRITIQUE : skills bloquantes ou incohérentes.
- MOYEN : optimisations de budget token.
- FAIBLE : améliorations de clarté.

---

## 📄 Format du rapport

```markdown
MODE: VERIFY-CONTEXT-HEALTH

## Inventaire des skills
| Skill | Lignes | Tokens estimés (boot) | Progressive Disclosure | Statut |
|-------|--------|----------------------|----------------------|--------|
| verify | 180 | ~420 | ✅ | OK |
| mon-skill | 620 | ~1450 | ❌ | ATTENTION |

## Budget token estimé au boot
- Total skills chargées : X
- Total tokens estimés : ~Y tokens
- Budget recommandé : < 2000 tokens au boot pour 10 skills

## Anomalies détectées
- ❌ <skill-name> : description trop courte (<10 mots)
- ⚠️ <skill-name> : corps > 500 lignes sans progressive disclosure

## Recommandations
1. [CRITIQUE] Ajouter une description claire à <skill-name>.
2. [MOYEN] Passer <skill-name> en progressive disclosure (déplacer le corps dans assets/).
3. [FAIBLE] Ajouter disable-model-invocation: true à <skill-name> si rarement utilisée.

## Verdict
**PASS** – Contexte sain, budget token OK.
# ou
**ATTENTION** – X anomalies détectées. Voir recommandations.
# ou
**CRITIQUE** – Budget token trop élevé ou skills bloquantes. Actions requises avant déploiement.
```

---

## 🛡️ Règles anti-hallucination

- Ne jamais déclarer un skill "inutilisée" sans avoir cherché des traces d'invocation dans les logs.
- Ne jamais estimer le coût token sans lire la taille réelle des fichiers via Bash.
- Toujours baser les recommandations sur des métriques lues, pas devinées.
- Si le dossier `.claude/skills/` n'existe pas, déclarer BLOQUÉ et demander le chemin correct.
