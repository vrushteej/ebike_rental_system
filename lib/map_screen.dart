import 'dart:convert';
import 'package:ebike_rental_system/api_service.dart';
import 'package:ebike_rental_system/chat_screen.dart';
import 'package:ebike_rental_system/my_wallet_screen.dart';
import 'package:ebike_rental_system/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final String userId;
  const MapScreen({super.key, required this.userId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  bool isLoading = true;
  bool isManualSource = false;
  LatLng? _currentlocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  double _currentZoom = 15.0;
  List<dynamic> nearestStations = [];
  bool showStations = false;
  List<Marker> _markers = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!await _checkRequestPermission()) return;

    _location.onLocationChanged.listen((LocationData locationData) {
      if (!isManualSource && locationData.latitude != null && locationData.longitude != null) {
        if(mounted) {
          setState(() {
            _currentlocation =
                LatLng(locationData.latitude!, locationData.longitude!);
            isLoading = false;
          });
        }
        // Move the map to the updated location
        // _mapController.move(_currentlocation!, _currentZoom);
      }
    });
  }

  void _createMarkers() {
    _markers.clear();
    if (_currentlocation != null) {
      // Add current location marker in blue
      _markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: _currentlocation!,
          child: Icon(
            Icons.location_pin,
            color: Colors.blue,  // Blue color for current location
            size: 40.0,
          ),
        ),
      );
    }
    // Add station markers
    for (int i = 0; i < nearestStations.length; i++) {
      var station = nearestStations[i];
      _markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(station['latitude'], station['longitude']),
          child: Icon(
            Icons.location_pin,
            color: Colors.red,  // Red color for the station markers
            size: 40.0,
          ),
        ),
      );
    }
  }

  Future<void> _fetchCoordinatesPoints(String source, String dest) async {
    isManualSource = true;
    final sUrl = Uri.parse('https://nominatim.openstreetmap.org/search?q=$source&format=json&limit=1');
    final dUrl = Uri.parse('https://nominatim.openstreetmap.org/search?q=$dest&format=json&limit=1');
    final sResponse = await http.get(sUrl);
    final dResponse = await http.get(dUrl);
    print("Source: ${sResponse.statusCode} and Destination: ${dResponse.statusCode}");
    if (sResponse.statusCode == 200 && dResponse.statusCode == 200) {
      final sData = json.decode(sResponse.body);
      final dData = json.decode(dResponse.body);
      if (sData.isNotEmpty && dData.isNotEmpty) {
        final sLat = double.parse(sData[0]['lat']);
        final sLon = double.parse(sData[0]['lon']);
        final dLat = double.parse(dData[0]['lat']);
        final dLon = double.parse(dData[0]['lon']);
        if(mounted) {
          setState(() {
            _currentlocation = LatLng(sLat, sLon);
            _destination = LatLng(dLat, dLon);
          });
        }
        // Move the map to the updated location
        _mapController.move(_currentlocation!, _currentZoom);
        print("Source: $_currentlocation and Destination: $_destination");

        await _fetchRoute();
      }
    } else {
      if (sResponse.statusCode != 200) {
        errorMessage('Failed to fetch current location. Try again later');
      } else {
        errorMessage('Failed to fetch destination. Try again later');
      }
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentlocation == null){
      errorMessage('Current location not available');
      return;
    }
    if (_destination == null){
      errorMessage('Destination location not available');
      return;
    }
    final url = Uri.parse(
      "http://router.project-osrm.org/route/v1/driving/"
          "${_currentlocation!.longitude},${_currentlocation!.latitude};"
          "${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline",
    );
    final response = await http.get(url);

    print("Fetch Route Response = ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      errorMessage('Failed to fetch route. Try again later');
    }
  }

  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedpoints = polylinePoints.decodePolyline(
        encodedPolyline);
    print("Decoded points = $decodedpoints");
    if (mounted) {
      setState(() {
        _route = decodedpoints.map((point) =>
            LatLng(point.latitude, point.longitude)).toList();
      });
      print("Route = $_route");
    }
  }

  Future<bool> _checkRequestPermission() async {
    bool serviveEnabled = await _location.serviceEnabled();
    if (!serviveEnabled) {
      serviveEnabled = await _location.requestService();
      if (!serviveEnabled) {
        return false;
      }
    }
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<String?> _reverseGeocode(LatLng latLng) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}"
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? null;
    } else {
      return null;
    }
  }

  Future<void> _findNearestStations() async {
    if (_currentlocation == null) {
      errorMessage("Current location is not available.");
      return;
    }

    try {
      // Call the API service to fetch the nearest stations
      final data = await ApiService().findNearestStations(
        _currentlocation!.latitude,
        _currentlocation!.longitude,
      );

      if (mounted) {
        setState(() {
          nearestStations = data; // List of nearest stations
          showStations = true;
          _createMarkers();
        });
      }
    } catch (e) {
      errorMessage("Failed to fetch nearest stations: $e");
    }
  }

  void _zoomIn() {
    _currentZoom = _currentZoom + 1;
    if (_currentZoom > 18) _currentZoom = 18;
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    _currentZoom = _currentZoom - 1;
    if (_currentZoom < 3) _currentZoom = 3;
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _onStationClick(Map<String, dynamic> station) {
    setState(() {
      showStations = false; // Hide the stations list
    });

    // You can navigate to another screen or show additional information here
    // For example, to show details in the same screen:
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(station['station_name']),
          content: Text('Available Bikes: ${station['available_bikes']}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  showStations = true; // Show stations list again
                });
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                tileProvider: NetworkTileProvider(),
                maxZoom: 18,
                keepBuffer: 5,
              ),
              LocationMarkerLayer(
                position: _currentlocation != null
                    ? LocationMarkerPosition(
                  latitude: _currentlocation!.latitude,
                  longitude: _currentlocation!.longitude,
                  accuracy: 15.0, // You can set the accuracy as per your use case
                )
                    : LocationMarkerPosition(
                  latitude: 0.0,
                  longitude: 0.0,
                  accuracy: 100.0,
                ),
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size(35, 35),
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
            top: MediaQuery.of(context).size.height * 0.075, // 10% of screen height
            right: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
            left: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sourceController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Your Current location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Color(0xFF2FEEB6), // Border color
                                width: 1.5, // Set the border width
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Color(0xFF2FEEB6), // Ensure the border is green when not focused
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Color(0xFF2FEEB6), // Green when focused
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      IconButton(
                        padding: EdgeInsets.all(6), // Remove padding to make the icon fit snugly within the border
                        style: IconButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: () async{
                          if (!await _checkRequestPermission()) {
                            return;
                          }
                          isManualSource = false;
                          LocationData? locationData = await _location.getLocation();
                          if (locationData.latitude != null && locationData.longitude != null) {
                          _currentlocation = LatLng(locationData.latitude!, locationData.longitude!);

                          // Convert coordinates to a human-readable address
                          String? address = await _reverseGeocode(_currentlocation!);
                          if(address != null && address.isNotEmpty) {
                            print("Address = $address");
                            if (mounted) {
                              setState(() {
                                _sourceController.text =
                                    address; // Update 'Your location' text field
                              });
                            }
                          }else {
                            print("Failed to retrieve address.");
                            setState(() {
                              _sourceController.text = ""; // Clear the text field if no address
                              errorMessage("Unable to retrieve current location"); // Show error message
                            });
                          }
                          } else {
                            errorMessage("Unable to fetch current location.");
                          }
                        },
                        icon: Icon(
                          Icons.my_location,
                          size: 30, // Icon size to ensure it fits nicely
                          color: Color(0xFF2FEEB6), // Icon color matching the border color
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.04),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextField(
                  //       controller: _destinationController,
                  //       decoration: InputDecoration(
                  //         filled: true,
                  //         fillColor: Colors.white,
                  //         hintText: 'Destination',
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(24),
                  //           borderSide: BorderSide(
                  //             color: Color(0xFF2FEEB6), // Border color
                  //             width: 1.5, // Set the border width
                  //           ),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(24),
                  //           borderSide: BorderSide(
                  //             color: Color(0xFF2FEEB6), // Ensure the border is green when not focused
                  //             width: 1.5,
                  //           ),
                  //         ),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(24),
                  //           borderSide: BorderSide(
                  //             color: Color(0xFF2FEEB6), // Green when focused
                  //             width: 1.5,
                  //           ),
                  //         ),
                  //         contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  //     IconButton(
                  //       padding: EdgeInsets.all(6), // Remove padding to make the icon fit snugly within the border
                  //       style: IconButton.styleFrom(backgroundColor: Colors.white),
                  //       onPressed: () {
                  //         final source = _sourceController.text.trim();
                  //         final dest = _destinationController.text.trim();
                  //         if (source.isNotEmpty && dest.isNotEmpty) {
                  //           _fetchCoordinatesPoints(source, dest);
                  //         }
                  //         else{
                  //           if (source.isEmpty) {
                  //             errorMessage("Please enter your location.");
                  //           } else {
                  //             errorMessage("Please enter a destination.");
                  //           }
                  //         }
                  //       },
                  //       icon: Icon(
                  //         Icons.search,
                  //         size: 30, // Icon size to ensure it fits nicely
                  //         color: Color(0xFF2FEEB6), // Icon color matching the border color
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  ElevatedButton(
                    onPressed: _findNearestStations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2FEEB6),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)
                      )
                    ),
                    child: Text(
                      "Find nearest stations",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: showStations ?
            MediaQuery.of(context).size.height*0.38 :
            MediaQuery.of(context).size.height*0.72, // Adjust based on the state of showStations
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "Zoom in",
                  onPressed: _zoomIn,
                  backgroundColor: Color(0xFF2FEEB6),
                  mini: true,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "Zoom out",
                  onPressed: _zoomOut,
                  backgroundColor: Color(0xFF2FEEB6),
                  mini: true,
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (showStations)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Max height: up to 60% of the screen height
                  maxHeight: MediaQuery.of(context).size.height * 0.36,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFe0fff6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.048,
                    left: MediaQuery.of(context).size.width * 0.075,
                    right: MediaQuery.of(context).size.width * 0.075,
                    bottom: MediaQuery.of(context).size.width * 0.032,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Stations Near You",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.018),
                      ...nearestStations.map<Widget>((station) {
                        return StationCard(
                          stationName: station['station_name'],
                          availableBikes: station['available_bikes'],
                          onTap: () =>
                              _onStationClick(station),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       heroTag: "Zoom in",
      //       onPressed: _zoomIn,
      //       backgroundColor: Color(0xFF2FEEB6),
      //       mini: true,
      //       child: Icon(
      //         Icons.add,
      //         color: Colors.white,
      //       ),
      //     ),
      //     SizedBox(height: 10),
      //     FloatingActionButton(
      //       heroTag: "Zoom out",
      //       onPressed: _zoomOut,
      //       backgroundColor: Color(0xFF2FEEB6),
      //       mini: true,
      //       child: Icon(
      //         Icons.remove,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ],
      // ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if(mounted) {
            setState(() {
              _selectedIndex = index;
            });
          }
          // Navigate to different screens based on the selected index
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(userId: widget.userId)));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyWalletScreen(userId: widget.userId)));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.chat_bubble_outline, 1),
          _buildNavItem(Icons.attach_money, 2),
          _buildNavItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          if (_selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.tealAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
      label: '',
    );
  }
}

class StationList extends StatelessWidget {
  final List<dynamic> stations;
  final Function(Map<String, dynamic>) onStationClick;

  const StationList({super.key,
    required this.stations,
    required this.onStationClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return StationCard(
          stationName: station['station_name'],
          availableBikes: station['available_bikes'],
          onTap: () => onStationClick(station), // Pass the station data on tap
        );
      },
    );
  }
}

class StationCard extends StatelessWidget {
  final String stationName;
  final int availableBikes;
  final Function onTap;

  const StationCard({
    super.key,
    required this.stationName,
    required this.availableBikes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.directions_bike, color: Colors.green),
              SizedBox(width: MediaQuery.of(context).size.width*0.05),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Available Bikes: $availableBikes',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}