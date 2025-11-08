class Cultivo {
  final int id;
  final String nombre;
  final String imagenUrl;

  Cultivo({required this.id, required this.nombre, required this.imagenUrl});

  factory Cultivo.fromMap(Map<String, dynamic> map) {
    return Cultivo(
      id: map['id'],
      nombre: map['nombre'],
      imagenUrl: map['imagen_url'] ?? '',
    );
  }
}
