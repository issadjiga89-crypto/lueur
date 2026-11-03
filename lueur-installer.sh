#!/data/data/com.termux/files/usr/bin/bash
# Lueur — ancien nom de l'installateur, gardé pour les anciennes instructions.
#   bash lueur-installer.sh               installer ou mettre à jour
#   bash lueur-installer.sh --uninstall   désinstaller
# Il lance install.sh : celui d'à côté s'il est là, sinon celui du dépôt GitHub.
# (Lis install.sh avant : c'est lui qui fait tout.)

if [ -z "${BASH_VERSION:-}" ]; then
  echo "Lueur : lance ce script avec bash, pas avec sh." >&2
  exit 1
fi
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
if [ -n "$here" ] && [ -r "$here/install.sh" ] && [ -r "$here/prompt.sh" ]; then
  if [ "${1:-}" = --uninstall ]; then exec bash "$here/install.sh" --desinstaller; fi
  exec bash "$here/install.sh" --depuis "$here" "$@"
fi
command -v curl >/dev/null 2>&1 || { echo "Lueur : il faut curl (pkg install curl)." >&2; exit 1; }
script=$(curl -fsSL https://raw.githubusercontent.com/issadjiga89-crypto/lueur/main/install.sh) ||
  { echo "Lueur : téléchargement de install.sh impossible." >&2; exit 1; }
exec bash -c "$script" lueur-install "$@"
