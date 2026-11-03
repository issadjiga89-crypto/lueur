# Lueur — l'invite de commande
case $- in *i*) ;; *) return 0 ;; esac

__lueur_version=2.0

# Préférences gérées par Lueur Studio (facultatives, mode privé).
__lueur_config="$HOME/.lueur/studio.conf"
if [ -r "$__lueur_config" ]; then
  while IFS='=' read -r __key __value; do
    case $__key in
      LUEUR_THEME)
        case $__value in mint|violet|cyan|gold|rainbow|arcenciel|classique|minimal) LUEUR_THEME=$__value ;; esac ;;
      LUEUR_SYMBOL)
        case $__value in '❯'|'➜'|'»'|'›'|'λ') LUEUR_SYMBOL=$__value ;; esac ;;
      LUEUR_SHOW_TIME|LUEUR_SHOW_DIR|LUEUR_SHOW_GIT|LUEUR_SHOW_GIT_STATUS|LUEUR_SHOW_DURATION|LUEUR_SHOW_JOBS|LUEUR_SHOW_VENV|LUEUR_CHECK_UPDATE)
        case $__value in 0|1) printf -v "$__key" '%s' "$__value" ;; esac ;;
    esac
  done < "$__lueur_config"
fi
: "${LUEUR_THEME:=mint}"
: "${LUEUR_SYMBOL:=❯}"
: "${LUEUR_SHOW_TIME:=1}"
: "${LUEUR_SHOW_DIR:=1}"
: "${LUEUR_SHOW_GIT:=1}"
: "${LUEUR_SHOW_GIT_STATUS:=${LUEUR_STATUS:-0}}"
: "${LUEUR_SHOW_DURATION:=1}"
: "${LUEUR_SHOW_JOBS:=1}"
: "${LUEUR_SHOW_VENV:=1}"
: "${LUEUR_CHECK_UPDATE:=1}"

# --- Nouvelle version sur GitHub ------------------------------------------------------------
# Au plus une fois par jour, en arrière-plan : l'ouverture de Termux n'attend jamais le réseau.
# Si une version plus récente est connue, une ligne (au plus une fois par jour) donne la
# commande de mise à jour. Rien n'est jamais installé tout seul : seul « lueur-maj », tapé par
# toi, lance l'installateur. Désactivable : LUEUR_CHECK_UPDATE=0 (Lueur Studio → Paramètres).
# Cache ~/.lueur/update.cache : jour de la dernière vérification, dernière version vue, jour du
# dernier message.
__lueur_repo=issadjiga89-crypto/lueur
: "${LUEUR_UPDATE_URL:=https://raw.githubusercontent.com/$__lueur_repo/main/VERSION}"

