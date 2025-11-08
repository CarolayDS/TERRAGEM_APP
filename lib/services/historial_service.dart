import 'package:supabase_flutter/supabase_flutter.dart';

class HistorialService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> obtenerUltimoResultado(
      String usuarioAuthId) async {
    final data = await supabase
        .from('usuario_contexto')
        .select()
        .eq('usuario_auth_id', usuarioAuthId)
        .not('resultado_ia', 'is', null)
        .order('fecha', ascending: false)
        .limit(1);

    if (data.isEmpty) return null;
    return data.first;
  }

  Future<List<Map<String, dynamic>>> obtenerHistorial(
      String usuarioAuthId) async {
    final data = await supabase
        .from('usuario_contexto')
        .select()
        .eq('usuario_auth_id', usuarioAuthId)
        .not('resultado_ia', 'is', null)
        .order('fecha', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
