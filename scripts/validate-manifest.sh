#!/usr/bin/env bash
# validate-manifest.sh — Valide la cohérence du manifest.yml avec les skills présents
# Usage: bash scripts/validate-manifest.sh
set -euo pipefail

MANIFEST="skills/manifest.yml"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

errors=0
warnings=0

echo "═══════════════════════════════════════"
echo "  VALIDATE MANIFEST — skill-verify"
echo "═══════════════════════════════════════"

# ── 1. Syntaxe YAML de base ────────────────────────────────────────────
if ! python3 -c "import yaml; yaml.safe_load(open('$MANIFEST'))" 2>/dev/null; then
  echo "❌ ERREUR: Le manifest.yml contient des erreurs YAML"
  errors=$((errors+1))
else
  echo "✅ Syntaxe YAML : OK"
fi

# ── 2. Champs obligatoires du manifest ────────────────────────────────
for field in version project description; do
  value=$(grep -E "^${field}:" "$MANIFEST" | head -1 || true)
  if [ -z "$value" ]; then
    echo "❌ ERREUR: Champ obligatoire manquant dans manifest: '$field'"
    errors=$((errors+1))
  else
    echo "✅ Champ manifest '$field' : présent"
  fi
done

# ── 3. Chaque skill du manifest doit avoir SKILL.md ──────────────────
echo ""
echo "── Vérification des skills référencés dans manifest.yml ──"
skill_dirs=$(grep -E '^\s+path:\s+' "$MANIFEST" | awk '{print $2}')
for skill_path in $skill_dirs; do
  if [ ! -d "$skill_path" ]; then
    echo "❌ Dossier manquant : $skill_path"
    errors=$((errors+1))
  elif [ ! -f "$skill_path/SKILL.md" ]; then
    echo "❌ SKILL.md absent : $skill_path/SKILL.md"
    errors=$((errors+1))
  else
    # Vérifier que le frontmatter SKILL.md contient name + description
    skill_name=$(awk -F': ' '/^name:/{print $2; exit}' "$skill_path/SKILL.md" | tr -d '"\047' | xargs)
    skill_desc=$(awk -F': ' '/^description:/{print $2; exit}' "$skill_path/SKILL.md" | xargs)
    dir_name=$(basename "$skill_path")

    if [ -z "$skill_name" ]; then
      echo "⚠️  WARNING: 'name' manquant dans frontmatter de $skill_path/SKILL.md"
      warnings=$((warnings+1))
    elif [ "$skill_name" != "$dir_name" ]; then
      echo "⚠️  WARNING: Nom skill '$skill_name' != dossier '$dir_name' dans $skill_path/SKILL.md"
      warnings=$((warnings+1))
    else
      echo "✅ $skill_path — name OK ($skill_name)"
    fi

    if [ -z "$skill_desc" ]; then
      echo "⚠️  WARNING: 'description' manquant dans frontmatter de $skill_path/SKILL.md"
      warnings=$((warnings+1))
    fi
  fi
done

# ── 4. Chaque dossier skills/* doit être dans le manifest ─────────────
echo ""
echo "── Vérification des skills sur disque vs manifest ──"
for skill_dir in skills/*/; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue
  skill_name=$(basename "$skill_dir")
  if ! grep -q "path: $skill_dir" "$MANIFEST" && ! grep -q "path: ${skill_dir%/}" "$MANIFEST"; then
    echo "⚠️  WARNING: '$skill_name' présent sur disque mais absent du manifest"
    warnings=$((warnings+1))
  fi
done

# ── 5. Vérifier les scripts référencés dans manifest ─────────────────
echo ""
echo "── Vérification des scripts référencés ──"
script_refs=$(grep -E '^\s+- skills/' "$MANIFEST" | awk '{print $2}' || true)
for script_path in $script_refs; do
  if [ ! -f "$script_path" ]; then
    echo "⚠️  WARNING: Script référencé dans manifest mais absent: $script_path"
    warnings=$((warnings+1))
  else
    echo "✅ Script présent : $script_path"
  fi
done

# ── Résumé final ──────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
if [ "$errors" -gt 0 ]; then
  echo "❌ ECHEC — $errors erreur(s), $warnings warning(s)"
  exit 1
elif [ "$warnings" -gt 0 ]; then
  echo "⚠️  PARTIEL — 0 erreur, $warnings warning(s)"
  exit 0
else
  echo "✅ PASS — Manifest valide, 0 erreur, 0 warning"
  exit 0
fi
