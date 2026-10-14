#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Lueur — une invite de commande stylée pour Termux
#
#  Installer :     bash lueur-installer.sh
#  Désinstaller :  bash lueur-installer.sh --uninstall
#
#  Ce script est du texte lisible : ouvre-le et lis-le avant de
#  le lancer. Il n'utilise pas internet, sauf pour installer le
#  paquet Termux « command-not-found » avec la commande pkg.
# ─────────────────────────────────────────────────────────────
set -u

DIR="$HOME/.lueur"
RC="$HOME/.bashrc"
BEGIN="# >>> lueur >>>"
END="# <<< lueur <<<"

OK=$'\e[38;5;84m'; ERR=$'\e[38;5;203m'; GO=$'\e[1;38;5;222m'
DIM=$'\e[38;5;245m'; R=$'\e[0m'

retirer_bloc() {
  [ -f "$RC" ] && sed -i "/^$BEGIN\$/,/^$END\$/d" "$RC"
}

if [ "${1:-}" = "--uninstall" ]; then
  retirer_bloc
  rm -rf "$DIR"
  printf '%s✔ Lueur est désinstallé.%s Ferme et rouvre Termux.\n' "$OK" "$R"
  exit 0
fi

if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  printf '%s✘ Ce script est prévu pour Termux (Android).%s\n' "$ERR" "$R"
  exit 1
fi

printf '\n%s✦ Installation de Lueur%s\n\n' "$GO" "$R"

# 1. Sauvegarde de ~/.bashrc
if [ -f "$RC" ]; then
  SAUV="$RC.lueur-$(date +%Y%m%d-%H%M%S).bak"
  cp "$RC" "$SAUV"
  printf '  %s•%s Sauvegarde : %s\n' "$DIM" "$R" "$SAUV"
fi

# 2. Liste des paquets Termux (pour proposer d'installer un programme manquant)
if command -v pkg >/dev/null 2>&1; then
  printf '  %s•%s Installation de command-not-found…\n' "$DIM" "$R"
  pkg install -y command-not-found >/dev/null 2>&1 \
    || printf '  %s!%s command-not-found n’a pas pu être installé : l’invite marchera, mais pas la proposition d’installation.\n' "$ERR" "$R"
fi

# 3. Fichiers de Lueur
mkdir -p "$DIR"

cat > "$DIR/prompt.sh" << 'LUEUR_PROMPT'
# Lueur — l'invite de commande
case $- in *i*) ;; *) return 0 ;; esac

PROMPT_DIRTRIM=3
__t_start() { [ -z "$__t0" ] && [ "$BASH_COMMAND" != "__prompt" ] && __t0=$SECONDS; }
trap '__t_start' DEBUG
__prompt() {
  local s=$?
  local E=$'\e' R=$'\e[0m'
  local cy="${E}[38;5;81m" go="${E}[1;38;5;222m" vi="${E}[38;5;141m"
  local re="${E}[38;5;203m" gr="${E}[38;5;84m" dim="${E}[38;5;245m" pk="${E}[38;5;215m"
  local ac=$gr x='' d='' jb='' v='' g='' b t='\A' w='\w'
  t=${t@P}; w=${w@P}

  if [ $s -ne 0 ]; then ac=$re; x=" ${re}✘ ${s}${R}"; fi

  if [ -n "$__t0" ]; then
    local e=$((SECONDS-__t0))
    if [ $e -ge 60 ]; then d=" ${dim}⏱ $((e/60))m$((e%60))s${R}"
    elif [ $e -ge 2 ]; then d=" ${dim}⏱ ${e}s${R}"; fi
    unset __t0
  fi

  local n; n=$(jobs -p | wc -l)
  [ "$n" -gt 0 ] && jb=" ${pk}⚙ ${n}${R}"

  [ -n "$VIRTUAL_ENV" ] && v=" ${dim}(${VIRTUAL_ENV##*/})${R}"

  b=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$b" ]; then
    local dirty=''
    [ -n "$(git status --porcelain 2>/dev/null | head -1)" ] && dirty=' ✱'
    g=" ${vi}‹${b}${dirty}›${R}"
  fi

  printf '\n%s\n' "${cy}╭─${R} ${dim}${t}${R} ${cy}─${R} ${go}${w}${R}${g}${x}${d}${jb}${v}"
  PS1="\[${ac}\]╰─❯\[${R}\] "
}
PROMPT_COMMAND=__prompt
LUEUR_PROMPT

cat > "$DIR/guide.sh" << 'LUEUR_GUIDE'
# Lueur — propose d'installer un programme manquant
case $- in *i*) ;; *) return 0 ;; esac

command_not_found_handle() {
  local cmd=$1 cnf="${PREFIX:-/data/data/com.termux/files/usr}/libexec/termux/command-not-found"
  local out pkgname='' key
  if [ -x "$cnf" ]; then
    out=$("$cnf" "$cmd" 2>&1)
    pkgname=$(printf '%s\n' "$out" | sed -n 's/.*pkg install \([A-Za-z0-9._+-]\{1,\}\).*/\1/p' | head -n1)
  fi
  if [ -z "$pkgname" ] || [ ! -t 0 ]; then
    printf 'bash: %s: command not found\n' "$cmd" >&2
    return 127
  fi
  printf '\n\e[1;38;5;222m▸ « %s » n’est pas installé sur ce système.\e[0m\n' "$cmd" >&2
  printf '  Paquet disponible : \e[1m%s\e[0m\n' "$pkgname" >&2
  printf '  \e[38;5;84m⏎ Entrée\e[0m  Installer     \e[38;5;203mÉchap\e[0m  Annuler ' >&2
  while true; do
    IFS= read -rsn1 key </dev/tty
    if [ -z "$key" ]; then break; fi
    if [ "$key" = $'\e' ]; then
      read -rsn2 -t 0.05 _ </dev/tty
      printf '\n\n  Installation annulée.\n\n' >&2
      return 127
    fi
  done
  printf '\n\n  Installation de %s…\n\n' "$pkgname" >&2
  if pkg install -y "$pkgname"; then
    printf '\n  \e[38;5;84m✔ %s est installé.\e[0m\n\n' "$pkgname" >&2
    command "$@"
    return $?
  fi
  printf '\n  \e[38;5;203m✘ L’installation de %s a échoué.\e[0m\n\n' "$pkgname" >&2
  return 127
}
LUEUR_GUIDE

# 4. Branchement dans ~/.bashrc (un seul bloc, retirable)
retirer_bloc
touch "$RC"
cat >> "$RC" << 'LUEUR_BLOC'
# >>> lueur >>>
[ -f "$HOME/.lueur/guide.sh" ] && . "$HOME/.lueur/guide.sh"
[ -f "$HOME/.lueur/prompt.sh" ] && . "$HOME/.lueur/prompt.sh"
# <<< lueur <<<
LUEUR_BLOC

printf '\n%s✔ Lueur est installé.%s\n' "$OK" "$R"
printf '  Ferme et rouvre Termux, ou tape : %ssource ~/.bashrc%s\n' "$GO" "$R"
printf '  Pour désinstaller : %sbash %s --uninstall%s\n\n' "$GO" "$(basename "$0")" "$R"
