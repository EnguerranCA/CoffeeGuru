# 📋 TODO Coffee Guru

## 🎯 Objectifs du TP5

### Orientation Équilibrée - Contraintes à respecter

#### Fonctionnel (minimum 2/4)
1. [ ] **Stockage persistant**
   - Choix : SharedPreferences / Hive / SQLite / Firebase
   - Utilisation : Sauvegarder les cafés loggés, profil utilisateur, favoris
   
   
4. [ ] **Package pub.dev**
   - Maps : google_maps_flutter / flutter_map
   - Charts : fl_chart / charts_flutter
   - Autres : geolocator, intl, etc.

#### Design
2. [ ] **Animations**
   - Hero animations entre pages
   - AnimatedContainer pour les transitions
   - Rotation des badges (mentionné dans les specs)
   - Transitions fluides dans la navigation
   
3. [ ] **Mode light et dark**
   - Switch dans les paramètres
   - Sauvegarder la préférence
   - Adapter tous les composants

---

## 📱 Fonctionnalités par Page

### 1. Coffee Map (Map Page)
- [ ] Intégrer Google Maps ou équivalent
- [ ] Afficher la position de l'utilisateur
- [ ] Markers pour les cafés à proximité
- [ ] Filtres :
  - [ ] Par type de recette (espresso, latte, cappuccino, etc.)
  - [ ] Par type de lieu (café, distributeur, bar, restaurant)
- [ ] Fiche détail d'un café :
  - [ ] Nom, adresse, horaires
  - [ ] Note moyenne
  - [ ] Commentaires des utilisateurs
- [ ] Ajouter un avis (note + commentaire)
- [ ] Calculer la distance depuis la position actuelle

**Branches suggérées** :
- `feature/map-integration`
- `feature/map-markers`
- `feature/map-filters`
- `feature/cafe-detail-page`

---

### 2. Coffee Tracker (Tracker Page)
- [ ] Bouton pour logger un café
- [ ] Formulaire de log :
  - [ ] Type de café (liste déroulante)
  - [ ] Lieu (sélection depuis la carte ou saisie manuelle)
  - [ ] Heure (auto ou manuelle)
  - [ ] Taille (small, medium, large)
  - [ ] Photo (optionnel)
- [ ] Calcul de la caféine consommée (mg)
  - Espresso : ~63mg
  - Americano : ~77mg
  - Latte : ~77mg
  - Cappuccino : ~77mg
  - Cold brew : ~200mg
- [ ] Visualisation style "temps d'écran" :
  - [ ] Graphique journalier
  - [ ] Graphique hebdomadaire
  - [ ] Graphique mensuel
- [ ] Statistiques personnelles :
  - [ ] Nombre de cafés aujourd'hui/semaine/mois
  - [ ] Type de café préféré
  - [ ] Lieu préféré
  - [ ] Heure moyenne de consommation
- [ ] Limite de caféine recommandée : 400mg/jour
  - [ ] Barre de progression
  - [ ] Popup d'alerte si dépassement
- [ ] Historique des cafés consommés (liste)
- [ ] Possibilité de supprimer/modifier un log

**Branches suggérées** :
- `feature/coffee-logger`
- `feature/caffeine-calculator`
- `feature/tracker-statistics`
- `feature/tracker-charts`

---

### 3. Leaderboard (Leaderboard Page)
- [ ] Classement par nombre de cafés consommés
- [ ] Classement par nombre de lieux différents visités
- [ ] Classement par nombre de recettes goûtées
- [ ] Filtres :
  - [ ] Cette semaine
  - [ ] Ce mois
  - [ ] Tout le temps
- [ ] Affichage du rang de l'utilisateur
- [ ] Podium top 3 (avec animation)
- [ ] Liste complète des utilisateurs
- [ ] Badges visibles dans le classement

**Branches suggérées** :
- `feature/leaderboard-ranking`
- `feature/leaderboard-filters`
- `feature/leaderboard-animations`

---

### 4. Profil (Profile Page)
- [ ] Informations utilisateur :
  - [ ] Avatar (photo ou icône)
  - [ ] Nom/Pseudo
  - [ ] Email
  - [ ] Date d'inscription
- [ ] Statistiques personnelles résumées :
  - [ ] Total de cafés consommés
  - [ ] Nombre de lieux visités
  - [ ] Nombre de recettes goûtées
  - [ ] Badge du moment
- [ ] Système de badges :
  - [ ] "Caf'explorateur" : Visiter 5 lieux différents
  - [ ] "Latte Gourou" : Boire 10 lattes
  - [ ] "Décaféiné" : Ne pas dépasser 200mg/jour pendant 7 jours
  - [ ] "Marathonien" : Boire 30 cafés en un mois
  - [ ] "Connaisseur" : Goûter 10 recettes différentes
  - [ ] Animation de rotation des badges
  - [ ] Affichage des badges débloqués vs verrouillés
- [ ] Paramètres :
  - [ ] Modifier le profil
  - [ ] Switch mode sombre/clair
  - [ ] Choix de la langue (FR/EN)
  - [ ] Notifications (activer/désactiver)
  - [ ] Unités (ml, oz)
- [ ] Bouton de déconnexion (si authentification)

**Branches suggérées** :
- `feature/profile-info`
- `feature/badges-system`
- `feature/profile-settings`
- `feature/theme-switcher`

---

## 🎨 Design & UX

