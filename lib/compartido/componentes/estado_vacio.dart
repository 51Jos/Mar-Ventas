import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

class EstadoVacio extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData? icono;
  final Widget? boton;

  const EstadoVacio({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.icono,
    this.boton,
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
              icono ?? Icons.inbox_outlined,
              size: 80,
              color: AppColores.gris,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColores.texto,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColores.textoSecundario,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (boton != null) ...[
              const SizedBox(height: 24),
              boton!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Estados vacíos predefinidos
class EstadosVacios {
  static Widget sinProductos({VoidCallback? onAgregar}) {
    return EstadoVacio(
      icono: Icons.inventory_2_outlined,
      titulo: 'No hay productos',
      subtitulo: 'Agrega tu primer producto para comenzar',
      boton: onAgregar != null
          ? ElevatedButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Producto'),
            )
          : null,
    );
  }

  static Widget sinVentas() {
    return const EstadoVacio(
      icono: Icons.shopping_cart_outlined,
      titulo: 'No hay ventas',
      subtitulo: 'Las ventas del día aparecerán aquí',
    );
  }

  static Widget sinClientes({VoidCallback? onAgregar}) {
    return EstadoVacio(
      icono: Icons.people_outline,
      titulo: 'No hay clientes',
      subtitulo: 'Registra tu primer cliente',
      boton: onAgregar != null
          ? ElevatedButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.person_add),
              label: const Text('Agregar Cliente'),
            )
          : null,
    );
  }

  static Widget sinResultados() {
    return const EstadoVacio(
      icono: Icons.search_off,
      titulo: 'Sin resultados',
      subtitulo: 'No se encontraron coincidencias',
    );
  }

  static Widget sinConexion({VoidCallback? onReintentar}) {
    return EstadoVacio(
      icono: Icons.wifi_off,
      titulo: 'Sin conexión',
      subtitulo: 'Verifica tu conexión a internet',
      boton: onReintentar != null
          ? ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            )
          : null,
    );
  }
}