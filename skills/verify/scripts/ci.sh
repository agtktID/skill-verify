#!/usr/bin/env bash
# ci.sh — Pipeline CI locale complète pour le skill verify
# Usage: bash ci.sh
# Séquence: clean → install → lint → typecheck → tests → build
# Produit un rapport complet dans .verify/<ts>/ci-report.md

set -uo pipefail

TS=$(date +%Y%m%dT%H%M%S)
CI_DIR=".verify/${TS}"
mkdir -p "${CI_DIR}"
REPORT="${CI_DIR}/ci-report.md"

echo "# CI LOCAL — ${TS}" > "${REPORT}"
echo "" >> "${REPORT}"

PASS_COUNT=0
FAIL_COUNT=0

step() {
  local STEP_NAME="$1"
  local CMD="$2"
  local LOG="${CI_DIR}/${STEP_NAME}.log"

  echo "[ci] ▶ ${STEP_NAME}: ${CMD}"
  local START_TIME
  START_TIME=$(date +%s)

  if eval "${CMD}" > "${LOG}" 2>&1; then
    local END_TIME
    END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    echo "     ✅ PASS (${DURATION}s)"
    echo "- ✅ **${STEP_NAME}** → PASS (${DURATION}s) \`${CMD}\`" >> "${REPORT}"
    PASS_COUNT=$((PASS_COUNT + 1))
    return 0
  else
    local EXIT_CODE=$?
    local END_TIME
    END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    echo "     ❌ ECHEC (exit ${EXIT_CODE}, ${DURATION}s)"
    echo "     → Voir: ${LOG}"
    echo "- ❌ **${STEP_NAME}** → ECHEC (exit ${EXIT_CODE}, ${DURATION}s) \`${CMD}\`" >> "${REPORT}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return 1
  fi
}

optional_step() {
  local STEP_NAME="$1"
  local CMD="$2"
  local LOG="${CI_DIR}/${STEP_NAME}.log"

  if eval "${CMD} --version" > /dev/null 2>&1 || [ -f "${CMD}" ]; then
    step "${STEP_NAME}" "${CMD}"
  else
    echo "[ci] ⚠️  ${STEP_NAME}: SKIP (commande non disponible)"
    echo "- ⚠️  **${STEP_NAME}** → SKIP (commande non disponible)" >> "${REPORT}"
  fi
}

echo "## Étapes CI" >> "${REPORT}"
echo "" >> "${REPORT}"

# ── 1. Clean (optionnel)
if [ -f "package.json" ]; then
  if grep -q '"clean"' package.json 2>/dev/null; then
    step "clean" "npm run clean" || true
  fi
fi

# ── 2. Install des dépendances
if [ -f "package-lock.json" ]; then
  step "install" "npm ci" || true
elif [ -f "yarn.lock" ]; then
  step "install" "yarn install --frozen-lockfile" || true
elif [ -f "pnpm-lock.yaml" ]; then
  step "install" "pnpm install --frozen-lockfile" || true
elif [ -f "requirements.txt" ]; then
  step "install" "pip install -r requirements.txt" || true
elif [ -f "go.mod" ]; then
  step "install" "go mod download" || true
fi

# ── 3. Lint
if [ -f "package.json" ] && grep -q '"lint"' package.json 2>/dev/null; then
  step "lint" "npm run lint"
elif command -v flake8 &>/dev/null; then
  step "lint" "flake8 ."
elif command -v golangci-lint &>/dev/null; then
  step "lint" "golangci-lint run"
fi

# ── 4. Typecheck
if [ -f "tsconfig.json" ]; then
  step "typecheck" "npx tsc --noEmit"
elif command -v mypy &>/dev/null; then
  step "typecheck" "mypy ."
fi

# ── 5. Tests
if [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  step "tests" "npm test"
elif command -v pytest &>/dev/null; then
  step "tests" "pytest --tb=short"
elif [ -f "go.mod" ]; then
  step "tests" "go test ./..."
elif command -v dotnet &>/dev/null; then
  step "tests" "dotnet test"
fi

# ── 6. Build
if [ -f "package.json" ] && grep -q '"build"' package.json 2>/dev/null; then
  step "build" "npm run build"
elif [ -f "go.mod" ]; then
  step "build" "go build ./..."
elif command -v dotnet &>/dev/null; then
  step "build" "dotnet build --no-restore"
fi

# ── Rapport final
echo "" >> "${REPORT}"
echo "## Verdict" >> "${REPORT}"
echo "" >> "${REPORT}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CI LOCAL REPORT — ${TS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ PASS  : ${PASS_COUNT}"
echo "  ❌ ECHEC : ${FAIL_COUNT}"
echo "  📁 Logs  : ${CI_DIR}/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "${FAIL_COUNT}" -gt 0 ]; then
  echo "  VERDICT: ECHEC"
  echo "**ECHEC** — ${FAIL_COUNT} étape(s) ont échoué." >> "${REPORT}"
  exit 1
else
  echo "  VERDICT: PASS"
  echo "**PASS** — Toutes les étapes ont réussi." >> "${REPORT}"
  exit 0
fi
