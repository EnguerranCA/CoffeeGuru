import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/cafe_place.dart';
import '../models/coffee_log.dart';
import '../services/cafe_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final CafeService _cafeService = CafeService();
  
  LatLng _currentLocation = const LatLng(48.8566, 2.3522); // Paris par défaut
  List<Cafe> _cafes = [];
  bool _isLoading = true;
  bool _hasUserLocation = false; // Indique si la position a été récupérée
  bool _mapReady = false; // Indique si la carte est prête
  String? _errorMessage;
  
  // Filtres
  Set<CafeType> _selectedCafeTypes = Set.from(CafeType.values); // Tous sélectionnés par défaut
  Set<CoffeeType> _selectedCoffeeTypes = {}; // Aucun sélectionné par défaut
  double _maxDistanceKm = 10.0; // Distance max en km

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  /// Initialise la carte : récupère la position et charge les cafés
  Future<void> _initializeMap() async {
    // Lancer la récupération de position en arrière-plan (sans attendre)
    _getCurrentLocation();
    
    // Charger immédiatement les cafés avec la position par défaut
    await _loadCafes();
  }

  /// Récupère la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Permission de localisation refusée';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Permission de localisation refusée définitivement';
        });
        return;
      }

      // 1. Utiliser d'abord la dernière position connue (instantané)
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        setState(() {
          _currentLocation = LatLng(lastKnown.latitude, lastKnown.longitude);
          _hasUserLocation = true;
        });
        if (_mapReady) {
          _mapController.move(_currentLocation, 14.0);
        }
        // Recharger les cafés avec la nouvelle position
        _loadCafes();
      }

      // 2. Ensuite, récupérer la position précise (en arrière-plan) avec timeout
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Position timeout');
          },
        );

        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _hasUserLocation = true;
        });

        // Centrer la carte sur la position si elle est prête
        if (_mapReady) {
          _mapController.move(_currentLocation, 14.0);
        }
        
        // Recharger les cafés avec la position précise
        _loadCafes();
      } on TimeoutException {
        // Timeout - on garde la position lastKnown
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de localisation: $e';
      });
    }
  }

  /// Charge les cafés depuis le service
  Future<void> _loadCafes() async {
    try {
      await _cafeService.loadCafesFromAPI(_currentLocation);
      final cafes = await _cafeService.getCafesNearby(_currentLocation, radiusKm: 10);
      setState(() {
        _cafes = cafes;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Erreur de chargement des cafés: $e';
        _isLoading = false;
      });
    }
  }

  /// Applique les filtres sélectionnés
  Future<void> _applyFilters() async {
    List<Cafe> filteredCafes = await _cafeService.getAllCafes();
    
    setState(() {
      // Filtre par distance
      if (_hasUserLocation) {
        filteredCafes = filteredCafes.where((cafe) =>
          cafe.distanceFrom(_currentLocation) <= _maxDistanceKm
        ).toList();
      }
      
      // Filtre par type d'établissement (seulement si pas tout sélectionné)
      if (_selectedCafeTypes.length < CafeType.values.length) {
        filteredCafes = filteredCafes.where((cafe) =>
          _selectedCafeTypes.contains(cafe.type)
        ).toList();
      }
      
      // Filtre par type de café (seulement si au moins un type est sélectionné)
      if (_selectedCoffeeTypes.isNotEmpty) {
        filteredCafes = filteredCafes.where((cafe) {
          // Le café doit avoir au moins un des types sélectionnés
          return cafe.availableCoffeeTypes.any((type) => _selectedCoffeeTypes.contains(type));
        }).toList();
      }
      
      _cafes = filteredCafes;
    });
  }

  /// Affiche le dialog de filtres
  void _showFiltersDialog() {
    // Variables locales pour le dialog
    double tempDistance = _maxDistanceKm;
    Set<CafeType> tempCafeTypes = Set.from(_selectedCafeTypes);
    Set<CoffeeType> tempCoffeeTypes = Set.from(_selectedCoffeeTypes);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF5E6D3),
          title: const Text(
            'Filtres',
            style: TextStyle(color: Color(0xFF6B4423)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtre par distance
                const Text(
                  '📍 Distance maximale',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4423),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempDistance,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        activeColor: const Color(0xFF6B4423),
                        onChanged: (value) {
                          setDialogState(() {
                            tempDistance = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4423).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${tempDistance.round()} km',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Filtres par type d'établissement
                const Text(
                  '🏪 Type d\'établissement',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4423),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: CafeType.values.map((type) {
                    final isSelected = tempCafeTypes.contains(type);
                    return FilterChip(
                      label: Text('${type.emoji} ${type.displayName}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            tempCafeTypes.add(type);
                          } else {
                            tempCafeTypes.remove(type);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF6B4423).withOpacity(0.3),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Filtres par type de café
                const Text(
                  '☕ Type de café',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4423),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: CoffeeType.values.map((type) {
                    final isSelected = tempCoffeeTypes.contains(type);
                    return FilterChip(
                      label: Text('${type.emoji} ${type.displayName}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            tempCoffeeTypes.add(type);
                          } else {
                            tempCoffeeTypes.remove(type);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF6B4423).withOpacity(0.3),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Réinitialiser les filtres
                setDialogState(() {
                  tempDistance = 10.0;
                  tempCafeTypes = Set.from(CafeType.values);
                  tempCoffeeTypes = {}; // Aucun type de café sélectionné par défaut
                });
              },
              child: const Text(
                'Réinitialiser',
                style: TextStyle(color: Color(0xFF6B4423)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _maxDistanceKm = tempDistance;
                  _selectedCafeTypes = tempCafeTypes;
                  _selectedCoffeeTypes = tempCoffeeTypes;
                });
                _applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4423),
                foregroundColor: Colors.white,
              ),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Coffee Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_currentLocation, 15.0);
            },
            tooltip: 'Ma position',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              interactionOptions: InteractionOptions(
                flags: ~InteractiveFlag.rotate,
              ),
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onMapReady: () {
                setState(() {
                  _mapReady = true;
                });
                // Centrer sur la position utilisateur si déjà disponible
                if (_hasUserLocation) {
                  _mapController.move(_currentLocation, 14.0);
                }
              },
            ),
            children: [
              // Tuiles de la carte
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              
              // Markers
              MarkerLayer(
                markers: [
                  // Marker de la position actuelle (si disponible)
                  if (_hasUserLocation) _buildUserLocationMarker(),
                  
                  // Markers des cafés
                  ..._buildCafeMarkers(),
                ],
              ),
            ],
          ),

          // Indicateur de chargement
          if (_isLoading)
            Container(
              color: const Color(0xFFF5E6D3).withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B4423)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chargement de la carte...',
                      style: TextStyle(
                        color: Color(0xFF6B4423),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Message d'erreur
          if (_errorMessage != null && !_isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Compteur de cafés en bas
          if (!_isLoading)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_cafe,
                      color: Color(0xFF6B4423),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_cafes.length} café${_cafes.length > 1 ? 's' : ''} à proximité',
                      style: const TextStyle(
                        color: Color(0xFF6B4423),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construit le marker de la position utilisateur
  Marker _buildUserLocationMarker() {
    return Marker(
      point: _currentLocation,
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6B4423).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_pin_circle,
          color: Color(0xFF6B4423),
          size: 40,
        ),
      ),
    );
  }

  /// Construit les markers des cafés
  List<Marker> _buildCafeMarkers() {
    return _cafes.map((cafe) {
      return Marker(
        point: cafe.location,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showCafeInfo(cafe),
          child: Container(
            decoration: BoxDecoration(
              color: _getCafeColor(cafe.type),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getCafeIcon(cafe.type),
              color: const Color(0xFFF5E6D3),
              size: 24,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Retourne la couleur en fonction du type de café
  Color _getCafeColor(CafeType type) {
    switch (type) {
      case CafeType.cafe:
        return const Color(0xFF6B4423);
      case CafeType.restaurant:
        return const Color(0xFF8B5E3C);
      case CafeType.bar:
        return const Color(0xFFA0522D);
      case CafeType.vendingMachine:
        return const Color(0xFF5D4E37);
      case CafeType.bakery:
        return const Color(0xFFD2691E);
    }
  }

  /// Retourne l'icône en fonction du type de café
  IconData _getCafeIcon(CafeType type) {
    switch (type) {
      case CafeType.cafe:
        return Icons.local_cafe;
      case CafeType.restaurant:
        return Icons.restaurant;
      case CafeType.bar:
        return Icons.local_bar;
      case CafeType.vendingMachine:
        return Icons.coffee_maker;
      case CafeType.bakery:
        return Icons.bakery_dining;
    }
  }

  /// Affiche les informations d'un café
  void _showCafeInfo(Cafe cafe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5E6D3),
        title: Row(
          children: [
            Text(cafe.type.emoji),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cafe.name,
                style: const TextStyle(color: Color(0xFF6B4423)),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Distance
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Color(0xFF6B4423)),
                  const SizedBox(width: 4),
                  Text(
                    cafe.distanceTextFrom(_currentLocation),
                    style: const TextStyle(color: Color(0xFF6B4423)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Adresse
              Text(
                cafe.address,
                style: const TextStyle(color: Color(0xFF6B4423)),
              ),
              const SizedBox(height: 12),
              
              // Types de café disponibles
              if (cafe.availableCoffeeTypes.isNotEmpty) ...[
                const Text(
                  'Cafés disponibles :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4423),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: cafe.availableCoffeeTypes.map((type) {
                    return Chip(
                      label: Text(
                        '${type.emoji} ${type.displayName}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: const Color(0xFF6B4423).withOpacity(0.2),
                      padding: const EdgeInsets.all(4),
                    );
                  }).toList(),
                ),
              ],

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Color(0xFF6B4423)),
            ),
          ),
        ],
      ),
    );
  }
}
