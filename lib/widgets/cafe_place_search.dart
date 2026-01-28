import 'package:flutter/material.dart';
import '../models/cafe_place.dart';
import '../models/coffee_log.dart';
import '../services/cafe_service.dart';
import '../services/geocoding_service.dart';

/// Widget de recherche et sélection d'un CafePlace
/// Permet de rechercher dans la base ou d'ajouter un nouveau lieu
class CafePlaceSearchDialog extends StatefulWidget {
  const CafePlaceSearchDialog({super.key});

  @override
  State<CafePlaceSearchDialog> createState() => _CafePlaceSearchDialogState();
}

class _CafePlaceSearchDialogState extends State<CafePlaceSearchDialog> {
  final CafeService _cafeService = CafeService();
  final GeocodingService _geocodingService = GeocodingService();
  final TextEditingController _searchController = TextEditingController();

  List<Cafe> _searchResults = [];
  bool _isSearching = false;
  bool _showAddNewForm = false;
  bool _isAddingCafe = false; // Nouvel état pour le chargement

  // Contrôleurs pour le formulaire d'ajout
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  CafeType _selectedType = CafeType.cafe;
  final List<CoffeeType> _selectedCoffeeTypes = [];

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _cafeService.searchByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de recherche: $e')),
        );
      }
    }
  }

  Future<void> _addNewCafePlace() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      _isAddingCafe = true;
    });

    try {
      // Géocoder l'adresse pour obtenir les coordonnées
      final location = await _geocodingService.getCoordinates(_addressController.text);
      
      if (location == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adresse introuvable. Vérifiez l\'adresse saisie.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isAddingCafe = false;
          });
        }
        return;
      }

      final newCafe = Cafe(
        id: '', // Sera généré par Supabase
        name: _nameController.text,
        address: _addressController.text,
        location: location,
        type: _selectedType,
        availableCoffeeTypes: _selectedCoffeeTypes,
      );

      final addedCafe = await _cafeService.addCafe(newCafe);
      if (addedCafe != null && mounted) {
        Navigator.of(context).pop(addedCafe);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingCafe = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6B4423)),
                const SizedBox(width: 8),
                const Text(
                  'Rechercher un lieu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4423),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Barre de recherche
            if (!_showAddNewForm) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Nom du café, restaurant...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _performSearch(value);
                },
              ),
              const SizedBox(height: 16),

              // Résultats de recherche
              if (_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun résultat trouvé',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAddNewForm = true;
                              _nameController.text = _searchController.text;
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter ce lieu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B4423),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final cafe = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6B4423),
                          child: Text(
                            cafe.type.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          cafe.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${cafe.address}\n${cafe.type.displayName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.of(context).pop(cafe);
                        },
                      );
                    },
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Recherchez un café, restaurant ou autre lieu...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],

            // Formulaire d'ajout
            if (_showAddNewForm) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              setState(() {
                                _showAddNewForm = false;
                                _nameController.clear();
                                _addressController.clear();
                              });
                            },
                          ),
                          const Text(
                            'Ajouter un nouveau lieu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nom
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du lieu*',
                          hintText: 'Ex: Café de la Gare',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Adresse
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Adresse*',
                          hintText: 'Ex: 15 Rue de la Paix, Paris',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Type d'établissement
                      const Text(
                        'Type d\'établissement',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: CafeType.values.map((type) {
                          return ChoiceChip(
                            label: Text('${type.emoji} ${type.displayName}'),
                            selected: _selectedType == type,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedType = type;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Types de café disponibles
                      const Text(
                        'Types de café disponibles',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: CoffeeType.values.map((type) {
                          return FilterChip(
                            label: Text('${type.emoji} ${type.displayName}'),
                            selected: _selectedCoffeeTypes.contains(type),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCoffeeTypes.add(type);
                                } else {
                                  _selectedCoffeeTypes.remove(type);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Bouton d'ajout
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAddingCafe ? null : _addNewCafePlace,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B4423),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isAddingCafe
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Ajouter ce lieu',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
