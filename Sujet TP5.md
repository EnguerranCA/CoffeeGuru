# 🧱 TP5 – Projet final en binôme

## 🎯 Objectifs
- Concevoir et développer une **application Flutter complète en binôme**
- Appliquer l'ensemble des notions vues dans les TPs précédents et plus encore
- Faire des choix techniques et architecturaux
- Travailler en équipe avec Git
- Produire une application fonctionnelle et/ou esthétique selon vos objectifs

🕐 **Durée estimée : 4 heures et plus** (sur 2 séances minimum)

---

## 👥 Organisation

- **Travail en binôme**
- **Dépôt GitHub** : Le projet doit être hébergé sur GitHub avec historique des commits des deux membres
- **Choix libre du sujet** : Vous êtes libres de choisir le thème de votre application (réseau social, e-commerce, productivité, jeu, etc.)
- **Choix d'orientation** : Vous devez choisir une des trois orientations ci-dessous

---

## 🎯 Trois orientations possibles

Vous devez choisir **UNE** des trois orientations suivantes pour votre projet :

### 📊 Option 1 : Riche en fonctionnel
**Focus : Aspect métier et technique fort (elle peut êre vraiment moche ca ne me dérange pas)**

Votre application doit respecter **TOUTES** les contraintes suivantes :
- ✅ Un aspect **métier fort** avec logique complexe (calculs, algorithmes, workflows)
- ✅ Utilisation de **stockage persistant** (local avec SharedPreferences/Hive/SQLite ou Firebase/Supabase)
- ✅ Intégration d'**au moins un package** de pub.dev (hors stockage) pertinent pour votre métier
- ✅ Consommation d'**une API** (publique, créée par vous, ou utilisation de Firebase/Supabase)

> **💡 Pourquoi cette option ?**
> Si vous aimez la logique, les algorithmes et résoudre des problèmes techniques complexes, cette option est pour vous. Vous allez créer une app avec une vraie "intelligence" métier (calculs, traitements de données, workflows), pas juste afficher des listes. Le design peut rester simple.

### 💡 Besoin d'inspiration ? 5 idées de projets fonctionnels

1. **Gestionnaire de budget personnel** - Suivi des dépenses par catégorie, graphiques, export PDF, API de conversion de devises
2. **Application de suivi d'habitudes** - Création d'habitudes, système de streaks, statistiques, notifications de rappel
3. **Gestionnaire de recettes avec liste de courses** - Base de données de recettes, calcul de quantités, génération automatique de liste, API spoonacular
4. **App de révision avec flashcards** - Système de répétition espacée (SM-2), catégories, statistiques, import/export
5. **Gestionnaire de bibliothèque personnelle** - Scan ISBN, suivi de lecture, statistiques annuelles, API Open Library

#### 🌟 Les idées originales
- **App anti-gaspillage alimentaire** - Scan de tickets de caisse, alertes avant péremption, suggestions de recettes avec les restes, statistiques de gaspillage en € et kg, API de recettes anti-gaspi
- **Traducteur médical/administratif** - Convertit le jargon médical/légal en français simple, explications visuelles, OCR pour documents papier, API de définitions médicales

---

### 🎨 Option 2 : Riche en design
**Focus : Interface utilisateur et expérience visuelle (intéractive quand même mais vous pouvez mettre du bullshit en données si ca vous fait plaisir)**

Votre application doit respecter **TOUTES** les contraintes suivantes :
- ✅ Design basé sur un **template mobile Dribbble** (avec lien dans le README)
- ✅ Utilisation d'**images** (assets locaux ou réseau) de manière cohérente
- ✅ Mise en place de **i18n** (internationalisation) avec au moins 2 langues
- ✅ Intégration d'**animations** (Hero, AnimatedContainer, Lottie, etc.)
- ✅ Gestion du **thème avancé** avec mode **light** et **dark** (switch dans paramètres, sauvegarde de la préférence, toute l'app s'adapte)

> **💡 Pourquoi cette option ?**
> Si vous aimez le design, les belles interfaces et l'expérience utilisateur, cette option est idéale. Vous allez reproduire un design pro de Dribbble et le rendre vivant avec des animations. La logique métier peut rester basique (affichage de listes, navigation simple).

### 💡 Besoin d'inspiration ? 5 idées de projets design

1. **Portfolio créatif animé** - Présentation de projets avec Hero animations, transitions fluides, thème dark/light adaptatif, multilingue
2. **Application de méditation** - Design zen avec animations Lottie, sons d'ambiance, timer personnalisable, mode jour/nuit pour confort visuel, i18n FR/EN
3. **Galerie d'art moderne** - Grille/liste de photos, zoom animé, filtres par catégorie, transitions Hero entre vues, thème sombre pour mettre en valeur les œuvres
4. **App de mode/lookbook** - Catalogues de vêtements, carousel animé, filtres visuels, thème clair/sombre selon l'heure, changement de langue dynamique
5. **Journal intime visuel** - Design élégant avec animations d'écriture, mode lecture de nuit, thèmes personnalisables avec couleurs adaptatives, photos, i18n

