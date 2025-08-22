class Validadores {
  // ==================== VALIDACIONES BÁSICAS ====================
  
  /// Valida que el campo no esté vacío
  static String? requerido(String? valor, [String mensaje = 'Campo requerido']) {
    if (valor == null || valor.trim().isEmpty) {
      return mensaje;
    }
    return null;
  }
  
  /// Valida email básico
  static String? email(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Email requerido';
    }
    
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(valor)) {
      return 'Email inválido';
    }
    
    return null;
  }
  
  /// Valida teléfono (9 dígitos para Perú)
  static String? telefono(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Teléfono requerido';
    }
    
    // Remover espacios y guiones
    final numeroLimpio = valor.replaceAll(RegExp(r'[\s-]'), '');
    
    if (numeroLimpio.length != 9) {
      return 'Debe tener 9 dígitos';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(numeroLimpio)) {
      return 'Solo números';
    }
    
    return null;
  }
  
  /// Valida números decimales (para precios y cantidades)
  static String? numero(String? valor, {bool decimal = true}) {
    if (valor == null || valor.isEmpty) {
      return 'Número requerido';
    }
    
    // Reemplazar coma por punto
    final valorLimpio = valor.replaceAll(',', '.');
    
    if (decimal) {
      // Permitir decimales
      if (!RegExp(r'^[0-9]+\.?[0-9]*$').hasMatch(valorLimpio)) {
        return 'Número inválido';
      }
    } else {
      // Solo enteros
      if (!RegExp(r'^[0-9]+$').hasMatch(valorLimpio)) {
        return 'Solo números enteros';
      }
    }
    
    return null;
  }
  
  /// Valida que sea mayor a cero
  static String? mayorQueCero(String? valor) {
    final validacionNumero = numero(valor);
    if (validacionNumero != null) {
      return validacionNumero;
    }
    
    final numeroValor = double.tryParse(valor!.replaceAll(',', '.')) ?? 0;
    if (numeroValor <= 0) {
      return 'Debe ser mayor a 0';
    }
    
    return null;
  }
  
  /// Valida rango de números
  static String? rango(String? valor, double min, double max) {
    final validacionNumero = numero(valor);
    if (validacionNumero != null) {
      return validacionNumero;
    }
    
    final num = double.tryParse(valor!.replaceAll(',', '.')) ?? 0;
    if (num < min || num > max) {
      return 'Debe estar entre $min y $max';
    }
    
    return null;
  }
  
  /// Valida longitud mínima
  static String? minimo(String? valor, int min) {
    if (valor == null || valor.length < min) {
      return 'Mínimo $min caracteres';
    }
    return null;
  }
  
  /// Valida longitud máxima
  static String? maximo(String? valor, int max) {
    if (valor != null && valor.length > max) {
      return 'Máximo $max caracteres';
    }
    return null;
  }
  
  /// Valida contraseña simple
  static String? password(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Contraseña requerida';
    }
    
    if (valor.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    
    return null;
  }
  
  /// Confirmar contraseña
  static String? confirmarPassword(String? valor, String password) {
    if (valor == null || valor.isEmpty) {
      return 'Confirme la contraseña';
    }
    
    if (valor != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }
}