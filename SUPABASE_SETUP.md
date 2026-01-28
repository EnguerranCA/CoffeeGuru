# 📋 Instructions de Configuration - Coffee Guru avec Supabase

## ✅ Ce qui a été fait

1. ✅ Création du schéma SQL (`supabase_schema.sql`)
2. ✅ Ajout des packages `supabase_flutter` et `flutter_dotenv`
3. ✅ Configuration du fichier `.env`
4. ✅ Création du `DatabaseService`
5. ✅ Mise à jour des modèles (`User`, `Cafe`, `CoffeeLog`)
6. ✅ Mise à jour de `CafeService` et `CoffeeService` pour utiliser Supabase
7. ✅ Initialisation de Supabase dans `main.dart`

## 🚀 Étapes suivantes pour terminer la configuration

### 1. Configurer Supabase

#### a) Créer les tables dans Supabase

1. Connectez-vous à votre projet Supabase : https://supabase.com/dashboard
2. Allez dans **SQL Editor**
3. Copiez tout le contenu du fichier `supabase_schema.sql`
4. Collez-le dans l'éditeur SQL
5. Cliquez sur **Run** pour exécuter le script

Cela va créer :
- Table `users`
- Table `cafe_places`
- Table `available_coffee_types`
- Table `coffee_logs`
- + indexes, triggers, et quelques données de test

#### b) Récupérer les clés API Supabase

1. Dans Supabase Dashboard, allez dans **Settings** > **API**
2. Copiez ces valeurs :
   - **Project URL** (commence par `https://...supabase.co`)
   - **anon public** key (dans la section "Project API keys")

#### c) Mettre à jour le fichier `.env`

Ouvrez le fichier `.env` et remplacez :

```env
SUPABASE_URL=https://nvhgoexyplowsinnlkom.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Par vos vraies valeurs récupérées ci-dessus.

⚠️ **Important** : La `DATABASE_URL` est déjà correcte, ne la modifiez pas.

### 2. Installer les packages Flutter

```bash
flutter pub get
```

### 3. Tester l'application

```bash
flutter run
```

### 4. Vérifier la connexion

Au démarrage, vous devriez voir dans la console :
```
✅ Connexion à Supabase établie
✅ Supabase initialisé avec succès
```

Si vous voyez des erreurs, vérifiez que :
- Le fichier `.env` est à la racine du projet
- Les valeurs SUPABASE_URL et SUPABASE_ANON_KEY sont correctes
- Les tables ont bien été créées dans Supabase

---

## 🔧 Prochaines étapes de développement

### Widget de recherche de lieux (TODO)

Il faut créer un widget pour :
1. Rechercher des CafePlaces existants dans la base
2. Permettre d'ajouter un nouveau CafePlace si non trouvé

Exemple de structure :

```dart
// lib/widgets/cafe_place_search.dart
class CafePlaceSearch extends StatefulWidget {
  final Function(Cafe?) onCafePlaceSelected;
  
  // ...
}
```

### Mise à jour des widgets existants

Certains widgets doivent être mis à jour pour utiliser les nouvelles méthodes async :

#### TrackerPage (`lib/pages/tracker_page.dart`)

- Remplacer `_coffeeService.addCoffeeLog(result)` par `await _coffeeService.addCoffeeLog(result)`
- Remplacer `_coffeeService.removeCoffeeLog(id)` par `await _coffeeService.removeCoffeeLog(id)`
- Charger les logs au démarrage avec `await _coffeeService.getCoffeeLogs()`

#### MapPage (`lib/pages/map_page.dart`)

- La méthode `_loadCafes()` est déjà async, devrait fonctionner
- Mais vérifier que `getAllCafes()` est appelé avec `await`

#### AddCoffeeDialog (si existe)

- Ajouter un champ pour rechercher/sélectionner un CafePlace
- Ou permettre de choisir entre CafePlace et location privée (home, work, friend)

---

## 📊 Structure de la base de données

### Table: users
| Colonne | Type | Description |
|---------|------|-------------|
| id | UUID | Primary key |
| username | VARCHAR(50) | Nom d'utilisateur unique |
| created_at | TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | Date de mise à jour |

### Table: cafe_places
| Colonne | Type | Description |
|---------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(255) | Nom du café |
| address | TEXT | Adresse complète |
| latitude | FLOAT | Latitude GPS |
| longitude | FLOAT | Longitude GPS |
| type | VARCHAR(50) | Type (cafe, restaurant, bar, etc.) |
| image_url | TEXT | URL de l'image (optionnel) |
| created_by | UUID | FK vers users |
| created_at | TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | Date de mise à jour |

### Table: available_coffee_types
| Colonne | Type | Description |
|---------|------|-------------|
| id | UUID | Primary key |
| cafe_place_id | UUID | FK vers cafe_places |
| coffee_type | VARCHAR(50) | Type de café disponible |
| created_at | TIMESTAMP | Date de création |

### Table: coffee_logs
| Colonne | Type | Description |
|---------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | FK vers users |
| coffee_type | VARCHAR(50) | Type de café consommé |
| cafe_place_id | UUID | FK vers cafe_places (optionnel) |
| location_type | VARCHAR(50) | Type de lieu privé (home, work, friend) |
| timestamp | TIMESTAMP | Date/heure de consommation |
| created_at | TIMESTAMP | Date de création |

**Contrainte** : Soit `cafe_place_id` soit `location_type` doit être renseigné.

---

## 🐛 Résolution de problèmes

### Erreur : "SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis"

➡️ Vérifiez que le fichier `.env` existe et contient les bonnes valeurs.

### Erreur : "relation does not exist"

➡️ Les tables n'ont pas été créées. Exécutez le script SQL dans Supabase.

### Erreur de connexion réseau

➡️ Vérifiez votre connexion Internet et que l'URL Supabase est correcte.

### L'application démarre mais ne charge pas de données

➡️ Vérifiez la console pour voir les messages d'erreur détaillés (🔴 avec emoji).

---

## 📝 Notes importantes

1. **Authentification** : Pour l'instant, tous les logs utilisent l'utilisateur de test avec l'ID `00000000-0000-0000-0000-000000000001`. Il faudra implémenter un vrai système d'authentification plus tard.

2. **Cache local** : Les services utilisent un cache local (`_cachedCafes`, `_cachedLogs`) pour éviter trop d'appels réseau. Pensez à appeler `refreshLogs()` ou `getCafesNearby()` quand nécessaire.

3. **Gestion d'erreurs** : Toutes les méthodes de service gèrent les erreurs et affichent des messages dans la console. En production, il faudrait afficher des messages à l'utilisateur.

4. **Migration des données** : Si vous aviez des données locales avant, elles ne sont pas migrées automatiquement vers Supabase.

---

## ✨ Fonctionnalités activées

Avec cette configuration, vous pouvez maintenant :

✅ Stocker les CafePlaces dans Supabase (partagés entre utilisateurs)
✅ Stocker les CoffeeLogs dans Supabase (par utilisateur)
✅ Rechercher des cafés par nom
✅ Filtrer les cafés par distance, type, etc.
✅ Ajouter de nouveaux CafePlaces
✅ Logger des consommations de café dans des établissements OU des lieux privés

---

Bon développement ! ☕
