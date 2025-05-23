import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
  LatLng? _pointA;
  LatLng? _pointB;
  String? _pointAName;
  String? _pointBName;
  LatLng? _selectedDestination;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isNavigating = false;
  bool _isSelectingPointA = false;
  bool _isSelectingPointB = false;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
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

      // Point A
      if (_pointA != null) {
        _markers.add(
          Marker(
            point: _pointA!,
            child: GestureDetector(
              onTap: () => _showPointOptions('A', _pointA!, _pointAName ?? 'Point A'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _pointAName ?? 'Point A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_pin,
                    color: Colors.green,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Point B
      if (_pointB != null) {
        _markers.add(
          Marker(
            point: _pointB!,
            child: GestureDetector(
              onTap: () => _showPointOptions('B', _pointB!, _pointBName ?? 'Point B'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _pointBName ?? 'Point B',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  // Définir le point A
  void _setPointA() {
    setState(() {
      _isSelectingPointA = true;
      _isSelectingPointB = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapez sur la carte pour définir le Point A ou recherchez un lieu'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            setState(() {
              _isSelectingPointA = false;
            });
          },
        ),
      ),
    );
  }

  // Définir le point B
  void _setPointB() {
    setState(() {
      _isSelectingPointB = true;
      _isSelectingPointA = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapez sur la carte pour définir le Point B ou recherchez un lieu'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            setState(() {
              _isSelectingPointB = false;
            });
          },
        ),
      ),
    );
  }

  // Gérer le tap sur la carte
  void _onMapTap(LatLng point) {
    if (_isSelectingPointA) {
      setState(() {
        _pointA = point;
        _pointAName = 'Point A (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
        _isSelectingPointA = false;
      });
      _updateMarkers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Point A défini')),
      );
    } else if (_isSelectingPointB) {
      setState(() {
        _pointB = point;
        _pointBName = 'Point B (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
        _isSelectingPointB = false;
      });
      _updateMarkers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Point B défini')),
      );
    }
  }

  // Afficher les options pour un point
  void _showPointOptions(String pointType, LatLng point, String pointName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.location_pin,
                color: pointType == 'A' ? Colors.green : Colors.red,
              ),
              title: Text(pointName),
              subtitle: Text('${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.navigation, color: Colors.blue),
              title: Text('Aller à ce point'),
              onTap: () {
                Navigator.pop(context);
                _navigateToPoint(point, pointName);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.orange),
              title: Text('Redéfinir ce point'),
              onTap: () {
                Navigator.pop(context);
                if (pointType == 'A') {
                  _setPointA();
                } else {
                  _setPointB();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Supprimer ce point'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  if (pointType == 'A') {
                    _pointA = null;
                    _pointAName = null;
                  } else {
                    _pointB = null;
                    _pointBName = null;
                  }
                });
                _updateMarkers();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Naviguer vers un point
  void _navigateToPoint(LatLng destination, String destinationName) {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Position utilisateur non disponible')),
      );
      return;
    }
    _getRoute(destination, destinationName);
  }

  // Obtenir l'itinéraire
  Future<void> _getRoute(LatLng destination, String destinationName) async {
    if (_userLocation == null) return;

    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${_userLocation!.longitude},${_userLocation!.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      
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
              color: Colors.blue,
            ),
          );
          _selectedDestination = destination;
        });

        _fitBounds([_userLocation!, destination]);
        
        final duration = route['duration'];
        final distance = route['distance'];
        _showRouteInfo(destinationName, duration, distance);
      }
    } catch (e) {
      print('Erreur itinéraire: $e');
    }
  }

  // Afficher les informations de l'itinéraire
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
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 8),
                Text('Durée: $durationMin min'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.straighten, color: Colors.green),
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
              _startNavigation(_selectedDestination!, destination);
            },
            child: Text('Commencer'),
          ),
        ],
      ),
    );
  }

  // Commencer la navigation
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
        action: SnackBarAction(
          label: 'Arrêter',
          onPressed: _stopNavigation,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Arrêter la navigation
  void _stopNavigation() {
    _positionStream?.cancel();
    setState(() {
      _isNavigating = false;
      _routeLines.clear();
      _selectedDestination = null;
    });
  }

  // Arrivé à destination
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

  // Ajuster la vue
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

  // Recherche avec Nominatim
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

  // Aller à un lieu recherché
  void _goToSearchedLocation(double lat, double lon, String name) {
    final position = LatLng(lat, lon);
    
    if (_isSelectingPointA) {
      setState(() {
        _pointA = position;
        _pointAName = name;
        _isSelectingPointA = false;
        _searchResults.clear();
      });
      _updateMarkers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Point A défini: $name')),
      );
    } else if (_isSelectingPointB) {
      setState(() {
        _pointB = position;
        _pointBName = name;
        _isSelectingPointB = false;
        _searchResults.clear();
      });
      _updateMarkers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Point B défini: $name')),
      );
    } else {
      _mapController.move(position, 15.0);
      setState(() {
        _searchResults.clear();
      });
    }
    _searchController.clear();
  }

  // Calculer l'itinéraire entre A et B
  void _calculateRouteAB() {
    if (_pointA == null || _pointB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez définir les points A et B d\'abord')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir la destination'),
        content: Text('Vers quel point voulez-vous aller ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getRoute(_pointA!, _pointAName ?? 'Point A');
            },
            child: Text('Point A'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getRoute(_pointB!, _pointBName ?? 'Point B');
            },
            child: Text('Point B'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNavigating ? 'Navigation en cours...' : 'Navigation 2 Points'),
        backgroundColor: _isNavigating ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isNavigating)
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: _stopNavigation,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Carte
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

          // Barre de recherche
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
                      hintText: (_isSelectingPointA || _isSelectingPointB) 
                          ? 'Rechercher pour ${_isSelectingPointA ? "Point A" : "Point B"}...'
                          : 'Rechercher un lieu...',
                      prefixIcon: Icon(Icons.search),
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
                      constraints: BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            title: Text(
                              result['display_name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: Icon(Icons.location_on),
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

          // Panel de contrôle des points
          Positioned(
            bottom: 16,
            left: 16,
            right: 100,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Points de navigation',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _setPointA,
                            icon: Icon(Icons.location_pin),
                            label: Text(_pointA == null ? 'Définir A' : 'Point A'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pointA == null ? Colors.grey : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _setPointB,
                            icon: Icon(Icons.location_pin),
                            label: Text(_pointB == null ? 'Définir B' : 'Point B'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pointB == null ? Colors.grey : Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_pointA != null && _pointB != null) ...[
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _calculateRouteAB,
                        icon: Icon(Icons.directions),
                        label: Text('Naviguer entre A et B'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Boutons d'action
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                if (_isNavigating)
                  FloatingActionButton(
                    heroTag: "stop_nav",
                    onPressed: _stopNavigation,
                    child: Icon(Icons.stop),
                    backgroundColor: Colors.red,
                  ),
                SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "location",
                  onPressed: _getCurrentLocation,
                  child: Icon(Icons.my_location),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "clear",
                  onPressed: () {
                    setState(() {
                      _pointA = null;
                      _pointB = null;
                      _pointAName = null;
                      _pointBName = null;
                      _routeLines.clear();
                      _selectedDestination = null;
                    });
                    _updateMarkers();
                    _stopNavigation();
                  },
                  child: Icon(Icons.clear_all),
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
          ),

          // Indicateur de sélection
          if (_isSelectingPointA || _isSelectingPointB)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Card(
                color: _isSelectingPointA ? Colors.green : Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    _isSelectingPointA 
                        ? '📍 Tapez sur la carte pour définir le Point A'
                        : '📍 Tapez sur la carte pour définir le Point B',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
    _searchController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }
}