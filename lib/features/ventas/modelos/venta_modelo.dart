class VentaModelo {
  final String? id;
  final String? clienteId;
  final String clienteNombre;
  final String? clienteTelefono;
  final List<ItemVenta> items;
  final double subtotal;
  final double descuento;
  final double total;
  final String tipoPago; // contado, credito
  final String metodoPago; // efectivo, yape, plin, transferencia
  final double montoPagado; // Monto pagado en el momento
  final double saldo; // Saldo pendiente si es crédito
  final String estado; // activa, anulada, pagada, pendiente
  final DateTime fecha;
  final String? observaciones;

  VentaModelo({
    this.id,
    this.clienteId,
    required this.clienteNombre,
    this.clienteTelefono,
    required this.items,
    required this.tipoPago,
    required this.metodoPago,
    this.montoPagado = 0,
    this.descuento = 0,
    required this.fecha,
    this.estado = 'activa',
    this.observaciones,
  })  : subtotal = items.fold(0.0, (double sum, item) => sum + item.total),
        total = items.fold(0.0, (double sum, item) => sum + item.total) - descuento,
        saldo = tipoPago == 'credito' 
            ? items.fold(0.0, (double sum, item) => sum + item.total) - descuento - montoPagado
            : 0;

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'clienteTelefono': clienteTelefono,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'descuento': descuento,
      'total': total,
      'tipoPago': tipoPago,
      'metodoPago': metodoPago,
      'montoPagado': montoPagado,
      'saldo': saldo,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
      'observaciones': observaciones,
    };
  }

  // Crear desde Firebase
  factory VentaModelo.fromMap(Map<String, dynamic> map, String id) {
    return VentaModelo(
      id: id,
      clienteId: map['clienteId'],
      clienteNombre: map['clienteNombre'] ?? '',
      clienteTelefono: map['clienteTelefono'],
      items: (map['items'] as List).map((item) => ItemVenta.fromMap(item)).toList(),
      tipoPago: map['tipoPago'] ?? 'contado',
      metodoPago: map['metodoPago'] ?? 'efectivo',
      montoPagado: (map['montoPagado'] ?? 0).toDouble(),
      descuento: (map['descuento'] ?? 0).toDouble(),
      fecha: DateTime.parse(map['fecha']),
      estado: map['estado'] ?? 'activa',
      observaciones: map['observaciones'],
    );
  }

  // Copiar con cambios
  VentaModelo copyWith({
    String? estado,
    double? montoPagado,
    double? saldo,
  }) {
    return VentaModelo(
      id: id,
      clienteId: clienteId,
      clienteNombre: clienteNombre,
      clienteTelefono: clienteTelefono,
      items: items,
      tipoPago: tipoPago,
      metodoPago: metodoPago,
      montoPagado: montoPagado ?? this.montoPagado,
      descuento: descuento,
      fecha: fecha,
      estado: estado ?? this.estado,
      observaciones: observaciones,
    );
  }
}

/// Modelo de Item de Venta
class ItemVenta {
  final String productoId;
  final String productoNombre;
  final double cantidad; // en kilos
  final double precio; // precio unitario
  final String tipoPrecio; // publico, mayorista
  final double total;

  ItemVenta({
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precio,
    required this.tipoPrecio,
  }) : total = cantidad * precio;

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'productoNombre': productoNombre,
      'cantidad': cantidad,
      'precio': precio,
      'tipoPrecio': tipoPrecio,
      'total': total,
    };
  }

  factory ItemVenta.fromMap(Map<String, dynamic> map) {
    return ItemVenta(
      productoId: map['productoId'] ?? '',
      productoNombre: map['productoNombre'] ?? '',
      cantidad: (map['cantidad'] ?? 0).toDouble(),
      precio: (map['precio'] ?? 0).toDouble(),
      tipoPrecio: map['tipoPrecio'] ?? 'publico',
    );
  }
}