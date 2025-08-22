import 'package:flutter/material.dart';
import '../nucleo/configuracion_firebase.dart';
import 'rutas_app.dart';

class GuardiasRuta {
  /// Verifica si el usuario está autenticado
  static bool estaAutenticado() {
    return ConfigFirebase.usuario != null;
  }
  
  /// Redirige al login si no está autenticado
  static void verificarAutenticacion(BuildContext context) {
    if (!estaAutenticado()) {
      RutasApp.limpiarEIr(context, RutasApp.login);
    }
  }
  
  /// Widget wrapper para proteger vistas
  static Widget proteger({
    required Widget child,
    required BuildContext context,
  }) {
    // Si no está autenticado, mostrar loading y redirigir
    if (!estaAutenticado()) {
      Future.microtask(() {
        // ignore: use_build_context_synchronously
        RutasApp.limpiarEIr(context, RutasApp.login);
      });
      
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si está autenticado, mostrar la vista
    return child;
  }
  
  /// Stream para escuchar cambios de autenticación
  static Stream<bool> get estadoAuth {
    return ConfigFirebase.authStream.map((user) => user != null);
  }
}