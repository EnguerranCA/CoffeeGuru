# 🔄 Guide Git pour Coffee Guru

## Configuration initiale

### 1. Initialiser le repository (si pas déjà fait)
```bash
git init
git add .
git commit -m "chore: initialisation du projet Coffee Guru"
```

### 2. Créer le repository sur GitHub
1. Aller sur GitHub et créer un nouveau repository
2. Nommer le repository `coffee-guru-app`
3. Ne pas initialiser avec README (on a déjà le nôtre)

### 3. Lier le repository local avec GitHub
```bash
git remote add origin https://github.com/VOTRE-USERNAME/coffee-guru-app.git
git branch -M main
git push -u origin main
```

## Structure des branches

### Branches principales
- **`main`** : Code en production (stable, protégé)
- **`develop`** : Code en développement (intégration)

### Branches de fonctionnalités
- **`feature/map-page`** : Page de carte
- **`feature/tracker-page`** : Page de tracker
- **`feature/leaderboard-page`** : Page de classement
- **`feature/profile-page`** : Page de profil
- etc.

### Branches de correction
- **`fix/bug-name`** : Correction de bug

## Créer la branche develop

```bash
# Créer et pousser la branche develop
git checkout -b develop
git push -u origin develop
```

## Workflow de développement

### 1. Commencer une nouvelle fonctionnalité

```bash
# Se mettre sur develop
git checkout develop

# Récupérer les dernières modifications
git pull origin develop

# Créer une nouvelle branche
git checkout -b feature/nom-de-la-fonctionnalite
```

### 2. Développer et commiter

```bash
# Faire vos modifications...

# Voir les fichiers modifiés
git status

# Ajouter les fichiers
git add .
# ou de manière sélective
git add lib/pages/map_page.dart

# Commiter avec un message clair
git commit -m "feat: ajoute l'intégration de Google Maps"
```

### 3. Pousser la branche

```bash
git push origin feature/nom-de-la-fonctionnalite
```

### 4. Créer une Pull Request

1. Aller sur GitHub
2. Cliquer sur "Compare & pull request"
3. Base branch : `develop`
4. Compare branch : `feature/nom-de-la-fonctionnalite`
5. Remplir le template de PR :
   ```markdown
   ## Description
   Brève description de la fonctionnalité
   
   ## Type de changement
   - [ ] Nouvelle fonctionnalité
   - [ ] Correction de bug
   - [ ] Amélioration
   
   ## Checklist
   - [ ] Le code compile sans erreur
   - [ ] Les commentaires sont clairs
   - [ ] La documentation est à jour
   
   ## Screenshots (si applicable)
   ```
6. Assigner l'autre membre en reviewer
7. Créer la PR

### 5. Code Review

**Pour le reviewer** :
1. Lire le code ligne par ligne
2. Tester localement si possible :
   ```bash
   git fetch origin
   git checkout feature/nom-de-la-fonctionnalite
   flutter run
   ```
3. Laisser des commentaires constructifs :
   - ✅ "Bon travail ! Le code est clair"
   - ✅ "Suggestion : on pourrait extraire cette logique dans une méthode séparée"
   - ✅ "Question : pourquoi ce choix plutôt qu'un autre ?"
   - ❌ "C'est nul"
   - ❌ Pas de feedback

4. Approuver ou demander des changements

**Pour l'auteur** :
1. Répondre aux commentaires
2. Faire les modifications demandées
3. Commiter et pusher :
   ```bash
   git add .
   git commit -m "fix: applique les suggestions de review"
   git push origin feature/nom-de-la-fonctionnalite
   ```

### 6. Merger la PR

Une fois approuvée :
1. Cliquer sur "Merge pull request"
2. Choisir "Squash and merge" (optionnel, pour un historique propre)
3. Supprimer la branche sur GitHub après merge

