class TipoSuelo {
  final int id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;

  TipoSuelo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
  });

  factory TipoSuelo.fromMap(Map<String, dynamic> map) {
    return TipoSuelo(
      id: map['id'] as int,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      imagenUrl: map['imagen_url'] ?? '',
    );
  }
}
