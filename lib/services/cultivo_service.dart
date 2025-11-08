import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cultivo.dart';

class CultivoService {
  final supabase = Supabase.instance.client;

  Future<List<Cultivo>> obtenerCultivos() async {
    final response = await supabase.from('cultivos').select('*');
    return (response as List).map((data) => Cultivo.fromMap(data)).toList();
  }

  Future<void> registrarSeleccion({
    required String usuarioAuthId,
    required int cultivoId,
  }) async {
    await supabase.from('usuario_cultivo').insert({
      'usuario_auth_id': usuarioAuthId,
      'cultivo_id': cultivoId,
    });
  }
}
