import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

class BotonPersonalizado extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icono;
  final Color? color;
  final bool expandido;
  final bool secundario;

  const BotonPersonalizado({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
    this.color,
    this.expandido = true,
    this.secundario = false,
  });

  @override
  Widget build(BuildContext context) {
    final boton = ElevatedButton(
      onPressed: cargando ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: secundario 
            ? Colors.white 
            : (color ?? AppColores.primario),
        foregroundColor: secundario 
            ? AppColores.primario 
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: secundario 
              ? const BorderSide(color: AppColores.primario) 
              : BorderSide.none,
        ),
        elevation: secundario ? 0 : 2,
      ),
      child: cargando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono != null) ...[
                  Icon(icono, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );

    if (expandido) {
      return SizedBox(
        width: double.infinity,
        child: boton,
      );
    }

    return boton;
  }
}