import 'package:flutter/material.dart';
import 'colores_app.dart';

class EstilosTexto {
  // ==================== TÍTULOS ====================
  static const TextStyle titulo1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColores.texto,
  );
  
  static const TextStyle titulo2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColores.texto,
  );
  
  static const TextStyle titulo3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColores.texto,
  );
  
  // ==================== TEXTOS NORMALES ====================
  static const TextStyle normal = TextStyle(
    fontSize: 14,
    color: AppColores.texto,
  );
  
  static const TextStyle normalNegrita = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColores.texto,
  );
  
  static const TextStyle secundario = TextStyle(
    fontSize: 14,
    color: AppColores.textoSecundario,
  );
  
  static const TextStyle pequeno = TextStyle(
    fontSize: 12,
    color: AppColores.textoSecundario,
  );
  
  // ==================== ESPECIALES ====================
  static const TextStyle precio = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColores.primario,
  );
  
  static const TextStyle stock = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColores.texto,
  );
  
  static const TextStyle boton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColores.textoClaro,
  );
  
  static const TextStyle error = TextStyle(
    fontSize: 12,
    color: AppColores.error,
  );
}