#### 🌟 Les idées originales
- **App de suivi de sommeil visuel** - Graphiques de cycles en paysages nocturnes, animations jour/nuit, journal de rêves avec mood colors, thème adaptatif à l'heure
- **App d'hydratation gamifiée** - Visualisation de remplissage avec animations fluides, plante virtuelle qui pousse avec l'hydratation, Hero animations, thème océanique light/dark, multilingue

---

### ⚖️ Option 3 : Équilibrée
**Focus : Mix entre fonctionnel et design (ma partie préférée)**

Votre application doit respecter :
- ✅ **Au moins 2 contraintes** de l'option "Riche en fonctionnel"
- ✅ **Au moins 2 contraintes** de l'option "Riche en design"
- Un respect de TOUTES les contraintes des autres parties = 1 point bonus directement (car respect)

> **💡 Pourquoi cette option ?**
> C'est l'option "tout terrain" pour ceux qui veulent un bon équilibre. Vous aurez une app fonctionnelle ET jolie, sans aller à l'extrême dans l'un ou l'autre. Idéal pour un profil généraliste ou si vous êtes deux avec des compétences complémentaires (un dev, un designer).

### 💡 Besoin d'inspiration ? 5 idées de projets équilibrés

1. **Application météo complète** - API OpenWeather, stockage favoris local, design animé avec icônes Lottie, mode sombre, multilingue
2. **App de streaming musical** - API Spotify/Deezer, player avec animations, playlists sauvegardées, design moderne, i18n
3. **Réseau social de photos** - Firebase pour stockage, timeline avec animations, filtres, likes/commentaires, design inspiré Instagram
4. **Application de voyage/exploration** - API Google Places ou TripAdvisor, sauvegarde des destinations favorites, design moderne avec maps animées, filtres par catégorie, multilingue
5. **App de fitness tracker** - Stockage local des entraînements, graphiques de progression, design motivant avec animations, API nutrition

#### 🌟 Les idées originales
- **Comparateur de prix courses** - Scan de code-barres, comparaison automatique entre magasins (API), historique des prix, alertes promotions, liste optimisée par magasin, visualisation graphique des économies
- **Gestionnaire de prêts entre proches** - Liste de qui a emprunté quoi avec photos, rappels de retour, historique complet, notation d'état, calcul de valeur en cas de casse, design ludique

---

## 📋 Livrables obligatoires

### 1. **Dépôt GitHub**
- Repository public ou privé (avec accès enseignant)
- README complet (voir section ci-dessous)
- `.gitignore` Flutter configuré
- Historique Git propre avec commits des deux membres

### 2. **README.md détaillé**
Votre README doit contenir :
```markdown
# Nom du Projet

## 👥 Équipe
- Prénom Nom (email)
- Prénom Nom (email)

## 📱 Description
[Description du projet en 3-5 phrases]

## 🎯 Orientation choisie
[Riche en fonctionnel / Riche en design / Équilibrée]

## ✅ Contraintes respectées
- [ ] Contrainte 1
- [ ] Contrainte 2
- [ ] Contrainte 3
- [ ] Contrainte 4

## 🚀 Installation
[Instructions pour lancer le projet]

## 📸 Screenshots
[3-5 captures d'écran de l'application]

## 🎨 Design (si applicable)
[Lien vers le template Dribbble utilisé]

## 🔑 API/Credentials (si applicable)
[Instructions pour obtenir les clés API nécessaires]

## 🧪 Tests
[Commande pour lancer les tests s'il y en a]

## 📝 Difficultés rencontrées
[2-3 défis techniques que vous avez surmontés]
```

### 3. **Vidéo de démonstration (2-3 minutes)**
- Présentation rapide de l'application
- Démonstration des fonctionnalités principales
- Format : MP4, lien YouTube
- Uploadée sur le dépôt ou lien dans le README

### 4. **Code source**
- Structure claire : `lib/models/`, `lib/services/`, `lib/pages/`, `lib/widgets/`
- Code commenté aux endroits stratégiques
- Respect des conventions Dart/Flutter
- Pas de code mort ou commenté en masse

### 5. **Revue de code entre membres du binôme**
Les deux membres doivent se faire des **code reviews mutuelles** via GitHub :

> **💡 Pourquoi les code reviews ?**
> Les **code reviews** sont une pratique pro essentielle : un autre développeur lit votre code avant de l'intégrer. Ça permet de :
> - Détecter des bugs tôt
> - Partager les connaissances dans l'équipe
> - Améliorer la qualité du code
> - S'assurer que tout le monde comprend le code
>
> C'est un peu comme une relecture avant de publier un article !

