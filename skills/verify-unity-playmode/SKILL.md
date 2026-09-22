---
name: verify-unity-playmode
description: >
  Vérifie un projet Unity via la CLI : exécute les tests EditMode et PlayMode, build le projet en
  batchmode, et optionnellement lance un scénario de playmode ou une scène spécifique pour confirmer
  le comportement d'une feature avant merge ou déploiement.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
  tags:
    - unity
    - gamedev
    - verify
    - playmode
    - editmode
    - ci
allowed-tools:
  - Bash
  - Read
  - Write
---

# 🎯 Rôle du skill `verify-unity-playmode`

Ce skill orchestre une boucle de vérification dédiée aux projets Unity :

1. **Tests EditMode** : vérifie la logique pure (composants, systèmes, utilitaires).
2. **Tests PlayMode** : vérifie le comportement en conditions de jeu réelles.
3. **Build** : compile le projet en batchmode pour détecter les erreurs de compilation.
4. **Rapport** : génère `.verify/<timestamp>/unity-report.md` avec verdict PASS / ECHEC / PARTIEL.

---

## ✅ Quand utiliser ce skill

Utilise `/verify-unity-playmode` quand :

- Tu viens d'ajouter ou de modifier une feature Unity (mécanique de jeu, UI, système).
- Tu veux valider le comportement en PlayMode avant de fusionner une branche.
- Tu veux t'assurer que le build compile sans erreur après une modification.
- Tu travailles avec le skill `unity-gamedev` et tu veux une couche de QA dédiée.

**Ne pas utiliser pour :**

- Projets non-Unity (utiliser `/verify` ou `/verify-feature-end2end` à la place).
- Quand Unity CLI (batchmode) n'est pas disponible dans l'environnement.

---

## 🔧 Pré-requis

- Unity Editor installé avec accès CLI (commande `unity` ou chemin complet vers l'exécutable).
- Projet Unity structuré avec un Assembly Definition (`.asmdef`) pour les tests.
- Dossier de tests présent : `Assets/Tests/EditMode/` et/ou `Assets/Tests/PlayMode/`.
- Optionnel : script de scène personnalisé dans `skills/verify-unity-playmode/scripts/`.

---

## 🧱 Architecture de la boucle Unity

```text
User → /verify-unity-playmode
         ↓
   1. Vérification de l'environnement (Unity CLI disponible ?)
         ↓
   2. Tests EditMode (unity -runTests -testPlatform EditMode)
         ↓
   3. Tests PlayMode (unity -runTests -testPlatform PlayMode)
         ↓
   4. Build batchmode (unity -quit -batchmode -buildTarget ...)
         ↓
   5. Optionnel : lancement d'une scène spécifique et vérification des logs
         ↓
   6. Rapport .verify/<timestamp>/unity-report.md
         ↓
   Verdict: PASS / ECHEC / PARTIEL / BLOQUÉ
```

---

## 🔁 Procédure pour l'agent

### Étape 1 : Vérification de l'environnement

1. Vérifier que Unity CLI est disponible :
   ```bash
   unity -version
   # ou
   /Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity -version
   ```
2. Détecter la version du projet Unity (fichier `ProjectSettings/ProjectVersion.txt`).
3. Si Unity CLI n'est pas trouvé, afficher un message d'erreur et indiquer à l'utilisateur
   comment configurer le chemin, puis retourner le verdict BLOQUÉ.

### Étape 2 : Tests EditMode

```bash
unity \
  -runTests \
  -testPlatform EditMode \
  -projectPath . \
  -testResults .verify/<ts>/editmode-results.xml \
  -logFile .verify/<ts>/editmode.log \
  -batchmode \
  -nographics
```

1. Analyser `.verify/<ts>/editmode-results.xml` : compter PASS / FAIL / SKIP.
2. Si des tests échouent, afficher les noms des tests en échec et les messages d'erreur.

### Étape 3 : Tests PlayMode

```bash
unity \
  -runTests \
  -testPlatform PlayMode \
  -projectPath . \
  -testResults .verify/<ts>/playmode-results.xml \
  -logFile .verify/<ts>/playmode.log \
  -batchmode \
  -nographics
```

1. Analyser `.verify/<ts>/playmode-results.xml` : compter PASS / FAIL / SKIP.
2. Si des tests PlayMode échouent, les lister avec leurs messages d'erreur.

### Étape 4 : Build batchmode

```bash
unity \
  -quit \
  -batchmode \
  -nographics \
  -projectPath . \
  -buildTarget StandaloneWindows64 \
  -logFile .verify/<ts>/build.log
```

> **Note** : adapter `-buildTarget` selon la plateforme cible
> (`StandaloneLinux64`, `StandaloneOSX`, `Android`, `WebGL`, etc.).

1. Vérifier l'exit code de la commande Unity.
2. Analyser `.verify/<ts>/build.log` : détecter les erreurs de compilation.

### Étape 5 (optionnel) : Lancement d'une scène spécifique

Si un script de scène est présent dans `skills/verify-unity-playmode/scripts/run-scene.sh` :

```bash
bash skills/verify-unity-playmode/scripts/run-scene.sh <SceneName> .verify/<ts>/scene.log
```

1. Analyser `.verify/<ts>/scene.log` pour les erreurs ou exceptions.
2. Vérifier les comportements attendus (ex. absence de NullReferenceException).

### Étape 6 : Synthèse et verdict

1. Calculer le verdict global :
   - **PASS** : tests EditMode PASS, tests PlayMode PASS, build OK.
   - **ECHEC** : au moins un test critique FAIL ou build échoué.
   - **PARTIEL** : build OK mais des tests SKIP ou warnings non bloquants.
   - **BLOQUÉ** : Unity CLI non disponible ou erreur de configuration.
2. Compléter `.verify/<ts>/unity-report.md`.

---

## 📜 Format du rapport `unity-report.md`

```markdown
MODE: VERIFY UNITY

## Projet
- Nom: <nom du projet Unity>
- Version Unity: <version>
- Build target: <plateforme>

## Tests EditMode
- PASS: <nombre>
- FAIL: <nombre>
- SKIP: <nombre>
- Logs: .verify/<ts>/editmode.log

## Tests PlayMode
- PASS: <nombre>
- FAIL: <nombre>
- SKIP: <nombre>
- Logs: .verify/<ts>/playmode.log

## Build
- Statut: PASS / ECHEC
- Logs: .verify/<ts>/build.log

## Scène (optionnel)
- Scène testée: <nom>
- Erreurs: <liste ou "Aucune">

## Verdict
**PASS** – Tous les critères Unity sont remplis.

## Prochaines étapes
- <liste des actions>
```

---

## 🔗 Voir aussi

- `unity-gamedev` : skill de développement Unity complet.
- `verify` : boucle de vérification générique (non-Unity).
- `gauntlet-loop-dev` : orchestration de gates de qualité.
