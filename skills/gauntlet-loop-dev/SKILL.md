---
name: gauntlet-loop-dev
description: >-
  Boucle builder-critic pour itérer vers une barre de qualité concrète.
  Utiliser pour construire une UI, une API, un script ou une feature en comparant
  à une référence observable jusqu'à atteindre le seuil ou l'arrêt explicite.
version: "1.1.0"
license: MIT
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - gauntlet
    - builder
    - critic
    - iteration
    - quality
    - tdd
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🥊 Gauntlet Loop Dev

Skill de boucle builder-critic pour itérer vers une barre de qualité concrète et observable.
Chaque itération produit un écart actionnable, une correction et une preuve avant de continuer.

---

## ✅ When to Use

Utiliser ce skill pour :

- Construire une UI, une API, un script ou une feature en visant une référence concrète.
- Refactorer du code existant jusqu'à atteindre des critères mesurables.
- Implémenter une feature avec TDD (Red → Green → Refactor).
- Combiner avec `verify` pour valider les preuves avant de conclure.

Ne pas utiliser pour :

- Questions de documentation ou de syntaxe simples.
- Tâches sans barre de qualité observable (si tu ne peux pas mesurer, définis la barre d'abord).

---

## 🔧 Pré-requis

- Un objectif de feature clairement défini.
- Une **barre de qualité observable** : référence visuelle, capture d'écran, dépôt de référence, ou critères mesurables (coverage, perf, sortie attendue).
- Une stack et des contraintes définies (langage, framework, limites de périmètre).

---

## 🔁 Procédure (Gauntlet Loop)

```text
User → Skill gauntlet-loop-dev
         ↓
   Analyze → Define Bar → Decompose
         ↓
   Builder (produit) → Critic (compare à la barre) → Gap
         ↓
   Correct biggest gap → Re-run tests
         ↓
   Iterate → Seuil atteint OU arrêt explicite
         ↓
   Preuves → Verdict → Combiner avec /verify
```

### Étapes détaillées

1. **Définir l'objectif** : quoi construire, stack, contraintes, périmètre.
2. **Choisir la barre de qualité** : référence, capture, dépôt ou critères mesurables.
3. **Découper en morceaux testables** : tâches indépendantes, une variable principale par itération.
4. **Builder** : l'agent produit l'implémentation.
5. **Critic** (rôle séparé, sans auto-évaluation) : compare à la barre et identifie les écarts concrets.
6. **Corriger le plus gros écart** : une correction ciblée, une variable à la fois.
7. **Rejouer les tests** et recommencer jusqu'au seuil ou à l'arrêt explicite.
8. **Combiner avec `verify`** avant de déclarer terminé.

---

## 🛡️ Règles

- **Une seule variable principale** par itération lorsque possible.
- Le **critic doit produire des écarts concrets et actionnables** — pas de jugements vagues.
- **Ne jamais déclarer « au niveau »** sans comparaison observable avec la barre.
- **Combiner avec `verify`** avant de conclure : les preuves exécutables valident le résultat.
- Si la barre de qualité n'est pas définie, **STOP** et demander à l'utilisateur de la définir.
- Ne pas modifier le périmètre en cours d'itération sans accord explicite.

---

## 📋 Output attendu

Chaque itération produit :

```
## Gauntlet Itération N

### Objectif
<description de la tâche>

### Barre de qualité
<référence ou critères mesurables>

### Builder — Implémentation
<fichiers produits, diff ou description>

### Critic — Écarts identifiés
- Écart 1 : <description concrète et actionnable>
- Écart 2 : ...

### Correction appliquée
<plus gros écart corrigé, preuve>

### Tests relancés
- ✅ <test 1> → PASS
- ❌ <test 2> → ECHEC (correction planifiée)

### Verdict
Seuil atteint : OUI / NON → prochaine itération ou arrêt
```

**Sortie finale** : objectif, barre, tâches, critique, correction, preuves, verdict et prochaine itération.
