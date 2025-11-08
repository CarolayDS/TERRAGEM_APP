import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClimaService {
  final supabase = Supabase.instance.client;
  final String apiKey = '0419f68c51f62cb08f92d9d03301252b'; // tu API key

  // Obtiene la ubicación actual
  Future<Position?> _obtenerUbicacionActual() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Solo obtiene el clima (sin guardar)
  Future<Map<String, dynamic>?> obtenerClimaActual() async {
    try {
      final posicion = await _obtenerUbicacionActual();
      if (posicion == null) return null;

      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${posicion.latitude}&lon=${posicion.longitude}&appid=$apiKey&units=metric&lang=es';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      return {
        'ciudad': data['name'] ?? 'Sin nombre',
        'estado': data['weather'][0]['main'], // Cloud, Rain, etc.
        'descripcion': data['weather'][0]['description'],
        'temperatura': data['main']['temp'],
        'sensacion': data['main']['feels_like'],
        'temp_min': data['main']['temp_min'],
        'temp_max': data['main']['temp_max'],
        'presion': data['main']['pressure'],
        'humedad': data['main']['humidity'],
        'velocidad_viento': data['wind']['speed'],
        'latitud': posicion.latitude,
        'longitud': posicion.longitude,
        'fecha_registro': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print("Error obtener clima: $e");
      return null;
    }
  }

  // Obtiene y guarda el clima para un usuario autenticado
  Future<Map<String, dynamic>?> obtenerYGuardarClimaActual() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final clima = await obtenerClimaActual();
      if (clima == null) return null;

      await supabase.from('clima').insert({
        'usuario_auth_id': user.id,
        'nombre_ciudad': clima['ciudad'],
        'estado': clima['estado'],
        'descripcion': clima['descripcion'],
        'temperatura': clima['temperatura'],
        'sensacion': clima['sensacion'],
        'temp_min': clima['temp_min'],
        'temp_max': clima['temp_max'],
        'presion': clima['presion'],
        'humedad': clima['humedad'],
        'velocidad_viento': clima['velocidad_viento'],
        'latitud': clima['latitud'],
        'longitud': clima['longitud'],
        'fecha_registro': clima['fecha_registro'],
      });

      return clima;
    } catch (e) {
      print("Error al guardar clima: $e");
      return null;
    }
  }
}
