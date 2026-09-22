#!/usr/bin/env bash
# run-verify.sh — Déclencheur manuel du skill verify
# Usage: bash run-verify.sh [--task "description"] [--gates tests,lint,build]
# Peut être appelé depuis un hook, un script CI ou manuellement.

set -uo pipefail

TASK="${1:-Vérification automatique post-tâche}"
GATES="${2:-all}"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     SKILL VERIFY — AUTO-TRIGGER          ║"
echo "╠══════════════════════════════════════════╣"
echo "║  Task  : ${TASK}"
echo "║  Gates : ${GATES}"
echo "╚══════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")""; pwd)"

# Lancer check.sh avec les gates demandées
if [ "${GATES}" = "all" ]; then
  bash "${SCRIPT_DIR}/check.sh" --all
else
  # Convertir la liste CSV en arguments
  ARGS=""
  IFS=',' read -ra GATE_LIST <<< "${GATES}"
  for gate in "${GATE_LIST[@]}"; do
    ARGS="${ARGS} --${gate}"
  done
  bash "${SCRIPT_DIR}/check.sh" ${ARGS}
fi

EXIT_CODE=$?

if [ ${EXIT_CODE} -eq 0 ]; then
  echo ""
  echo "✅ Verify auto-trigger: PASS — la tâche est validée."
elif [ ${EXIT_CODE} -eq 1 ]; then
  echo ""
  echo "❌ Verify auto-trigger: ECHEC — corrige les erreurs avant de continuer."
elif [ ${EXIT_CODE} -eq 2 ]; then
  echo ""
  echo "⚠️  Verify auto-trigger: BLOQUÉ — aucune commande détectée. Configure tes gates."
fi

exit ${EXIT_CODE}
