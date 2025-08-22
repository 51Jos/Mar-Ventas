import 'package:flutter/material.dart';
import 'colores_app.dart';

class TemaApp {
  static ThemeData get tema => ThemeData(
    // Colores principales
    primaryColor: AppColores.primario,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColores.primario,
      secondary: AppColores.secundario,
    ),
    
    // Fondo general
    scaffoldBackgroundColor: AppColores.fondo,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColores.primario,
      foregroundColor: AppColores.textoClaro,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColores.primario,
        foregroundColor: AppColores.textoClaro,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Campos de texto
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColores.grisClaro),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColores.grisClaro),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColores.primario, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColores.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    
    // Tarjetas
    cardTheme: CardThemeData(
      color: AppColores.fondoTarjeta,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
    ),
    
    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColores.acento,
      foregroundColor: AppColores.textoClaro,
    ),
    
    // Fuente
    fontFamily: 'Roboto',
    
    // Usar Material 3
    useMaterial3: true,
  );
}