class ProductoModelo {
  final String? id;
  final String nombre;
  final double stock; // en kilos
  final double precioPublico;
  final double precioMayorista;
  final double? precioCompra; // último precio de compra
  final DateTime? fechaActualizacion;
  final bool activo;

  ProductoModelo({
    this.id,
    required this.nombre,
    required this.stock,
    required this.precioPublico,
    required this.precioMayorista,
    this.precioCompra,
    this.fechaActualizacion,
    this.activo = true,
  });

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'stock': stock,
      'precioPublico': precioPublico,
      'precioMayorista': precioMayorista,
      'precioCompra': precioCompra,
      'fechaActualizacion': DateTime.now().toIso8601String(),
      'activo': activo,
    };
  }

  // Crear desde Firebase
  factory ProductoModelo.fromMap(Map<String, dynamic> map, String id) {
    return ProductoModelo(
      id: id,
      nombre: map['nombre'] ?? '',
      stock: (map['stock'] ?? 0).toDouble(),
      precioPublico: (map['precioPublico'] ?? 0).toDouble(),
      precioMayorista: (map['precioMayorista'] ?? 0).toDouble(),
      precioCompra: map['precioCompra']?.toDouble(),
      fechaActualizacion: map['fechaActualizacion'] != null 
          ? DateTime.parse(map['fechaActualizacion']) 
          : null,
      activo: map['activo'] ?? true,
    );
  }

  // Copiar con cambios
  ProductoModelo copyWith({
    String? id,
    String? nombre,
    double? stock,
    double? precioPublico,
    double? precioMayorista,
    double? precioCompra,
    bool? activo,
  }) {
    return ProductoModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      stock: stock ?? this.stock,
      precioPublico: precioPublico ?? this.precioPublico,
      precioMayorista: precioMayorista ?? this.precioMayorista,
      precioCompra: precioCompra ?? this.precioCompra,
      activo: activo ?? this.activo,
    );
  }
}