# Vrai si la version $1 est plus récente que $2 (numéros séparés par des points).
__lueur_newer() {
  local IFS=. i
  local -a a=($1) b=($2)
  for (( i = 0; i < ${#a[@]} || i < ${#b[@]}; i++ )); do
    (( 10#${a[i]:-0} > 10#${b[i]:-0} )) && return 0
    (( 10#${a[i]:-0} < 10#${b[i]:-0} )) && return 1
  done
  return 1
}

__lueur_update_check() {
  local f=$HOME/.lueur/update.cache today checked='' latest='' shown=''
  [[ $LUEUR_CHECK_UPDATE == 1 ]] || return 0
  printf -v today '%(%Y%m%d)T' -1
  if [ -r "$f" ]; then { read -r checked; read -r latest; read -r shown; } < "$f" 2>/dev/null; fi
  [[ $latest =~ ^[0-9]+(\.[0-9]+)*$ ]] || latest=''
  if [ -n "$latest" ] && [ "$shown" != "$today" ] && __lueur_newer "$latest" "$__lueur_version"; then
    printf '  \e[38;5;245m↑ Lueur \e[1;38;5;84m%s\e[0;38;5;245m est disponible (tu as %s) · mise à jour : \e[1mlueur-maj\e[0m\n' \
      "$latest" "$__lueur_version"
    shown=$today
    printf '%s\n%s\n%s\n' "$checked" "$latest" "$shown" > "$f" 2>/dev/null
  fi
  [ "$checked" = "$today" ] && return 0
  command -v curl >/dev/null 2>&1 || return 0
  # La journée est marquée tout de suite : une seule vérification même avec plusieurs sessions.
  printf '%s\n%s\n%s\n' "$today" "$latest" "$shown" > "$f" 2>/dev/null || return 0
  # En arrière-plan, puis retirée de la liste des tâches (ni « [1] 1234 », ni ⚙) : un seul fork.
  {
    v=$(curl -fsSL -m 15 "$LUEUR_UPDATE_URL" 2>/dev/null) || exit 0
    v=${v%%[$'\r\n']*}
    [[ $v =~ ^[0-9]+(\.[0-9]+)*$ ]] || exit 0
    printf '%s\n%s\n%s\n' "$today" "$v" "$shown" > "$f.$BASHPID" && mv -f -- "$f.$BASHPID" "$f"
  } >/dev/null 2>&1 &
  disown $! 2>/dev/null
}

# Mise à jour, seulement quand tu la demandes : lance l'installateur officiel (il sauvegarde tout).
lueur-maj() {
  local url=https://raw.githubusercontent.com/$__lueur_repo/main/install.sh
  printf 'Mise à jour de Lueur : curl -fsSL %s | bash\n' "$url"
  curl -fsSL "$url" | bash && rm -f -- "$HOME/.lueur/update.cache" &&
    printf 'Ouvre une nouvelle session Termux pour utiliser la nouvelle version.\n'
}

# À l'ouverture d'un vrai terminal seulement (pas dans l'aperçu de Lueur Studio, pas à chaque rechargement).
if [ -z "${__lueur_update_done:-}" ] && [ -t 1 ] && [ -z "${LUEUR_PREVIEW_SET+x}" ]; then
  __lueur_update_done=1
  __lueur_update_check
fi

PROMPT_DIRTRIM=3
# Début de la commande : PS0 est développé par bash juste avant d'exécuter une ligne tapée.
# L'indice du tableau vide fait l'affectation et le tout ne s'affiche pas. Contrairement à un
# piège DEBUG, rien ne tourne pendant les commandes (une boucle tapée reste à pleine vitesse).
__lueur_nil=()
PS0='${__lueur_nil[__t0=SECONDS,0]}'
# Lueur v1 chronométrait avec un piège DEBUG : s'il est encore là (rechargement dans un shell
# ouvert avant la v2), on le vide. « trap - DEBUG » ne marcherait pas : bash remet le piège
# d'avant à la fin de « . » sauf s'il a été changé ; un piège vide ne lance rien.
if declare -F __t_start >/dev/null; then trap '' DEBUG; unset -f __t_start; fi
# ✱ : résultat gardé tant qu'aucune commande n'a été lancée (Entrée seule) dans le même dépôt.
__lueur_dirty_repo='' __lueur_dirty=''

# Lit la branche git directement dans .git/HEAD, sans lancer git (rapide)
__lueur_branch() {
  __br='' __lueur_git=''
  local d=$PWD l h=''
  while [ -n "$d" ]; do
    if [ -d "$d/.git" ]; then h="$d/.git/HEAD"; break
    elif [ -f "$d/.git" ]; then
      read -r l < "$d/.git" 2>/dev/null || return
      h=${l#gitdir: }; [[ $h = /* ]] || h="$d/$h"; h="$h/HEAD"; break
    fi
    d=${d%/*}
  done
  [ -n "$h" ] && [ -r "$h" ] || return
  __lueur_git=${h%/HEAD}
  read -r l < "$h" || return
  case $l in
    'ref: refs/heads/'*) __br=${l#ref: refs/heads/} ;;
    *) __br=${l:0:7} ;;
  esac
}

__prompt() {
  local s=$?
  local E=$'\e' R=$'\e[0m'
  local cy="${E}[38;5;81m" go="${E}[1;38;5;222m" vi="${E}[38;5;141m"
  local re="${E}[38;5;203m" gr="${E}[38;5;84m" dim="${E}[38;5;245m" pk="${E}[38;5;215m"
  case $LUEUR_THEME in
    violet) cy="${E}[38;5;183m"; go="${E}[1;38;5;220m"; vi="${E}[38;5;141m"; re="${E}[38;5;203m"; gr="${E}[38;5;177m"; dim="${E}[38;5;245m"; pk="${E}[38;5;213m" ;;
    cyan) cy="${E}[38;5;51m"; go="${E}[1;38;5;159m"; vi="${E}[38;5;45m"; re="${E}[38;5;196m"; gr="${E}[38;5;42m"; dim="${E}[38;5;244m"; pk="${E}[38;5;51m" ;;
    gold) cy="${E}[38;5;220m"; go="${E}[1;38;5;228m"; vi="${E}[38;5;214m"; re="${E}[38;5;196m"; gr="${E}[38;5;178m"; dim="${E}[38;5;245m"; pk="${E}[38;5;220m" ;;
    rainbow) cy="${E}[38;5;51m"; go="${E}[1;38;5;220m"; vi="${E}[38;5;177m"; re="${E}[38;5;203m"; gr="${E}[38;5;84m"; dim="${E}[38;5;245m"; pk="${E}[38;5;213m" ;;
    arcenciel) cy="${E}[38;5;196m"; dim="${E}[38;5;208m"; go="${E}[1;38;5;226m"; vi="${E}[38;5;46m"; pk="${E}[38;5;39m"; gr="${E}[38;5;135m"; re="${E}[38;5;196m" ;;
    classique) cy="${E}[38;5;250m"; go="${E}[1;38;5;220m"; vi="${E}[38;5;75m"; re="${E}[38;5;196m"; gr="${E}[38;5;76m"; dim="${E}[38;5;245m"; pk="${E}[38;5;208m" ;;
    minimal) cy="${E}[37m"; go="${E}[1;37m"; vi="${E}[37m"; re="${E}[31m"; gr="${E}[37m"; dim="${E}[90m"; pk="${E}[37m" ;;
    *) LUEUR_THEME=mint ;;
  esac
  local ac=$gr x='' d='' jb='' v='' g='' t w jp ran=0
  [ -n "$__t0" ] && ran=1

  if [ $s -ne 0 ]; then ac=$re; x=" ${re}✘ ${s}${R}"; fi

  if [[ ${LUEUR_SHOW_DURATION:-1} == 1 && -n "$__t0" ]]; then
    local e=$((SECONDS-__t0))
    if [ $e -ge 60 ]; then d=" ${dim}⏱ $((e/60))m$((e%60))s${R}"
    elif [ $e -ge 2 ]; then d=" ${dim}⏱ ${e}s${R}"; fi
  fi
  unset __t0

  if [[ ${LUEUR_SHOW_JOBS:-1} == 1 ]]; then
    # \j : nombre de tâches, donné par bash lui-même (pas de sous-shell).
    jp='\j'; jp=${jp@P}
    if [ "$jp" != 0 ]; then jb=" ${pk}⚙ ${jp}${R}"; fi
  fi

  if [[ ${LUEUR_SHOW_VENV:-1} == 1 && -n "${VIRTUAL_ENV:-}" ]]; then
    v=" ${dim}(${VIRTUAL_ENV##*/})${R}"
  fi

  __br=''
  if [[ ${LUEUR_SHOW_GIT:-1} == 1 ]]; then __lueur_branch; fi
  if [ -n "$__br" ]; then
    local dirty=''
    # ✱ (fichiers modifiés) : LUEUR_SHOW_GIT_STATUS=1 dans studio.conf, ou export LUEUR_STATUS=1 dans ~/.bashrc
    if [[ ${LUEUR_SHOW_GIT_STATUS:-0} == 1 ]]; then
      if (( ! ran )) && [ "$__lueur_dirty_repo" = "$__lueur_git" ]; then
        dirty=$__lueur_dirty
      elif command -v git >/dev/null 2>&1; then
        [ -n "$(git status --porcelain 2>/dev/null | head -1)" ] && dirty=' ✱'
        __lueur_dirty_repo=$__lueur_git __lueur_dirty=$dirty
      fi
    fi
    g=" ${vi}‹${__br}${dirty}›${R}"
  fi

  t=''; w=''
  if [[ ${LUEUR_SHOW_TIME:-1} == 1 ]]; then t='\A'; t=${t@P}; fi
  if [[ ${LUEUR_SHOW_DIR:-1} == 1 ]]; then w='\w'; w=${w@P}; fi
  printf '\n%s\n' "${cy}╭─${R} ${dim}${t}${R} ${cy}─${R} ${go}${w}${R}${g}${x}${d}${jb}${v}"
  PS1="\[${ac}\]╰─${LUEUR_SYMBOL}\[${R}\] "
}
# __prompt en premier (il lit le code de retour de ta commande), sans écraser les commandes
# d'autres outils (zoxide, direnv…). Recharger ce fichier ne l'ajoute pas deux fois.
if (( BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 1) )); then
  __lueur_pc=()
  for __c in "${PROMPT_COMMAND[@]}"; do
    case $__c in __prompt|'') ;; *) __lueur_pc+=("$__c") ;; esac
  done
  PROMPT_COMMAND=(__prompt "${__lueur_pc[@]}")
  unset __lueur_pc __c
else
  # bash < 5.1 : PROMPT_COMMAND est une seule chaîne.
  __c=${PROMPT_COMMAND:-}
  __c=${__c#__prompt}; __c=${__c#;}; __c=${__c//;__prompt;/;}; __c=${__c%;__prompt}
  PROMPT_COMMAND="__prompt${__c:+;$__c}"
  unset __c
fi
