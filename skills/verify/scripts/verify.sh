#!/usr/bin/env bash
set -euo pipefail
TS=$(date +%Y%m%d-%H%M%S)
OUT=".verify/${TS}"
mkdir -p "${OUT}"
echo "verify.sh - horodatage ${TS}"
DETECTED=""
[ -f package.json ] && DETECTED="node"
[ -f pyproject.toml ] || [ -f setup.py ] || [ -f requirements.txt ] && DETECTED="python"
[ -f go.mod ] && DETECTED="go"
[ -f Cargo.toml ] && DETECTED="rust"
[ -f Makefile ] && DETECTED="make"
echo "stacks detectees: ${DETECTED:- aucune}"
GATES_RUN=0
GATES_FAIL=0
run_gate() {
  local name="$1"; local cmd="$2"
  echo "=== GATE: ${name}"; echo "--- cmd: ${cmd}"
  GATES_RUN=$((GATES_RUN + 1))
  if eval "${cmd}" > "${OUT}/${name}.log" 2>&1; then
    echo "--- exit: 0  log: .verify/${TS}/${name}.log"
  else
    local code=$?
    echo "--- exit: ${code}  log: .verify/${TS}/${name}.log"
    GATES_FAIL=$((GATES_FAIL + 1))
  fi
}
case "${DETECTED}" in
  node) grep -q '"test"' package.json 2>/dev/null && run_gate tests "npm run test"; grep -q '"build"' package.json 2>/dev/null && run_gate build "npm run build" ;;
  python) command -v pytest >/dev/null 2>&1 && run_gate tests "pytest -q" ;;
  go) command -v go >/dev/null 2>&1 && run_gate tests "go test ./..." ;;
  rust) command -v cargo >/dev/null 2>&1 && run_gate tests "cargo test --quiet" ;;
  make) grep -q '^test:' Makefile 2>/dev/null && run_gate tests "make test" ;;
esac
VERDICT="BLOQUE"
[ "$GATES_RUN" -gt 0 ] && [ "$GATES_FAIL" -eq 0 ] && VERDICT="PASS"
[ "$GATES_RUN" -gt 0 ] && [ "$GATES_FAIL" -gt 0 ] && VERDICT="FAIL"
[ "$GATES_RUN" -eq 0 ] && [ -z "${DETECTED}" ] && echo "BLOQUE: aucun manifeste de projet trouve."
{
  echo "# Rapport de verification - ${TS}"; echo
  echo "- Stacks detectees : ${DETECTED:- aucune}"; echo "- Gates executees : ${GATES_RUN}"; echo "- Gates en echec : ${GATES_FAIL}"; echo
  echo "## Logs"; echo
  for log in "${OUT}"/*.log; do [ -f "${log}" ] || continue; echo "### $(basename "${log}" .log)"; echo '```'; cat "${log}"; echo '```'; echo; done
  echo "## NON VERIFIE"; echo; echo "- Verification visuelle UI : non couverte par ce script."; echo "- Flux utilisateur complet : a rejouer via Playwright ou MCP navigateur."; echo
  echo "## Verdict"; echo; echo "**${VERDICT}** - ${GATES_RUN} gate(s), ${GATES_FAIL} echec(s)."
} > "${OUT}/report.md"
echo ""; echo "==================================="; echo "VERDICT: ${VERDICT} (${GATES_RUN} gates, ${GATES_FAIL} echecs)"; echo "Rapport: .verify/${TS}/report.md"; echo "==================================="
[ "${VERDICT}" = PASS ] && exit 0
[ "${VERDICT}" = FAIL ] && exit 1
exit 2
