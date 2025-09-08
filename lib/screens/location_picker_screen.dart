import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(15.3694, 44.1910); // صنعاء، اليمن
  String _selectedAddress = '';
  bool _isLoading = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation,
            draggable: true,
            onDragEnd: (LatLng position) {
              _onLocationSelected(position);
            },
          ),
        };
      });

      await _getAddressFromLatLng(_selectedLocation);
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation),
      );
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      print('خطأ في الحصول على العنوان: $e');
      setState(() {
        _selectedAddress = 'غير محدد';
      });
    }
  }

  void _onLocationSelected(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            _onLocationSelected(newPosition);
          },
        ),
      };
    });
    _getAddressFromLatLng(position);
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('خدمة الموقع غير مفعلة'),
          content: const Text('يرجى تفعيل خدمة الموقع للمتابعة.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إذن الموقع مرفوض'),
          content: const Text('يرجى السماح بالوصول للموقع لاستخدام هذه الميزة.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إذن الموقع مرفوض نهائياً'),
          content: const Text('يرجى الذهاب إلى الإعدادات وتفعيل إذن الموقع يدوياً.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  String _generateLocationUrl() {
    return 'https://www.google.com/maps?q=${_selectedLocation.latitude},${_selectedLocation.longitude}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'اختيار الموقع',
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
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
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
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'الموقع المحدد:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedAddress.isNotEmpty
                              ? _selectedAddress
                              : 'جاري تحديد العنوان...',
                          style: const TextStyle(fontSize: 14),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            String locationUrl = _generateLocationUrl();
                            Navigator.of(context).pop({
                              'address': _selectedAddress,
                              'url': locationUrl,
                              'latitude': _selectedLocation.latitude,
                              'longitude': _selectedLocation.longitude,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'تأكيد الموقع',
                            style: TextStyle(fontSize: 16),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}