import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

class DialogoConfirmacion {
  /// Diálogo de confirmación básico
  static Future<bool?> mostrar({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String? textoConfirmar,
    String? textoCancelar,
    bool esDestructivo = false,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(textoCancelar ?? 'Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: esDestructivo 
                    ? AppColores.error 
                    : AppColores.primario,
              ),
              child: Text(textoConfirmar ?? 'Confirmar'),
            ),
          ],
        );
      },
    );
  }

  /// Confirmar eliminación
  static Future<bool?> eliminar(BuildContext context, String item) {
    return mostrar(
      context: context,
      titulo: 'Eliminar $item',
      mensaje: '¿Estás seguro de que deseas eliminar este $item? Esta acción no se puede deshacer.',
      textoConfirmar: 'Eliminar',
      esDestructivo: true,
    );
  }

  /// Confirmar anulación
  static Future<bool?> anular(BuildContext context, String item) {
    return mostrar(
      context: context,
      titulo: 'Anular $item',
      mensaje: '¿Estás seguro de que deseas anular este $item?',
      textoConfirmar: 'Anular',
      esDestructivo: true,
    );
  }

  /// Confirmar salir sin guardar
  static Future<bool?> salirSinGuardar(BuildContext context) {
    return mostrar(
      context: context,
      titulo: 'Cambios sin guardar',
      mensaje: 'Tienes cambios sin guardar. ¿Deseas salir de todas formas?',
      textoConfirmar: 'Salir',
      textoCancelar: 'Seguir editando',
      esDestructivo: true,
    );
  }

  /// Confirmar cerrar sesión
  static Future<bool?> cerrarSesion(BuildContext context) {
    return mostrar(
      context: context,
      titulo: 'Cerrar Sesión',
      mensaje: '¿Estás seguro de que deseas cerrar sesión?',
      textoConfirmar: 'Cerrar Sesión',
      textoCancelar: 'Cancelar',
    );
  }
}

/// Diálogo de información
class DialogoInfo {
  static Future<void> mostrar({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String? textoBoton,
    IconData? icono,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              if (icono != null) ...[
                Icon(icono, color: AppColores.info),
                const SizedBox(width: 12),
              ],
              Text(titulo),
            ],
          ),
          content: Text(mensaje),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(textoBoton ?? 'Entendido'),
            ),
          ],
        );
      },
    );
  }

  /// Mostrar éxito
  static Future<void> exito(BuildContext context, String mensaje) {
    return mostrar(
      context: context,
      titulo: 'Éxito',
      mensaje: mensaje,
      icono: Icons.check_circle_outline,
    );
  }

  /// Mostrar error
  static Future<void> error(BuildContext context, String mensaje) {
    return mostrar(
      context: context,
      titulo: 'Error',
      mensaje: mensaje,
      icono: Icons.error_outline,
    );
  }
}