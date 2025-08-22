import 'package:flutter/material.dart';

class Dimensiones {
  // ==================== ESPACIADOS ====================
  static const double espacioXS = 4.0;
  static const double espacioS = 8.0;
  static const double espacioM = 16.0;
  static const double espacioL = 24.0;
  static const double espacioXL = 32.0;
  
  // ==================== PADDING ====================
  static const EdgeInsets paddingTodo = EdgeInsets.all(16);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets paddingTarjeta = EdgeInsets.all(12);
  
  // ==================== BORDES ====================
  static const double radioS = 4.0;
  static const double radioM = 8.0;
  static const double radioL = 12.0;
  static const double radioCircular = 100.0;
  
  // ==================== TAMAÑOS ====================
  static const double alturaBoton = 48.0;
  static const double alturaCampoTexto = 56.0;
  static const double alturaAppBar = 56.0;
  static const double iconoS = 20.0;
  static const double iconoM = 24.0;
  static const double iconoL = 32.0;
  
  // ==================== HELPERS ====================
  static SizedBox espacioH(double width) => SizedBox(width: width);
  static SizedBox espacioV(double height) => SizedBox(height: height);
  
  // Espacios predefinidos
  static SizedBox get esp4 => const SizedBox(height: 4);
  static SizedBox get esp8 => const SizedBox(height: 8);
  static SizedBox get esp16 => const SizedBox(height: 16);
  static SizedBox get esp24 => const SizedBox(height: 24);
  static SizedBox get esp32 => const SizedBox(height: 32);
}