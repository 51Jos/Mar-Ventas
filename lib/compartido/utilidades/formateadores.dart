class Formateadores {
  // ==================== TEXTO ====================
  
  /// Capitaliza la primera letra
  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }
  
  /// Capitaliza cada palabra
  static String capitalizarPalabras(String texto) {
    if (texto.isEmpty) return texto;
    return texto.split(' ').map((palabra) => capitalizar(palabra)).join(' ');
  }
  
  /// Limpia espacios extras
  static String limpiarTexto(String texto) {
    return texto.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  // ==================== NÚMEROS ====================
  
  /// Formatea número con decimales
  static String numero(double num, [int decimales = 2]) {
    return num.toStringAsFixed(decimales);
  }
  
  /// Formatea como entero
  static String entero(num numero) {
    return numero.round().toString();
  }
  
  /// Formatea peso en kilos
  static String kilos(double peso) {
    if (peso >= 1000) {
      return '${numero(peso / 1000, 1)} ton';
    }
    return '${numero(peso, 2)} kg';
  }
  
  /// Formatea cantidad con unidad
  static String cantidad(double cant, String unidad) {
    return '${numero(cant, 2)} $unidad';
  }
  
  // ==================== TELÉFONO ====================
  
  /// Formatea teléfono peruano (999 999 999)
  static String telefono(String tel) {
    final limpio = tel.replaceAll(RegExp(r'[^\d]'), '');
    if (limpio.length != 9) return tel;
    
    return '${limpio.substring(0, 3)} ${limpio.substring(3, 6)} ${limpio.substring(6)}';
  }
  
  // ==================== PORCENTAJES ====================
  
  /// Formatea como porcentaje
  static String porcentaje(double valor, [int decimales = 0]) {
    return '${numero(valor, decimales)}%';
  }
  
  /// Calcula y formatea porcentaje
  static String calcularPorcentaje(double parte, double total) {
    if (total == 0) return '0%';
    final pct = (parte / total) * 100;
    return porcentaje(pct, 1);
  }
  
  // ==================== ESTADO ====================
  
  /// Texto para estados booleanos
  static String siNo(bool valor) {
    return valor ? 'Sí' : 'No';
  }
  
  /// Texto para disponibilidad
  static String disponible(bool valor) {
    return valor ? 'Disponible' : 'No disponible';
  }
  
  /// Texto para stock
  static String estadoStock(double cantidad) {
    if (cantidad <= 0) return 'Sin stock';
    if (cantidad < 5) return 'Stock bajo';
    return 'Disponible';
  }
  
  // ==================== OTROS ====================
  
  /// Abrevia texto largo
  static String abreviar(String texto, int maxCaracteres) {
    if (texto.length <= maxCaracteres) return texto;
    return '${texto.substring(0, maxCaracteres)}...';
  }
  
  /// Oculta parte del texto (para datos sensibles)
  static String ocultar(String texto, {int mostrar = 4}) {
    if (texto.length <= mostrar) return texto;
    final ocultos = '*' * (texto.length - mostrar);
    return '$ocultos${texto.substring(texto.length - mostrar)}';
  }
}