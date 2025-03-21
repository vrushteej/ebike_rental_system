import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class OpenStreetMapScreen extends StatefulWidget {
  const OpenStreetMapScreen({super.key});

  @override
  State<OpenStreetMapScreen> createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;
  LatLng? _currentlocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  // Add this variable to track current zoom level
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!await _checkRequestPermission()) return;

    // listen for location updates and the current location
    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentlocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          isLoading = false; // stops loading once the location is obtained.
        });
      }
    });
  }

  // fetch coordinates for a given location using OSM Nominatin API
  Future<void> _fetchCoordinatesPoints(String location) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        // extract latitude and longitude from the API response
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        await _fetchRoute(); // fetch route to the destination
      } else {
        errorMessage('Location not found. Please try another search');
      }
    } else {
      errorMessage('Failed to fetch location. Try again later');
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentlocation == null && _destination == null) return;
    final url = Uri.parse(
      "http://router.project-osrm.org/route/v1/driving/"
      "${_currentlocation!.longitude},${_currentlocation!.latitude};"
      "${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      errorMessage('Failed to fetch route. Try again later');
    }
  }

  // method to decode a polyline string into a list of geographic coordinates.
  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedpoints =
        polylinePoints.decodePolyline(encodedPolyline);

    setState(() {
      _route = decodedpoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }

  // check permission granted or not
  Future<bool> _checkRequestPermission() async {
    bool serviveEnabled = await _location.serviceEnabled();
    if (!serviveEnabled) {
      serviveEnabled = await _location.requestService();
      if (!serviveEnabled) {
        return false;
      }
    }
    // check if location permissions are granted
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentlocation != null) {
      _mapController.move(_currentlocation!, _currentZoom);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current location not available."),
        ),
      );
    }
  }

  // Add zoom in function
  void _zoomIn() {
    _currentZoom = _currentZoom + 1;
    if (_currentZoom > 18) _currentZoom = 18;
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  // Add zoom out function
  void _zoomOut() {
    _currentZoom = _currentZoom - 1;
    if (_currentZoom < 3) _currentZoom = 3;
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  // method to display error message
  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('OpenStreetMap'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentlocation ?? LatLng(0, 0),
                    initialZoom: _currentZoom,
                    minZoom: 3,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      tileProvider: NetworkTileProvider(),
                      maxZoom: 18,
                      keepBuffer: 5,
                    ),
                    CurrentLocationLayer(
                      style: LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.white,
                          ),
                        ),
                        markerSize: Size(35, 35),
                        markerDirection: MarkerDirection.heading,
                      ),
                    ),
                    if (_destination != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _destination!,
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    if (_currentlocation != null &&
                        _destination != null &&
                        _route.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route,
                            strokeWidth: 5,
                            color: Colors.red,
                          ),
                        ],
                      ),
                  ],
                ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // expanded widget to make the text field take up available space.
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter a location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  // icon button to trigger the search for entered location.
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      final location = _locationController.text.trim();
                      if (location.isNotEmpty) {
                        _fetchCoordinatesPoints(location);
                      }
                    },
                    icon: const Icon(Icons.search),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Zoom in button
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: _zoomIn,
            backgroundColor: Colors.blue,
            mini: true,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          
          // Zoom out button
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: _zoomOut,
            backgroundColor: Colors.blue,
            mini: true,
            child: Icon(
              Icons.remove,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          
          // Your existing my location button
          FloatingActionButton(
            heroTag: "btn3",
            onPressed: _userCurrentLocation,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.my_location,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}