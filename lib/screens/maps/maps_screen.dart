import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TiendasMapaScreen extends StatefulWidget {
  const TiendasMapaScreen({super.key});

  @override
  State<TiendasMapaScreen> createState() => _TiendasMapaScreenState();
}

class _TiendasMapaScreenState extends State<TiendasMapaScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  LatLng? _ubicacionActual;
  bool _cargando = true;
  String _tipoBusqueda = 'fertilizantes';
  int _selectedIndex = 2;
  List<Map<String, dynamic>> _tiendas = [];

  final primaryColor = const Color(0xFF6B3E26);
  final secondaryColor = const Color(0xFFF8F5F0);

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionYTiendas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 1) {
      Navigator.pop(context);
    }
  }

  Future<void> _obtenerUbicacionYTiendas() async {
    setState(() => _cargando = true);

    try {
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Location permissions permanently denied'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        setState(() => _cargando = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _ubicacionActual = LatLng(position.latitude, position.longitude);

      _markers.add(Marker(
        markerId: const MarkerId('mi_ubicacion'),
        position: _ubicacionActual!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: '📍 Your location',
          snippet: 'You are here',
        ),
      ));

      await _buscarTiendasCercanas(position.latitude, position.longitude);

      setState(() => _cargando = false);
    } catch (e) {
      print('❌ Error while getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error while getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _cargando = false);
    }
  }

  Future<void> _buscarTiendasCercanas(double lat, double lng) async {
    final apiKey = 'AIzaSyCp-guZIgHZ14VMAuKNHKMegs75mjvqyGc';

    // Keywords to search for fertilizer and agro stores
    final keywords = _tipoBusqueda == 'fertilizantes'
        ? 'agrochemical fertilizers agricultural'
        : _searchController.text.isEmpty
            ? 'agricultural store'
            : _searchController.text;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=$lat,$lng'
        '&radius=5000'
        '&keyword=$keywords'
        '&key=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _tiendas.clear();

        _markers
            .removeWhere((marker) => marker.markerId.value != 'mi_ubicacion');

        if (data['results'] != null && data['results'].isNotEmpty) {
          for (var result in data['results']) {
            final markerId = result['place_id'];
            final name = result['name'];
            final vicinity = result['vicinity'] ?? 'Sin dirección';
            final loc = result['geometry']['location'];
            final latLng = LatLng(loc['lat'], loc['lng']);

            _tiendas.add({
              'nombre': name,
              'direccion': vicinity,
              'latLng': latLng,
            });

            _markers.add(Marker(
              markerId: MarkerId(markerId),
              position: latLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(
                title: name,
                snippet: vicinity,
              ),
              onTap: () => _mostrarDetallesTienda(name, vicinity, latLng),
            ));
          }

          if (mounted) {
            setState(() {});
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('No stores were found nearby'),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      } else {
        print('❌ Error when getting stores: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in search: $e');
    }
  }

  void _mostrarDetallesTienda(
      String nombre, String direccion, LatLng ubicacion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.store, color: primaryColor, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              direccion,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _moverCamaraA(ubicacion);
                },
                icon: Icon(Icons.my_location),
                label: Text('See on the map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moverCamaraA(LatLng posicion) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: posicion, zoom: 17),
      ),
    );
  }

  void _buscarPersonalizado() {
    if (_ubicacionActual != null) {
      _buscarTiendasCercanas(
        _ubicacionActual!.latitude,
        _ubicacionActual!.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          'Agricultural Shops',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _obtenerUbicacionYTiendas,
            tooltip: 'Update location',
          ),
        ],
      ),
      body: _cargando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Looking for nearby shops...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Quick filters
                      Row(
                        children: [
                          Expanded(
                            child: _buildFiltroChip(
                              'Fertilizers',
                              'fertilizers',
                              Icons.agriculture,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildFiltroChip(
                              'Seeds',
                              'seeds',
                              Icons.eco,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildFiltroChip(
                              'Tools',
                              'tools',
                              Icons.build,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Custom search engine
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a specific store...',
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send, color: primaryColor),
                            onPressed: _buscarPersonalizado,
                          ),
                          filled: true,
                          fillColor: secondaryColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _buscarPersonalizado(),
                      ),
                    ],
                  ),
                ),

                // Map
                Expanded(
                  child: _ubicacionActual == null
                      ? Center(
                          child: Text(
                            'Could not get the location',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _ubicacionActual!,
                                zoom: 15,
                              ),
                              markers: _markers,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              scrollGesturesEnabled: true,
                              zoomGesturesEnabled: true,
                              tiltGesturesEnabled: true,
                              rotateGesturesEnabled: true,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                            ),
                            if (_tiendas.isNotEmpty)
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.store,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${_tiendas.length} tiendas',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),

                // List of stores (expandable)
                if (_tiendas.isNotEmpty)
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(10),
                      itemCount: _tiendas.length,
                      itemBuilder: (context, index) {
                        final tienda = _tiendas[index];
                        return GestureDetector(
                          onTap: () => _mostrarDetallesTienda(
                            tienda['nombre'],
                            tienda['direccion'],
                            tienda['latLng'],
                          ),
                          child: Container(
                            width: 180,
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.store,
                                      color: primaryColor,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        tienda['nombre'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: primaryColor,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        tienda['direccion'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory),
            label: 'Stores',
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String label, String tipo, IconData icono) {
    final seleccionado = _tipoBusqueda == tipo;
    return GestureDetector(
      onTap: () {
        setState(() => _tipoBusqueda = tipo);
        if (_ubicacionActual != null) {
          _buscarTiendasCercanas(
            _ubicacionActual!.latitude,
            _ubicacionActual!.longitude,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: seleccionado ? primaryColor : secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 18,
              color: seleccionado ? Colors.white : primaryColor,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: seleccionado ? Colors.white : primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
