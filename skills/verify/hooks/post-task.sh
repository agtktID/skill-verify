#!/usr/bin/env bash
# post-task.sh — Hook Claude Code : auto-déclenche le skill verify
# après chaque complétion de tâche (événement PostToolUse:Bash ou Stop).
#
# Installation :
#   1. Copier ce fichier dans .claude/hooks/post-task.sh
#   2. Référencer dans .claude/hooks/hooks.json (voir hooks.json)
#   3. Rendre exécutable : chmod +x .claude/hooks/post-task.sh
#
# Ce hook lit le contexte Claude Code depuis stdin (JSON),
# détecte si une tâche/feature/étape vient d'être complétée,
# et lance run-verify.sh si c'est le cas.

set -uo pipefail

# Lire le payload JSON de Claude Code depuis stdin
INPUT=$(cat)

# Extraire les champs utiles via python (disponible partout)
TOOL_NAME=$(echo "${INPUT}" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_name', '') or data.get('event', ''))
" 2>/dev/null || echo "")

TOOL_OUTPUT=$(echo "${INPUT}" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_output', '') or data.get('output', ''))
" 2>/dev/null || echo "")

# Mots-clés qui indiquent une complétion de tâche/feature/étape
COMPLETION_KEYWORDS="done|finished|completed|implemented|refactored|fixed|added|merged|shipped|deployed|PASS|feature complete|step complete|task complete"

# Ne déclencher que si :
# 1. L'événement est PostToolUse:Bash ou Stop
# 2. La sortie contient des mots-clés de complétion
SHOULD_VERIFY=false

if [[ "${TOOL_NAME}" == *"Bash"* ]] || [[ "${TOOL_NAME}" == *"Stop"* ]]; then
  if echo "${TOOL_OUTPUT}" | grep -qiE "${COMPLETION_KEYWORDS}"; then
    SHOULD_VERIFY=true
  fi
fi

# Vérifier aussi si un fichier de marqueur de tâche existe
if [ -f ".verify/pending-task" ]; then
  SHOULD_VERIFY=true
  rm -f ".verify/pending-task"
fi

if $SHOULD_VERIFY; then
  echo "[hook:post-task] Complétion détectée — déclenchement de verify..."

  # Trouver le script run-verify.sh (chemin relatif au projet)
  VERIFY_SCRIPT=""
  if [ -f ".claude/skills/verify/scripts/run-verify.sh" ]; then
    VERIFY_SCRIPT=".claude/skills/verify/scripts/run-verify.sh"
  elif [ -f "skills/verify/scripts/run-verify.sh" ]; then
    VERIFY_SCRIPT="skills/verify/scripts/run-verify.sh"
  fi

  if [ -n "${VERIFY_SCRIPT}" ]; then
    bash "${VERIFY_SCRIPT}" "Post-task auto-verify" "all"
  else
    echo "[hook:post-task] ⚠️  run-verify.sh non trouvé. Installe le skill verify dans .claude/skills/."
  fi
else
  echo "[hook:post-task] Pas de complétion détectée — verify ignoré."
fi

# Retourner 0 : ce hook est non-bloquant (PostToolUse)
exit 0
