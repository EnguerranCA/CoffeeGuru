# Coffee Guru ☕

## 👥 Équipe
- Gilian Cannier gilian.cannier@etu.unilim.fr
- Enguerran Caro--Alquier enguerran.caroalquier@etu.unilim.fr

## 📱 Description
Coffee Guru est une application mobile dédiée aux amateurs de café. Elle permet de découvrir des cafés à proximité via une carte interactive, de suivre sa consommation quotidienne de café, de comparer ses statistiques avec d'autres utilisateurs dans un classement, et de gérer son profil avec un système de badges d'accomplissement.

## 🎯 Orientation choisie
**Option 3 : Équilibrée** - Mix entre fonctionnel et design

## ✅ Contraintes respectées

### Fonctionnel 
- [X] Stockage persistant (Supabase)
- [X] Package pub.dev pertinent (fluttermaps, geolocator, etc.)

### Design
- [x] Animations (rotation des badges, popup de badges, clic sur les filtres, chargements, etc.)
- [x] Utilisation d'**images** (icones, illustrations) de manière cohérente

## 🚀 Installation

### Prérequis
- Flutter SDK
- Android studio

### Étapes
```bash
# Cloner le repository
git clone https://github.com/enguerranCA/CoffeeGuru.git

# Installer les dépendances
cd flutter_application_1
flutter pub get

# Lancer l'application
flutter run --dart-define-from-file=.env
# ou utiliser Run and Debug dans VS Code et lancer flutter_application_1
```

## 🏗️ Structure du projet

```
lib/
├── main.dart                       # Point d'entrée avec navigation
├── models/                         # Modèles de données
│   ├── badge.dart                  # Modèle des badges d'accomplissement
│   ├── cafe_place.dart             # Modèle des cafés/établissements
│   ├── coffee_log.dart             # Modèle des logs de consommation
│   └── user.dart                   # Modèle utilisateur
├── pages/                          # Pages de l'application
│   ├── map_page.dart               # Carte des cafés avec filtres
│   ├── tracker_page.dart           # Suivi de consommation et statistiques
│   ├── leaderboard_page.dart       # Classement des utilisateurs
│   └── profile_page.dart           # Profil utilisateur et badges
├── services/                       # Services (API, stockage, logique métier)
│   ├── auth_service.dart           # Authentification et gestion utilisateur
│   ├── badge_service.dart          # Gestion et déblocage des badges
│   ├── cafe_service.dart           # Gestion des cafés et établissements
│   ├── coffee_service.dart         # Gestion des logs de consommation
│   ├── database_service.dart       # Communication avec Supabase
│   ├── geocoding_service.dart      # Services de géolocalisation
│   └── leaderboard_service.dart    # Gestion du classement
└── widgets/                        # Widgets réutilisables
    ├── add_coffee_dialog.dart      # Dialog d'ajout de café
    ├── auth_dialog.dart            # Dialog de connexion/inscription
    ├── badge_display.dart          # Affichage des badges
    ├── badge_notification.dart     # Notification de nouveau badge
    ├── cafe_place_search.dart      # Recherche d'établissements
    └── caffeine_progress_bar.dart  # Barre de progression de caféine
```

## 📋 Fonctionnalités

### ✅ Implémenté
- [x] Navigation bottom bar avec 4 pages
- [x] Structure de base des pages
- [x] Thème personnalisé (beige et marron)

### 🚧 Tâches en cours

#### Coffee Map
- [x] Afficher une carte interactive des cafés à proximité
- [x] Filtrer les cafés selon les recettes et le type de point de vente (cafés, distributeurs, bars, etc.)

#### Coffee Tracker
- [x] Suivi de la consommation de café (log quand on prend un café : où, type, heure)
- [x] Statistiques personnelles sur la consommation (fréquence, types préférés)
- [x] Visualisation comme une app de temps d'écran
- [x] Visualisation de la limite recommandée de consommation de caféine
- [x] Popup quand la limite de café est atteinte

#### Leaderboard Coffee Lovers
- [x] Comparaison de la consommation entre utilisateurs
- [x] Classement du nombre d'endroits différents visités
- [x] Classement des recettes goûtées

#### Profil
- [x] Création et gestion de profil utilisateur
- [x] Badges des avancements de cafés (ex: "Caf'explorateur", "Latte Gourou", "Décaféiné")
- [x] Animation de rotation des badges

## 🎨 Design

**Palette de couleurs** :
- Fond principal : Beige `#F5E6D3`
- Couleur principale : Marron café `#6B4423`
- Navigation : Beige foncé `#EDD5B8`

**Logo** : `logo-coffee-guru.png`


## 🔑 API/Credentials

Clés potentiellement nécessaires :
- Supabase URL et Anon Key pour le dev

## 📸 Screenshots

_Screenshots à venir après développement des fonctionnalités_

## 🧪 Tests

```bash
# Lancer les tests
flutter test
```


## 📝 Difficultés rencontrées

1. La mise en place de Flutter map car au début il y avait des problèmes de chargements et de race conditions avec le cahrgement des lieux notamment.
2. Gestion de la base de données Supabase et les migrations que nous avons dû faire manuellement et qu'il était compliqué de comprendre surtout au début.

## 🔄 Workflow Git

### Branches
- `main` : Branche principale
- `feature/nom-feature` : Branches pour chaque fonctionnalité

### Commits
- Messages en français si possible
