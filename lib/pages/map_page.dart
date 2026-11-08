import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class PlantMapPage extends StatefulWidget {
  const PlantMapPage({super.key});

  @override
  State<PlantMapPage> createState() => _PlantMapPageState();
}

class _PlantMapPageState extends State<PlantMapPage> {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  bool isAddingPlant = false;
  bool isLoadingLocation = false;

  LatLng? currentLocation;

  final List<Plant> plants = [
    Plant(
      id: '1',
      name: 'Mango Tree',
      species: 'Mangifera indica',
      latitude: 33.6844,
      longitude: 73.0479,
    ),
    Plant(
      id: '2',
      name: 'Lemon Tree',
      species: 'Citrus limon',
      latitude: 33.6850,
      longitude: 73.0485,
    ),
  ];

  List<Plant> get filteredPlants {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) return plants;

    return plants.where((plant) {
      return plant.name.toLowerCase().contains(query) ||
          plant.species.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  // ---------------- CURRENT LOCATION ----------------

  Future<void> goToCurrentLocation() async {
    if (isLoadingLocation) return;

    setState(() => isLoadingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please enable your device location service.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. Enable it in app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = location;
      });

      mapController.move(location, 17);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  // ---------------- ADD PLANT ----------------

  Future<void> addPlantAtLocation(LatLng location) async {
    final nameController = TextEditingController();
    final speciesController = TextEditingController();

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Plant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Plant Name',
                  hintText: 'e.g. Mango Tree',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species',
                  hintText: 'e.g. Mangifera indica',
                  prefixIcon: Icon(Icons.local_florist_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Latitude: ${location.latitude.toStringAsFixed(5)}\n'
                'Longitude: ${location.longitude.toStringAsFixed(5)}',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter a plant name.')),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Add Plant'),
            ),
          ],
        );
      },
    );

    if (shouldAdd == true && mounted) {
      final plant = Plant(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        species: speciesController.text.trim().isEmpty
            ? 'Unknown species'
            : speciesController.text.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
      );

      setState(() {
        plants.add(plant);
        isAddingPlant = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plant.name} added to your garden.')),
      );
    }

    nameController.dispose();
    speciesController.dispose();
  }

  // ---------------- PLANT DETAILS ----------------

  Future<void> showPlantDetails(Plant plant) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.eco, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text(plant.name)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Species', plant.species),
              const SizedBox(height: 10),
              _detailRow('Latitude', plant.latitude.toStringAsFixed(6)),
              const SizedBox(height: 10),
              _detailRow('Longitude', plant.longitude.toStringAsFixed(6)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete Plant'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      setState(() {
        plants.removeWhere((item) => item.id == plant.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plant.name} removed from map.')),
      );
    }
  }

  Widget _detailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  // ---------------- MAP CONTROLS ----------------

  void zoomIn() {
    final camera = mapController.camera;
    mapController.move(camera.center, camera.zoom + 1);
  }

  void zoomOut() {
    final camera = mapController.camera;
    mapController.move(camera.center, camera.zoom - 1);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visiblePlants = filteredPlants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garden Map'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${plants.length} Plants',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(33.6844, 73.0479),
              initialZoom: 17,
              onTap: (tapPosition, point) {
                if (isAddingPlant) {
                  addPlantAtLocation(point);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.plant_app',
              ),

              // PLANT MARKERS
              MarkerLayer(
                markers: visiblePlants.map((plant) {
                  return Marker(
                    point: LatLng(plant.latitude, plant.longitude),
                    width: 120,
                    height: 75,
                    child: GestureDetector(
                      onTap: () => showPlantDetails(plant),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 36,
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                plant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // CURRENT LOCATION MARKER
              if (currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation!,
                      width: 35,
                      height: 35,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // SEARCH BAR
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search your plants...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ADD PLANT MODE MESSAGE
          if (isAddingPlant)
            Positioned(
              top: 82,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tap anywhere on the map to place your plant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // MAP CONTROLS
          Positioned(
            right: 14,
            bottom: 110,
            child: Column(
              children: [
                _MapButton(icon: Icons.add, onTap: zoomIn),
                const SizedBox(height: 8),
                _MapButton(icon: Icons.remove, onTap: zoomOut),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.my_location,
                  onTap: goToCurrentLocation,
                  isLoading: isLoadingLocation,
                ),
              ],
            ),
          ),

          // PLANT COUNT
          Positioned(
            left: 14,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: Text(
                '${visiblePlants.length} plants displayed',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),

      // ADD PLANT BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            isAddingPlant = !isAddingPlant;
          });
        },
        icon: Icon(isAddingPlant ? Icons.close : Icons.add_location_alt),
        label: Text(isAddingPlant ? 'Cancel' : 'Add Plant'),
      ),
    );
  }
}

// ---------------- MAP BUTTON ----------------

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _MapButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon),
          ),
        ),
      ),
    );
  }
}

// ---------------- PLANT MODEL ----------------

class Plant {
  final String id;
  final String name;
  final String species;
  final double latitude;
  final double longitude;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.latitude,
    required this.longitude,
  });
}