Localement :
```bash
# Retourner sur develop
git checkout develop

# Récupérer les changements
git pull origin develop

# Supprimer la branche locale (optionnel)
git branch -d feature/nom-de-la-fonctionnalite
```

## Format des commits

### Convention
```
type: description courte (max 50 caractères)

Corps du message (optionnel, max 72 caractères par ligne)
Explique le POURQUOI, pas le COMMENT
```

### Types de commits
- **feat**: Nouvelle fonctionnalité
- **fix**: Correction de bug
- **docs**: Documentation uniquement
- **style**: Formatage, point-virgules manquants, etc. (pas de changement de code)
- **refactor**: Refactoring du code sans changer le comportement
- **test**: Ajout ou modification de tests
- **chore**: Tâches de maintenance (mise à jour de dépendances, etc.)

### Exemples
```bash
feat: ajoute la carte Google Maps à la MapPage

fix: corrige le calcul de caféine dans le tracker
Le calcul ne prenait pas en compte les expressos

docs: met à jour le README avec les instructions d'installation

style: formate le code selon les conventions Dart

refactor: extrait la logique de calcul dans un service séparé

test: ajoute des tests unitaires pour le CoffeeService

chore: met à jour les dépendances Flutter
```

## Protéger les branches sur GitHub

### Recommandations
1. Aller dans Settings > Branches > Add branch protection rule
2. Pour `main` :
   - ✅ Require pull request reviews before merging (1 approbation minimum)
   - ✅ Require status checks to pass before merging
   - ✅ Do not allow bypassing the above settings
3. Pour `develop` :
   - ✅ Require pull request reviews before merging

## Résolution de conflits

### Si vous avez des conflits

```bash
# Récupérer les dernières modifications de develop
git checkout develop
git pull origin develop

# Retourner sur votre branche
git checkout feature/votre-branche

# Merger develop dans votre branche
git merge develop

# Résoudre les conflits dans VS Code
# Les sections en conflit seront marquées avec <<<<<< ======= >>>>>>

# Après résolution
git add .
git commit -m "fix: résout les conflits avec develop"
git push origin feature/votre-branche
```

## Bonnes pratiques

### ✅ À FAIRE
- Commits fréquents (petits et atomiques)
- Messages de commit clairs et descriptifs
- Pull avant de commencer à travailler
- Tester votre code avant de pusher
- Faire des reviews constructives et bienveillantes
- Garder les branches à jour avec develop

### ❌ À ÉVITER
- Commits énormes avec plein de fichiers
- Messages vagues : "fix", "update", "changes"
- Pusher du code qui ne compile pas
- Merger sans review
- Travailler directement sur main ou develop
- Laisser des branches obsolètes traîner

## Commandes utiles

```bash
# Voir l'état actuel
git status

# Voir les branches
git branch -a

# Voir l'historique des commits
git log --oneline --graph

# Annuler les modifications non commitées
git restore .

# Revenir au dernier commit (annule les modifs)
git reset --hard HEAD

# Voir les différences
git diff

# Stash (mettre de côté) vos modifications
git stash
git stash pop  # Pour les récupérer

# Mettre à jour toutes les branches locales
git fetch --all
```

## Checklist avant chaque Push

- [ ] Le code compile sans erreur : `flutter analyze`
- [ ] L'application se lance : `flutter run`
- [ ] Pas de TODO ou de code commenté en masse
- [ ] Les imports sont propres
- [ ] Le code suit les conventions Dart
- [ ] Les fichiers sensibles ne sont pas commitées (.env, clés API)

## Objectif : Minimum 3 PR reviewées par membre

Pour valider le critère "Travail d'équipe" du TP5, chaque membre doit :
- ✅ Créer au moins 3 Pull Requests
- ✅ Reviewer au moins 3 Pull Requests de l'autre membre
- ✅ Laisser des commentaires constructifs
- ✅ Appliquer les suggestions de review

---

**Bon workflow Git ! 🚀**
