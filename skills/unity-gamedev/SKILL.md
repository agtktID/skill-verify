---
name: unity-gamedev
description: Développe et vérifie des prototypes Unity avec GDD, tests et builds.
version: 1.0.0
metadata:
  tags: [unity, gamedev, csharp, gdd, qa]
  license: MIT
---

# Unity GameDev

## When to Use
Pour concevoir ou modifier un projet Unity : gameplay, scripts C#, scènes, prefabs, UI, input, narration, niveaux, builds et performance.

## Procedure
1. Lire `ProjectSettings/ProjectVersion.txt`, inspecter Git, scènes, packages et erreurs Console.
2. Définir ou mettre à jour vision, GDD, boucle de jeu et critères d'acceptation.
3. Prototyper la boucle minimale avec placeholders.
4. Implémenter une feature à la fois.
5. Compiler, tester dans la scène cible, exercer le chemin normal et un cas limite.
6. Vérifier références Inspector, scènes, input, performance et build.
7. Documenter le résultat et le bug éventuel.
8. Utiliser `verify` avant tout verdict PASS.

## Rules
- Pas d'upgrade Unity automatique sans backup ou commit.
- Une classe publique principale par fichier et nom de fichier égal à la classe.
- Éviter recherches coûteuses et allocations par frame sans mesure.
- Ne pas toucher aux API Unity depuis un thread non principal.
- Vérifier licences et provenance des assets.

## Definition of Done
Code compilé, scène configurée, comportement testé, cas limite testé, Console vérifiée, documentation mise à jour et état reproductible.
