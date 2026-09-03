---
name: indagis-feature-builder
description: Construit les features Indagis une par une avec scope strict et vérification.
version: 1.0.0
metadata:
  tags: [indagis, plugins, feature, spec-first, bmad]
  license: MIT
---

# Indagis Feature Builder

## When to Use
Pour ajouter une feature, un plugin ou un module à Indagis Agent sans dérive de périmètre.

## Procedure
1. Écrire la spec : quoi, pourquoi, scope, hors scope, critères d'acceptation.
2. Inspecter le dépôt et choisir une référence réelle, par exemple le plugin kanban.
3. Définir l'aire de contribution et l'emplacement autorisé.
4. Découper en tâches indépendantes et testables.
5. Construire une seule tâche à la fois.
6. Vérifier le diff littéral avant chaque commit.
7. Vérifier que les fonctionnalités existantes ne régressent pas.
8. Rejouer le flux réel, capturer l'UI et seulement ensuite continuer.

## Strict Scope
- Ne créer que dans le dossier autorisé.
- Ne modifier aucun fichier existant sans décision explicite si la spec l'interdit.
- Si une dépendance ou une route existante manque, STOP et expliquer.
- Ne jamais inventer de données de session.
- Push uniquement après validation explicite.

## Output
Spec, plan, tâches, fichiers touchés, diff, tests, captures, NON VÉRIFIÉ, verdict et prochaine tâche.
