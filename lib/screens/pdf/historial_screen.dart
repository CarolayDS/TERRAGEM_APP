import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_filex/open_filex.dart';
import '../../services/historial_service.dart';
import '../../services/auth_service.dart';
import '../../services/clima_service.dart';
import '../maps/maps_screen.dart';

class HistorialPage extends StatefulWidget {
  final String usuarioAuthId;
  const HistorialPage({super.key, required this.usuarioAuthId});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final historialService = HistorialService();
  final authService = AuthService();
  final climaService = ClimaService();
  final Map<int, bool> _generandoPdf = {};
  String? nombreUsuario;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    try {
      final usuarioData = await authService.getUsuarioData();
      if (usuarioData != null && mounted) {
        setState(() {
          nombreUsuario = usuarioData['nombre'] ?? 'Usuario';
        });
      }
    } catch (e) {
      print('⚠️ Error al cargar usuario: $e');
      nombreUsuario = 'Usuario';
    }
  }

  Future<void> _mostrarClimaFlotante() async {
    final clima = await climaService.obtenerClimaActual();
    if (clima == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Clima en ${clima['ciudad']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🌡️ Temperatura: ${clima['temperatura']}°C"),
            Text("🌡️ Sensación: ${clima['sensacion']}°C"),
            Text("📉 Temp min: ${clima['temp_min']}°C"),
            Text("📈 Temp max: ${clima['temp_max']}°C"),
            Text("💧 Humedad: ${clima['humedad']}%"),
            Text("🌬️ Viento: ${clima['velocidad_viento']} m/s"),
            Text("☁️ Estado: ${clima['estado']}"),
            Text("📝 Descripción: ${clima['descripcion']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      _mostrarClimaFlotante();
    } else if (index == 1) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TiendasMapaScreen()),
      );
    }
  }

  String _limpiarTextoParaPdf(String texto) {
    return texto
        .replaceAll(RegExp(r'\uFE0F'), '')
        .replaceAll(RegExp(r'\u20E3'), '')
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _generarPdf(Map<String, dynamic> item, int index) async {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _generandoPdf[index] = true;
    });

    pw.Font? ttf;

    try {
      print(
          '📂 Iniciando generación de PDF para interpretación #${index + 1}...');

      final resultadoOriginal = item['resultado_ia'] ?? 'Sin interpretación';
      final resultado = _limpiarTextoParaPdf(resultadoOriginal);

      final fechaStr = item['fecha']?.toString() ?? DateTime.now().toString();
      final fechaFormateada = fechaStr.length > 19
          ? fechaStr.substring(0, 19).replaceAll('T', ' ')
          : (fechaStr.length > 10 ? fechaStr.substring(0, 10) : fechaStr);

      try {
        final fontData =
            await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        ttf = pw.Font.ttf(fontData);
        print('✅ Fuente NotoSans cargada correctamente');
      } catch (e) {
        print('⚠️ No se pudo cargar NotoSans, usando Helvetica: $e');
        ttf = pw.Font.helvetica();
      }

      if (!mounted) return;

      final parrafos =
          resultado.split('\n').where((p) => p.trim().isNotEmpty).toList();

      if (parrafos.isEmpty) {
        parrafos.add('Sin contenido disponible');
      }

      List<pw.Widget> construirParrafos() {
        List<pw.Widget> widgets = [];

        for (var parrafo in parrafos) {
          if (parrafo.length > 500) {
            final palabras = parrafo.split(' ');
            String chunk = '';

            for (var palabra in palabras) {
              if ((chunk + ' ' + palabra).length > 500) {
                if (chunk.isNotEmpty) {
                  widgets.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Text(
                        chunk.trim(),
                        style:
                            pw.TextStyle(font: ttf!, fontSize: 12, height: 1.5),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  );
                }
                chunk = palabra;
              } else {
                chunk = chunk.isEmpty ? palabra : chunk + ' ' + palabra;
              }
            }

            if (chunk.isNotEmpty) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Text(
                    chunk.trim(),
                    style: pw.TextStyle(font: ttf!, fontSize: 12, height: 1.5),
                    textAlign: pw.TextAlign.justify,
                  ),
                ),
              );
            }
          } else {
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  parrafo,
                  style: pw.TextStyle(font: ttf!, fontSize: 12, height: 1.5),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
            );
          }
        }

        return widgets;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Center(
              child: pw.Text(
                'Reporte de Interpretación del Análisis de Suelo',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 10.0),
            pw.Divider(thickness: 2, color: PdfColors.brown),
            pw.SizedBox(height: 16.0),
            pw.Text(
              'Usuario: ${nombreUsuario ?? widget.usuarioAuthId}',
              style: pw.TextStyle(font: ttf, fontSize: 12),
            ),
            pw.Text(
              'Fecha: $fechaFormateada',
              style: pw.TextStyle(font: ttf, fontSize: 12),
            ),
            pw.Text(
              'Interpretación #${index + 1}',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 20.0),
            pw.Text(
              'Resultado de la Interpretación:',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.brown,
              ),
            ),
            pw.SizedBox(height: 12.0),
            ...construirParrafos(),
            pw.SizedBox(height: 20.0),
            pw.Divider(thickness: 1),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generado automáticamente por IA - ${DateTime.now().year}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          "${dir.path}/interpretacion_historial_${DateTime.now().millisecondsSinceEpoch}_$index.pdf");

      if (!mounted) return;

      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      print('✅ PDF guardado en: ${file.path}');

      await OpenFilex.open(file.path);

      if (!mounted) return;

      print('✅ PDF abierto correctamente');

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('PDF generado exitosamente'),
            ],
          ),
          backgroundColor: const Color(0xFF6B3E26),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error al generar PDF: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _generandoPdf[index] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6B3E26);
    final secondaryColor = const Color(0xFFF8F5F0);

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          'Historial de Análisis',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: historialService.obtenerHistorial(widget.usuarioAuthId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cargando historial...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar historial',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final historial = snapshot.data;

          if (historial == null || historial.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sin historial de análisis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los análisis que realices aparecerán aquí',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historial.length,
            itemBuilder: (context, index) {
              final item = historial[index];
              final resultado = item['resultado_ia'] ?? 'Sin interpretación';
              final fechaStr = item['fecha']?.toString() ?? 'Sin fecha';
              final fechaFormateada = fechaStr.length > 19
                  ? fechaStr.substring(0, 19).replaceAll('T', ' ')
                  : (fechaStr.length > 10
                      ? fechaStr.substring(0, 10)
                      : fechaStr);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    childrenPadding: const EdgeInsets.all(20),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Análisis ${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            fechaFormateada,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(
                          resultado,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (_generandoPdf[index] ?? false)
                              ? null
                              : () => _generarPdf(item, index),
                          icon: Icon(
                            (_generandoPdf[index] ?? false)
                                ? Icons.hourglass_empty
                                : Icons.picture_as_pdf,
                            size: 22,
                          ),
                          label: Text(
                            (_generandoPdf[index] ?? false)
                                ? 'Generando PDF...'
                                : 'Generar PDF',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_generandoPdf[index] ?? false)
                                ? Colors.grey[400]
                                : const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: (_generandoPdf[index] ?? false) ? 0 : 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
            label: 'Clima',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory),
            label: 'Tiendas',
          ),
        ],
      ),
    );
  }
}
