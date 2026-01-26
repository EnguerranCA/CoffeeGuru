# 🎯 Exemple pratique - Ajouter une nouvelle feature avec tests

## Scénario : Ajouter une fonction "Café favori"

Imaginez que vous voulez ajouter la possibilité de marquer un café comme "favori".

## 📝 Étapes complètes

### 1. Créer une branche

```bash
git checkout -b feature/Nom-favorite-coffee
```

### 2. Modifier le modèle (TDD - Test First!)

**D'abord, écrivez le test** - `test/models/coffee_log_test.dart`

```dart
group('CoffeeLog Favorite Tests', () {
  test('CoffeeLog should have isFavorite property', () {
    final log = CoffeeLog(
      id: '1',
      type: CoffeeType.espresso,
      location: CoffeeLocation.home,
      timestamp: DateTime.now(),
      isFavorite: true,  // Nouvelle propriété
    );

    expect(log.isFavorite, true);
  });

  test('CoffeeLog should default to not favorite', () {
    final log = CoffeeLog(
      id: '1',
      type: CoffeeType.espresso,
      location: CoffeeLocation.home,
      timestamp: DateTime.now(),
    );

    expect(log.isFavorite, false);
  });

  test('toggleFavorite should change favorite status', () {
    final log = CoffeeLog(
      id: '1',
      type: CoffeeType.espresso,
      location: CoffeeLocation.home,
      timestamp: DateTime.now(),
    );

    final updated = log.toggleFavorite();

    expect(updated.isFavorite, true);
  });
});
```

**Ensuite, implémentez le code** - `lib/models/coffee_log.dart`

```dart
class CoffeeLog {
  final String id;
  final CoffeeType type;
  final CoffeeLocation location;
  final DateTime timestamp;
  final bool isFavorite;  // Nouvelle propriété

  CoffeeLog({
    required this.id,
    required this.type,
    required this.location,
    required this.timestamp,
    this.isFavorite = false,  // Valeur par défaut
  });

  // Méthode pour toggler le favori
  CoffeeLog toggleFavorite() {
    return CoffeeLog(
      id: id,
      type: type,
      location: location,
      timestamp: timestamp,
      isFavorite: !isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'location': location.name,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,  // Ajouter dans JSON
    };
  }

  factory CoffeeLog.fromJson(Map<String, dynamic> json) {
    return CoffeeLog(
      id: json['id'],
      type: CoffeeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CoffeeType.espresso,
      ),
      location: CoffeeLocation.values.firstWhere(
        (e) => e.name == json['location'],
        orElse: () => CoffeeLocation.home,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isFavorite: json['isFavorite'] ?? false,  // Gérer le cas null
    );
  }
}
```

### 3. Modifier le service

**Tests du service** - `test/services/coffee_service_test.dart`

```dart
group('CoffeeService Favorite Tests', () {
  test('toggleFavorite should update the log', () {
    final log = CoffeeLog(
      id: '1',
      type: CoffeeType.espresso,
      location: CoffeeLocation.home,
      timestamp: DateTime.now(),
    );

    coffeeService.addCoffeeLog(log);
    coffeeService.toggleFavorite('1');

    expect(coffeeService.coffeeLogs.first.isFavorite, true);
  });

  test('getFavoriteLogs should return only favorites', () {
    coffeeService.addCoffeeLog(CoffeeLog(
      id: '1',
      type: CoffeeType.espresso,
      location: CoffeeLocation.home,
      timestamp: DateTime.now(),
      isFavorite: true,
    ));
    coffeeService.addCoffeeLog(CoffeeLog(
      id: '2',
      type: CoffeeType.latte,
      location: CoffeeLocation.work,
      timestamp: DateTime.now(),
      isFavorite: false,
    ));

    final favorites = coffeeService.getFavoriteLogs();

    expect(favorites.length, 1);
    expect(favorites.first.id, '1');
  });
});
```

**Implémentation du service** - `lib/services/coffee_service.dart`

```dart
class CoffeeService {
  // ... code existant ...

  // Toggler le favori d'un log
  void toggleFavorite(String id) {
    final index = _coffeeLogs.indexWhere((log) => log.id == id);
    if (index != -1) {
      _coffeeLogs[index] = _coffeeLogs[index].toggleFavorite();
    }
  }

  // Obtenir les logs favoris
  List<CoffeeLog> getFavoriteLogs() {
    return _coffeeLogs.where((log) => log.isFavorite).toList();
  }
}
```

### 4. Modifier l'UI

**Tests de widgets** - `test/widgets/tracker_page_test.dart`

```dart
testWidgets('should toggle favorite when star icon is tapped', (tester) async {
  final now = DateTime.now();
  coffeeService.addCoffeeLog(CoffeeLog(
    id: '1',
    type: CoffeeType.espresso,
    location: CoffeeLocation.home,
    timestamp: now,
  ));

  await tester.pumpWidget(createTestWidget());
  await tester.pump();

  // Trouver et taper sur l'icône étoile
  final starIcon = find.byIcon(Icons.star_outline);
  await tester.tap(starIcon);
  await tester.pump();

  // Vérifier que c'est devenu favori
  expect(find.byIcon(Icons.star), findsOneWidget);
  expect(coffeeService.coffeeLogs.first.isFavorite, true);
});
```

