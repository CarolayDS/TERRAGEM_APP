import 'package:supabase_flutter/supabase_flutter.dart';

class CultivoAreaService {
  final supabase = Supabase.instance.client;

  Future<void> registrarArea({
    required String usuarioAuthId,
    required String cultivoId,
    required double valor,
    required String unidad,
  }) async {
    final data = {
      'usuario_auth_id': usuarioAuthId,
      'cultivo_id': cultivoId,
      'valor': valor,
      'unidad': unidad,
    };

    await supabase.from('cultivo_area').insert(data);
  }
}
