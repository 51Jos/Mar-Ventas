class FormateadorMoneda {
  static const String simbolo = 'S/';
  static const int decimales = 2;
  
  /// Formatea número como moneda
  static String formatear(double monto) {
    // Formato básico con 2 decimales
    final montoStr = monto.toStringAsFixed(decimales);
    
    // Separar parte entera y decimal
    final partes = montoStr.split('.');
    final entero = partes[0];
    final decimal = partes.length > 1 ? partes[1] : '00';
    
    // Agregar separadores de miles
    final enteroConSeparadores = _agregarSeparadorMiles(entero);
    
    return '$simbolo $enteroConSeparadores.$decimal';
  }
  
  /// Formato corto para montos grandes
  static String formatearCorto(double monto) {
    if (monto >= 1000000) {
      return '$simbolo ${(monto / 1000000).toStringAsFixed(1)}M';
    } else if (monto >= 1000) {
      return '$simbolo ${(monto / 1000).toStringAsFixed(1)}K';
    }
    return formatear(monto);
  }
  
  /// Formato sin símbolo
  static String soloNumero(double monto) {
    final formatted = formatear(monto);
    return formatted.replaceAll('$simbolo ', '');
  }
  
  /// Parsea string a double
  static double parsear(String texto) {
    // Remover símbolo y espacios
    String limpio = texto.replaceAll(simbolo, '').trim();
    
    // Remover separadores de miles
    limpio = limpio.replaceAll(',', '');
    
    // Reemplazar coma decimal por punto
    limpio = limpio.replaceAll(',', '.');
    
    return double.tryParse(limpio) ?? 0.0;
  }
  
  /// Valida si es un monto válido
  static bool esValido(String texto) {
    final monto = parsear(texto);
    return monto > 0;
  }
  
  /// Calcula el cambio
  static String calcularCambio(double total, double pago) {
    final cambio = pago - total;
    if (cambio < 0) return 'Falta: ${formatear(cambio.abs())}';
    return 'Cambio: ${formatear(cambio)}';
  }
  
  /// Calcula descuento
  static String conDescuento(double monto, double porcentajeDescuento) {
    final descuento = monto * (porcentajeDescuento / 100);
    final montoFinal = monto - descuento;
    return formatear(montoFinal);
  }
  
  /// Formato para rango de precios
  static String rango(double min, double max) {
    return '${formatear(min)} - ${formatear(max)}';
  }
  
  /// Agrega separador de miles
  static String _agregarSeparadorMiles(String numero) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return numero.replaceAllMapped(
      reg,
      (Match match) => '${match[1]},',
    );
  }
  
  /// Compara dos montos
  static int comparar(double monto1, double monto2) {
    if (monto1 < monto2) return -1;
    if (monto1 > monto2) return 1;
    return 0;
  }
  
  /// Suma lista de montos
  static double sumar(List<double> montos) {
    return montos.fold(0.0, (total, monto) => total + monto);
  }
  
  /// Promedio de montos
  static double promedio(List<double> montos) {
    if (montos.isEmpty) return 0.0;
    return sumar(montos) / montos.length;
  }
}