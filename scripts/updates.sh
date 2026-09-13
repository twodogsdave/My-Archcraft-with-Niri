#!/usr/bin/env bash
# Official repos + AUR updates for Waybar
# Uses a private checkupdates DB so it never fights pacman.

set -euo pipefail

CHECKUPDATES_DB="/tmp/checkup-db-${UID}"
export CHECKUPDATES_DB
mkdir -p "$CHECKUPDATES_DB"

pac=$(checkupdates 2>/dev/null || true)
aur=$(yay -Qua 2>/dev/null || true)

pac_n=$(printf '%s\n' "$pac" | sed '/^$/d' | wc -l)
aur_n=$(printf '%s\n' "$aur" | sed '/^$/d' | wc -l)
total=$((pac_n + aur_n))

tooltip=""
if (( pac_n > 0 )); then
  tooltip+="pacman (${pac_n})\n"
  tooltip+="$(printf '%s\n' "$pac" | head -n 20 | sed 's/"/\\"/g')\n"
  (( pac_n > 20 )) && tooltip+="… +$((pac_n - 20)) more\n"
fi
if (( aur_n > 0 )); then
  tooltip+="\nAUR (${aur_n})\n"
  tooltip+="$(printf '%s\n' "$aur" | head -n 20 | sed 's/"/\\"/g')\n"
  (( aur_n > 20 )) && tooltip+="… +$((aur_n - 20)) more"
fi

# Escape for JSON
tooltip=$(printf '%s' "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')

if (( total == 0 )); then
  printf '{"text":"","alt":"updated","class":"updated","tooltip":"System is up to date"}\n'
else
  printf '{"text":"%s","alt":"has-updates","class":"has-updates","tooltip":"%s"}\n' "$total" "$tooltip"
fi
