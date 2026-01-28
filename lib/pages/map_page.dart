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
  String? _errorMessage;
  
  // Filtres
  Set<CafeType> _selectedCafeTypes = {};
  Set<CoffeeType> _selectedCoffeeTypes = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  /// Initialise la carte : récupère la position et charge les cafés
  Future<void> _initializeMap() async {
    await _getCurrentLocation();
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
          if (mounted) {
            setState(() {
              _errorMessage = 'Permission de localisation refusée';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Permission de localisation refusée définitivement';
          });
        }
        return;
      }

      // Récupérer la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        // Centrer la carte sur la position
        _mapController.move(_currentLocation, 13.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur de localisation: $e';
        });
      }
    }
  }

  /// Charge les cafés depuis le service
  Future<void> _loadCafes() async {
    try {
      await _cafeService.loadCafesFromAPI(_currentLocation);
      final cafes = await _cafeService.getCafesNearby(_currentLocation, radiusKm: 10);
      if (mounted) {
        setState(() {
          _cafes = cafes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur de chargement des cafés: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Applique les filtres sélectionnés
  Future<void> _applyFilters() async {
    List<Cafe> filteredCafes = await _cafeService.getAllCafes();
    
    if (mounted) {
      setState(() {
        // Filtre par type d'établissement
        if (_selectedCafeTypes.isNotEmpty) {
          filteredCafes = _cafeService.filterByType(_selectedCafeTypes.toList());
        }
        
        // Filtre par type de café
        if (_selectedCoffeeTypes.isNotEmpty) {
          filteredCafes = filteredCafes.where((cafe) =>
            cafe.availableCoffeeTypes.any((type) => _selectedCoffeeTypes.contains(type))
          ).toList();
        }
        
        _cafes = filteredCafes;
      });
    }
  }

  /// Affiche le dialog de filtres
  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              // Filtres par type d'établissement
              const Text(
                'Type d\'établissement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B4423),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: CafeType.values.map((type) {
                  final isSelected = _selectedCafeTypes.contains(type);
                  return FilterChip(
                    label: Text('${type.emoji} ${type.displayName}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCafeTypes.add(type);
                        } else {
                          _selectedCafeTypes.remove(type);
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
              final allCafes = await _cafeService.getAllCafes();
              if (mounted) {
                setState(() {
                  _selectedCafeTypes.clear();
                  _selectedCoffeeTypes.clear();
                  _cafes = allCafes;
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Réinitialiser',
              style: TextStyle(color: Color(0xFF6B4423)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
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
            ),
            children: [
              // Tuiles de la carte
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              
              // Markers
              MarkerLayer(
                markers: [
                  // Marker de la position actuelle
                  _buildUserLocationMarker(),
                  
                  // Markers des cafés
                  ..._buildCafeMarkers(),
                ],
              ),
            ],
          ),

          // Indicateur de chargement
          if (_isLoading)
            Container(
              color: const Color(0xFFF5E6D3).withOpacity(0.9),
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
