import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/suelo.dart';

class TipoSueloService {
  final supabase = Supabase.instance.client;

  Future<List<TipoSuelo>> obtenerTiposSuelo() async {
    final response = await supabase.from('tipo_suelo').select();

    return response.map<TipoSuelo>((row) => TipoSuelo.fromMap(row)).toList();
  }

  Future<void> registrarSeleccion({
    required String usuarioAuthId,
    required int tipoSueloId,
  }) async {
    await supabase.from('usuario_suelo').insert({
      'usuario_auth_id': usuarioAuthId,
      'tipo_suelo_id': tipoSueloId,
    });
  }
}
