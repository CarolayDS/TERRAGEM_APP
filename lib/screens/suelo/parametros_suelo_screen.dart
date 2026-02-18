import 'package:flutter/material.dart';
import '../../services/parametro_service.dart';
import '../../models/parametro.dart';
import '../analisis/interpretacion_general_screen.dart';

class IngresarParametrosPage extends StatefulWidget {
  final String usuarioAuthId;
  final int cultivoId;
  final String cultivoNombre;

  const IngresarParametrosPage({
    super.key,
    required this.usuarioAuthId,
    required this.cultivoId,
    required this.cultivoNombre,
  });

  @override
  State<IngresarParametrosPage> createState() => _IngresarParametrosPageState();
}

class _IngresarParametrosPageState extends State<IngresarParametrosPage> {
  final _formKey = GlobalKey<FormState>();
  final _parametroService = ParametroService();
  final Map<String, TextEditingController> _controllers = {};

  List<ParametroCultivo> _parametros = [];
  bool _cargando = true;
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    _cargarParametros();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
    } else if (index == 2) {
      Navigator.pushNamed(context, '/tiendas');
    }
  }

  Future<void> _cargarParametros() async {
    try {
      final lista = await _parametroService.obtenerParametrosPorCultivo(
        widget.cultivoId,
      );
      setState(() {
        _parametros = lista;
        for (var p in lista) {
          _controllers[p.nombreParametro] = TextEditingController();
        }
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error loading parameters: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _guardarAnalisis() async {
    if (_formKey.currentState!.validate()) {
      final valores = <String, double>{};
      for (var param in _parametros) {
        valores[param.nombreParametro] =
            double.tryParse(_controllers[param.nombreParametro]!.text) ?? 0;
      }

      try {
        await _parametroService.guardarAnalisisUsuario(
          usuarioAuthId: widget.usuarioAuthId,
          cultivoId: widget.cultivoId,
          valores: valores,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Parameters saved correctly'),
              ],
            ),
            backgroundColor: const Color(0xFF6B3E26),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InterpretacionGeneralScreen(
              usuarioAuthId: widget.usuarioAuthId,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error saving: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  IconData _getIconForParameter(String paramName) {
    final name = paramName.toLowerCase();
    if (name.contains('ph')) return Icons.science_outlined;
    if (name.contains('nitrogen')) return Icons.bubble_chart;
    if (name.contains('phosphorus')) return Icons.blur_on;
    if (name.contains('potassium')) return Icons.scatter_plot;
    if (name.contains('temperature')) return Icons.thermostat_outlined;
    if (name.contains('humidity')) return Icons.water_drop_outlined;
    if (name.contains('electrical conductivity')) return Icons.bolt_outlined;
    if (name.contains('organic matter')) return Icons.eco_outlined;
    if (name.contains('calcium')) return Icons.grain;
    if (name.contains('magnesium')) return Icons.grass;
    return Icons.analytics_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6B3E26);
    final secondaryColor = const Color(0xFFF8F5F0);

    if (_cargando) {
      return Scaffold(
        backgroundColor: secondaryColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          'Soil Parameters',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
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
                    Icons.science,
                    size: 40,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soil Analysis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your lab test results',
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

            // List of parameters
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _parametros.length,
                itemBuilder: (context, index) {
                  final param = _parametros[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Parameter title with icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getIconForParameter(param.nombreParametro),
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    param.nombreParametro,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  if (param.unidad != null &&
                                      param.unidad!.isNotEmpty)
                                    Text(
                                      'Unit: ${param.unidad}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Input field
                        TextFormField(
                          controller: _controllers[param.nombreParametro],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter the value',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: Icon(
                              Icons.edit_outlined,
                              color: primaryColor,
                            ),
                            filled: true,
                            fillColor: secondaryColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a value';
                            }
                            final numValue = double.tryParse(value);
                            if (numValue == null) {
                              return 'It must be a number';
                            }
                            if (numValue < param.valorMinimo ||
                                numValue > param.valorMaximo) {
                              return 'Out of permitted range';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Allowed range
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5E3C).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF8B5E3C).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF8B5E3C),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Range: ${param.valorMinimo} - ${param.valorMaximo}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8B5E3C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Save button
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardarAnalisis,
                  icon: const Icon(Icons.check_circle_outline, size: 24),
                  label: const Text(
                    'Save and View Analysis',
                    style: TextStyle(
                      fontSize: 17,
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
                    elevation: 5,
                  ),
                ),
              ),
            ),
          ],
        ),
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
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory),
            label: 'Stores',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
