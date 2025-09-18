import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapSelectionScreen extends StatefulWidget {
  final String title;
  final LatLng? initialPosition;

  const MapSelectionScreen({
    Key? key,
    required this.title,
    this.initialPosition,
  }) : super(key: key);

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    LatLng initialPosition;
    
    if (widget.initialPosition != null) {
      initialPosition = widget.initialPosition!;
    } else {
      // Try to get current location
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition();
          initialPosition = LatLng(position.latitude, position.longitude);
        } else {
          // Default to Cairo if permission denied
          initialPosition = const LatLng(30.0444, 31.2357);
        }
      } catch (e) {
        // Default to Cairo if error
        initialPosition = const LatLng(30.0444, 31.2357);
      }
    }

    setState(() {
      _selectedLocation = initialPosition;
      _isLoading = false;
    });

    _updateMarker(initialPosition);
    _getAddressFromCoordinates(initialPosition);
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            _onLocationSelected(newPosition);
          },
        ),
      );
    });
  }

  void _onLocationSelected(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _updateMarker(position);
    _getAddressFromCoordinates(position);
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'الموقع المحدد: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        LatLng currentLocation = LatLng(position.latitude, position.longitude);
        
        _onLocationSelected(currentLocation);
        
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحصول على الموقع: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              tooltip: 'موقعي الحالي',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  // Address display
                  if (_selectedAddress.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Text(
                        _selectedAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Map
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation ?? const LatLng(30.0444, 31.2357),
                        zoom: 15.0,
                      ),
                      markers: _markers,
                      onTap: _onLocationSelected,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                    ),
                  ),
                  
                  // Confirm button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _selectedLocation != null ? _confirmSelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'تأكيد الاختيار',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}