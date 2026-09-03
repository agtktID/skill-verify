---
name: gauntlet-loop-dev
description: Boucle builder-critic pour itérer vers une barre de qualité concrète.
version: 1.0.0
metadata:
  tags: [gauntlet, builder, critic, iteration, quality]
  license: MIT
---

# Gauntlet Loop Dev

## When to Use
Utiliser pour construire une UI, une API, un script ou une feature en visant une référence concrète.

## Procedure
1. Définir l'objectif, la stack et les contraintes.
2. Choisir une barre de qualité observable : référence, capture, dépôt ou critères mesurables.
3. Découper en morceaux testables.
4. Faire produire par un builder.
5. Faire critiquer par un rôle séparé, sans auto-évaluation.
6. Corriger le plus gros écart.
7. Rejouer les tests et recommencer jusqu'au seuil ou à l'arrêt explicite.

## Rules
- Une seule variable principale par itération lorsque possible.
- Le critic doit produire des écarts concrets et actionnables.
- Ne jamais déclarer « au niveau » sans comparaison observable.
- Combiner avec `verify` avant de conclure.

## Output
Objectif, barre, tâches, critique, correction, preuves, verdict et prochaine itération.
