# Lueur

Une invite de commande stylée et rapide pour **Termux** (Android), en bash pur.

> [!IMPORTANT]
> **Vous êtes en v1 ?** Passez à la v2 (invite bien plus rapide, nouvelles versions signalées) avec une seule commande dans Termux :
>
> ```bash
> curl -fsSL https://github.com/issadjiga89-crypto/lueur/releases/latest/download/install.sh | bash
> ```
>
> La mise à jour conserve vos réglages et le reste de votre `~/.bashrc`, et sauvegarde d'abord tout dans `~/.lueur-installations/`.
>
> Pour savoir quelle version vous avez : `grep -q __lueur_version ~/.lueur/prompt.sh 2>/dev/null && echo v2 || echo v1`

```
╭─ 00:41 ─ ~/projet ‹main ✱› ⏱ 12s
╰─❯
```

## Installation

Dans Termux :

```bash
curl -fsSL https://github.com/issadjiga89-crypto/lueur/releases/latest/download/install.sh | bash
```

Ouvre ensuite une nouvelle session Termux.

Tu préfères lire le script avant de le lancer ? C'est du texte :

```bash
curl -fsSLO https://raw.githubusercontent.com/issadjiga89-crypto/lueur/main/install.sh
less install.sh        # q pour quitter
bash install.sh
```

La même commande **met à jour** une installation existante. Avant de toucher à quoi que ce soit, elle sauvegarde `~/.lueur` et `~/.bashrc` dans `~/.lueur-installations/<date>/`. Tes réglages (`~/.lueur/studio.conf`) sont gardés.

## Ce que ça affiche

- L'heure et le dossier courant
- La branche git, avec `✱` s'il y a des modifications non enregistrées (facultatif)
- `✘` et le code d'erreur quand une commande échoue, avec une flèche rouge
- `⏱` la durée des commandes qui prennent 2 secondes ou plus
- `⚙` le nombre de tâches en arrière-plan
- Le nom de l'environnement Python (venv)

Si tu tapes un programme qui n'est pas installé mais qui existe dans Termux, Lueur te propose de l'installer :

```
▸ « tree » n'est pas installé sur ce système.
  Paquet disponible : tree
  ⏎ Entrée  Installer     Échap  Annuler
```

Un programme inconnu (faute de frappe) garde l'erreur habituelle, avec son code.

## Thèmes et réglages

8 thèmes : Mint Neon (par défaut), Violet Cyber, Cyan Night, Golden Dark, Rainbow, 🌈 Arc-en-ciel, Classique, Minimal.

Les réglages se trouvent dans `~/.lueur/studio.conf`, une ligne `CLÉ=valeur` par réglage :

| Réglage | Valeurs |
|---|---|
| `LUEUR_THEME` | `mint` `violet` `cyan` `gold` `rainbow` `arcenciel` `classique` `minimal` |
| `LUEUR_SYMBOL` | `❯` `➜` `»` `›` `λ` |
| `LUEUR_SHOW_TIME`, `LUEUR_SHOW_DIR`, `LUEUR_SHOW_GIT`, `LUEUR_SHOW_DURATION`, `LUEUR_SHOW_JOBS`, `LUEUR_SHOW_VENV` | `1` affiché, `0` masqué |
| `LUEUR_SHOW_GIT_STATUS` | `1` pour afficher `✱` (lance `git status`), `0` par défaut |
| `LUEUR_CHECK_UPDATE` | `1` signaler les nouvelles versions (par défaut), `0` jamais |

Le plus simple est de les régler avec **[Lueur Studio](https://github.com/issadjiga89-crypto/lueur-studio)**, le centre de contrôle en menus. Il offre l'aperçu des thèmes, une bannière d'accueil et des sauvegardes.

## Rapide

L'invite est calculée sans lancer de programme : la branche est lue directement dans `.git/HEAD`, et le nombre de tâches vient de bash (`\j`). Seul `git status` est lancé, pour `✱`, et seulement si tu l'as activé. Il n'est pas relancé quand tu appuies juste sur Entrée.

Temps de calcul de l'invite, mesurés sous proot (dans Termux natif, tout est plus rapide) :

| | v1 | v2 |
|---|---|---|
| dossier normal | 189 ms | 6 ms |
| dépôt git, `✱` activé, après une commande | 334 ms | 109 ms |
| dépôt git, `✱` activé, Entrée seule | 329 ms | 6 ms |

La durée des commandes est chronométrée avec `PS0`, pas avec un piège `DEBUG` : une boucle tapée à l'invite garde toute sa vitesse.

Lueur ajoute sa fonction à `PROMPT_COMMAND` sans écraser celles des autres outils (zoxide, direnv…).

## Nouvelles versions

Quand une nouvelle version de Lueur existe sur GitHub, une ligne te le signale à l'ouverture de Termux, au plus une fois par jour :

```
  ↑ Lueur 2.1 est disponible (tu as 2.0) · mise à jour : lueur-maj
```

- **Rien n'est installé tout seul.** Il faut taper `lueur-maj` pour lancer l'installateur, qui sauvegarde tout avant.
- **Termux n'attend jamais le réseau.** La vérification lit le fichier `VERSION` de ce dépôt (quelques octets), en arrière-plan et au plus une fois par jour. Le résultat est gardé dans `~/.lueur/update.cache` et s'affiche à l'ouverture suivante.
- **Pas de réseau, pas de `curl`** : rien ne s'affiche, et rien ne se bloque.
- **Pour la désactiver** : `LUEUR_CHECK_UPDATE=0` dans `~/.lueur/studio.conf`, ou dans Lueur Studio → 🔧 Paramètres → Vérifier les versions.

## Désinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/issadjiga89-crypto/lueur/main/install.sh | bash -s -- --desinstaller
```

Le bloc Lueur est retiré de `~/.bashrc`, et `~/.lueur` est mis de côté dans `~/.lueur-installations/`, pas effacé.

L'ancienne méthode marche toujours : `bash lueur-installer.sh` pour installer, `bash lueur-installer.sh --uninstall` pour désinstaller.

## Licence

[MIT](LICENSE) © 2026 issadjiga89-crypto
