class UsuarioContexto {
  final String usuarioAuthId;
  Map<String, dynamic>? analisis;
  Map<String, dynamic>? clima;
  Map<String, dynamic>? cultivo;
  Map<String, dynamic>? tipoSuelo;
  String? resultadoIa;
  String? interpretacion;

  UsuarioContexto({
    required this.usuarioAuthId,
    this.analisis,
    this.clima,
    this.cultivo,
    this.tipoSuelo,
    this.resultadoIa,
    this.interpretacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuario_auth_id': usuarioAuthId,
      'analisis': analisis,
      'clima': clima,
      'cultivo': cultivo,
      'tipo_suelo': tipoSuelo,
      'resultado_ia': resultadoIa,
      'interpretacion': interpretacion,
    };
  }

  factory UsuarioContexto.fromMap(Map<String, dynamic> map) {
    return UsuarioContexto(
      usuarioAuthId: map['usuario_auth_id'] ?? '',
      analisis: map['analisis'],
      clima: map['clima'],
      cultivo: map['cultivo'],
      tipoSuelo: map['tipo_suelo'],
      resultadoIa: map['resultado_ia'],
      interpretacion: map['interpretacion'],
    );
  }
}
