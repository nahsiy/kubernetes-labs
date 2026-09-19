#!/usr/bin/env bash
set -u

failures=0

check_command() {
  local command_name="$1"

  if command -v "$command_name" >/dev/null 2>&1; then
    printf '[PASS] %-8s %s\n' "$command_name" "$(command -v "$command_name")"
  else
    printf '[FAIL] %-8s commande introuvable\n' "$command_name"
    failures=$((failures + 1))
  fi
}

for command_name in git docker kubectl kind helm gh make; do
  check_command "$command_name"
done

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    printf '[PASS] docker   moteur accessible\n'
  else
    printf '[FAIL] docker   moteur inaccessible ; démarrer Docker Desktop\n'
    failures=$((failures + 1))
  fi
fi

if ((failures > 0)); then
  printf '\n%d contrôle(s) en échec. Corriger les prérequis avant de continuer.\n' "$failures"
  exit 1
fi

printf '\nTous les prérequis sont disponibles.\n'

