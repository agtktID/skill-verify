---
name: verify
description: Mode de vérification persistante avec preuve d'exécution.
version: 1.0.0
metadata:
  hermes:
    tags: [verification, testing, quality, devops]
    category: devops
  author: promptchat
  license: MIT
---

# verify Skill

## When to Use
Utiliser ce skill lorsque l'utilisateur demande de vérifier, prouver, tester ou valider qu'un changement fonctionne, ou après toute modification de code, configuration, données, contenu, interface ou comportement d'exécution.

Déclencheurs : `$verify`, « vérifie », « prouve-le », « montre-moi que ça marche », correction de bug, refactor, build, test, commit, push ou déploiement.

## Prerequisites
- Bash disponible.
- Optionnel : Playwright ou MCP navigateur pour UI, jq, git.

## How to Run
```bash
bash scripts/verify.sh
node scripts/capture_ui.mjs --url http://localhost:3000 --out .verify/ui
```

## Quick Reference
- `$verify` arme le mode persistant.
- `bash scripts/verify.sh` exécute les gates disponibles.
- `.verify/<timestamp>/report.md` contient les preuves.
- `$verify off` désarme le mode.

## Procedure

1. Définir le périmètre du changement.
2. Identifier la stack et les gates disponibles.
3. Repartir d'un état initial propre.
4. Rejouer le flux utilisateur réel affecté.
5. Exécuter tests, build, lint ou smoke tests.
6. Vérifier les sorties et les codes de sortie.
7. Capturer chaque état visuel affecté.
8. Tester au moins un chemin d'erreur.
9. Générer un rapport avec la section `NON VÉRIFIÉ`.
10. Rendre `PASS`, `FAIL`, `PARTIEL` ou `BLOQUE`.

## Mode Persistant

Après `$verify`, chaque modification rend les preuves précédentes périmées. Même une petite retouche impose une nouvelle vérification du flux affecté et de nouvelles captures si l'interface a changé. Ne jamais attendre que l'utilisateur répète `$verify`.

## Loi de Fer

```text
AUCUNE AFFIRMATION DE SUCCÈS SANS PREUVE FRAÎCHE PRODUITE DANS CE TOUR.
```

Une preuve est un artefact observable : sortie complète, code de sortie, log, réponse HTTP, fichier produit ou capture d'écran. « Ça devrait marcher » n'est pas une preuve.

## Evidence Matrix

| Affirmation | Preuve minimale |
|---|---|
| Build réussi | commande de build + exit 0 |
| Tests réussis | suite complète + exit 0 |
| Bouton fonctionnel | capture avant/après et action réelle |
| API fonctionnelle | requête réelle + statut et corps |
| Bug corrigé | reproduction avant + retest après |
| Déploiement sain | déploiement + smoke test + health check |

## Verdicts

- `PASS` : toutes les gates pertinentes ont été exécutées et les preuves affichées.
- `FAIL` : au moins une gate échoue.
- `PARTIEL` : certaines preuves sont positives, mais une partie critique reste non testée.
- `BLOQUE` : outil, donnée, environnement ou accès manquant.

## Pitfalls

- Ne pas recycler une preuve d'un tour précédent.
- Ne pas tronquer la sortie critique.
- Ne pas confondre compilation et comportement utilisateur.
- Ne pas ignorer l'UI parce que le code compile.
- Ne pas cacher les éléments non vérifiés.
- Ne pas exécuter une action destructive sans confirmation.

## Verification

Le skill est valide si l'agent produit une preuve fraîche après chaque modification, cite la commande exacte, indique l'exit code, rejoue le flux concerné, affiche les screenshots nécessaires et rend un verdict cohérent.
