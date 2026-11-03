# Journal des versions

## v2 — 2026-11-03

### Plus rapide
- La branche git est lue dans `.git/HEAD` au lieu de lancer `git` deux fois à chaque affichage. Hors d'un dépôt, l'invite passe de 189 ms à 6 ms (mesuré sous proot).
- `✱` (fichiers modifiés) devient facultatif : il est désactivé par défaut. Une fois activé, `git status` n'est plus relancé quand tu appuies juste sur Entrée.
- Le nombre de tâches vient de bash (`\j`), sans sous-shell.
- La durée des commandes est mesurée avec `PS0` au lieu d'un piège `DEBUG`, qui ralentissait chaque commande (une boucle tapée à l'invite était 14 fois plus lente).

### Nouveau
- 8 thèmes : Mint Neon, Violet Cyber, Cyan Night, Golden Dark, Rainbow, 🌈 Arc-en-ciel, Classique, Minimal.
- Symbole au choix : `❯` `➜` `»` `›` `λ`.
- Chaque élément peut être masqué : heure, dossier, branche, `✱`, durée, tâches, venv.
- Les réglages sont lus dans `~/.lueur/studio.conf`, modifiable à la main ou avec [Lueur Studio](https://github.com/issadjiga89-crypto/lueur-studio).
- La proposition d'installation ne s'affiche que dans un vrai terminal : les scripts gardent l'erreur habituelle.
- Les commandes de Lueur Studio (`~/.lueur/lueur.sh`) sont chargées si elles sont présentes.

### Nouvelles versions
- À l'ouverture de Termux, une ligne signale une nouvelle version, au plus une fois par jour, avec la commande `lueur-maj`.
- La vérification se fait en arrière-plan, au plus une fois par jour, avec un cache dans `~/.lueur/update.cache` : l'ouverture n'attend jamais le réseau.
- Rien n'est installé tout seul. La vérification se désactive avec `LUEUR_CHECK_UPDATE=0` (ou dans Lueur Studio → Paramètres).
- Le numéro de version est dans `prompt.sh` (`__lueur_version`) et dans le fichier `VERSION`.

### Installation
- Installation et mise à jour en une ligne : `curl … install.sh | bash`.
- Sauvegarde de `~/.lueur` et de `~/.bashrc` avant toute modification, dans `~/.lueur-installations/<date>/`.
- Les réglages (`studio.conf`) sont gardés lors d'une mise à jour.
- La désinstallation met `~/.lueur` de côté au lieu de l'effacer.
- `PROMPT_COMMAND` : Lueur s'ajoute sans écraser les autres outils, et un rechargement ne l'ajoute pas deux fois.
- `lueur-installer.sh` est gardé pour les anciennes instructions et lance `install.sh`.
- Licence MIT.

## v1 — 2026-10-14

Première version : heure, dossier, branche git avec `✱`, code d'erreur, durée, tâches, venv, et proposition d'installer un programme manquant.
