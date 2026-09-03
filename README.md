# Skill `verify` – Mode de vérification persistante pour agents IA

[![License](https://img.shields.io/github/license/agtktID/skill-verify.svg)](https://github.com/agtktID/skill-verify/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/agtktID/skill-verify.svg?style=social)](https://github.com/agtktID/skill-verify)

> Skill Claude Code qui force les agents à **prouver** que ce qu'ils font marche, pas juste à le dire. Active un mode de vérification persistante avec gates, artefacts et verdict minimal.

![Skill verify demo](docs/demo.gif "Dé·¹mo du skill verify en action – tests, build, UI")

## Présentation

`verify` est un skill Claude Code qui transforme la façon dont les agents travaillent sur tes projets :

- **Plus de "trust me bro"** : l'agent doit exé·¹cuter les tests, builds et flux réels, pas juste raisonner dessus.
- **Vé·¹rification persistante** : une fois activé·¹, le mode reste actif pour toute la session. Chaque modification dé→clenche une nouvelle vé→rification.
- **Preuves, pas d'intentions** : l'agent collecte des artefacts (sorties de tests, builds, captures UI) et les écrit dans `.verify/<ts>/report.md`.
- **Verdict minimal** : `PASS`, `ECHEC`, `PARTIEL`, `BLOQUE` – sans pédagogie ni chain-of-thought visible.

## Quick-start

### 1. Installer le skill

```bash
# Dans ton projet
mkdir -p .claude/skills
# Copie le dossier `verify/` (avec SKILL.md) dans .claude/skills/
```

### 2. Activer le mode verify

```bash
claude
> /verify
# Le mode de vé→rification persistante est maintenant actif
```

### 3. Demander une feature avec preuve

```bash
claude
> Ajoute cette feature et prouve que ça marche
```

L'agent va :
1. Exé·¹cuter les commandes ré→elles (tests, build, etc.).
2. Gén→é·¹rer un rapport dans `.verify/<ts>/report.md`.
3. Retourner un verdict `PASS/ECHEC/PARTIEL/BLOQUE` avec les preuves.

## Fonctionnalité·¹s clé

| Fonctionnalité·¹ | Description |
|------------------|-------------|
| **Boucle agentique** | Analyse → Gauntlet → Action → Vé→rification → Verdict (interne, non affiché·¹e). |
| **Gates configurables** | Tests, build, lint, UI, endpoints – définis dans `SKILL.md` ou via contexte. |
| **Artefacts structururé·¹s** | Rapports dans `.verify/<ts>/report.md` avec tableaux de preuves. |
| **Verdict minimal** | `PASS`, `ECHEC`, `PARTIEL`, `BLOQUE` – une ligne, pas de blabla. |
| **Mode persistant** | Une fois `$verify` actif, chaque tour modifiant le code dé→clenche une vé→rification. |
| **Compatible MCP** | Fonctionne avec tes MCP servers (Unity, GitHub, Apify, etc.). |

## Architecture

```text
User
  └── Claude Code + Skill `verify`
        ├── Boucle agentique interne (analyse/gauntlet/action/verify/verdict)
        ├── Scripts de vé→rification (tests, build, capture UI, etc.)
        ├── Artefacts `.verify/<ts>/report.md`
        └── Verdict minimal (PASS/ECHEC/PARTIEL/BLOQUE)
```

## Structure du skill

```text
verify/
├── SKILL.md              # Instructions principales du skill
├── scripts/
│   ├── verify.sh         # Script de vé→rification (tests, build, etc.)
│   └── capture_ui.mjs    # Capture d'é·¹cran UI (optionnel)
├── assets/
│   └── report-template.md # Template de rapport `.verify/<ts>/report.md`
└── evals/
    └── evals.json        # Tests du skill (should-trigger / should-not-trigger)
```

## Utilisation type

### Feature + preuve

```bash
claude
> /verify
> Ajoute un endpoint POST /api/items et prouve que les tests passent
```

L'agent :
- Crè·¹e l'endpoint.
- Lance `npm run test` (ou équivalent).
- Écrit le rapport dans `.verify/<ts>/report.md`.
- Retourne : `PASS – tests et build OK` ou `ECHEC – tests KO` + détails.

### Correctif + re-vé·¹rification

```bash
claude
> /verify
> Corrige ce bug et re-vé·¹rifie que tout passe
```

Le skill rejoue les gates affecté·¹s et met à jour le rapport.

## Contrat de sortie (quand verify est actif)

Quand le mode est armé·¹, la sortie de l'agent doit respecter ce format :

```markdown
MODE: VERIFY ARME

## Preuves
| Gate | Commande | Ré→sultat | Exit |
|------|----------|-----------|------|
| tests | `npm run test` | PASS | 0 |
| build | `npm run build` | PASS | 0 |

## NON VERIFIE
- Vé→rification visuelle (UI) : non couvert
- Autres é→lé·¹ments non testé·¹s : <liste>

## Verdict
PASS | ECHEC | PARTIEL | BLOQUE
```

**Rè·¹gles :**
- Pas de section "Analyse", "Self-review", "Socratic", etc.
- Pas de pé→dagogie, pas de justification narrative.
- Une ligne de verdict qui pointe vers les gates.

## Contribuer

Les contributions sont bienvenues : nouveaux scripts de vé→rification, amélioration du SKILL.md, exemples.

1. Fork du repo.
2. Crè·¹e une branche (`feat/nouveau-script`).
3. Ajoute ou modifie des fichiers dans `verify/`.
4. Ouvre une pull request.

## Licence

MIT – voir `LICENSE`.
