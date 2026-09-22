---
name: indagis-feature-builder
description: >-
  Construit les features Indagis une par une avec scope strict, spec-first et vérification.
  Utiliser pour ajouter une feature, un plugin ou un module à Indagis Agent sans dérive de périmètre.
  Toujours vérifier le diff avant commit et rejouer le flux réel avant de continuer.
version: "1.1.0"
license: MIT
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - indagis
    - plugins
    - feature
    - spec-first
    - bmad
    - scope-control
    - diff-driven
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🧩 Indagis Feature Builder

Skill de construction de features pour Indagis Agent avec scope strict, spec-first et vérification continue.
Chaque feature est construite en isolant le périmètre, en vérifiant le diff, et en rejouant le flux réel avant de valider.

---

## ✅ When to Use

Utiliser ce skill pour :

- Ajouter une **feature, un plugin ou un module** à Indagis Agent.
- Implémenter une feature depuis une spec sans dériver du périmètre défini.
- Vérifier qu'une feature existante ne régresse pas après une modification.
- Rejouer le flux réel et capturer l'UI avant de continuer.

Ne pas utiliser pour :

- Modifier des fichiers hors du dossier autorisé sans accord explicite.
- Inventer des données de session ou des comportements non spécifiés.
- Push sans validation explicite de l'utilisateur.

---

## 🔧 Pré-requis

- Le dépôt Indagis disponible localement ou accessible.
- Un dossier autorisé défini (ex. `plugins/mon-plugin/`).
- Une référence de plugin existant (ex. le plugin kanban) pour s'aligner sur le pattern.
- Les critères d'acceptation de la feature.

---

## 🔁 Procédure (Spec-First)

```text
User → Skill indagis-feature-builder
         ↓
   Spec (quoi, pourquoi, scope, hors scope, critères d'acceptation)
         ↓
   Inspecter le dépôt → Choisir une référence réelle
         ↓
   Définir l'aire de contribution + dossier autorisé
         ↓
   Découper en tâches indépendantes et testables
         ↓
   [Pour chaque tâche]
   Construire → Vérifier diff → Commit → Tester régression
         ↓
   Rejouer flux réel → Capturer UI → Valider
         ↓
   Push uniquement après validation explicite
```

### Étapes détaillées

1. **Écrire la spec** : quoi, pourquoi, scope, hors scope, critères d'acceptation.
2. **Inspecter le dépôt** et choisir une **référence réelle** (ex. plugin kanban) comme point de comparaison.
3. **Définir l'aire de contribution** : dossier autorisé, fichiers existants interdits de modification sauf accord.
4. **Découper en tâches indépendantes et testables** : une tâche = un changement vérifiable.
5. **Construire une seule tâche à la fois**.
6. **Vérifier le diff littéral** avant chaque commit — signaler toute modification hors périmètre.
7. **Vérifier la non-régression** : les fonctionnalités existantes doivent rester intactes.
8. **Rejouer le flux réel**, capturer l'UI, et seulement ensuite continuer à la tâche suivante.
9. **Push uniquement après validation explicite** de l'utilisateur.

---

## 🛡️ Règles de scope strict

- **Ne créer que dans le dossier autorisé** — tout fichier hors dossier nécessite une décision explicite.
- **Ne modifier aucun fichier existant** si la spec l'interdit, même pour corriger une erreur adjacente.
- **Si une dépendance ou route existante manque** : STOP, signaler clairement, ne pas improviser.
- **Ne jamais inventer de données de session** : utiliser uniquement les données réelles du contexte.
- **Push uniquement après validation explicite** : ne pas auto-pusher même si tout est PASS.
- Si une étape bloque et que la spec ne couvre pas le cas, **STOP et demander clarification**.

---

## 📋 Output attendu

```
## Indagis Feature — <nom de la feature>

### Spec
- Quoi : <description>
- Pourquoi : <justification>
- Scope : <périmètre autorisé>
- Hors scope : <ce qui est exclu>
- Critères d'acceptation : <liste>

### Référence utilisée
<plugin ou fichier de référence>

### Plan de tâches
1. <tâche 1>
2. <tâche 2>
...

### Tâche courante : <N>
- Fichiers touchés : <liste>
- Diff vérifié : OUI / NON
- Tests régression : PASS / ECHEC
- Flux réel rejoué : OUI / NON
- Capture UI : <chemin ou description>

### Statut
NON VÉRIFIÉ / EN COURS / VALIDÉ — prochaine tâche : <N+1>
```
