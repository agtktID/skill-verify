---
name: project-review
description: >
  Effectue une revue complète d'un projet ou d'une PR : qualité du code, architecture, performance,
  sécurité, et accessibilité. Produit un rapport structuré avec des recommandations priorisées.
  Utiliser avant un merge, une release, ou quand l'utilisateur veut améliorer la qualité du code.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
  tags:
    - project
    - review
    - code-quality
    - security
    - performance
    - architecture
    - matt-pocock
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🔍 Rôle du skill `project-review`

Ce skill effectue une revue de code complète en 5 dimensions :

1. **Qualité du code** — lisibilité, nommage, complexité, duplication.
2. **Architecture** — structure, séparation des préoccupations, SOLID.
3. **Performance** — algorithmes, requêtes N+1, mémoïsation, bundle size.
4. **Sécurité** — injections, secrets exposés, dépendances vulnérables.
5. **Accessibilité / DX** — README, types, commentaires, onboarding.

Inspiré de Matt Pocock's `/improve-codebase-architecture` + `/code-review` +
Superpowers `/systematic-debugging` + Trail of Bits security review.

---

## ✅ Quand utiliser ce skill

Utilise `/project-review` quand :

- Tu veux faire une revue avant de merger une PR.
- Tu veux améliorer la qualité globale du projet.
- Tu prépares un release public (open-source, npm, etc.).
- Tu veux un rapport de dette technique.

**Ne pas utiliser pour :**

- Reviewer une feature en cours de dev (utiliser `/project-build` TDD à la place).
- Des projets avec moins de 100 lignes de code (trop petit pour une revue formelle).

---

## 🧱 Pipeline de revue

```text
/project-review [--scope code|arch|perf|security|all] [--path src/]
    ↓
[DIM 1] Qualité du code
    → Complexité cyclomatique, nommage, duplication
    ↓
[DIM 2] Architecture
    → Structure, dépendances, SOLID, couplage
    ↓
[DIM 3] Performance
    → Algorithmes O(n²), requêtes DB, bundle, cache
    ↓
[DIM 4] Sécurité
    → OWASP Top 10, secrets, dépendances CVE
    ↓
[DIM 5] Accessibilité / DX
    → README, types, JSDoc/docstrings, onboarding
    ↓
[RAPPORT] Priorisé par criticité
    → .verify/<ts>/review-report.md
```

---

## 🔁 Procédure pour l'agent

### Dimension 1 : Qualité du code

Lire les fichiers sources et vérifier :

| Critère | Signal d'alarme | Recommandation |
|---------|----------------|----------------|
| Fonctions longues | > 30 lignes | Extraire en sous-fonctions |
| Nommage flou | `x`, `temp`, `data` | Nommer selon l'intention |
| Duplication | 3+ copies d'un même bloc | Extraire en utilitaire |
| Commentaires obsolètes | TODO anciens, code commenté | Supprimer ou résoudre |
| Complexité cyclomatique | > 10 | Décomposer en fonctions |

```bash
# Complexité cyclomatique (Node)
npx complexity-report --format json src/

# Duplication (Node)
npx jscpd src/ --min-tokens 50
```

### Dimension 2 : Architecture

1. Cartographier la structure : modules, services, couches.
2. Vérifier les principes SOLID :
   - **S** : chaque module a une seule responsabilité.
   - **O** : ouvert à l'extension, fermé à la modification.
   - **D** : dépendances vers des abstractions, pas des implémentations.
3. Détecter le couplage fort (imports circulaires, dépendances directes de DB dans les routes).
4. Proposer un refactor d'architecture si nécessaire.

### Dimension 3 : Performance

```bash
# Bundle size (Node)
npm run build -- --analyze  # ou webpack-bundle-analyzer

# Dépendances lourdes
npx depcheck

# Requêtes N+1 (patterns à détecter manuellement)
grep -r 'findById' src/ | head -20
```

Points à vérifier :
- [ ] Pas de requêtes DB dans des boucles.
- [ ] Mémoïsation des calculs coûteux.
- [ ] Lazy loading des modules lourds.
- [ ] Indexes DB sur les champs filtrés/triés.

### Dimension 4 : Sécurité

```bash
# Audit des dépendances
npm audit
pip audit
go mod tidy && govulncheck ./...

# Scan de secrets
git secrets --scan  # ou truffleHog
grep -r 'password\|secret\|token\|api_key' src/ --include='*.{js,ts,py,go}'

# SAST léger
npx semgrep --config=auto src/
```

OWASP Top 10 à vérifier :
- [ ] Injection SQL / NoSQL (utilise des ORM ou des requêtes paramétrées).
- [ ] Authentification défaillante (JWT, session, CSRF).
- [ ] Exposition de données sensibles (logs, réponses API).
- [ ] Contrôle d'accès manquant (routes non protégées).
- [ ] Dépendances avec CVE connues (`npm audit --audit-level=high`).

### Dimension 5 : Accessibilité / DX

1. Vérifier le `README.md` :
   - [ ] Description claire du projet.
   - [ ] Instructions d'installation (< 5 commandes).
   - [ ] Exemple d'usage.
   - [ ] Badge de licence.
2. Vérifier les types (TypeScript) :
   - [ ] Pas de `any` non justifié.
   - [ ] Types exportés pour l'API publique.
3. Vérifier la documentation :
   - [ ] JSDoc / docstrings sur les fonctions publiques.
   - [ ] CONTRIBUTING.md pour les projets open-source.

### Rapport final

Générer `.verify/<ts>/review-report.md` :

```markdown
# Rapport de revue — <timestamp>

## Score global
| Dimension | Score | Statut |
|-----------|-------|--------|
| Code quality | 7/10 | ⚠️ |
| Architecture | 8/10 | ✅ |
| Performance | 6/10 | ⚠️ |
| Sécurité | 9/10 | ✅ |
| DX | 7/10 | ⚠️ |

## Problèmes critiques (P0 — bloquer le merge)
- ⛔ <problème 1>

## Problèmes importants (P1 — corriger avant release)
- ⚠️ <problème 2>

## Suggestions (P2 — next iteration)
- 💡 <suggestion 1>

## Points positifs
- ✅ <point fort 1>
```

---

## 🔗 Après la revue

- Problèmes P0 → utiliser `/project-build` pour corriger.
- Tests manquants → utiliser `/project-test`.
- Prêt à livrer → utiliser `/project-ship`.
