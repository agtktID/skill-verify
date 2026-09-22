---
name: verify-unity-playmode
description: >
  Vérification Unity CLI : exécute les tests EditMode et PlayMode, build batchmode du projet,
  et optionnellement lance une scène pour vérifier le comportement runtime. Produit un rapport
  unity-verify-<ts>.md avec verdict PASS/ECHEC/PARTIEL/BLOQUE et logs complets.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  category: verification
  tags:
    - unity
    - gamedev
    - verify
    - playmode
    - editmode
    - cli
    - batchmode
allowed-tools:
  - Bash
  - Read
  - Write
---

# 🎯 Rôle du skill `verify-unity-playmode`

Boucle de vérification standard pour projets Unity : tests EditMode → tests PlayMode → build batchmode → rapport verdict. Prouve que le projet fonctionne réellement avant merge ou déploiement.

---

## ✅ Quand utiliser ce skill

Utilise `/verify-unity-playmode` quand :

- Après ajout d'un script C#, d'un prefab ou d'une mécanique de jeu.
- Avant merge d'une branche feature Unity.
- Intégration dans le pipeline `project-build` → `verify-unity-playmode` → `project-ship`.
- En combinaison avec `unity-gamedev` pour une validation complète.

Ne pas utiliser pour projets non-Unity → utilise `/verify` ou `/verify-feature-end2end`.

---

## 🔧 Pré-requis

- Unity CLI installé et accessible (`unity -version` doit répondre).
- Projet Unity configuré pour tests (dossier `Assets/Tests/` avec TestRunner).
- Variable d'environnement `UNITY_PATH` ou Unity dans le PATH système.
- Cible de build définie (StandaloneLinux64, StandaloneWindows64, WebGL, Android, iOS...).
- Optionnel : script `skills/verify-unity-playmode/scripts/build.sh` pour personnaliser le build.

```bash
# Vérifier que Unity CLI est accessible
unity -version 2>/dev/null || echo "Unity CLI non trouvé — vérifier UNITY_PATH"
```

---

## 🧱 Architecture de la boucle

```text
User → Claude Code + Skill verify-unity-playmode
         ↓
   1. Analyze (projet, target, tests disponibles)
         ↓
   2. EditMode Tests (unity -runTests -testPlatform EditMode)
         ↓
   3. PlayMode Tests (unity -runTests -testPlatform PlayMode)
         ↓
   4. Build Batchmode (unity -quit -batchmode -buildTarget ...)
         ↓
   5. Vérification artefacts (ls Build/)
         ↓
   6. Collect Logs → .verify/<timestamp>/
         ↓
   7. Verdict + rapport unity-verify-<ts>.md
```

---

## 📋 Procédure détaillée

### Étape 1 — Analyse et cadrage

1. Identifier :
   - Le chemin du projet Unity (`-projectPath`).
   - La cible de build (`-buildTarget`).
   - Les assemblies de test disponibles dans `Assets/Tests/`.
2. Si le chemin ou la cible manquent → demander avant d'agir.

### Étape 2 — Tests EditMode

```bash
unity -batchmode -runTests \
  -projectPath ./UnityProject \
  -testPlatform EditMode \
  -testResults .verify/<ts>/editmode-results.xml \
  -logFile .verify/<ts>/editmode.log \
  -quit
echo "EditMode exit: $?"
```

Parser `.verify/<ts>/editmode-results.xml` pour compter PASS / FAIL / Skipped.

### Étape 3 — Tests PlayMode

```bash
unity -batchmode -runTests \
  -projectPath ./UnityProject \
  -testPlatform PlayMode \
  -testResults .verify/<ts>/playmode-results.xml \
  -logFile .verify/<ts>/playmode.log \
  -quit
echo "PlayMode exit: $?"
```

### Étape 4 — Build Batchmode

```bash
unity -batchmode -quit \
  -projectPath ./UnityProject \
  -buildTarget StandaloneLinux64 \
  -executeMethod BuildScript.PerformBuild \
  -logFile .verify/<ts>/build.log
echo "Build exit: $?"
```

Si aucune `BuildScript` n'existe → utiliser `skills/verify-unity-playmode/scripts/build.sh` (si présent) ou demander à l'utilisateur de définir la méthode de build.

### Étape 5 — Vérification des artefacts

```bash
ls -lh Build/ 2>/dev/null | tee .verify/<ts>/build-artifacts.log
```

Un build PASS doit produire au moins un exécutable ou bundle dans le dossier cible.

### Étape 6 — Verdict

| Condition | Verdict |
|---|---|
| Tous les tests PASS + build OK + artefacts présents | **PASS** |
| Au moins un test FAIL ou build KO | **ECHEC** |
| Tests PASS avec warnings / build avec warnings | **PARTIEL** |
| Unity CLI inaccessible ou projet non trouvé | **BLOQUE** |

---

## 📜 Format du rapport `.verify/<timestamp>/unity-verify-<ts>.md`

```markdown
MODE: VERIFY-UNITY-PLAYMODE ARMÉ

## Contexte
- Projet: <chemin>
- Build target: <StandaloneLinux64 / WebGL / ...>
- Unity version: <version>

## Tests
- EditMode: <N> PASS / <N> FAIL / <N> Skipped
- PlayMode: <N> PASS / <N> FAIL / <N> Skipped

## Build
- Commande: <commande>
- Exit code: <0 / non-nul>
- Artefacts: <liste fichiers produits>

## Logs
- .verify/<ts>/editmode.log
- .verify/<ts>/playmode.log
- .verify/<ts>/build.log
- .verify/<ts>/editmode-results.xml
- .verify/<ts>/playmode-results.xml

## Verdict
**PASS** – Tous les tests PASS, build OK, artefacts présents.

## Prochaines étapes
- <corrections ou actions>
```

---

## 🛡️ Anti-hallucination et sécurité

- Jamais de PASS sans parsing réel du fichier XML de résultats.
- Jamais de build "OK" sans vérification que les artefacts existent (`ls Build/`).
- Si Unity CLI n'est pas trouvé → marquer BLOQUÉ et donner la procédure d'installation.
- Ne pas lancer `rm -rf Build/` sans confirmation explicite de l'utilisateur.

---

## 🔗 Intégration avec les autres skills

| Skill | Rôle |
|---|---|
| `unity-gamedev` | Développe scripts C# et prefabs → `verify-unity-playmode` valide |
| `project-build` | Build de feature → `verify-unity-playmode` pour projets Unity |
| `project-ship` | Livraison après verdict PASS de `verify-unity-playmode` |
| `verify` | Complémentaire pour vérifications non-Unity du même projet |
