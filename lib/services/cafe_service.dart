import 'package:latlong2/latlong.dart';
import '../models/cafe_place.dart';

/// Service pour gérer les cafés
class CafeService {
  // Singleton pattern
  static final CafeService _instance = CafeService._internal();
  factory CafeService() => _instance;
  CafeService._internal();

  /// Liste des cafés (en mémoire pour l'instant)
  /// TODO: Remplacer par une API réelle ou une base de données locale
  List<Cafe> _cafes = [];

  /// Récupère tous les cafés
  List<Cafe> getAllCafes() {
    return List.unmodifiable(_cafes);
  }

  /// Récupère les cafés à proximité d'une position
  /// [position] Position de référence
  /// [radiusKm] Rayon de recherche en kilomètres
  List<Cafe> getCafesNearby(LatLng position, {double radiusKm = 5.0}) {
    return _cafes
        .where((cafe) => cafe.distanceFrom(position) <= radiusKm)
        .toList()
      ..sort((a, b) =>
          a.distanceFrom(position).compareTo(b.distanceFrom(position)));
  }

  /// Filtre les cafés par type d'établissement
  List<Cafe> filterByType(List<CafeType> types) {
    if (types.isEmpty) return getAllCafes();
    return _cafes.where((cafe) => types.contains(cafe.type)).toList();
  }

  /// Filtre les cafés par types de café disponibles
  List<Cafe> filterByCoffeeType(List<CoffeeType> coffeeTypes) {
    if (coffeeTypes.isEmpty) return getAllCafes();
    return _cafes
        .where((cafe) => cafe.availableCoffeeTypes
            .any((type) => coffeeTypes.contains(type)))
        .toList();
  }

  /// Recherche un café par nom
  List<Cafe> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return _cafes
        .where((cafe) => cafe.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Récupère un café par son ID
  Cafe? getCafeById(String id) {
    try {
      return _cafes.firstWhere((cafe) => cafe.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Charge les cafés de démonstration
  /// TODO: Remplacer par un vrai appel API
  Future<void> loadDemoCafes(LatLng centerPosition) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));

    _cafes = [
      Cafe(
        id: '1',
        name: 'Café des Arts',
        address: '15 Rue de la Paix, Paris',
        location: LatLng(
          centerPosition.latitude + 0.01,
          centerPosition.longitude + 0.01,
        ),
        availableCoffeeTypes: [
          CoffeeType.espresso,
          CoffeeType.cappuccino,
          CoffeeType.latte,
          CoffeeType.mocha,
        ],
        type: CafeType.cafe,
      ),
      Cafe(
        id: '2',
        name: 'Le Petit Torréfacteur',
        address: '8 Avenue des Champs',
        location: LatLng(
          centerPosition.latitude - 0.01,
          centerPosition.longitude + 0.015,
        ),
        availableCoffeeTypes: [
          CoffeeType.espresso,
          CoffeeType.americano,
          CoffeeType.flatWhite,
          CoffeeType.coldBrew,
        ],
        type: CafeType.cafe,
      ),
      Cafe(
        id: '3',
        name: 'Coffee Corner',
        address: '42 Boulevard Saint-Germain',
        location: LatLng(
          centerPosition.latitude + 0.015,
          centerPosition.longitude - 0.01,
        ),
        availableCoffeeTypes: [
          CoffeeType.espresso,
          CoffeeType.cappuccino,
          CoffeeType.latte,
          CoffeeType.frappe,
          CoffeeType.decaf,
        ],
        type: CafeType.bar,
      ),
      Cafe(
        id: '4',
        name: 'Boulangerie du Coin',
        address: '3 Rue du Four',
        location: LatLng(
          centerPosition.latitude - 0.008,
          centerPosition.longitude - 0.012,
        ),
        availableCoffeeTypes: [
          CoffeeType.espresso,
          CoffeeType.cappuccino,
        ],
        type: CafeType.bakery,
      ),
      Cafe(
        id: '5',
        name: 'Distributeur Gare du Nord',
        address: 'Gare du Nord, Hall principal',
        location: LatLng(
          centerPosition.latitude + 0.02,
          centerPosition.longitude + 0.005,
        ),
        availableCoffeeTypes: [
          CoffeeType.espresso,
          CoffeeType.cappuccino,
          CoffeeType.decaf,
        ],
        type: CafeType.vendingMachine,
      ),
    ];
  }

  /// TODO: Récupérer les endroits depuis la base de l'appi sur supabase
  Future<void> loadCafesFromAPI(LatLng position) async {
    // TODO: Appel API réel
    // Exemple avec Google Places :
    // final response = await dio.get(
    //   'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
    //   queryParameters: {
    //     'location': '${position.latitude},${position.longitude}',
    //     'radius': 5000,
    //     'type': 'cafe',
    //     'key': apiKey,
    //   },
    // );

    // Pour l'instant, on utilise les données de démo
    await loadDemoCafes(position);
  }

  /// Ajoute un nouveau café (pour admin ou contribution utilisateur)
  void addCafe(Cafe cafe) {
    _cafes.add(cafe);
  }

  /// Supprime un café
  void removeCafe(String id) {
    _cafes.removeWhere((cafe) => cafe.id == id);
  }

  /// Met à jour un café
  void updateCafe(Cafe updatedCafe) {
    final index = _cafes.indexWhere((cafe) => cafe.id == updatedCafe.id);
    if (index != -1) {
      _cafes[index] = updatedCafe;
    }
  }

  /// Nettoie les données
  void clearCafes() {
    _cafes.clear();
  }
}
