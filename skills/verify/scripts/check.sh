#!/usr/bin/env bash
# check.sh — Gate runner pour le skill verify
# Usage: bash check.sh [--tests] [--lint] [--build] [--typecheck] [--all]
# Produit les logs dans .verify/<ts>/ et retourne 0 si PASS, 1 si ECHEC

set -euo pipefail

TS=$(date +%Y%m%dT%H%M%S)
VERIFY_DIR=".verify/${TS}"
mkdir -p "${VERIFY_DIR}"

PASS=0
FAIL=0
SKIPPED=0
SUMMARY=[]

run_gate() {
  local GATE_NAME="$1"
  local CMD="$2"
  local LOG_FILE="${VERIFY_DIR}/${GATE_NAME}.log"

  echo "[verify] Running gate: ${GATE_NAME} → ${CMD}"
  if eval "${CMD}" > "${LOG_FILE}" 2>&1; then
    echo "  ✅ ${GATE_NAME}: PASS"
    PASS=$((PASS + 1))
  else
    echo "  ❌ ${GATE_NAME}: ECHEC (exit code $?)"
    echo "  → Logs: ${LOG_FILE}"
    FAIL=$((FAIL + 1))
  fi
}

# Détection auto des commandes disponibles
detect_test_cmd() {
  if [ -f "package.json" ]; then
    if grep -q '"test"' package.json 2>/dev/null; then echo "npm test"; return; fi
  fi
  if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then echo "pytest"; return; fi
  if [ -f "go.mod" ]; then echo "go test ./..."; return; fi
  if [ -f "*.csproj" ] || [ -f "*.sln" ]; then echo "dotnet test"; return; fi
  echo ""
}

detect_lint_cmd() {
  if [ -f "package.json" ] && grep -q '"lint"' package.json 2>/dev/null; then
    echo "npm run lint"; return
  fi
  if command -v flake8 &>/dev/null; then echo "flake8 ."; return; fi
  if command -v golangci-lint &>/dev/null; then echo "golangci-lint run"; return; fi
  echo ""
}

detect_build_cmd() {
  if [ -f "package.json" ] && grep -q '"build"' package.json 2>/dev/null; then
    echo "npm run build"; return
  fi
  if [ -f "tsconfig.json" ]; then echo "tsc --noEmit"; return; fi
  if [ -f "go.mod" ]; then echo "go build ./..."; return; fi
  if [ -f "*.csproj" ]; then echo "dotnet build"; return; fi
  echo ""
}

# Parsing des arguments
RUN_ALL=false
RUN_TESTS=false
RUN_LINT=false
RUN_BUILD=false
RUN_TYPECHECK=false

if [ $# -eq 0 ]; then
  RUN_ALL=true
fi

for arg in "$@"; do
  case $arg in
    --all)       RUN_ALL=true ;;
    --tests)     RUN_TESTS=true ;;
    --lint)      RUN_LINT=true ;;
    --build)     RUN_BUILD=true ;;
    --typecheck) RUN_TYPECHECK=true ;;
  esac
done

# Exécution des gates
if $RUN_ALL || $RUN_TESTS; then
  CMD=$(detect_test_cmd)
  if [ -n "${CMD}" ]; then
    run_gate "tests" "${CMD}"
  else
    echo "  ⚠️  tests: SKIP (aucune commande détectée)"
    SKIPPED=$((SKIPPED + 1))
  fi
fi

if $RUN_ALL || $RUN_LINT; then
  CMD=$(detect_lint_cmd)
  if [ -n "${CMD}" ]; then
    run_gate "lint" "${CMD}"
  else
    echo "  ⚠️  lint: SKIP (aucune commande détectée)"
    SKIPPED=$((SKIPPED + 1))
  fi
fi

if $RUN_ALL || $RUN_BUILD || $RUN_TYPECHECK; then
  CMD=$(detect_build_cmd)
  if [ -n "${CMD}" ]; then
    run_gate "build" "${CMD}"
  else
    echo "  ⚠️  build: SKIP (aucune commande détectée)"
    SKIPPED=$((SKIPPED + 1))
  fi
fi

# Rapport final
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  VERIFY REPORT — ${TS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ PASS     : ${PASS}"
echo "  ❌ ECHEC    : ${FAIL}"
echo "  ⚠️  SKIP     : ${SKIPPED}"
echo "  📁 Logs dir : ${VERIFY_DIR}/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "${FAIL}" -gt 0 ]; then
  echo "  VERDICT: ECHEC"
  exit 1
elif [ "${SKIPPED}" -gt 0 ] && [ "${PASS}" -eq 0 ]; then
  echo "  VERDICT: BLOQUE (aucune gate exécutée)"
  exit 2
elif [ "${SKIPPED}" -gt 0 ]; then
  echo "  VERDICT: PARTIEL"
  exit 0
else
  echo "  VERDICT: PASS"
  exit 0
fi
