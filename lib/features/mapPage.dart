import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Marker> _markers = [];
  List<Polyline> _routeLines = [];
  LatLng _currentCenter = LatLng(48.8566, 2.3522);
  LatLng? _userLocation;
  List<Map<String, dynamic>> _destinations = [];
  Map<String, dynamic>? _activeDestination;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isNavigating = false;
  bool _isSelectingDestination = false;
  StreamSubscription<Position>? _positionStream;

  // Couleurs pastel foncées
  final List<Color> _destinationColors = [
    Color(0xFF8B5A3C), // Brun pastel foncé
    Color(0xFF6B5B95), // Violet pastel foncé
    Color(0xFF88A96F), // Vert pastel foncé
    Color(0xFF9B7BB8), // Lavande pastel foncé
    Color(0xFF8FB4A3), // Turquoise pastel foncé
    Color(0xFFB5838C), // Rose pastel foncé
    Color(0xFF8B7A6B), // Beige pastel foncé
    Color(0xFF7B9BAB), // Bleu gris pastel foncé
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations().then((_) {
      _getCurrentLocation();
    });
  }

  // Sauvegarder les destinations
  Future<void> _saveDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final destinationsJson = _destinations.map((dest) {
      return jsonEncode({
        'id': dest['id'],
        'name': dest['name'],
        'lat': dest['position'].latitude,
        'lng': dest['position'].longitude,
        'color': dest['color'].value,
      });
    }).toList();
    
    await prefs.setStringList('saved_destinations', destinationsJson);
  }

  // Charger les destinations
  Future<void> _loadDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final destinationsJson = prefs.getStringList('saved_destinations') ?? [];
    
    setState(() {
      _destinations = destinationsJson.map((jsonStr) {
        final data = jsonDecode(jsonStr);
        return {
          'id': data['id'],
          'name': data['name'],
          'position': LatLng(data['lat'], data['lng']),
          'color': Color(data['color']),
        };
      }).toList();
    });
  }

  // Obtenir la position actuelle
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _currentCenter = _userLocation!;
          _updateMarkers();
        });
        _mapController.move(_currentCenter, 15.0);
      }
    } catch (e) {
      print('Erreur géolocalisation: $e');
    }
  }

  // Obtenir une couleur pour une nouvelle destination
  Color _getColorForDestination(int index) {
    return _destinationColors[index % _destinationColors.length];
  }

  // Mettre à jour tous les marqueurs
  void _updateMarkers() {
    setState(() {
      _markers.clear();

      // Marqueur utilisateur
      if (_userLocation != null) {
        _markers.add(
          Marker(
            point: _userLocation!,
            child: Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Destinations
      for (int i = 0; i < _destinations.length; i++) {
        final destination = _destinations[i];
        final isActive = _activeDestination != null && 
                        _activeDestination!['id'] == destination['id'];
        
        _markers.add(
          Marker(
            point: destination['position'],
            child: GestureDetector(
              onTap: () => _showDestinationOptions(destination),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 150),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: destination['color'],
                      borderRadius: BorderRadius.circular(8),
                      border: isActive ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                    child: Text(
                      destination['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    isActive ? Icons.navigation : Icons.place,
                    color: destination['color'],
                    size: isActive ? 32 : 28,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  // Gérer le tap sur la carte
  void _onMapTap(LatLng point) {
    if (_isSelectingDestination) {
      _addDestination(point, 'Position personnalisée');
    } else {
      _showQuickNavigationDialog(point);
    }
  }

  // Afficher le dialogue de navigation rapide
  void _showQuickNavigationDialog(LatLng point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.place, color: Color(0xFF8B5A3C)),
            SizedBox(width: 8),
            Text('Nouveau point'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Que voulez-vous faire avec ce point ?'),
            SizedBox(height: 8),
            Text(
              'Position: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addDestination(point, 'Position sélectionnée');
            },
            child: Text('Ajouter destination'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addDestination(point, 'Navigation directe');
              final newDestination = _destinations.last;
              _navigateToDestination(newDestination);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5A3C),
              foregroundColor: Colors.white,
            ),
            child: Text('Naviguer'),
          ),
        ],
      ),
    );
  }

  // Ajouter une destination
  void _addDestination(LatLng point, String name) {
    final destination = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'position': point,
      'name': name,
      'color': _getColorForDestination(_destinations.length),
    };
    
    setState(() {
      _destinations.add(destination);
    });
    _updateMarkers();
    _saveDestinations();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Destination ajoutée: $name'),
        backgroundColor: destination['color']as Color,
        action: SnackBarAction(
          label: 'Naviguer',
          textColor: Colors.white,
          onPressed: () => _navigateToDestination(destination),
        ),
      ),
    );
  }

  // Afficher les options pour une destination
  void _showDestinationOptions(Map<String, dynamic> destination) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.place, color: destination['color']),
              title: Text(destination['name']),
              subtitle: Text(
                '${destination['position'].latitude.toStringAsFixed(6)}, ${destination['position'].longitude.toStringAsFixed(6)}',
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.navigation, color: Color(0xFF6B5B95)),
              title: Text('Naviguer vers cette destination'),
              onTap: () {
                Navigator.pop(context);
                _navigateToDestination(destination);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Color(0xFF88A96F)),
              title: Text('Renommer'),
              onTap: () {
                Navigator.pop(context);
                _renameDestination(destination);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Color(0xFFB5838C)),
              title: Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _removeDestination(destination);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Renommer une destination
  void _renameDestination(Map<String, dynamic> destination) {
    final controller = TextEditingController(text: destination['name']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renommer la destination'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nouveau nom',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  destination['name'] = controller.text;
                });
                _updateMarkers();
                _saveDestinations();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: destination['color'],
              foregroundColor: Colors.white,
            ),
            child: Text('Renommer'),
          ),
        ],
      ),
    );
  }

  // Supprimer une destination
  void _removeDestination(Map<String, dynamic> destination) {
    setState(() {
      _destinations.removeWhere((d) => d['id'] == destination['id']);
      if (_activeDestination != null && _activeDestination!['id'] == destination['id']) {
        _activeDestination = null;
        _routeLines.clear();
        _stopNavigation();
      }
    });
    _updateMarkers();
    _saveDestinations();
  }

  // Naviguer vers une destination
  void _navigateToDestination(Map<String, dynamic> destination) {
    setState(() {
      _activeDestination = destination;
    });
    _updateMarkers();
    _getRoute(destination['position'], destination['name']);
  }

  // Commencer la sélection de destination
  void _startDestinationSelection() {
    setState(() {
      _isSelectingDestination = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapez sur la carte pour ajouter une destination'),
        backgroundColor: Color(0xFF8B5A3C),
        action: SnackBarAction(
          label: 'Annuler',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isSelectingDestination = false;
            });
          },
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  // Effacer toutes les destinations
  void _clearAllDestinations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Effacer toutes les destinations'),
        content: Text('Êtes-vous sûr de vouloir supprimer toutes les destinations ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _destinations.clear();
                _activeDestination = null;
                _routeLines.clear();
              });
              _updateMarkers();
              _stopNavigation();
              _saveDestinations();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB5838C),
              foregroundColor: Colors.white,
            ),
            child: Text('Effacer tout'),
          ),
        ],
      ),
    );
  }

  // Obtenir l'itinéraire
  Future<void> _getRoute(LatLng destination, String destinationName) async {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Position utilisateur non disponible')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF6B5B95)),
                SizedBox(height: 16),
                Text('Calcul de l\'itinéraire...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${_userLocation!.longitude},${_userLocation!.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      
      Navigator.pop(context);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final geometry = route['geometry']['coordinates'];
        
        List<LatLng> routePoints = geometry.map<LatLng>((point) {
          return LatLng(point[1].toDouble(), point[0].toDouble());
        }).toList();

        setState(() {
          _routeLines.clear();
          _routeLines.add(
            Polyline(
              points: routePoints,
              strokeWidth: 4.0,
              color: Color(0xFF6B5B95),
            ),
          );
        });

        _fitBounds([_userLocation!, destination]);
        
        final duration = route['duration'];
        final distance = route['distance'];
        _showRouteInfo(destinationName, duration, distance);
      } else {
        _showErrorDialog('Impossible de calculer l\'itinéraire');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Erreur de connexion: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRouteInfo(String destination, double duration, double distance) {
    final durationMin = (duration / 60).round();
    final distanceKm = (distance / 1000).toStringAsFixed(1);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Itinéraire vers $destination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFF6B5B95)),
                SizedBox(width: 8),
                Text('Durée: $durationMin min'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.straighten, color: Color(0xFF88A96F)),
                SizedBox(width: 8),
                Text('Distance: $distanceKm km'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNavigation(_activeDestination!['position'], destination);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6B5B95),
              foregroundColor: Colors.white,
            ),
            child: Text('Commencer'),
          ),
        ],
      ),
    );
  }

  void _startNavigation(LatLng destination, String destinationName) {
    setState(() {
      _isNavigating = true;
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _userLocation = newPosition;
        _updateMarkers();
      });

      double distanceToDestination = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        destination.latitude, destination.longitude,
      );

      if (distanceToDestination <= 50) {
        _arrivedAtDestination(destinationName);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation démarrée vers $destinationName'),
        backgroundColor: Color(0xFF88A96F),
        action: SnackBarAction(
          label: 'Arrêter',
          textColor: Colors.white,
          onPressed: _stopNavigation,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _stopNavigation() {
    _positionStream?.cancel();
    setState(() {
      _isNavigating = false;
      _activeDestination = null;
      _routeLines.clear();
    });
    _updateMarkers();
  }

  void _arrivedAtDestination(String destinationName) {
    _stopNavigation();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Arrivé !'),
        content: Text('Vous êtes arrivé à $destinationName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    
    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    
    LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    double zoom = _calculateZoom(minLat, maxLat, minLng, maxLng);
    
    _mapController.move(center, zoom);
  }

  double _calculateZoom(double minLat, double maxLat, double minLng, double maxLng) {
    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    if (maxDiff < 0.01) return 15.0;
    if (maxDiff < 0.05) return 13.0;
    if (maxDiff < 0.1) return 11.0;
    return 9.0;
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    try {
      final url = 'https://nominatim.openstreetmap.org/search?'
          'q=${Uri.encodeComponent(query)}&format=json&limit=5';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((item) => {
            'display_name': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          }).toList();
        });
      }
    } catch (e) {
      print('Erreur de recherche: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _goToSearchedLocation(double lat, double lon, String name) {
    final position = LatLng(lat, lon);
    _addDestination(position, name);
    _mapController.move(position, 15.0);
    
    setState(() {
      _searchResults.clear();
    });
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNavigating ? 'Navigation en cours...' : 'Mes Destinations'),
        backgroundColor: _isNavigating ? Color(0xFF88A96F) : Color(0xFF6B5B95),
        foregroundColor: Colors.white,
        actions: [
          if (_isNavigating)
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: _stopNavigation,
            ),
          if (_destinations.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearAllDestinations,
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 10.0,
              onTap: (tapPosition, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_routeLines.isNotEmpty)
                PolylineLayer(polylines: _routeLines),
              MarkerLayer(markers: _markers),
            ],
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un lieu...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B5B95)),
                      suffixIcon: _isSearching
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults.clear();
                                });
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: _searchLocation,
                  ),
                  
                  if (_searchResults.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              result['display_name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                            leading: Icon(Icons.location_on, size: 20),
                            onTap: () => _goToSearchedLocation(
                              result['lat'],
                              result['lon'],
                              result['display_name'],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (_destinations.isNotEmpty && !_isNavigating)
            Positioned(
              bottom: 16,
              left: 16,
              right: 80,
              child: Card(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 150),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destinations (${_destinations.length})',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _destinations.length,
                          itemBuilder: (context, index) {
                            final destination = _destinations[index];
                            final isActive = _activeDestination != null &&
                                            _activeDestination!['id'] == destination['id'];
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: isActive ? destination['color'].withOpacity(0.1) : null,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: destination['color'],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  destination['name'],
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isActive)
                                      Icon(Icons.navigation, size: 16, color: destination['color']),
                                    SizedBox(width: 4),
                                    InkWell(
                                      onTap: () => _navigateToDestination(destination),
                                      child: Icon(Icons.play_arrow, size: 16, color: Color(0xFF6B5B95)),
                                    ),
                                  ],
                                ),
                                onTap: () => _showDestinationOptions(destination),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isNavigating)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FloatingActionButton(
                      heroTag: "stop_nav",
                      onPressed: _stopNavigation,
                      child: Icon(Icons.stop, size: 20),
                      backgroundColor: Color(0xFFB5838C),
                      mini: true,
                    ),
                  ),
                SizedBox(height: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FloatingActionButton(
                    heroTag: "add_destination",
                    onPressed: _startDestinationSelection,
                    child: Icon(Icons.add_location, size: 20),
                    backgroundColor: Color(0xFF88A96F),
                    mini: true,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FloatingActionButton(
                    heroTag: "location",
                    onPressed: _getCurrentLocation,
                    child: Icon(Icons.my_location, size: 20),
                    backgroundColor: Color(0xFF6B5B95),
                    mini: true,
                  ),
                ),
              ],
            ),
          ),
          if (_isSelectingDestination)
            Positioned(
              bottom: 100,
              right: 16,
              child: Card(
                color: Color(0xFF8B5A3C),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Sélection en cours',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _saveDestinations();
    _positionStream?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
}
}
