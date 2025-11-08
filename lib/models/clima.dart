class Clima {
  final DateTime fecha;
  final double temperatura;
  final String descripcion;
  final String region;

  Clima({
    required this.fecha,
    required this.temperatura,
    required this.descripcion,
    required this.region,
  });

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'temperatura': temperatura,
      'descripcion': descripcion,
      'region': region,
    };
  }
}
