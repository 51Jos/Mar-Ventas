class FormateadorFecha {
  static const List<String> meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  
  static const List<String> diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 
    'Viernes', 'Sábado', 'Domingo'
  ];
  
  static const List<String> mesesCortos = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];
  
  /// Formato: 15/03/2024
  static String fecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final ano = fecha.year;
    return '$dia/$mes/$ano';
  }
  
  /// Formato: 15/03/2024 14:30
  static String fechaHora(DateTime fecha) {
    return '${FormateadorFecha.fecha(fecha)} ${hora(fecha)}';
  }
  
  /// Formato: 14:30
  static String hora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
  
  /// Formato: 15 de Marzo de 2024
  static String fechaCompleta(DateTime fecha) {
    final dia = fecha.day;
    final mes = meses[fecha.month - 1];
    final ano = fecha.year;
    return '$dia de $mes de $ano';
  }
  
  /// Formato: 15 Mar 2024
  static String fechaCorta(DateTime fecha) {
    final dia = fecha.day;
    final mes = mesesCortos[fecha.month - 1];
    final ano = fecha.year;
    return '$dia $mes $ano';
  }
  
  /// Formato: Viernes, 15 de Marzo
  static String fechaConDia(DateTime fecha) {
    final diaSemana = diasSemana[fecha.weekday - 1];
    final dia = fecha.day;
    final mes = meses[fecha.month - 1];
    return '$diaSemana, $dia de $mes';
  }
  
  /// Formato relativo: Hoy, Ayer, fecha
  static String relativo(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inDays == 0 && ahora.day == fecha.day) {
      return 'Hoy';
    } else if (diferencia.inDays == 1 || 
              (diferencia.inDays == 0 && ahora.day != fecha.day)) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return FormateadorFecha.fecha(fecha);
    }
  }
  
  /// Formato de tiempo transcurrido
  static String tiempoTranscurrido(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inMinutes < 1) {
      return 'Ahora';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 30) {
      return 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inDays < 365) {
      final meses = (diferencia.inDays / 30).floor();
      return 'Hace $meses ${meses == 1 ? 'mes' : 'meses'}';
    } else {
      final anos = (diferencia.inDays / 365).floor();
      return 'Hace $anos ${anos == 1 ? 'año' : 'años'}';
    }
  }
  
  /// Rango de fechas
  static String rango(DateTime inicio, DateTime fin) {
    if (inicio.year == fin.year) {
      if (inicio.month == fin.month) {
        // Mismo mes y año
        return '${inicio.day} - ${fin.day} de ${meses[inicio.month - 1]} ${inicio.year}';
      } else {
        // Mismo año
        return '${inicio.day} ${mesesCortos[inicio.month - 1]} - ${fin.day} ${mesesCortos[fin.month - 1]} ${inicio.year}';
      }
    } else {
      // Diferente año
      return '${fechaCorta(inicio)} - ${fechaCorta(fin)}';
    }
  }
  
  /// Parsea string a DateTime
  static DateTime? parsear(String texto) {
    try {
      // Formato: dd/mm/yyyy
      final partes = texto.split('/');
      if (partes.length == 3) {
        final dia = int.parse(partes[0]);
        final mes = int.parse(partes[1]);
        final ano = int.parse(partes[2]);
        return DateTime(ano, mes, dia);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Edad desde fecha de nacimiento
  static int edad(DateTime fechaNacimiento) {
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    if (ahora.month < fechaNacimiento.month ||
        (ahora.month == fechaNacimiento.month && 
         ahora.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }
  
  /// Días hasta fecha
  static int diasHasta(DateTime fecha) {
    final ahora = DateTime.now();
    return fecha.difference(ahora).inDays;
  }
}