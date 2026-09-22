---
name: project-test
description: >
  Écrit et exécute une suite de tests complète pour un projet ou une feature : tests unitaires,
  tests d'intégration, tests end-to-end (Playwright/cURL), et génère un rapport de couverture.
  Utiliser quand l'utilisateur veut valider un projet avant livraison, ou combler des lacunes de tests.
license: MIT
version: 1.0.0
metadata:
  author: agtktID
  repo: https://github.com/agtktID/skill-verify
  created: 2026-09-22
  tags:
    - project
    - test
    - coverage
    - integration
    - e2e
    - quality
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# 🧪 Rôle du skill `project-test`

Ce skill orchestre une suite de tests complète en 3 niveaux :

- **Niveau 1 — Unitaires** : fonctions et composants isolés.
- **Niveau 2 — Intégration** : interaction entre modules et services.
- **Niveau 3 — E2E** : comportement réel de l'application (Playwright, cURL, supertest).

Inspiré de : Matt Pocock's `/tdd`, Superpowers `/webapp-testing`, `verify-feature-end2end`.

---

## ✅ Quand utiliser ce skill

Utilise `/project-test` quand :

- Tu veux valider un projet complet avant livraison.
- Tu veux combler des lacunes de tests (couverture < 80%).
- Tu prépares un release et veux une preuve de qualité.
- Tu veux un rapport de couverture à partager avec l'équipe.

**Ne pas utiliser pour :**

- Écrire les tests d'une feature spécifique pendant le TDD (utiliser `/project-build`).
- Quand le projet n'a pas encore de code à tester.

---

## 🧱 Pipeline de tests

```text
/project-test
    ↓
[AUDIT] Cartographie de la couverture actuelle
    → Identifier les fichiers sans tests
    ↓
[NIVEAU 1] Tests unitaires
    → Chaque fonction publique testée
    → Edge cases couverts
    ↓
[NIVEAU 2] Tests d'intégration
    → Routes API, services, DB
    ↓
[NIVEAU 3] Tests E2E
    → Playwright ou cURL
    → Scénarios utilisateur complets
    ↓
[RAPPORT] Couverture + verdict
    → .verify/<ts>/coverage-report.md
```

---

## 🔁 Procédure pour l'agent

### Étape 1 : Audit de la couverture actuelle

1. Lancer la commande de couverture pour identifier les lacunes :

```bash
# Node/TypeScript
npm test -- --coverage

# Python
pytest --cov=. --cov-report=term-missing

# Go
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out -o coverage.html
```

2. Lister les fichiers avec couverture < 80%.
3. Prioriser : API routes > services > utilitaires > UI.

### Étape 2 : Tests unitaires manquants

Pour chaque fonction publique sans test :

1. Créer le fichier de test correspondant.
2. Couvrir :
   - Cas nominal.
   - Entrées invalides / null / undefined.
   - Cas limites (vide, très grand, etc.).
3. Lancer les tests après chaque ajout → doit être PASS.

### Étape 3 : Tests d'intégration

Pour les routes API et services :

```typescript
// Exemple Express + supertest
import request from 'supertest';
import app from '../src/app';

test('POST /api/cart/total', async () => {
  const res = await request(app)
    .post('/api/cart/total')
    .send({ items: [{ price: 10 }, { price: 20 }] });
  expect(res.status).toBe(200);
  expect(res.body.total).toBe(30);
});
```

```python
# Exemple Flask + pytest
def test_cart_total(client):
    response = client.post('/api/cart/total',
        json={'items': [{'price': 10}, {'price': 20}]})
    assert response.status_code == 200
    assert response.json['total'] == 30
```

### Étape 4 : Tests E2E

Si Playwright est disponible :

```typescript
// tests/e2e/cart.spec.ts
import { test, expect } from '@playwright/test';

test('Ajouter un article et vérifier le total', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await page.click('[data-testid="add-item"]');
  await expect(page.locator('[data-testid="total"]')).toHaveText('10€');
});
```

Sinon, utiliser cURL pour les routes API :

```bash
curl -s -X POST http://localhost:3000/api/cart/total \
  -H "Content-Type: application/json" \
  -d '{"items": [{"price": 10}, {"price": 20}]}' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); assert d['total']==30, f'Expected 30, got {d[\"total\"]}'" \
  && echo 'E2E PASS'
```

### Étape 5 : Rapport de couverture

Générer `.verify/<ts>/coverage-report.md` :

```markdown
## Rapport de couverture — <timestamp>

### Couverture globale
- Avant : <x>%
- Après : <y>%

### Tests ajoutés
| Fichier | Type | Cas couverts |
|---------|------|--------------|
| src/calculateTotal.js | Unitaire | 4 cas |
| routes/api/cart.js | Intégration | 3 cas |
| cart.spec.ts | E2E | 2 scénarios |

### Verdict
**PASS** — Couverture > 80%, tous les tests réussis.
```

---

## 🔗 Prochaines étapes

- Tests validés → utiliser `/project-ship` pour déployer.
- Des tests échouent → utiliser `/project-build` pour corriger.
