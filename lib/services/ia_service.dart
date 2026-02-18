import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_contexto.dart';

class IAService {
  final String apiKey = 'AIzaSyDILUt6LvPPSuRaEOgSDVREnsVwQswHpxg';

  Future<String> generarInterpretacion(UsuarioContexto contexto) async {
    if (apiKey.isEmpty || apiKey.contains('TU_API_KEY')) {
      return 'The Gemini API key needs to be configured.';
    }

    final prompt = '''
You are an expert agronomist. It analyzes this data and provides PRACTICAL and SPECIFIC recommendations in a CONCISE way.
CULTIVATION INFORMATION:
- Cultivation: ${contexto.cultivo?['cultivos']?['nombre'] ?? 'No especificado'}
- Area: ${contexto.cultivo?['valor'] ?? ''} ${contexto.cultivo?['unidad'] ?? ''}
- Type of soil: ${contexto.tipoSuelo?['tipo_suelo']?['nombre'] ?? 'No especificado'}

CURRENT WEATHER CONDITIONS:
- Temperature: ${contexto.clima?['temperatura'] ?? ''} °C
- Humidity: ${contexto.clima?['humedad'] ?? ''} %
- Condition: ${contexto.clima?['estado'] ?? ''}

RESULTS OF THE SOIL ANALYSIS:
- pH: ${contexto.analisis?['ph'] ?? ''}
- Conductividad Eléctrica (CE): ${contexto.analisis?['ce'] ?? ''} dS/m
- Organic Matter (MO): ${contexto.analisis?['mo'] ?? ''} %
- Nitrogen (N): ${contexto.analisis?['n'] ?? ''} ppm
- Phosphorus (P): ${contexto.analisis?['p'] ?? ''} ppm
- Potassium (K): ${contexto.analisis?['k'] ?? ''} ppm
- Calcium (Ca): ${contexto.analisis?['ca'] ?? ''} ppm
- Magnesium (Mg): ${contexto.analisis?['mg'] ?? ''} ppm

Structure your answer into 4 short, straightforward sections. Use CAPITALIZED titles followed by a colon. Each section should have a maximum of 3-4 concise sentences. Do NOT use asterisks, dashes or bullet points. Leave a blank line between sections.

DIAGNOSIS OF THE SOIL:
Summarize in 3 sentences the pH status and the main nutrients (N, P, K). It indicates whether they are optimal, deficient or in excess. It mentions the level of organic matter.

MAIN PROBLEMS:
Identify the 2 most critical nutrients. Briefly explain the impact on the crop in 2-3 sentences.

RECOMMENDED FERTILIZATION:
It recommends 2 specific fertilizers with doses per hectare. Example: "Apply 120 kg/ha of urea (46-0-0) at the beginning of the cycle." Be specific but brief.

HANDLING AND CORRECTIONS:
Gives 2-3 practical recommendations on pH, irrigation or amendments considering the climate. Maximum of 3 sentences.

IMPORTANT: BE CONCISE. Maximum 15 sentences in total. Use technical but clear language. No asterisks, dashes or bullet points.''';

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

  /// Extract and clean the text of the Gemini response

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
            text = text.trim();
            text = text.replaceAll(RegExp(r'\*+'), '');
            text = text.replaceAll(RegExp(r'_{2,}'), '');
            text = text.replaceAll(RegExp(r'^[-•]\s+', multiLine: true), '');
            text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
            text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
            text = text.replaceAll(RegExp(r' {2,}'), ' ');
            text = text.split('\n').map((line) => line.trim()).join('\n');

            if (text.isNotEmpty) {
              return text;
            }
          }
        }
      }

      return 'No valid response was obtained from Gemini.';
    } catch (e) {
      print('Error while processing response: $e');
      return 'Error processing Gemini response.';
    }
  }
}
