class ParametroCultivo {
  final int id;
  final int cultivoId;
  final String nombreParametro;
  final double valorMinimo;
  final double valorMaximo;
  final String? unidad;
  final String? recomendacion;

  ParametroCultivo({
    required this.id,
    required this.cultivoId,
    required this.nombreParametro,
    required this.valorMinimo,
    required this.valorMaximo,
    this.unidad,
    this.recomendacion,
  });

  factory ParametroCultivo.fromMap(Map<String, dynamic> map) {
    return ParametroCultivo(
      id: map['id'],
      cultivoId: map['cultivo_id'],
      nombreParametro: map['parametro'],
      valorMinimo: (map['valor_min'] as num).toDouble(),
      valorMaximo: (map['valor_max'] as num).toDouble(),
      unidad: map['unidad'],
      recomendacion: map['recomendacion'],
    );
  }
}
