# Lueur

Une invite de commande stylée pour **Termux** (Android).

```
╭─ 00:41 ─ ~/projet ‹main ✱› ⏱ 12s
╰─❯
```

## Ce que ça affiche

- L'heure et le dossier courant
- La branche git, avec `✱` s'il y a des modifications non enregistrées
- `✘` et le code d'erreur quand une commande échoue, avec une flèche rouge
- `⏱` la durée des commandes qui prennent 2 secondes ou plus
- `⚙` le nombre de tâches en arrière-plan
- Le nom de l'environnement Python (venv)

Si tu tapes un programme qui n'est pas installé mais qui existe dans Termux, Lueur te propose de l'installer :

```
▸ « tree » n’est pas installé sur ce système.
  Paquet disponible : tree
  ⏎ Entrée  Installer     Échap  Annuler
```

Un programme inconnu (faute de frappe) garde l'erreur habituelle, avec son code.

## Installation

Dans Termux :

```bash
pkg install -y curl
curl -fsSLO https://raw.githubusercontent.com/issadjiga89-crypto/lueur/main/lueur-installer.sh
less lueur-installer.sh
bash lueur-installer.sh
```

`less` te laisse lire le script avant de le lancer (quitte avec `q`). Puis ferme et rouvre Termux.

## Désinstallation

```bash
bash lueur-installer.sh --uninstall
```

## À savoir

- Lueur remplace ton invite de commande actuelle.
- Ton `~/.bashrc` est sauvegardé avant toute modification.
- Lueur ajoute un seul bloc balisé dans `~/.bashrc`, que la désinstallation retire.
