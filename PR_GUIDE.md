# Guide: Créer une Pull Request avec Tests

## 🎯 Workflow complet

### 1. Créer une branche pour votre feature

```bash
# Depuis la branche main
git checkout main
git pull origin main

# Créer une nouvelle branche
git checkout -b feature/nom-de-votre-feature
```

### 2. Développer votre fonctionnalité

Écrivez votre code dans `lib/` et vos tests dans `test/`.

**Structure des fichiers :**
```
lib/
  models/
    votre_model.dart
  services/
    votre_service.dart
  
test/
  models/
    votre_model_test.dart
  services/
    votre_service_test.dart
```

### 3. Écrire les tests AVANT de pousser

```bash
# Lancer tous les tests
flutter test

# Vérifier la couverture
flutter test --coverage
```

**Assurez-vous que :**
- ✅ Tous les tests passent
- ✅ Vous avez au moins 5 tests pour votre nouvelle feature
- ✅ La couverture ne diminue pas

### 4. Formater et analyser le code

```bash
# Formater le code
dart format .

# Analyser le code
flutter analyze
```

### 5. Committer vos changements

```bash
# Ajouter tous les fichiers
git add .

# Committer avec un message clair
git commit -m "feat: ajout de [nom de la feature] avec tests"

# Exemples de messages :
# git commit -m "feat: ajout du système de favoris"
# git commit -m "fix: correction du tri des cafés par date"
# git commit -m "test: ajout de tests pour CoffeeService"
```

### 6. Pousser vers GitHub

```bash
git push origin feature/nom-de-votre-feature
```

### 7. Créer la Pull Request sur GitHub

1. Allez sur https://github.com/EnguerranCA/CoffeeGuru
2. Cliquez sur "Pull requests" > "New pull request"
3. Sélectionnez votre branche
4. Remplissez le template de PR (voir ci-dessous)

## 📝 Template de Pull Request

```markdown
## 📋 Description

[Décrivez brièvement ce que fait cette PR]

## 🎯 Type de changement

- [ ] 🐛 Bug fix
- [ ] ✨ Nouvelle fonctionnalité
- [ ] 📝 Documentation
- [ ] 🎨 Amélioration UI/UX
- [ ] ♻️ Refactoring
- [ ] 🧪 Tests

## ✅ Checklist

- [ ] Mon code suit les conventions du projet
- [ ] J'ai écrit des tests pour ma feature (minimum 5 tests)
- [ ] Tous les tests passent (`flutter test`)
- [ ] Le code est formaté (`dart format .`)
- [ ] Aucun warning dans l'analyse (`flutter analyze`)
- [ ] J'ai mis à jour la documentation si nécessaire

## 🧪 Tests ajoutés

- [ ] Tests unitaires : [nombre] tests
- [ ] Tests de widgets : [nombre] tests
- Couverture : [X]%

## 📸 Screenshots (si applicable)

[Ajoutez des captures d'écran si changement UI]

## 🔗 Issue liée

Fixes #[numéro]
```

## 🤝 Code Review

### Pour le reviewer (l'autre membre du binôme)

1. **Allez dans l'onglet "Pull requests"**
2. **Cliquez sur la PR à reviewer**
3. **Allez dans "Files changed"**
4. **Laissez des commentaires :**

```markdown
# Exemples de commentaires constructifs

✅ "Belle implémentation ! Le code est clair"
💡 "Peut-être ajouter un test pour le cas où la liste est vide ?"
🐛 "Il y a un risque de null ici, peut-être ajouter un check ?"
📝 "Ce serait bien de commenter cette fonction complexe"
```

5. **Une fois satisfait, appuyez sur "Approve"**
6. **Le créateur de la PR peut alors merger**

### Pour le créateur de la PR

1. **Lisez les commentaires**
2. **Faites les modifications demandées**
3. **Committez et pushez les changements**
4. **Répondez aux commentaires**
5. **Une fois approuvé, mergez la PR**

## 🚨 GitHub Actions va automatiquement :

1. ✅ Installer Flutter
2. ✅ Télécharger les dépendances
3. ✅ Vérifier le formatage
4. ✅ Analyser le code
5. ✅ **Lancer tous les tests**
6. ✅ Générer le rapport de couverture
7. ✅ Builder l'APK

**Si un test échoue, la PR sera marquée comme ❌ et ne pourra pas être mergée.**

## 💡 Bonnes pratiques

### DO ✅

- Créer des branches descriptives : `feature/login`, `fix/date-sorting`
- Écrire des tests pour chaque nouvelle fonctionnalité
- Faire des commits atomiques (une feature = un commit)
- Demander une review AVANT de merger
- Répondre aux commentaires de review

### DON'T ❌

- Ne pas merger sans review
- Ne pas pousser du code non testé
- Ne pas faire des PR énormes (500+ lignes)
- Ne pas ignorer les warnings de la CI
- Ne pas merger avec des tests qui échouent

## 🎓 Exemple complet

```bash
# 1. Créer une branche
git checkout -b feature/coffee-statistics

# 2. Développer
# ... écrire le code dans lib/services/statistics_service.dart
# ... écrire les tests dans test/services/statistics_service_test.dart

# 3. Tester
flutter test
# ✅ 41 tests passed

# 4. Formater
dart format .

# 5. Analyser
flutter analyze
# ✅ No issues found

# 6. Committer
git add .
git commit -m "feat: ajout des statistiques de consommation avec tests"

# 7. Pousser
git push origin feature/coffee-statistics

# 8. Créer la PR sur GitHub

# 9. Attendre la review de votre binôme

# 10. Merger après approbation
```

## 📊 Vérifier le statut de la CI

Sur votre PR, vous verrez :

- ⏳ **Yellow dot** : Tests en cours
- ✅ **Green check** : Tous les tests passent, PR prête à merger
- ❌ **Red X** : Tests échoués, corrections nécessaires

Cliquez sur "Details" pour voir les logs complets.

## 🆘 En cas de problème

### Tests échouent localement

```bash
# Voir les détails
flutter test --verbose

# Tester un fichier spécifique
flutter test test/services/coffee_service_test.dart
```

### La CI échoue mais les tests passent localement

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get
flutter test
```

### Conflit de merge

```bash
# Mettre à jour votre branche avec main
git checkout main
git pull origin main
git checkout feature/votre-branch
git merge main

# Résoudre les conflits
# ... éditer les fichiers
git add .
git commit -m "merge: résolution des conflits avec main"
git push
```

## 🏆 Objectif du TP5

Pour obtenir les **3 points de "Travail d'équipe et revues"** :

- ✅ Chaque membre doit avoir au moins **3 PR reviewées**
- ✅ Les reviews doivent contenir des **commentaires constructifs**
- ✅ Les modifications suite aux reviews doivent être **appliquées**
- ✅ Les commits doivent être **équilibrés** entre les deux membres

**Astuce :** Alternez qui crée les PRs pour équilibrer les contributions !