**Implémentation UI** - `lib/pages/tracker_page.dart`

```dart
Widget _buildCoffeeLogCard(CoffeeLog log) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        child: Text(log.type.emoji),
      ),
      title: Text(log.type.displayName),
      subtitle: Text('${log.location.emoji} ${log.location.displayName}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône favori
          IconButton(
            icon: Icon(
              log.isFavorite ? Icons.star : Icons.star_outline,
              color: log.isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _coffeeService.toggleFavorite(log.id);
              });
            },
          ),
          // Heure
          Text(timeFormat.format(log.timestamp)),
        ],
      ),
    ),
  );
}
```

### 5. Tester localement

```bash
# Lancer les tests
flutter test

# Vérifier qu'ils passent tous
# ✅ 39 tests (36 + 3 nouveaux)

# Formater le code
dart format .

# Analyser
flutter analyze
```

### 6. Committer

```bash
git add .
git commit -m "feat: ajout de la fonctionnalité café favori avec tests

- Ajout de la propriété isFavorite au modèle CoffeeLog
- Méthode toggleFavorite() dans le modèle et le service
- Méthode getFavoriteLogs() dans le service
- Icône étoile dans l'UI pour marquer les favoris
- 3 nouveaux tests (modèle + service + widget)
"
```

### 7. Pousser et créer la PR

```bash
git push origin feature/favorite-coffee
```

Puis sur GitHub :
1. Créer la Pull Request
2. Remplir le template :

```markdown
## 📋 Description

Ajout de la fonctionnalité permettant de marquer des cafés comme favoris.

## 🎯 Type de changement

- [x] ✨ Nouvelle fonctionnalité

## ✅ Checklist

- [x] Mon code suit les conventions du projet
- [x] J'ai écrit des tests (3 nouveaux tests)
- [x] Tous les tests passent
- [x] Le code est formaté
- [x] Aucun warning

## 🧪 Tests ajoutés

- [x] Tests unitaires : 3 tests
- Couverture : 91%

Fichiers :
- test/models/coffee_log_test.dart (1 test)
- test/services/coffee_service_test.dart (2 tests)
- test/widgets/tracker_page_test.dart (1 test)
```

### 8. Attendre la CI

GitHub Actions va :
- ✅ Installer Flutter
- ✅ Lancer les 39 tests
- ✅ Vérifier le formatage
- ✅ Analyser le code
- ✅ Builder l'APK

**Résultat attendu : ✅ Tous les checks passent**

### 9. Code Review

L'autre membre du binôme va :
- Lire le code
- Vérifier les tests
- Laisser des commentaires

Exemple de commentaires :

```markdown
# Reviewer
💡 "Peut-être ajouter un filtre pour n'afficher que les favoris ?"
✅ "Tests bien écrits, couverture excellente !"
📝 "Petite typo dans le commentaire ligne 45"
```

Vous répondez :

```markdown
# Vous
✅ "Corrigé la typo, merci !"
💡 "Bonne idée pour le filtre, je l'ajoute dans une autre PR"
```

### 10. Merge

Une fois approuvé :
1. Cliquez sur "Merge pull request"
2. Confirmez
3. Supprimez la branche (optionnel)

```bash
# Localement, revenir sur main et mettre à jour
git checkout main
git pull origin main

# Supprimer la branche locale
git branch -d feature/favorite-coffee
```

---

## 📊 Résultat

**Avant :**
- 36 tests
- Fonctionnalité de base

**Après :**
- ✅ 39 tests (+3)
- ✅ Nouvelle feature (favoris)
- ✅ Code reviewé
- ✅ CI/CD validée
- ✅ Documentation à jour

---

## 🎓 Ce que vous avez appris

1. **TDD** - Tests d'abord, code ensuite
2. **Git workflow** - Branch, commit, PR, review, merge
3. **CI/CD** - Automatisation des tests
4. **Code review** - Collaboration en équipe
5. **Documentation** - Messages de commit clairs

---

## 💡 Tips pour vos propres features

### Structure de commit message

```
type: description courte (50 chars max)

Description détaillée si nécessaire.
- Point 1
- Point 2

Fixes #123
```

**Types courants :**
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `test:` Ajout de tests
- `docs:` Documentation
- `refactor:` Refactoring
- `style:` Formatage
- `chore:` Maintenance

### Taille des PRs

- ✅ **Petites PRs** : 50-200 lignes → Review rapide
- ⚠️ **Moyennes PRs** : 200-500 lignes → Review attentive
- ❌ **Grosses PRs** : 500+ lignes → Difficile à reviewer

**Astuce :** Découpez les grosses features en plusieurs PRs !

### Tests à écrire

Pour chaque feature :
1. **Happy path** - Cas nominal
2. **Edge cases** - Cas limites (null, vide, etc.)
3. **Error cases** - Cas d'erreur
4. **UI tests** - Interaction utilisateur

---

**Utilisez cet exemple comme template pour toutes vos futures features ! 🚀**
