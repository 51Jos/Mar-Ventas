import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

class WidgetCargando extends StatelessWidget {
  final String? mensaje;
  final bool conFondo;

  const WidgetCargando({
    super.key,
    this.mensaje,
    this.conFondo = false,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColores.primario),
        ),
        if (mensaje != null) ...[
          const SizedBox(height: 16),
          Text(
            mensaje!,
            style: TextStyle(
              fontSize: 16,
              color: conFondo ? Colors.white : AppColores.texto,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (conFondo) {
      return Container(
        color: Colors.black54,
        child: Center(child: contenido),
      );
    }

    return Center(child: contenido);
  }
}

/// Overlay de carga para cubrir toda la pantalla
class OverlayCargando extends StatelessWidget {
  final bool visible;
  final Widget child;
  final String? mensaje;

  const OverlayCargando({
    super.key,
    required this.visible,
    required this.child,
    this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (visible)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        if (mensaje != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            mensaje!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}