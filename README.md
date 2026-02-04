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
- [ ] Animations (Hero, AnimatedContainer, rotation des badges, etc.)

## 🚀 Installation

### Prérequis
- Flutter SDK (^3.7.2)
- Dart SDK
- Un émulateur Android/iOS ou un appareil physique

### Étapes
```bash
# Cloner le repository
git clone https://github.com/enguerranCA/CoffeeGuru.git

# Installer les dépendances
cd flutter_application_1
flutter pub get

# Lancer l'application
flutter run
```

## 🏗️ Structure du projet

```
lib/
├── main.dart                  # Point d'entrée avec navigation
├── models/                    # Modèles de données
│   └── (à venir)
├── pages/                     # Pages de l'application
│   ├── map_page.dart         # Carte des cafés
│   ├── tracker_page.dart     # Suivi de consommation
│   ├── leaderboard_page.dart # Classement
│   └── profile_page.dart     # Profil utilisateur
├── services/                  # Services (API, stockage)
│   └── (à venir)
└── widgets/                   # Widgets réutilisables
    └── (à venir)
```

## 📋 Fonctionnalités

### ✅ Implémenté
- [x] Navigation bottom bar avec 4 pages
- [x] Structure de base des pages
- [x] Thème personnalisé (beige et marron)

### 🚧 En cours / À venir

#### Coffee Map
- [X] Afficher une carte interactive des cafés à proximité
- [X] Filtrer les cafés selon les recettes et le type de point de vente (cafés, distributeurs, bars, etc.)

#### Coffee Tracker
- [x] Suivi de la consommation de café (log quand on prend un café : où, type, heure)
- [x] Statistiques personnelles sur la consommation (fréquence, types préférés)
- [x] Visualisation comme une app de temps d'écran
- [x] Visualisation de la limite recommandée de consommation de caféine
- [ ] Popup quand la limite de café est atteinte

#### Leaderboard Coffee Lovers
- [x] Comparaison de la consommation entre utilisateurs
- [x] Classement du nombre d'endroits différents visités
- [x] Classement des recettes goûtées

#### Profil
- [ ] Création et gestion de profil utilisateur
- [X] Badges des avancements de cafés (ex: "Caf'explorateur", "Latte Gourou", "Décaféiné")
- [ ] Animation de rotation des badges

## 🎨 Design

**Palette de couleurs** :
- Fond principal : Beige `#F5E6D3`
- Couleur principale : Marron café `#6B4423`
- Navigation : Beige foncé `#EDD5B8`

**Logo** : `logo-coffee-guru.png`

**Template Dribbble** : [Lien à ajouter]

## 🔑 API/Credentials

_Instructions pour les clés API seront ajoutées lors de l'intégration_

Clés potentiellement nécessaires :
- Google Maps API (pour la carte)
- Google Places API (pour les cafés à proximité)
- Firebase (si utilisé pour le backend)

## 📸 Screenshots

_Screenshots à venir après développement des fonctionnalités_

## 🧪 Tests

```bash
# Lancer les tests
flutter test
```

_Tests à implémenter_

## 📝 Difficultés rencontrées

_Section à compléter au fur et à mesure du développement_

1. 
2. 
3. 

## 🔄 Workflow Git

### Branches
- `main` : Branche principale (code stable, protégée)
- `develop` : Branche de développement
- `feature/nom-feature` : Branches pour chaque fonctionnalité

### Processus de Pull Request
1. Créer une branche depuis `develop` : `git checkout -b feature/ma-fonctionnalite`
2. Développer la fonctionnalité avec commits réguliers
3. Push de la branche : `git push origin feature/ma-fonctionnalite`
4. Créer une Pull Request vers `develop` sur GitHub
5. **Code review obligatoire** par l'autre membre
6. Appliquer les modifications demandées si nécessaire
7. Merge après validation (minimum 3 PR reviewées par membre)

### Commits
- Messages en français
- Format : `type: description courte`
- Types : `feat`, `fix`, `docs`, `style`, `refactor`, `test`

Exemples :
```
feat: ajoute la page de carte avec Google Maps
fix: corrige le calcul de caféine dans le tracker
docs: met à jour le README avec les instructions d'installation
```

## 📦 Dépendances actuelles

```yaml
dependencies:
  flutter:
    sdk: flutter
  font_awesome_flutter: ^10.9.1
  dio: ^5.9.0
  google_fonts: ^6.3.2
  share_plus: ^12.0.1
  url_launcher: ^6.3.2
```

_Dépendances à ajouter selon les besoins_

---

**Version** : 0.1.0  
**Date de création** : Janvier 2026  
**Cours** : TP5 - Projet Flutter en binôme