**Comment procéder** :
1. Chaque membre travaille sur sa branche (`feature/login`, `feature/home`, etc.)
2. Avant de merger dans `main`, créer une **Pull Request**
3. L'autre membre review la PR en laissant des commentaires
4. Discuter des changements et les appliquer si nécessaire
5. Merger seulement après validation

**Ce qui sera évalué** :
- Présence de **Pull Requests** avec reviews dans l'historique GitHub
- Commentaires constructifs sur le code de l'autre
- Modifications apportées suite aux reviews
- Au moins **3 PR reviewées par membre** minimum

---

## 🧮 Barème de notation (/20)

| Critère | Détails | Points |
|----------|----------|--------|
| **Respect des contraintes** | Toutes les contraintes de l'orientation choisie sont respectées | 5 |
| **Fonctionnalités** | L'application fonctionne sans crash, features complètes | 3 |
| **Architecture et code** | Structure claire, code propre, bonnes pratiques | 2 |
| **Design et UX** | Interface soignée, navigation fluide, cohérence visuelle | 2 |
| **Travail d'équipe et revues** | Commits équilibrés, Pull Requests reviewées (min 3 par membre) | 3 |
| **Documentation** | README complet, code commenté, instructions claires | 2 |
| **Originalité et ambition** | Innovation, complexité du projet, features supplémentaires | 2 |
| **Vidéo de démo** | Présentation claire, exhaustive et professionnelle | 1 |
| **Total** |  | **/20** |

---

### 🎁 Bonus (+1.5 points possibles)

#### Bonus : Tests unitaires et de widgets (+1.5 points)
Tests unitaires et widgets significatifs (minimum 5 à 10 tests par catégorie) couvrant les fonctionnalités principales de l'application.

---

## 💡 Conseils

### Git et collaboration
- Créez des **branches** pour chaque feature (`feature/login`, `feature/home-page`)
- Faites des **commits réguliers** avec des messages clairs
- Utilisez les **Pull Requests** pour review le code de l'autre
- Résolvez les conflits ensemble, ne forcez jamais un push

### Organisation du code
- Définissez l'architecture ensemble dès le début
- Utilisez des **widgets réutilisables** plutôt que de dupliquer du code
- Commentez les parties complexes

### Gestion du temps
- Ne soyez pas trop ambitieux : mieux vaut une app simple qui fonctionne bien qu'une app complexe buguée
- Priorisez les fonctionnalités : faites d'abord le MVP (Minimum Viable Product)
- Gardez du temps pour la documentation et la vidéo

### Choix techniques
- **Riche en fonctionnel** : Concentrez-vous sur la logique, le design peut être basique
- **Riche en design** : Choisissez un template réalisable, ne visez pas trop complexe
- **Équilibrée** : Trouvez le bon compromis, ne vous dispersez pas

### Ressources utiles
- **Templates Dribbble** : https://dribbble.com/search/mobile-app
- **APIs gratuites** : https://github.com/public-apis/public-apis
- **Icônes** : https://icons8.com/, https://www.flaticon.com/
- **Images** : https://unsplash.com/, https://www.pexels.com/
- **Animations Lottie** : https://lottiefiles.com/

---

## ⚠️ Pièges à éviter

- ❌ **Commits déséquilibrés** : Un membre fait tout le travail (ca se verra si c'est trop déséquilibré)
- ❌ **Pas de commits** : Tout le code est pushé d'un coup à la fin
- ❌ **Clés API commitées** : Utilisez `.gitignore` et des fichiers d'exemple
- ❌ **App qui ne build pas** : Testez régulièrement sur différents devices
- ❌ **README incomplet** : C'est la première chose qu'on regarde
- ❌ **Copier-coller sans comprendre** : Vous devez être capables d'expliquer votre code
- ❌ **Contraintes non respectées** : Vérifiez votre checklist avant le rendu

---

## 📤 Modalités de rendu

**Format du rendu** :
1. Lien vers le **repository GitHub** (déposé sur Moodle ou par email)
2. Lien vers la **vidéo de démonstration** (dans le README ou séparé)
3. **Aucune archive ZIP** : tout doit être sur GitHub

**Vérification avant rendu** :
- [x] Le dépôt est accessible (public ou accès donné)
- [x] Le README est complet
- [x] L'application builde et run sans erreur 
- [x] Au moins 2 Pull Requests reviewées par membre sont visibles
- [x] Toutes les contraintes de l'orientation choisie sont respectées
- [x] La vidéo est accessible et complète
- [x] Pas de fichiers sensibles commitées (clés API, .env)

---

## 🎉 Bon courage !

Ce TP final est l'occasion de montrer tout ce que vous avez appris et de créer quelque chose dont vous serez fiers.

N'oubliez pas : **une application simple et bien faite vaut mieux qu'une application complexe à moitié terminée**.

Soyez créatifs, collaborez efficacement, et amusez-vous ! 🚀