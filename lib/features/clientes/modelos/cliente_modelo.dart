class ClienteModelo {
  final String? id;
  final String nombre;
  final String? telefono;
  final String? direccion;
  final double deudaTotal;
  final DateTime? fechaRegistro;
  final bool activo;

  ClienteModelo({
    this.id,
    required this.nombre,
    this.telefono,
    this.direccion,
    this.deudaTotal = 0.0,
    this.fechaRegistro,
    this.activo = true,
  });

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'telefono': telefono ?? '',
      'direccion': direccion ?? '',
      'deudaTotal': deudaTotal,
      'fechaRegistro': fechaRegistro?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'activo': activo,
    };
  }

  // Crear desde Firebase
  factory ClienteModelo.fromMap(Map<String, dynamic> map, String id) {
    return ClienteModelo(
      id: id,
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'],
      direccion: map['direccion'],
      deudaTotal: (map['deudaTotal'] ?? 0.0).toDouble(),
      fechaRegistro: map['fechaRegistro'] != null 
          ? DateTime.parse(map['fechaRegistro']) 
          : null,
      activo: map['activo'] ?? true,
    );
  }

  // Copiar con cambios
  ClienteModelo copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? direccion,
    double? deudaTotal,
    bool? activo,
  }) {
    return ClienteModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      deudaTotal: deudaTotal ?? this.deudaTotal,
      fechaRegistro: fechaRegistro,
      activo: activo ?? this.activo,
    );
  }

  // Si tiene deuda
  bool get tieneDeuda => deudaTotal > 0;
}