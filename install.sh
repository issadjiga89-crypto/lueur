#!/data/data/com.termux/files/usr/bin/bash
# Lueur — une invite de commande stylée pour Termux. Installation et mise à jour.
#
#   curl -fsSL https://raw.githubusercontent.com/issadjiga89-crypto/lueur/main/install.sh | bash
#
# Autres usages :
#   bash install.sh --depuis <dossier>   installer depuis un dossier déjà téléchargé
#   bash install.sh --desinstaller       retirer Lueur (rien n'est effacé : tout est mis de côté)
#
# Ce que fait ce script :
#   1. vérifie qu'il tourne dans Termux, avec bash 4.4 ou plus ;
#   2. télécharge Lueur depuis GitHub (ou prend le dossier donné) et vérifie la syntaxe ;
#   3. sauvegarde ~/.lueur et ~/.bashrc dans ~/.lueur-installations/<date>/ ;
#   4. installe ou met à jour ~/.lueur/prompt.sh et ~/.lueur/guide.sh (tes réglages
#      studio.conf et les fichiers de Lueur Studio ne sont pas touchés) ;
#   5. installe le paquet Termux command-not-found s'il manque (proposition d'installation) ;
#   6. ajoute à ~/.bashrc le bloc « lueur » s'il n'y est pas.

if [ -z "${BASH_VERSION:-}" ]; then
  echo "Lueur : lance ce script avec bash (… | bash), pas avec sh." >&2
  exit 1
fi
set -u

LUEUR_REPO=${LUEUR_REPO:-issadjiga89-crypto/lueur}
LUEUR_BRANCH=${LUEUR_BRANCH:-main}
TERMUX_PREFIX=/data/data/com.termux/files/usr
BEGIN='# >>> lueur >>>'
END='# <<< lueur <<<'

E=$'\e' R=$'\e[0m'
ok() { printf '  %s✔%s %s\n' "${E}[1;38;5;84m" "$R" "$1"; }
info() { printf '  %s•%s %s\n' "${E}[38;5;245m" "$R" "$1"; }
fail() { printf '\n  %s✘ %s%s\n\n' "${E}[1;38;5;203m" "$1" "$R" >&2; exit 1; }

src='' mode=install
case ${1:-} in
  --depuis) [ -n "${2:-}" ] || fail "Utilisation : bash install.sh --depuis <dossier>"; src=$(cd -- "$2" 2>/dev/null && pwd) || fail "Dossier introuvable : $2" ;;
  --desinstaller|--uninstall) mode=uninstall ;;
  '') ;;
  -h|--help|--aide) sed -n '2,18p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) fail "Option inconnue : $1 (essaie --aide)" ;;
esac

# --- 1. Termux et bash ---------------------------------------------------------------------
[ "${PREFIX:-}" = "$TERMUX_PREFIX" ] && [ -d "$TERMUX_PREFIX" ] ||
  fail "Ce script est prévu pour Termux (application Android), pas pour proot, Ubuntu ou un autre Linux."
[ "$(id -u)" != 0 ] || fail "Ne lance pas ce script en root."
(( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )) ||
  fail "Il faut bash 4.4 ou plus (tu as $BASH_VERSION) : pkg upgrade bash"

lueur=$HOME/.lueur
rc=$HOME/.bashrc

# Sauvegarde de ~/.lueur et ~/.bashrc → $bk (dossier daté, jamais écrasé).
sauvegarder() {
  local stamp n=1
  printf -v stamp '%(%Y%m%d-%H%M%S)T' -1
  bk=$HOME/.lueur-installations/$stamp
  while [ -e "$bk" ]; do bk=$HOME/.lueur-installations/$stamp-$n; n=$((n + 1)); done
  if [ ! -e "$lueur" ] && [ ! -e "$rc" ]; then bk=''; return 0; fi
  mkdir -p -- "$bk" || fail "Sauvegarde impossible : rien n'a été modifié."
  if [ -e "$lueur" ]; then cp -a -- "$lueur" "$bk/.lueur" || fail "Sauvegarde impossible : rien n'a été modifié."; fi
  if [ -e "$rc" ]; then cp -p -- "$rc" "$bk/.bashrc" || fail "Sauvegarde impossible : rien n'a été modifié."; fi
}

# --- Désinstallation ------------------------------------------------------------------------
if [ "$mode" = uninstall ]; then
  printf '\n  %s✦ Désinstallation de Lueur%s\n\n' "${E}[1;38;5;222m" "$R"
  sauvegarder
  [ -n "$bk" ] && ok "Sauvegarde : ${bk/#$HOME/\~}"
  if grep -qxF "$BEGIN" "$rc" 2>/dev/null; then
    sed -i "/^$BEGIN\$/,/^$END\$/d" "$rc" || fail "Impossible de modifier ~/.bashrc (la sauvegarde est dans ${bk/#$HOME/\~})."
    ok "~/.bashrc : bloc Lueur retiré"
  fi
  if [ -e "$lueur" ]; then
    mv -- "$lueur" "$bk/.lueur-retire" || fail "Impossible de déplacer ~/.lueur."
    ok "~/.lueur mis de côté dans ${bk/#$HOME/\~}/.lueur-retire"
  fi
  [ -d "$HOME/lueur-studio" ] && info "Lueur Studio (~/lueur-studio) n'a pas été touché."
  printf '\n  Lueur est désinstallé. Ferme et rouvre Termux.\n\n'
  exit 0