### Thème
- [x] Couleurs définies (beige #F5E6D3, marron #6B4423)
- [x] Logo intégré (logo-coffee-guru.png)
- [ ] Polices personnalisées (Google Fonts)
- [ ] Mode sombre complet
- [ ] Transitions cohérentes

### Animations
- [ ] Hero animations
- [ ] Page transitions
- [ ] Rotation des badges
- [ ] Loading animations
- [ ] Success/Error feedback

### Template Dribbble
- [ ] Trouver un template coffee app
- [ ] S'inspirer pour le design des pages
- [ ] Adapter au projet
- [ ] Lien dans le README

---

## 🔧 Architecture & Code

### Structure des dossiers
- [x] `lib/pages/` : Pages principales
- [ ] `lib/models/` : Modèles de données
  - [ ] coffee.dart
  - [ ] user.dart
  - [ ] badge.dart
  - [ ] cafe.dart
- [ ] `lib/services/` : Services
  - [ ] cafe_service.dart (API)
  - [ ] storage_service.dart (local)
  - [ ] auth_service.dart (si auth)
- [ ] `lib/widgets/` : Widgets réutilisables
  - [ ] coffee_card.dart
  - [ ] badge_widget.dart
  - [ ] stats_chart.dart
- [ ] `lib/utils/` : Utilitaires
  - [ ] constants.dart
  - [ ] caffeine_calculator.dart
- [ ] `lib/l10n/` : Traductions (si i18n)

### Services à créer
- [ ] **CafeService** : Gestion des cafés (API)
- [ ] **CoffeeLogService** : Gestion des logs de café
- [ ] **StorageService** : Persistance des données
- [ ] **BadgeService** : Logique des badges
- [ ] **LeaderboardService** : Classements

### Modèles à créer
- [ ] **Coffee** : Un café consommé (type, lieu, heure, caféine)
- [ ] **Cafe** : Un lieu (nom, adresse, coordonnées)
- [ ] **User** : Utilisateur (nom, avatar, stats)
- [ ] **Badge** : Un badge (nom, description, icône, débloqué)

---

## 📦 Packages à ajouter

### Maps
```yaml
google_maps_flutter: ^2.5.0  # ou
flutter_map: ^6.0.0
```

### Charts
```yaml
fl_chart: ^0.65.0
```

### Géolocalisation
```yaml
geolocator: ^10.1.0
location: ^5.0.0
```

### Stockage
```yaml
shared_preferences: ^2.2.2  # ou
hive: ^2.2.3
hive_flutter: ^1.1.0
```

### Internationalization
```yaml
flutter_localizations:
  sdk: flutter
intl: ^0.18.1
```

### Images
```yaml
image_picker: ^1.0.5
cached_network_image: ^3.3.0
```

### Animations
```yaml
lottie: ^2.7.0
```

### Autres
```yaml
provider: ^6.1.1  # Gestion d'état
http: ^1.1.2  # Requêtes HTTP alternatives à Dio
```

---

## 🧪 Tests (Bonus +1.5 points)

### Tests unitaires (5-10 minimum)
- [ ] Test du calcul de caféine
- [ ] Test de la logique des badges
- [ ] Test des services
- [ ] Test des modèles

### Tests de widgets (5-10 minimum)
- [ ] Test de la navigation
- [ ] Test des boutons
- [ ] Test des formulaires
- [ ] Test de l'affichage des données

---

## 📚 Documentation

### README.md
- [x] Structure de base
- [ ] Ajouter screenshots
- [ ] Compléter section API/Credentials
- [ ] Ajouter lien template Dribbble
- [ ] Documenter difficultés rencontrées

### Code
- [ ] Commenter les parties complexes
- [ ] Documentation des méthodes publiques
- [ ] Explications des choix techniques

### Vidéo de démo (2-3 min)
- [ ] Filmer l'application en fonctionnement
- [ ] Présenter les fonctionnalités principales
- [ ] Uploader sur YouTube ou dans le repo
- [ ] Lien dans le README

---

## 🔄 Git & Collaboration

### Configuration
- [ ] Repository GitHub créé
- [ ] Branche main protégée
- [ ] Branche develop créée
- [ ] .gitignore configuré

### Pull Requests
- [ ] Membre 1 : 3+ PR créées
- [ ] Membre 1 : 3+ PR reviewées
- [ ] Membre 2 : 3+ PR créées
- [ ] Membre 2 : 3+ PR reviewées

### Commits
- [ ] Messages clairs et en français
- [ ] Format type: description
- [ ] Commits réguliers

---

## 📅 Planning suggéré

### Séance 1 (4h)
- [x] Setup du projet
- [x] Structure de base
- [ ] Choisir et répartir les tâches
- [ ] Commencer l'intégration de la carte
- [ ] Commencer le tracker de base

### Séance 2 (4h)
- [ ] Continuer les fonctionnalités principales
- [ ] Intégrer le stockage persistant
- [ ] Commencer le design avancé
- [ ] Première série de PR

### Hors séances
- [ ] Peaufiner le design
- [ ] Ajouter les animations
- [ ] Implémenter le mode sombre/i18n
- [ ] Tests (si bonus)
- [ ] Documentation finale
- [ ] Vidéo de démo

---

## ⚠️ Checklist avant rendu

- [ ] L'application compile sans erreur
- [ ] Toutes les pages sont fonctionnelles
- [ ] Minimum 2 contraintes fonctionnelles respectées
- [ ] Minimum 2 contraintes design respectées
- [ ] README complet avec screenshots
- [ ] Vidéo de démo uploadée
- [ ] Repository accessible
- [ ] 3+ PR reviewées par membre
- [ ] Pas de clés API/secrets commitées
- [ ] Code propre et commenté

---

**Bon courage pour le développement ! ☕🚀**
