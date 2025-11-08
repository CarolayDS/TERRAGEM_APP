import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../services/ia_service.dart';
import '../../services/usuario_contexto_service.dart';
import '../../services/auth_service.dart';
import '../../services/clima_service.dart';
import '../pdf/historial_screen.dart';
import '../maps/maps_screen.dart';

class InterpretacionGeneralScreen extends StatefulWidget {
  final String usuarioAuthId;
  const InterpretacionGeneralScreen({super.key, required this.usuarioAuthId});

  @override
  State<InterpretacionGeneralScreen> createState() =>
      _InterpretacionGeneralScreenState();
}

class _InterpretacionGeneralScreenState
    extends State<InterpretacionGeneralScreen> {
  final iaService = IAService();
  final contextoService = UsuarioContextoService();
  final authService = AuthService();
  final climaService = ClimaService();

  String? resultado;
  bool cargando = true;
  bool _generandoPdf = false;
  int _selectedIndex = 1;

  String? nombreUsuario;
  String? cultivoNombre;
  String? areaCultivo;
  String? tipoSuelo;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _generarInterpretacion();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final usuarioData = await authService.getUsuarioData();
      if (usuarioData != null && mounted) {
        setState(() {
          nombreUsuario = usuarioData['nombre'] ?? 'Usuario';
        });
        print('✅ Usuario cargado: $nombreUsuario');
      } else {
        nombreUsuario = 'Usuario';
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
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      _mostrarClimaFlotante();
    } else if (index == 1) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TiendasMapaScreen()),
      );
    }
  }

  Future<void> _generarInterpretacion() async {
    print('🧠 Generando interpretación con Gemini...');
    try {
      final contexto =
          await contextoService.obtenerUltimoContexto(widget.usuarioAuthId);

      if (contexto == null) {
        setState(() {
          resultado = 'No se encontró información suficiente.';
          cargando = false;
        });
        return;
      }

      cultivoNombre =
          contexto.cultivo?['cultivos']?['nombre'] ?? 'No especificado';
      areaCultivo =
          '${contexto.cultivo?['valor'] ?? ''} ${contexto.cultivo?['unidad'] ?? ''}';
      tipoSuelo =
          contexto.tipoSuelo?['tipo_suelo']?['nombre'] ?? 'No especificado';

      final respuesta = await iaService.generarInterpretacion(contexto);

      setState(() {
        resultado = respuesta;
        cargando = false;
      });

      print('✅ Interpretación generada:\n$respuesta');

      if (respuesta.isNotEmpty) {
        await contextoService.guardarInterpretacion(contexto, respuesta);
      }
    } catch (e) {
      print('⚠️ Error al generar interpretación: $e');
      setState(() {
        resultado = 'Error al generar la interpretación: $e';
        cargando = false;
      });
    }
  }

  Future<void> _generarPdf() async {
    if (_generandoPdf) return;

    setState(() => _generandoPdf = true);

    try {
      print('📂 Iniciando generación de PDF...');

      final textoInterpretacion =
          resultado ?? 'No se encontró texto generado por la IA.';

      if (textoInterpretacion.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                    child:
                        Text('No hay texto disponible para generar el PDF.')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() => _generandoPdf = false);
        return;
      }

      // Cargar fuente TrueType
      pw.Font ttf;
      pw.Font ttfBold;
      try {
        final fontData =
            await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        ttf = pw.Font.ttf(fontData);

        try {
          final fontBoldData =
              await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
          ttfBold = pw.Font.ttf(fontBoldData);
        } catch (e) {
          ttfBold = ttf;
        }

        print('✅ Fuentes cargadas correctamente');
      } catch (e) {
        print('⚠️ Usando fuentes por defecto: $e');
        ttf = pw.Font.helvetica();
        ttfBold = pw.Font.helveticaBold();
      }

      // Cargar logo (OPCIONAL)
      pw.ImageProvider? logoImage;
      try {
        final logoData = await rootBundle.load('assets/images/logo.png');
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
        print('✅ Logo cargado');
      } catch (e) {
        print('⚠️ Logo no encontrado, se usará solo texto: $e');
      }

      // Dividir el texto en secciones
      final parrafos = textoInterpretacion
          .split('\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();

      final pdf = pw.Document();
      final primaryColor = PdfColor.fromHex('#6B3E26');
      final accentColor = PdfColor.fromHex('#8B5A3C');
      final lightBg = PdfColor.fromHex('#F8F5F0');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Encabezado con diseño moderno
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: primaryColor, width: 2),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ANÁLISIS DE SUELO',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 24,
                              color: primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Reporte Agronómico Profesional',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 12,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      // LOGO O ÍCONO ALTERNATIVO
                      logoImage != null
                          ? pw.Container(
                              width: 60,
                              height: 60,
                              child: pw.Image(logoImage),
                            )
                          : pw.Container(
                              padding: const pw.EdgeInsets.all(12),
                              decoration: pw.BoxDecoration(
                                color: primaryColor,
                                borderRadius: pw.BorderRadius.circular(8),
                              ),
                              child: pw.Text(
                                'TG',
                                style: pw.TextStyle(
                                  font: ttfBold,
                                  fontSize: 20,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Información del usuario y cultivo
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INFORMACIÓN GENERAL',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 14,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildInfoRow(
                      ttf, ttfBold, 'Productor:', nombreUsuario ?? 'Usuario'),
                  _buildInfoRow(ttf, ttfBold, 'Cultivo:',
                      cultivoNombre ?? 'No especificado'),
                  _buildInfoRow(ttf, ttfBold, 'Área:', areaCultivo ?? '-'),
                  _buildInfoRow(ttf, ttfBold, 'Tipo de Suelo:',
                      tipoSuelo ?? 'No especificado'),
                  _buildInfoRow(
                    ttf,
                    ttfBold,
                    'Fecha de Análisis:',
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Título de interpretación
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'INTERPRETACIÓN Y RECOMENDACIONES',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 14,
                  color: PdfColors.white,
                ),
              ),
            ),

            pw.SizedBox(height: 16),

            // Contenido de la interpretación
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: parrafos.map((parrafo) {
                  final esTitulo = parrafo.contains(':') &&
                      parrafo.split(':')[0].length < 50 &&
                      parrafo.toUpperCase() == parrafo;

                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Text(
                      parrafo,
                      style: pw.TextStyle(
                        font: esTitulo ? ttfBold : ttf,
                        fontSize: esTitulo ? 13 : 11,
                        height: 1.6,
                        color: esTitulo ? primaryColor : PdfColors.grey800,
                      ),
                      textAlign: pw.TextAlign.justify,
                    ),
                  );
                }).toList(),
              ),
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Documento generado automáticamente',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  '© ${DateTime.now().year} - Sistema IA Agrícola',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          "${dir.path}/analisis_suelo_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Abrir PDF
      await OpenFilex.open(file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
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
        ),
      );
    } catch (e) {
      print('❌ Error al generar PDF: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error al generar PDF: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  pw.Widget _buildInfoRow(
      pw.Font regular, pw.Font bold, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                  font: bold, fontSize: 11, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                  font: regular, fontSize: 11, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _verHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistorialPage(usuarioAuthId: widget.usuarioAuthId),
      ),
    );
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
          'Análisis del Suelo',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: cargando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Analizando con IA...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header con ícono
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor.withOpacity(0.1), secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 40,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interpretación IA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Análisis completo de tu suelo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido del análisis
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
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
                    child: SingleChildScrollView(
                      child: SelectableText(
                        resultado ?? 'Sin resultado disponible.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                ),

                // Botones de acción
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generandoPdf ? null : _generarPdf,
                          icon: Icon(
                            _generandoPdf
                                ? Icons.hourglass_empty
                                : Icons.picture_as_pdf,
                            size: 22,
                          ),
                          label: Text(
                            _generandoPdf ? 'Generando...' : 'Generar PDF',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _generandoPdf
                                ? Colors.grey[400]
                                : const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: _generandoPdf ? 0 : 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _verHistorial,
                          icon: const Icon(Icons.history, size: 22),
                          label: const Text(
                            'Historial',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
