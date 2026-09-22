---
name: verify-context-health
description: >
  Audit de santé du contexte agent (Claude Code / Hermes / decode) : coût des skills en tokens
  au boot, taux d'utilisation des skills, respect de la progressive disclosure, skills inutilisées
  à désactiver, recommandations de nettoyage. Produit un rapport context-health-<ts>.md.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  category: verification
  tags:
    - context-engineering
    - health
    - progressive-disclosure
    - skills
    - token-budget
    - audit
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🎯 Rôle du skill `verify-context-health`

Audite l'ensemble des skills d'un projet agent pour identifier : coût en contexte, skills jamais invoquées, descriptions mal formées, absence de progressive disclosure, et propose des actions de nettoyage concrètes.

---

## ✅ Quand utiliser ce skill

Utilise `/verify-context-health` quand :

- Avant d'ajouter de nouveaux skills (éviter le context bloat).
- L'agent semble ignorer certains skills ou les confondre.
- Audit périodique de santé du projet agent.
- Après une refonte de skill avec `skill-architect`.
- Le budget token au boot semble trop élevé (lenteur, troncature de contexte).

---

## 🔧 Pré-requis

- Accès au dossier `.claude/skills/` ou `skills/` du projet.
- Optionnel : logs de sessions précédentes pour détecter les skills jamais invoquées.
- Optionnel : `manifest.yml` avec liste des skills enregistrées.

---

## 🧱 Architecture de l'audit

```text
Scan skills/ → Lire chaque SKILL.md → Analyser frontmatter + description
     ↓
Évaluer : taille, clarté trigger, progressive disclosure, redondance
     ↓
Croiser avec manifest.yml (si présent)
     ↓
Rapport context-health-<ts>.md avec score et recommandations
```

---

## 📋 Procédure détaillée

### Étape 1 — Inventaire des skills

```bash
find .claude/skills/ skills/ -name "SKILL.md" 2>/dev/null | sort | tee .verify/<ts>/skills-list.log
```

### Étape 2 — Audit de chaque SKILL.md

Pour chaque fichier, vérifier :

| Critère | Seuil recommandé | Impact |
|---|---|---|
| Taille du SKILL.md | < 4 000 tokens (~16 KB) | Context bloat si dépassé |
| Description frontmatter | 1–3 phrases, trigger clair | Active/inhibe l'invocation |
| Présence d'anti-trigger | Optionnel mais recommandé | Réduit les faux positifs |
| Progressive disclosure | Détails dans scripts/ ou assets/ | Réduit charge au boot |
| `allowed-tools` déclaré | Obligatoire | Sécurité + lisibilité |
| `version` déclarée | Obligatoire | Traçabilité |

### Étape 3 — Détection des skills inutilisées

```bash
# Si logs disponibles, chercher les invocations
grep -r "/<skill-name>" .claude/logs/ 2>/dev/null | sort | uniq -c | sort -rn
```

Toute skill sans invocation depuis > 30 sessions → candidat à `disable-model-invocation: true`.

### Étape 4 — Vérification progressive disclosure

Une SKILL.md respecte la progressive disclosure si :
- La description frontmatter est courte (trigger uniquement).
- Les scripts lourds vivent dans `scripts/`.
- Les docs longues vivent dans `assets/reference.md`.
- Le SKILL.md lui-même est < 4 000 tokens.

### Étape 5 — Détection des redondances

Comparer les descriptions de toutes les skills. Si deux descriptions se ressemblent sémantiquement → signaler la redondance possible et proposer une fusion ou une délimitation claire.

### Étape 6 — Calcul du budget token au boot

```bash
for f in $(find .claude/skills/ skills/ -name "SKILL.md" 2>/dev/null); do
  wc -c "$f"
done | awk '{sum += $1} END {printf "Total chars: %d\nEstimated tokens: %d\n", sum, sum/4}'
```

### Étape 7 — Synthèse et score global

| Score | Condition |
|---|---|
| **A** (sain) | Budget < 8 000 tokens, toutes les skills bien formées |
| **B** (améliorable) | 1–3 skills à refactorer, budget < 16 000 tokens |
| **C** (à refactorer) | > 3 skills problématiques ou budget > 16 000 tokens |
| **D** (critique) | Context bloat sévère ou skills cassées détectées |

---

## 📜 Format du rapport `context-health-<ts>.md`

```markdown
# Rapport Context Health — <timestamp>

## Inventaire
- Skills trouvées : <N>
- Budget token estimé au boot : <N> tokens

## Analyse par skill

| Skill | Taille (KB) | Tokens estimés | Trigger clair | Progressive Disc. | Score |
|---|---|---|---|---|---|
| verify | X KB | X | ✅ | ✅ | A |
| skill-architect | X KB | X | ✅ | ⚠️ | B |

## Skills à risque
- <skill> : <raison> → Recommandation : <action>

## Recommandations
1. Déplacer <section> de <skill> vers `scripts/` ou `assets/`
2. Passer <skill> en `disable-model-invocation: true`
3. Fusionner <skill-A> et <skill-B> (redondance détectée)
4. Réduire description de <skill> à 1–2 phrases trigger

## Score global
**A** (sain) / **B** (améliorable) / **C** (à refactorer) / **D** (critique)
```

---

## 🛡️ Anti-hallucination et sécurité

- Ne jamais estimer les tokens sans calcul réel via Bash.
- Ne jamais déclarer une skill "inutilisée" sans preuve (logs ou absence d'invocation vérifiée).
- Ne pas supprimer de fichiers sans confirmation explicite de l'utilisateur.
- Ne pas modifier les SKILL.md directement — seulement recommander des actions.

---

## 🔗 Intégration avec les autres skills

| Skill | Rôle |
|---|---|
| `skill-architect` | Refactore les skills identifiées comme problématiques |
| `verify` | Valide après refactor qu'aucun skill existant n'est cassé |
| `project-review` | Inclut un audit context-health dans la revue globale |
