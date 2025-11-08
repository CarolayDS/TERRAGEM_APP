import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/parametro.dart';

class ParametroService {
  final supabase = Supabase.instance.client;

  Future<List<ParametroCultivo>> obtenerParametrosPorCultivo(
    int cultivoId,
  ) async {
    final response = await supabase
        .from('parametros_cultivo')
        .select('*')
        .eq('cultivo_id', cultivoId);

    return (response as List)
        .map((data) => ParametroCultivo.fromMap(data))
        .toList();
  }

  Future<void> guardarAnalisisUsuario({
    required String usuarioAuthId,
    required int cultivoId,
    required Map<String, double> valores,
  }) async {
    final Map<String, String> columnas = {
      'ph': 'ph',
      'conductividad eléctrica': 'ce',
      'materia orgánica': 'mo',
      'nitrógeno': 'n',
      'fósforo': 'p',
      'potasio': 'k',
      'calcio': 'ca',
      'magnesio': 'mg',
    };

    final Map<String, dynamic> data = {
      'usuario_auth_id': usuarioAuthId,
      'cultivo_id': cultivoId,
    };

    for (var entry in valores.entries) {
      final nombre = entry.key.toLowerCase();
      final valor = entry.value;

      if (columnas.containsKey(nombre)) {
        data[columnas[nombre]!] = valor;
      }
    }

    await Supabase.instance.client.from('analisis_suelo').insert(data);
  }
}
