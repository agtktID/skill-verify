---
name: verify-context-health
description: >
  Audite la santé du contexte agent (Claude Code / Hermes / decode) : coût des skills en tokens,
  taux d'utilisation réel, respect des patterns de progressive disclosure, descriptions trop longues
  ou trop courtes, skills jamais invoquées, et recommandations de nettoyage. Produit un rapport
  context-health-<timestamp>.md avec score de santé et plan d'action.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
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

Ce skill inspecte la configuration de ton agent (skills, system prompt, hooks, CLAUDE.md)
pour détecter les problèmes de consommation de contexte et les non-conformités aux bonnes
pratiques de Context Engineering 2026 :

- **Progressive Disclosure** : les descriptions de skills sont-elles concises (< 120 chars) ?
- **Token budget** : combien de tokens sont consommés au boot ?
- **Skills inutilisées** : quelles skills ne sont jamais invoquées ?
- **Descriptions manquantes ou trop verboses** : quels skills ont des descriptions non conformes ?
- **Tool Schema Management** : les schémas d'outils sont-ils optimisés ?

---

## ✅ Quand utiliser ce skill

Utilise `/verify-context-health` quand :

- L'agent se plaint de **contexte saturé** ou répète des erreurs déjà corrigées.
- Tu as ajouté **plusieurs nouveaux skills** et tu veux vérifier l'impact sur le contexte.
- Tu veux **nettoyer** ton catalogue de skills (supprimer les inutilisées, optimiser les descriptions).
- Tu prépares un **audit de configuration** avant un déploiement en production.

**Ne pas utiliser pour :**

- Agents avec moins de 10 skills (l'optimisation n'est pas nécessaire en dessous de ce seuil).
- Quand l'agent n'a pas de problème connu de contexte et que le catalogue est petit.

---

## 🔧 Pré-requis

- Accès en lecture au dossier `.claude/skills/` (ou équivalent Hermes / decode).
- Accès au fichier `CLAUDE.md` ou équivalent (system prompt).
- Optionnel : logs d'utilisation des skills (pour détecter les inutilisées).

---

## 🧱 Architecture de l'audit

```text
User → /verify-context-health
         ↓
   1. Découverte : lister tous les SKILL.md disponibles
         ↓
   2. Analyse description : longueur, clarté, trigger / anti-trigger
         ↓
   3. Estimation token budget : coût au boot (descriptions + frontmatter)
         ↓
   4. Détection des skills inutilisées (si logs disponibles)
         ↓
   5. Vérification progressive disclosure (niveau 1 vs niveau 2)
         ↓
   6. Rapport context-health-<timestamp>.md
         ↓
   Score de santé : SAIN / ATTENTION / CRITIQUE
```

---

## 🔁 Procédure pour l'agent

### Étape 1 : Découverte des skills

1. Lister tous les fichiers `SKILL.md` disponibles dans `.claude/skills/` (ou équivalent).
2. Pour chaque skill, extraire :
   - `name`
   - `description` (longueur en caractères)
   - `allowed-tools`
   - `version`
   - `disable-model-invocation` (si présent)

### Étape 2 : Analyse des descriptions

Pour chaque description :

| Critère | Cible | Statut |
|---------|-------|--------|
| Longueur description | < 120 chars (niveau 1 boot) | ✅ / ⚠️ / ❌ |
| Trigger clair | Verbe d'action ou situation précise | ✅ / ⚠️ / ❌ |
| Anti-trigger présent | "Ne pas utiliser pour..." | ✅ / ⚠️ / ❌ |
| Allowed-tools minimal | Pas d'outils superflus | ✅ / ⚠️ / ❌ |

### Étape 3 : Estimation du token budget au boot

1. Estimer le coût en tokens de toutes les descriptions de skills au boot.
2. Cibles (source : Context Engineering 2026) :
   - < 5 000 tokens de descriptions au boot (même avec 100+ skills).
   - Chaque description de skill : < 50 tokens.
3. Signaler si le budget est dépassé.

### Étape 4 : Détection des skills inutilisées

1. Si des logs d'utilisation sont disponibles, identifier les skills jamais invoquées
   sur les 30 derniers jours.
2. Pour chaque skill inutilisée, recommander :
   - La désactiver (`disable-model-invocation: true`).
   - La supprimer si elle est obsolète.
   - Vérifier si sa description est assez claire pour être déclenchée.

### Étape 5 : Vérification progressive disclosure

1. Vérifier que chaque skill ne charge pas son contenu complet au boot.
2. Vérifier que les scripts et assets lourds sont dans des sous-dossiers
   (`scripts/`, `assets/`, `evals/`) et non dans `SKILL.md`.
3. Vérifier que `SKILL.md` ne dépasse pas 2 000 tokens (limite recommandée
   pour une progressive disclosure efficace).

### Étape 6 : Score de santé et rapport

Calculer le score de santé :

- **SAIN** : toutes les cibles sont respectées.
- **ATTENTION** : 1 à 3 problèmes mineurs détectés.
- **CRITIQUE** : budget token dépassé, ou 3+ skills avec des descriptions non conformes.

Générer `.verify/<timestamp>/context-health-report.md` avec :

- Tableau de synthèse des skills (nom, description, longueur, statut).
- Estimation du token budget au boot.
- Liste des skills inutilisées (si applicable).
- Score de santé global.
- Plan d'action prioritaire.

---

## 📜 Format du rapport `context-health-report.md`

```markdown
MODE: CONTEXT HEALTH AUDIT

## Résumé
- Skills analysées: <nombre>
- Token budget estimé au boot: <estimation>
- Score de santé: SAIN / ATTENTION / CRITIQUE

## Tableau des skills
| Skill | Description (chars) | Trigger clair | Anti-trigger | Allowed-tools | Statut |
|-------|-------------------|---------------|--------------|--------------|--------|
| verify | 89 | ✅ | ✅ | Bash, Read, Write | ✅ SAIN |
| ... | ... | ... | ... | ... | ... |

## Token budget au boot
- Total estimé: <tokens>
- Cible: < 5 000 tokens
- Statut: ✅ / ⚠️ / ❌

## Skills inutilisées (30 derniers jours)
- <liste ou "Aucune détectée">

## Plan d'action
1. <action prioritaire 1>
2. <action prioritaire 2>
3. <action prioritaire 3>
```

---

## 🔗 Voir aussi

- `skill-context-engineering` : les 5 patterns Context Engineering 2026.
- `skill-architect` : pour créer de nouveaux skills conformes.
- `verify` : pour vérifier du code après une modification.
