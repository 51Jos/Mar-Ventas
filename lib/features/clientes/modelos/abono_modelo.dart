class AbonoModelo {
  final String? id;
  final String clienteId;
  final String clienteNombre;
  final double monto;
  final String? ventaId; // ID de la venta relacionada (opcional)
  final DateTime fecha;
  final String? observaciones;

  AbonoModelo({
    this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.monto,
    this.ventaId,
    required this.fecha,
    this.observaciones,
  });

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'monto': monto,
      'ventaId': ventaId,
      'fecha': fecha.toIso8601String(),
      'observaciones': observaciones ?? '',
    };
  }

  // Crear desde Firebase
  factory AbonoModelo.fromMap(Map<String, dynamic> map, String id) {
    return AbonoModelo(
      id: id,
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      monto: (map['monto'] ?? 0.0).toDouble(),
      ventaId: map['ventaId'],
      fecha: DateTime.parse(map['fecha']),
      observaciones: map['observaciones'],
    );
  }
}