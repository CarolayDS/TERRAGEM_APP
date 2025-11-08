import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_contexto.dart';

class IAService {
  final String apiKey = ''; //COLOCAR API KEY DE GEMINI

  Future<String> generarInterpretacion(UsuarioContexto contexto) async {
    if (apiKey.isEmpty || apiKey.contains('TU_API_KEY')) {
      return 'Falta configurar la API key de Gemini.';
    }

    final prompt = '''
Eres un agrónomo experto. Analiza estos datos y proporciona recomendaciones PRÁCTICAS y ESPECÍFICAS de forma CONCISA.

INFORMACIÓN DEL CULTIVO:
- Cultivo: ${contexto.cultivo?['cultivos']?['nombre'] ?? 'No especificado'}
- Área: ${contexto.cultivo?['valor'] ?? ''} ${contexto.cultivo?['unidad'] ?? ''}
- Tipo de suelo: ${contexto.tipoSuelo?['tipo_suelo']?['nombre'] ?? 'No especificado'}

CONDICIONES CLIMÁTICAS ACTUALES:
- Temperatura: ${contexto.clima?['temperatura'] ?? ''} °C
- Humedad: ${contexto.clima?['humedad'] ?? ''} %
- Condición: ${contexto.clima?['estado'] ?? ''}

RESULTADOS DEL ANÁLISIS DE SUELO:
- pH: ${contexto.analisis?['ph'] ?? ''}
- Conductividad Eléctrica (CE): ${contexto.analisis?['ce'] ?? ''} dS/m
- Materia Orgánica (MO): ${contexto.analisis?['mo'] ?? ''} %
- Nitrógeno (N): ${contexto.analisis?['n'] ?? ''} ppm
- Fósforo (P): ${contexto.analisis?['p'] ?? ''} ppm
- Potasio (K): ${contexto.analisis?['k'] ?? ''} ppm
- Calcio (Ca): ${contexto.analisis?['ca'] ?? ''} ppm
- Magnesio (Mg): ${contexto.analisis?['mg'] ?? ''} ppm

Estructura tu respuesta en 4 secciones breves y directas. Usa títulos en MAYÚSCULAS seguidos de dos puntos. Cada sección debe tener máximo 3-4 oraciones concisas. NO uses asteriscos, guiones o viñetas. Deja una línea en blanco entre secciones.

DIAGNÓSTICO DEL SUELO:
Resume en 3 oraciones el estado del pH y los nutrientes principales (N, P, K). Indica si están óptimos, deficientes o en exceso. Menciona el nivel de materia orgánica.

PROBLEMAS PRINCIPALES:
Identifica los 2 nutrientes más críticos. Explica brevemente el impacto en el cultivo en 2-3 oraciones.

FERTILIZACIÓN RECOMENDADA:
Recomienda 2 fertilizantes específicos con dosis por hectárea. Ejemplo: "Aplicar 120 kg/ha de urea (46-0-0) al inicio del ciclo". Sé específico pero breve.

MANEJO Y CORRECCIONES:
Da 2-3 recomendaciones prácticas sobre pH, riego o enmiendas considerando el clima. Máximo 3 oraciones.

IMPORTANTE: Sé CONCISO. Máximo 15 oraciones en total. Usa lenguaje técnico pero claro. Sin asteriscos, guiones ni viñetas.
''';

    try {
      print('Enviando datos a Gemini...');

      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
              "generationConfig": {
                "temperature": 0.7,
                "maxOutputTokens": 800,
              }
            }),
          )
          .timeout(const Duration(seconds: 90));

      print('STATUS CODE: ${response.statusCode}');

      if (response.statusCode != 200) {
        // Fallback a gemini-1.5-flash si el modelo 2.0 no está disponible
        final fallbackUri = Uri.parse(
            'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey');
        final fallback = await http
            .post(
              fallbackUri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "contents": [
                  {
                    "parts": [
                      {"text": prompt},
                    ],
                  },
                ],
                "generationConfig": {
                  "temperature": 0.7,
                  "maxOutputTokens": 800,
                }
              }),
            )
            .timeout(const Duration(seconds: 90));

        print('FALLBACK STATUS: ${fallback.statusCode}');

        if (fallback.statusCode != 200) {
          try {
            final err = jsonDecode(response.body);
            final msg = err['error']?['message'] ?? response.body;
            return 'Error ${response.statusCode} de Gemini: $msg';
          } catch (_) {
            return 'Error ${response.statusCode} al llamar a Gemini.';
          }
        }

        return _extraerTexto(fallback.body);
      }

      return _extraerTexto(response.body);
    } catch (e) {
      print('Error en la llamada a Gemini: $e');
      return 'Error al generar interpretación con Gemini: $e';
    }
  }

  /// Extrae y limpia el texto de la respuesta de Gemini
  String _extraerTexto(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      final candidates = data['candidates'];

      if (candidates is List && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content?['parts'];

        if (parts is List && parts.isNotEmpty) {
          final firstPart = parts.firstWhere(
              (p) => p is Map && p['text'] != null,
              orElse: () => null);

          if (firstPart != null) {
            String text = firstPart['text'] as String;

            // Limpieza del texto
            text = text.trim();

            // Eliminar asteriscos y símbolos de formato markdown
            text = text.replaceAll(RegExp(r'\*+'), '');
            text = text.replaceAll(RegExp(r'_{2,}'), '');

            // Eliminar guiones al inicio de línea (viñetas)
            text = text.replaceAll(RegExp(r'^[-•]\s+', multiLine: true), '');

            // Eliminar símbolos de encabezado markdown
            text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

            // Limpiar múltiples saltos de línea consecutivos (máximo 2)
            text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

            // Limpiar espacios múltiples
            text = text.replaceAll(RegExp(r' {2,}'), ' ');

            // Limpiar espacios al inicio y final de cada línea
            text = text.split('\n').map((line) => line.trim()).join('\n');

            if (text.isNotEmpty) {
              return text;
            }
          }
        }
      }

      return 'No se obtuvo respuesta válida de Gemini.';
    } catch (e) {
      print('Error al procesar respuesta: $e');
      return 'Error al procesar la respuesta de Gemini.';
    }
  }
}
