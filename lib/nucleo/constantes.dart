class AppConstantes {
  // ==================== COLECCIONES FIREBASE ====================
  static const String coleccionProductos = 'productos';
  static const String coleccionClientes = 'clientes';
  static const String coleccionVentas = 'ventas';
  static const String coleccionCompras = 'compras';
  static const String coleccionAbonos = 'abonos';
  
  // ==================== TIPOS DE PRECIO ====================
  static const String precioCompra= 'compra';
  static const String precioPublico = 'publico';
  static const String precioMayorista = 'mayorista';
  
  // ==================== TIPOS DE PAGO ====================
  static const String pagoContado = 'contado';
  static const String pagoCredito = 'credito';
  
  // ==================== ESTADOS ====================
  static const String ventaActiva = 'activa';
  static const String ventaAnulada = 'anulada';
  
  // ==================== FORMATOS ====================
  static const String formatoMoneda = 'S/. ';
  static const int decimales = 2;
  
  // ==================== MENSAJES ====================
  static const String mensajeCargando = 'Cargando...';
  static const String mensajeExito = 'Operación exitosa';
  static const String mensajeError = 'Ha ocurrido un error';
  static const String campoRequerido = 'Este campo es requerido';
  static const String stockInsuficiente = 'Stock insuficiente';
}