fi

printf '\n  %s✦ Installation de Lueur%s\n\n' "${E}[1;38;5;222m" "$R"
ok "Termux, bash $BASH_VERSION"

# --- 2. Téléchargement et vérification ------------------------------------------------------
tmp=''
nettoyer() { if [ -n "$tmp" ]; then rm -rf -- "$tmp"; fi; }
trap nettoyer EXIT
if [ -z "$src" ]; then
  command -v tar >/dev/null 2>&1 || fail "Outil manquant : tar  →  pkg install tar"
  tmp=$(mktemp -d "${TMPDIR:-$TERMUX_PREFIX/tmp}/lueur-install.XXXXXX") || fail "Dossier temporaire impossible à créer."
  url=https://github.com/$LUEUR_REPO/archive/refs/heads/$LUEUR_BRANCH.tar.gz
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" | tar -xz -C "$tmp" || fail "Téléchargement impossible : $url"
  elif command -v git >/dev/null 2>&1; then
    git clone -q --depth 1 -b "$LUEUR_BRANCH" "https://github.com/$LUEUR_REPO.git" "$tmp/lueur" ||
      fail "Téléchargement impossible : https://github.com/$LUEUR_REPO"
  else
    fail "Il faut curl pour télécharger : pkg install curl"
  fi
  for d in "$tmp"/*/; do src=${d%/}; break; done
  ok "Téléchargé depuis github.com/$LUEUR_REPO"
fi
for f in prompt.sh guide.sh; do
  [ -r "$src/$f" ] || fail "Fichier manquant : $f"
  "$BASH" -n "$src/$f" 2>/dev/null || fail "Erreur de syntaxe dans $f : rien n'a été installé."
done
ok "Fichiers vérifiés (bash -n)"

# --- 3. Sauvegarde --------------------------------------------------------------------------
sauvegarder
if [ -n "$bk" ]; then ok "Existant sauvegardé dans ${bk/#$HOME/\~}"; else info "Première installation : rien à sauvegarder"; fi
restaurer="L'état d'avant est dans ${bk/#$HOME/\~}."

# --- 4. Fichiers de Lueur -------------------------------------------------------------------
mkdir -p -- "$lueur" && chmod 700 "$lueur" || fail "Impossible de créer ~/.lueur."
for f in prompt.sh guide.sh; do
  if cmp -s -- "$src/$f" "$lueur/$f"; then
    info "~/.lueur/$f : déjà à jour"
    continue
  fi
  # Copie temporaire puis renommage : jamais de fichier à moitié écrit.
  cp -- "$src/$f" "$lueur/.$f.tmp.$$" && chmod 600 "$lueur/.$f.tmp.$$" && mv -f -- "$lueur/.$f.tmp.$$" "$lueur/$f" ||
    { rm -f -- "$lueur/.$f.tmp.$$"; fail "Copie de $f impossible. $restaurer"; }
  ok "~/.lueur/$f installé"
done
[ -e "$lueur/studio.conf" ] && info "Tes réglages (~/.lueur/studio.conf) sont gardés"

# --- 5. command-not-found -------------------------------------------------------------------
if [ -x "$TERMUX_PREFIX/libexec/termux/command-not-found" ]; then
  info "command-not-found déjà présent"
elif command -v pkg >/dev/null 2>&1; then
  info "Installation du paquet command-not-found…"
  if pkg install -y command-not-found >/dev/null 2>&1; then ok "command-not-found installé"
  else info "command-not-found n'a pas pu être installé : l'invite marche, sans la proposition d'installation."; fi
fi

# --- 6. ~/.bashrc ---------------------------------------------------------------------------
if grep -qxF "$BEGIN" "$rc" 2>/dev/null; then
  info "~/.bashrc charge déjà Lueur : non modifié"
else
  {
    printf '\n%s\n' "$BEGIN"
    printf '[ -f "$HOME/.lueur/guide.sh" ] && . "$HOME/.lueur/guide.sh"\n'
    printf '[ -f "$HOME/.lueur/prompt.sh" ] && . "$HOME/.lueur/prompt.sh"\n'
    printf '%s\n' "$END"
  } >> "$rc" || fail "Écriture de ~/.bashrc impossible. $restaurer"
  ok "~/.bashrc : bloc Lueur ajouté"
fi

printf '\n  %s✔ Lueur est installé.%s Ouvre une nouvelle session Termux (ou : source ~/.bashrc).\n' "${E}[1;38;5;84m" "$R"
printf '  Pour désinstaller : %scurl -fsSL https://raw.githubusercontent.com/%s/%s/install.sh | bash -s -- --desinstaller%s\n\n' \
  "${E}[1m" "$LUEUR_REPO" "$LUEUR_BRANCH" "$R"
