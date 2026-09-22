---
name: verify-unity-playmode
description: >
  Vérifie un projet Unity via CLI : exécute les tests EditMode et PlayMode, build le projet en batchmode,
  et valide qu'une scène ou une feature Unity fonctionne avant merge ou déploiement.
  Produit un rapport .verify/<timestamp>/unity-verify-report.md avec verdict clair.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - verify
    - unity
    - gamedev
    - playmode
    - editmode
    - cli
    - build
    - anti-hallucination
allowed-tools:
  - Bash
  - Read
  - Write
---

# 🎮 Skill `verify-unity-playmode`

Skill de vérification pour projets Unity. Il force l'agent à **prouver via Unity CLI** que les tests passent et que le projet se build correctement avant de valider une feature ou un merge.

---

## ✅ Quand utiliser ce skill

Utilise `/verify-unity-playmode` quand :

- Tu ajoutes ou modifies une feature dans un projet Unity (gameplay, UI, scripts, prefabs).
- Tu veux vérifier que les tests EditMode et/ou PlayMode passent.
- Tu veux un build de validation avant de merger ou de déployer.
- Tu travailles avec le skill `unity-gamedev` et veux une couche de QA à la fin.

Ne pas utiliser pour :

- Projets non-Unity (utilise `verify` ou `verify-feature-end2end`).
- Environnements sans Unity CLI installé (`unity` ou `Unity.exe` dans le PATH).

---

## 🔧 Pré-requis

- Unity CLI installé et accessible (`unity -version` retourne un résultat).
- Un projet Unity valide avec un `Assets/` et un `ProjectSettings/`.
- Optionnel : tests EditMode dans `Assets/Tests/EditMode/`.
- Optionnel : tests PlayMode dans `Assets/Tests/PlayMode/`.
- Optionnel : script `skills/verify-unity-playmode/scripts/unity-verify.sh` pour encapsuler les commandes.

Si Unity CLI n'est pas disponible → gate BLOQUÉ, afficher l'erreur.

---

## 🧱 Pipeline de vérification

```text
User → Claude Code + Skill verify-unity-playmode
         ↓
   1. Vérifier Unity CLI disponible
   2. Lancer tests EditMode
   3. Lancer tests PlayMode (si présents)
         ↓
   4. Build batchmode (si demandé)
         ↓
   5. Verdict PASS/ECHEC/PARTIEL/BLOQUE
         ↓
   .verify/<timestamp>/unity-verify-report.md
```

---

## 📜 Procédure détaillée

### 1. Vérification de l'environnement

```bash
unity -version
# ou sur Windows :
# "C:/Program Files/Unity/Hub/Editor/<version>/Editor/Unity.exe" -version
```

Si Unity CLI n'est pas dans le PATH, vérifier les chemins standards :

- macOS : `/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity`
- Linux : `~/Unity/Hub/Editor/<version>/Editor/Unity`
- Windows : `C:/Program Files/Unity/Hub/Editor/<version>/Editor/Unity.exe`

### 2. Tests EditMode

```bash
unity \
  -runTests \
  -testPlatform editmode \
  -projectPath . \
  -testResults .verify/<ts>/editmode-results.xml \
  -logFile .verify/<ts>/editmode.log \
  -batchmode \
  -nographics
```

- Gate PASS si exit code 0.
- Gate ECHEC si exit code non nul → lire `.verify/<ts>/editmode.log`.

### 3. Tests PlayMode (si présents)

```bash
unity \
  -runTests \
  -testPlatform playmode \
  -projectPath . \
  -testResults .verify/<ts>/playmode-results.xml \
  -logFile .verify/<ts>/playmode.log \
  -batchmode \
  -nographics
```

- Si pas de tests PlayMode → gate SKIP (ne pas compter comme ECHEC).
- Gate PASS si exit code 0.

### 4. Build batchmode (optionnel)

Si l'utilisateur demande un build de validation :

```bash
unity \
  -quit \
  -batchmode \
  -nographics \
  -projectPath . \
  -buildTarget <StandaloneWindows64|StandaloneOSX|Android|WebGL> \
  -buildPath .verify/<ts>/build/ \
  -logFile .verify/<ts>/build.log
```

- Gate PASS si exit code 0 et dossier `.verify/<ts>/build/` non vide.
- Gate ECHEC sinon.

### 5. Verdict et rapport

Verdicts possibles :

- **PASS** : tous les tests PASS, build OK (si demandé).
- **ECHEC** : au moins un test ECHEC ou build ECHEC.
- **PARTIEL** : tests PASS mais warnings importants dans les logs.
- **BLOQUÉ** : Unity CLI non disponible ou projet non valide.

---

## 📄 Format du rapport

```markdown
MODE: VERIFY-UNITY-PLAYMODE

## Contexte
- Projet Unity: <chemin>
- Version Unity: <version>
- Feature vérifiée: <description>

## Gates
- ✅/❌ Unity CLI disponible → <version ou erreur>
- ✅/❌ Tests EditMode → <nb tests PASS / nb total>
- ✅/⏭️/❌ Tests PlayMode → <nb tests PASS / nb total ou SKIP>
- ✅/❌/⏭️ Build batchmode → <target ou SKIP>

## Logs
- .verify/<ts>/editmode.log
- .verify/<ts>/editmode-results.xml
- .verify/<ts>/playmode.log (si applicable)
- .verify/<ts>/build.log (si applicable)

## Verdict
**PASS** – Tous les critères sont remplis.
# ou
**ECHEC** – <gate échouée> : <description de l'erreur>.
# ou
**BLOQUÉ** – Unity CLI non disponible : <message d'erreur>.
```

---

## 🔗 Intégration avec les autres skills

Ce skill est conçu pour fonctionner avec :

- `unity-gamedev` : pour générer ou modifier les scripts/prefabs Unity avant vérification.
- `verify` : comme gate de vérification générale si Unity ne suffit pas.
- `project-ship` : avant le ship final d'une version du jeu.

---

## 🛡️ Règles anti-hallucination

- Ne jamais déclarer les tests PASS sans avoir lu l'exit code de Unity CLI.
- Toujours capturer les logs complets dans `.verify/<ts>/`.
- Si Unity CLI retourne un exit code non nul, afficher les dernières lignes du log.
- Ne jamais simuler les résultats des tests ou du build.
- Si les tests PlayMode sont absents, déclarer SKIP (pas ECHEC).
