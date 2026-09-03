# verify

Mode de vérification persistante pour agents IA.

## Installation Hermes

```bash
mkdir -p ~/.hermes/skills
cp -r skills/verify ~/.hermes/skills/
```

## Installation Claude Code

Copier `skills/verify` dans `.claude/skills/verify/`, puis fusionner `skills/verify/hooks/hooks.json` dans `.claude/settings.json`.

## Usage

```text
$verify
```

Après activation, toute modification exige une nouvelle vérification et des preuves fraîches avant de conclure.
