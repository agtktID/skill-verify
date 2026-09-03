# skill-verify

Collection de skills pour agents IA : vérification persistante, boucles de qualité, Unity, Indagis et architecture de skills.

## Skills

- `skills/verify/` — vérification persistante : aucune affirmation de succès sans preuve fraîche.
- `skills/gauntlet-loop-dev/` — boucle builder → critic → compare → iterate.
- `skills/unity-gamedev/` — développement Unity piloté par GDD, tests, builds et preuves.
- `skills/indagis-feature-builder/` — construction feature-par-feature avec scope strict.
- `skills/skill-architect/` — conception, audit et évaluation de skills de production.

## Installation Hermes

```bash
mkdir -p ~/.hermes/skills
cp -r skills/* ~/.hermes/skills/
```

Redémarrer Hermes ou recharger ses skills, puis tester avec `$verify`.

## Installation Claude Code

Copier un dossier skill dans `.claude/skills/` du projet. Pour `verify`, fusionner aussi `hooks/hooks.json` dans `.claude/settings.json`.

## Licence

MIT
