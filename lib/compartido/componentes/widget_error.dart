import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

class WidgetError extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;
  final IconData? icono;

  const WidgetError({
    super.key,
    required this.mensaje,
    this.onReintentar,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono ?? Icons.error_outline,
              size: 64,
              color: AppColores.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColores.texto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 16,
                color: AppColores.textoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.primario,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Banner de error simple
class BannerError extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onCerrar;

  const BannerError({
    super.key,
    required this.mensaje,
    this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColores.error.withOpacity(0.1),
        border: Border.all(color: AppColores.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColores.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: AppColores.error,
                fontSize: 14,
              ),
            ),
          ),
          if (onCerrar != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColores.error,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onCerrar,
            ),
        ],
      ),
    );
  }
}