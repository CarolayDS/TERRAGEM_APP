import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/clima_service.dart';
import '../auth/login_screen.dart';
import '../clima/ClimaScreen.dart';
import '../maps/maps_screen.dart';
import 'package:nwt/screens/pdf/historial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  final climaService = ClimaService();
  Map<String, dynamic>? usuarioData;
  bool loading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final data = await auth.getUsuarioData();
    if (!mounted) return;
    setState(() {
      usuarioData = data;
      loading = false;
    });
  }

  Future<void> _guardarClima() async {
    final clima = await climaService.obtenerYGuardarClimaActual();
    if (clima != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClimaScreen(
            climaData: clima,
            usuarioAuthId: usuarioData!['auth_id'],
          ),
        ),
      );
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

  void _mostrarUsuarioInfo() {
    if (usuarioData == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "👤 Información del Usuario",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre: ${usuarioData!['nombre']}"),
            Text("Correo: ${usuarioData!['correo']}"),
            Text(
              "Registrado el: ${usuarioData!['fecha'].toString().split("T").first}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
          TextButton(
            onPressed: () async {
              await auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.red),
            ),
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
      // Ya está en Home
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TiendasMapaScreen()),
      );
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
        title: const Text(
          'TerraGem',
          style: TextStyle(
            color: Color(0xFF6B3E26),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF6B3E26)),
            onPressed: _mostrarUsuarioInfo,
          ),
        ],
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator(color: Color(0xFF6B3E26))
            : usuarioData != null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hola, ${usuarioData!['nombre']} 👋',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B3E26),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '¡Bienvenido a TerraGem!',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF8B5E3C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Image.asset(
                          'assets/images/bienvenido.png',
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ingresa los datos de tu análisis de suelo y recibe sugerencias personalizadas para lograr un crecimiento saludable y eficiente de tus cultivos. 🌾',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _guardarClima,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Interpretar Análisis',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (usuarioData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistorialPage(
                                    usuarioAuthId: usuarioData!['auth_id'],
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5E3C),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.history, color: Colors.white),
                          label: const Text(
                            'Historial',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Text('No se encontraron datos del usuario'),
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
