import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Résultat d'une recherche de géocodage
class GeocodingResult {
  final String displayName;
  final LatLng location;
  final String? street;
  final String? city;
  final String? country;

  GeocodingResult({
    required this.displayName,
    required this.location,
    this.street,
    this.city,
    this.country,
  });

  factory GeocodingResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    
    return GeocodingResult(
      displayName: json['display_name'] as String,
      location: LatLng(
        double.parse(json['lat'] as String),
        double.parse(json['lon'] as String),
      ),
      street: address['road'] as String?,
      city: address['city'] ?? address['town'] ?? address['village'] as String?,
      country: address['country'] as String?,
    );
  }
}

/// Service de géocodage utilisant l'API Nominatim (OpenStreetMap)
class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://nominatim.openstreetmap.org',
    headers: {
      'User-Agent': 'FlutterCoffeeApp/1.0', // Requis par Nominatim
    },
  ));

  /// Convertit une adresse en coordonnées GPS (géocodage)
  /// Retourne une liste de résultats possibles
  Future<List<GeocodingResult>> geocodeAddress(String address) async {
    if (address.isEmpty) return [];

    try {
      final response = await _dio.get('/search', queryParameters: {
        'q': address,
        'format': 'json',
        'addressdetails': 1,
        'limit': 5,
      });

      if (response.statusCode == 200 && response.data is List) {
        final results = response.data as List;
        return results
            .map((json) => GeocodingResult.fromNominatim(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Erreur de géocodage: $e');
      return [];
    }
  }

  /// Convertit une adresse en coordonnées GPS (retourne le premier résultat)
  Future<LatLng?> getCoordinates(String address) async {
    final results = await geocodeAddress(address);
    if (results.isEmpty) return null;
    return results.first.location;
  }

  /// Convertit des coordonnées GPS en adresse (géocodage inverse)
  Future<String?> reverseGeocode(LatLng location) async {
    try {
      final response = await _dio.get('/reverse', queryParameters: {
        'lat': location.latitude,
        'lon': location.longitude,
        'format': 'json',
        'addressdetails': 1,
      });

      if (response.statusCode == 200 && response.data != null) {
        return response.data['display_name'] as String?;
      }
      return null;
    } catch (e) {
      print('Erreur de géocodage inverse: $e');
      return null;
    }
  }
}
