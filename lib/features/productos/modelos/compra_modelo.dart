class CompraModelo {
  final String? id;
  final String productoId;
  final String productoNombre;
  final String proveedor;
  final double kilos;
  final double precioKilo;
  final double total;
  final DateTime fecha;

  CompraModelo({
    this.id,
    required this.productoId,
    required this.productoNombre,
    required this.proveedor,
    required this.kilos,
    required this.precioKilo,
    required this.fecha,
  }) : total = kilos * precioKilo;

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'productoNombre': productoNombre,
      'proveedor': proveedor,
      'kilos': kilos,
      'precioKilo': precioKilo,
      'total': total,
      'fecha': fecha.toIso8601String(),
    };
  }

  // Crear desde Firebase
  factory CompraModelo.fromMap(Map<String, dynamic> map, String id) {
    return CompraModelo(
      id: id,
      productoId: map['productoId'] ?? '',
      productoNombre: map['productoNombre'] ?? '',
      proveedor: map['proveedor'] ?? '',
      kilos: (map['kilos'] ?? 0).toDouble(),
      precioKilo: (map['precioKilo'] ?? 0).toDouble(),
      fecha: DateTime.parse(map['fecha']),
    );
  }
}