import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_contexto.dart';

class UsuarioContextoService {
  final supabase = Supabase.instance.client;

  Future<UsuarioContexto?> obtenerUltimoContexto(String usuarioAuthId) async {
    try {
      print('🔍 Obteniendo contexto completo para usuario: $usuarioAuthId');

      final analisisResponse = await supabase
          .from('analisis_suelo')
          .select('*')
          .eq('usuario_auth_id', usuarioAuthId)
          .order('fecha', ascending: false)
          .limit(1)
          .maybeSingle();

      print('📊 Análisis obtenido: $analisisResponse');

      final climaResponse = await supabase
          .from('clima')
          .select('*')
          .eq('usuario_auth_id', usuarioAuthId)
          .order('fecha_registro', ascending: false)
          .limit(1)
          .maybeSingle();

      print('🌤️ Clima obtenido: $climaResponse');

      final cultivoResponse = await supabase
          .from('usuario_cultivo')
          .select('''
            *,
            cultivos (
              id,
              nombre,
              imagen_url
            )
          ''')
          .eq('usuario_auth_id', usuarioAuthId)
          .order('fecha', ascending: false)
          .limit(1)
          .maybeSingle();

      print('🌱 Cultivo obtenido: $cultivoResponse');

      Map<String, dynamic>? cultivoConArea;
      if (cultivoResponse != null) {
        final areaResponse = await supabase
            .from('cultivo_area')
            .select('*')
            .eq('usuario_auth_id', usuarioAuthId)
            .eq('cultivo_id', cultivoResponse['cultivo_id'])
            .order('creado_en', ascending: false)
            .limit(1)
            .maybeSingle();

        print('📏 Área obtenida: $areaResponse');

        cultivoConArea = {
          ...cultivoResponse,
          'valor': areaResponse?['valor'],
          'unidad': areaResponse?['unidad'],
        };
      }

      final tipoSueloResponse = await supabase
          .from('usuario_suelo')
          .select('''
            *,
            tipo_suelo (
              id,
              nombre,
              descripcion,
              imagen_url
            )
          ''')
          .eq('usuario_auth_id', usuarioAuthId)
          .order('fecha', ascending: false)
          .limit(1)
          .maybeSingle();

      print('🏜️ Tipo de suelo obtenido: $tipoSueloResponse');

      if (analisisResponse == null || cultivoResponse == null) {
        print('⚠️ Faltan datos mínimos: análisis o cultivo');
        return null;
      }

      final contexto = UsuarioContexto(
        usuarioAuthId: usuarioAuthId,
        analisis: analisisResponse,
        clima: climaResponse,
        cultivo: cultivoConArea,
        tipoSuelo: tipoSueloResponse,
      );

      print('✅ Contexto completo obtenido exitosamente');
      return contexto;
    } catch (e) {
      print('❌ Error al obtener contexto: $e');
      return null;
    }
  }

  Future<void> guardarInterpretacion(
    UsuarioContexto contexto,
    String interpretacion,
  ) async {
    try {
      print(
          '💾 Guardando interpretación para usuario: ${contexto.usuarioAuthId}');

      final responseContexto = await supabase.from('usuario_contexto').insert({
        'usuario_auth_id': contexto.usuarioAuthId,
        'analisis': contexto.analisis,
        'clima': contexto.clima,
        'cultivo': contexto.cultivo,
        'tipo_suelo': contexto.tipoSuelo,
        'resultado_ia': interpretacion,
        'fecha': DateTime.now().toIso8601String(),
      }).select();

      print('✅ Contexto guardado: $responseContexto');

      final responseHistorial =
          await supabase.from('historial_interpretaciones').insert({
        'usuario_auth_id': contexto.usuarioAuthId,
        'interpretacion': interpretacion,
        'fecha': DateTime.now().toIso8601String(),
      }).select();

      print('✅ Historial guardado: $responseHistorial');
      print('✅ Nueva interpretación guardada correctamente');

      if (responseHistorial.isNotEmpty) {
        print('✅ ID del registro: ${responseHistorial[0]['id']}');
        print('✅ Usuario guardado: ${responseHistorial[0]['usuario_auth_id']}');
      }

      print('💾 ========== GUARDADO EXITOSO ==========');
    } catch (e) {
      print('❌ Error al guardar interpretación: $e');
      rethrow;
    }
  }

  Future<List<UsuarioContexto>> obtenerHistorialContextos(
      String usuarioAuthId) async {
    try {
      final response = await supabase
          .from('usuario_contexto')
          .select('*')
          .eq('usuario_auth_id', usuarioAuthId)
          .order('fecha', ascending: false);

      return (response as List)
          .map((data) => UsuarioContexto.fromMap(data))
          .toList();
    } catch (e) {
      print('❌ Error al obtener historial: $e');
      return [];
    }
  }

  Future<Map<String, bool>> verificarDatosCompletos(
      String usuarioAuthId) async {
    try {
      final analisis = await supabase
          .from('analisis_suelo')
          .select('id')
          .eq('usuario_auth_id', usuarioAuthId)
          .limit(1)
          .maybeSingle();

      final clima = await supabase
          .from('clima')
          .select('id')
          .eq('usuario_auth_id', usuarioAuthId)
          .limit(1)
          .maybeSingle();

      final cultivo = await supabase
          .from('usuario_cultivo')
          .select('id')
          .eq('usuario_auth_id', usuarioAuthId)
          .limit(1)
          .maybeSingle();

      final tipoSuelo = await supabase
          .from('usuario_suelo')
          .select('id')
          .eq('usuario_auth_id', usuarioAuthId)
          .limit(1)
          .maybeSingle();

      return {
        'analisis': analisis != null,
        'clima': clima != null,
        'cultivo': cultivo != null,
        'tipo_suelo': tipoSuelo != null,
      };
    } catch (e) {
      print('❌ Error al verificar datos: $e');
      return {
        'analisis': false,
        'clima': false,
        'cultivo': false,
        'tipo_suelo': false,
      };
    }
  }
}
