import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

class SnackBarExito {
  /// Mostrar snackbar de éxito
  static void mostrar(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColores.exito,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar snackbar de error
  static void error(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColores.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Mostrar snackbar de advertencia
  static void advertencia(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColores.advertencia,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar snackbar de información
  static void info(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColores.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Snackbar con acción
  static void conAccion({
    required BuildContext context,
    required String mensaje,
    required String textoAccion,
    required VoidCallback onAccion,
    Color? color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color ?? AppColores.primario,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: textoAccion,
          textColor: Colors.white,
          onPressed: onAccion,
        ),
      ),
    );
  }

  /// Ocultar snackbar actual
  static void ocultar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

/// Snackbar helpers para operaciones comunes
class MensajesOperacion {
  static void guardadoExitoso(BuildContext context) {
    SnackBarExito.mostrar(context, 'Guardado exitosamente');
  }

  static void actualizadoExitoso(BuildContext context) {
    SnackBarExito.mostrar(context, 'Actualizado exitosamente');
  }

  static void eliminadoExitoso(BuildContext context) {
    SnackBarExito.mostrar(context, 'Eliminado exitosamente');
  }

  static void ventaRegistrada(BuildContext context) {
    SnackBarExito.mostrar(context, 'Venta registrada exitosamente');
  }

  static void compraRegistrada(BuildContext context) {
    SnackBarExito.mostrar(context, 'Compra registrada exitosamente');
  }

  static void abonoRegistrado(BuildContext context) {
    SnackBarExito.mostrar(context, 'Abono registrado exitosamente');
  }

  static void errorGeneral(BuildContext context) {
    SnackBarExito.error(context, 'Ha ocurrido un error. Intenta nuevamente');
  }

  static void sinConexion(BuildContext context) {
    SnackBarExito.error(context, 'Sin conexión a internet');
  }

  static void stockInsuficiente(BuildContext context) {
    SnackBarExito.advertencia(context, 'Stock insuficiente');
  }
}