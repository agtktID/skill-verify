---
name: skill-architect
description: Conçoit, audite et évalue des skills et prompts de production.
version: 1.0.0
metadata:
  tags: [skills, prompts, architecture, evals, security]
  license: MIT
---

# Skill Architect

## When to Use
Pour créer, auditer, refactorer, versionner ou évaluer un `SKILL.md`, un system prompt, un workflow ou une équipe d'agents.

## Procedure
1. Extraire Goal / Output / Limits / Data / Evaluation.
2. Définir le déclenchement et les cas d'exclusion.
3. Écrire un frontmatter valide : nom identique au dossier, description précise et courte.
4. Structurer rôle, mission, procédure, outils, sécurité, sortie et critères d'arrêt.
5. Ajouter références, templates, scripts et evals seulement s'ils servent le comportement.
6. Séparer instructions et données de référence avec délimiteurs.
7. Vérifier secrets, actions destructives et prompt injection.
8. Tester should-trigger et should-not-trigger plusieurs fois.
9. Versionner et documenter chaque changement.

## Quality Gates
- Le skill se déclenche au bon moment.
- Les sorties sont directement utilisables.
- Les inconnues sont signalées.
- Aucun secret en clair.
- Les actions externes exigent confirmation.
- Le skill refuse ou demande clarification lorsque le contexte est insuffisant.

## Output
Diagnostic, architecture, SKILL.md final, arborescence, tests, limites et changelog.
