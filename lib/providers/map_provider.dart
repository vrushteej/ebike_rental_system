import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart';

class MapProvider extends ChangeNotifier {
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> route = [];
  bool isManualSource = false;
  double currentZoom = 15.0;
  List<dynamic> nearestStations = [];
  bool isLoading = true;
  final Location _location = Location();
  List<Marker> _markers = [];

  MapProvider() {
    initLocation();
  }

  Future<void> initLocation() async {
    if (!await checkPermission()) {
      isLoading = false;
      notifyListeners();
      return;
    }
    _location.onLocationChanged.listen((loc) {
      if (!isManualSource && loc.latitude != null && loc.longitude != null) {
        currentLocation = LatLng(loc.latitude!, loc.longitude!);
        isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<bool> checkPermission() async {
    if (!await _location.serviceEnabled() && !await _location.requestService()) return false;
    final perm = await _location.hasPermission();
    if (perm == PermissionStatus.denied && await _location.requestPermission() != PermissionStatus.granted) return false;
    return true;
  }

  Future<void> setCurrentLocationManually() async {
    isManualSource = true;
    final locData = await _location.getLocation();
    if (locData.latitude != null && locData.longitude != null)
      currentLocation = LatLng(locData.latitude!, locData.longitude!);
    notifyListeners();
  }

  Future<void> fetchRouteFromText(String source, String dest, MapController mapCtr) async {
    isManualSource = true;
    final s = await _geocode(source), d = await _geocode(dest);
    if (s != null && d != null) {
      currentLocation = LatLng(s.latitude, s.longitude);
      destination = LatLng(d.latitude, d.longitude);
      mapCtr.move(currentLocation!, currentZoom);
      await fetchRoute();
    }
    notifyListeners();
  }

  Future<LatLng?> _geocode(String address) async {
    final res = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1'));
    if (res.statusCode == 200) {
      final arr = json.decode(res.body);
      if (arr.isNotEmpty) {
        return LatLng(double.parse(arr[0]['lat']), double.parse(arr[0]['lon']));
      }
    }
    return null;
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null || destination == null) return;
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
          '${currentLocation!.longitude},${currentLocation!.latitude};'
          '${destination!.longitude},${destination!.latitude}'
          '?overview=full&geometries=polyline',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final geom = json.decode(res.body)['routes'][0]['geometry'];
      final pts = PolylinePoints().decodePolyline(geom);
      route = pts.map((p) => LatLng(p.latitude, p.longitude)).toList();
    }
    notifyListeners();
  }

  Future<void> findNearestStations(BuildContext context) async {
    // if (currentLocation == null)
    //   return;
    try {
      nearestStations = await ApiService().findNearestStations(
        currentLocation?.latitude,
        currentLocation?.longitude,
      );
    } catch (e) {
      errorMessage(context, "Failed to fetch nearest stations: $e");
    }
  }

  void zoomIn(MapController controller) {
    currentZoom = (currentZoom + 1).clamp(3.0, 18.0);
    controller.move(controller.camera.center, currentZoom);
  }
  void zoomOut(MapController controller) {
    currentZoom = (currentZoom - 1).clamp(3.0, 18.0);
    controller.move(controller.camera.center, currentZoom);
  }

  Future<String?> reverseGeocode(LatLng ll) async {
    final res = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${ll.latitude}&lon=${ll.longitude}'
    ));
    if (res.statusCode == 200) {
      return json.decode(res.body)['display_name'];
    }
    return null;
  }

  void errorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void createMarkers() {
    _markers.clear();
    if (currentLocation != null) {
      _markers.add(
        Marker(width: 40.0, height: 40.0, point: currentLocation!,
          child: Icon(Icons.location_pin, color: Colors.blue, size: 40.0 ),
        ),
      );
    }
    for (int i = 0; i < nearestStations.length; i++) {
      var station = nearestStations[i];
      _markers.add(
        Marker(width: 40.0, height: 40.0, point: LatLng(station['latitude'], station['longitude']),
          child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
        ),
      );
    }
  }

}
