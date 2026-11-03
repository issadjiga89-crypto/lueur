# Lueur — propose d'installer un programme manquant
case $- in *i*) ;; *) return 0 ;; esac

command_not_found_handle() {
  local cmd=$1 cnf="${PREFIX:-/data/data/com.termux/files/usr}/libexec/termux/command-not-found"
  local out pkgname='' key
  if [ ! -t 0 ] || [ ! -t 1 ] || [ ! -t 2 ]; then
    printf 'bash: %s: command not found\n' "$cmd" >&2
    return 127
  fi
  if [ -x "$cnf" ]; then
    out=$("$cnf" "$cmd" 2>&1)
    pkgname=$(printf '%s\n' "$out" | sed -n 's/.*pkg install \([A-Za-z0-9._+-]\{1,\}\).*/\1/p' | head -n1)
  fi
  if [ -z "$pkgname" ]; then
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

# Commandes « lueur » / « lu » et bannière d'accueil (Lueur Studio).
if [ -r "${BASH_SOURCE[0]%/*}/lueur.sh" ]; then . "${BASH_SOURCE[0]%/*}/lueur.sh"; fi
