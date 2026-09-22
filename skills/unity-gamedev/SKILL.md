---
name: unity-gamedev
description: >-
  Développement de features et de systèmes pour projets Unity : gameplay, UI, scripts C#,
  prefabs, ScriptableObjects et architecture de jeu. Utiliser pour implémenter, refactorer
  ou documenter n'importe quelle feature Unity. Combine avec verify-unity-playmode pour
  les gates de vérification CLI.
license: MIT
version: "1.0.0"
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  updated: 2026-09-22
  tags:
    - unity
    - gamedev
    - csharp
    - gameplay
    - prefabs
    - scriptableobjects
    - architecture
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🎮 Skill `unity-gamedev`

Skill de développement Unity. Il guide la conception, l'implémentation et la documentation
de features pour projets Unity (gameplay, UI, systèmes, architecture).

---

## ✅ Quand utiliser

Utilise `/unity-gamedev` quand :

- Tu développes une feature Unity (gameplay, UI, système de jeu, animation, etc.).
- Tu veux un script C# production-ready avec les patterns Unity recommandés.
- Tu veux refactorer ou documenter un système Unity existant.
- Tu veux concevoir l'architecture d'un projet Unity (dossiers, namespaces, ScriptableObjects).

Ne pas utiliser pour :

- Vérification et tests Unity CLI (utilise `verify-unity-playmode` pour ça).
- Tâches non-Unity (utilise `project-build` ou `gauntlet-loop-dev`).

**Complémentaire avec :** `verify-unity-playmode` pour les gates de vérification.

---

## 🔧 Pré-requis

- Un projet Unity existant (dossier `Assets/` et `ProjectSettings/`).
- La version Unity utilisée (pour adapter les APIs et les patterns).
- Optionnel : description de l'architecture existante ou d'une feature de référence.

---

## 🧱 Patterns Unity recommandés

### Structure de dossiers

```
Assets/
├── Scripts/
│   ├── Core/          # Systèmes fondamentaux (GameManager, etc.)
│   ├── Gameplay/      # Logique de jeu (Player, Enemy, etc.)
│   ├── UI/            # Scripts d'interface
│   ├── Data/          # ScriptableObjects, modèles de données
│   └── Utils/         # Utilitaires et extensions
├── Prefabs/
├── ScriptableObjects/
├── Scenes/
├── Art/
│   ├── Sprites/
│   ├── Models/
│   └── Animations/
└── Tests/
    ├── EditMode/
    └── PlayMode/
```

### Script C# de base

```csharp
using UnityEngine;

namespace <Namespace>.Gameplay
{
    /// <summary>
    /// <Description de la responsabilité du script>
    /// </summary>
    public class <NomDuScript> : MonoBehaviour
    {
        [Header("Configuration")]
        [SerializeField] private float _speed = 5f;

        [Header("References")]
        [SerializeField] private Rigidbody2D _rb;

        private void Awake()
        {
            // Initialisation des références si non assignées dans l'inspecteur
            if (_rb == null) _rb = GetComponent<Rigidbody2D>();
        }

        private void Start() { }
        private void Update() { }
    }
}
```

### Patterns conseillés

| Pattern | Quand l'utiliser |
|---|---|
| **ScriptableObject** | Données de configuration (stats, items, dialogues) |
| **Event System** | Communication découplée entre systèmes |
| **Object Pooling** | Instanciation fréquente (balles, ennemis, particules) |
| **State Machine** | IA ennemie, états du joueur, menus |
| **Singleton** | GameManager, AudioManager (avec parcimonie) |
| **Observer (UnityEvent)** | Réactions UI ou gameplay à des événements |

---

## 🔁 Procédure de développement

### 1. Définir la feature

- Nom, description, comportement attendu.
- Références visuelles ou de gameplay si disponibles.
- Scope : scripts, prefabs, scènes touchées.

### 2. Inspecter le projet existant

```bash
find Assets/Scripts -name '*.cs' | head -30
```

- Identifier les patterns déjà en place.
- Choisir une référence réelle à aligner.

### 3. Implémenter

1. Écrire le(s) script(s) C# avec les patterns appropriés.
2. Documenter avec `/// <summary>`.
3. Utiliser `[SerializeField]` plutôt que `public` pour les champs Inspector.
4. Séparer la logique métier des MonoBehaviours (préférer la composition à l'héritage profond).

### 4. Vérifier

- Après implémentation, lancer `/verify-unity-playmode` pour les tests et le build.
- Vérifier qu'il n'y a pas d'erreurs dans la console Unity (chercher `error` dans les logs).

### 5. Documenter

- Mettre à jour `docs/ARCHITECTURE.md` si un nouveau système est introduit.
- Ajouter un commentaire `/// <summary>` sur chaque classe et méthode publique.

---

## 📋 Output attendu

```
## Feature Unity — <nom>

### Spec
- Description : <>
- Scripts créés/modifiés : <liste>
- Prefabs : <liste>
- Scènes touchées : <liste>

### Implémentation
<scripts produits avec chemins>

### Patterns utilisés
- <pattern 1> : <justification>

### Tests recommandés
- EditMode : <description du test>
- PlayMode : <description du test>

### Prochaine étape
Lancer /verify-unity-playmode pour valider les tests et le build.
```

---

## 🛡️ Règles

- Toujours utiliser `[SerializeField]` plutôt que `public` pour les champs exposés à l'inspecteur.
- Ne jamais utiliser `GameObject.Find()` ou `FindObjectOfType()` dans `Update()` — cacher les références dans `Awake()`.
- Ne jamais modifier des assets dans `Assets/ThirdParty/` ou des packages sans accord explicite.
- Si Unity CLI n'est pas disponible pour les tests, signaler et proposer des tests manuels.
- Après chaque implémentation importante, recommander `/verify-unity-playmode`.
