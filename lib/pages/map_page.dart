import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(45.8292, 1.2612); // Limoges par défaut
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Permission de localisation refusée';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Permission de localisation refusée définitivement';
          _isLoading = false;
        });
        return;
      }

      // Récupérer la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Centrer la carte sur la position
      _mapController.move(_currentLocation, 13.0);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
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
            onPressed: () {
              // TODO: Afficher les filtres
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtres à venir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
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
              // Tuiles de la carte avec style simple et clair
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
                // Style simple et flat
                tileBuilder: (context, widget, tile) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      const Color(0xFFF5E6D3).withOpacity(1.0),
                      BlendMode.lighten,
                    ),
                    child: widget,
                  );
                },
              ),

              // Marker de la position actuelle
              MarkerLayer(
                markers: [
                  Marker(
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
                  ),

                  // TODO: Ajouter des markers pour les cafés
                  // Exemple de markers fictifs
                  ..._getDemoCafeMarkers(),
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6B4423),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chargement de la carte...',
                      style: TextStyle(color: Color(0xFF6B4423), fontSize: 16),
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

          // Légende en bas
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_cafe, color: Color(0xFF6B4423), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cafés à proximité',
                    style: TextStyle(
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

  // Méthode pour générer des markers de démonstration
  List<Marker> _getDemoCafeMarkers() {
    // Quelques cafés de démo autour de la position actuelle
    final List<Map<String, dynamic>> demoCafes = [
      {
        'name': 'Café des Arts',
        'lat': _currentLocation.latitude + 0.01,
        'lng': _currentLocation.longitude + 0.01,
      },
      {
        'name': 'Le Petit Torréfacteur',
        'lat': _currentLocation.latitude - 0.01,
        'lng': _currentLocation.longitude + 0.015,
      },
      {
        'name': 'Coffee Corner',
        'lat': _currentLocation.latitude + 0.015,
        'lng': _currentLocation.longitude - 0.01,
      },
    ];

    return demoCafes.map((cafe) {
      return Marker(
        point: LatLng(cafe['lat'], cafe['lng']),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            _showCafeInfo(cafe['name']);
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6B4423),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_cafe,
              color: Color(0xFFF5E6D3),
              size: 24,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showCafeInfo(String name) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFF5E6D3),
            title: Row(
              children: [
                const Icon(Icons.local_cafe, color: Color(0xFF6B4423)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(color: Color(0xFF6B4423)),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Informations détaillées à venir...\n\n'
              '• Adresse\n'
              '• Horaires\n'
              '• Avis',
              style: TextStyle(color: Color(0xFF6B4423)),
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
