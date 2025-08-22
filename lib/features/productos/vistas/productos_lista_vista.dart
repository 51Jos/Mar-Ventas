import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../compartido/layout/layout_principal.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/componentes/dialogo_confirmacion.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../rutas/rutas_app.dart';
import '../controladores/productos_controlador.dart';
import '../modelos/producto_modelo.dart';
import '../servicios/productos_servicio.dart';

class ProductosListaVista extends StatelessWidget {
  const ProductosListaVista({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductosControlador()..inicializar(),
      child: const _ProductosListaContent(),
    );
  }
}

class _ProductosListaContent extends StatefulWidget {
  const _ProductosListaContent();

  @override
  State<_ProductosListaContent> createState() => _ProductosListaContentState();
}

class _ProductosListaContentState extends State<_ProductosListaContent> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ProductosControlador>(
      context,
      listen: false,
    );

    return LayoutPrincipal(
      titulo: 'Productos',
      indiceActual: 0,
      acciones: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => RutasApp.ir(context, RutasApp.historialVentas),
          tooltip: 'Historial de Compras',
        ),
      ],
      child: Column(
        children: [
          // Buscador
          Padding(
            padding: Dimensiones.paddingTodo,
            child: CampoTextoPersonalizado(
              etiqueta: 'Buscar producto',
              controller: _busquedaController,
              icono: Icons.search,
              onChanged: (valor) {
                setState(() {});
              },
            ),
          ),

          // Stream de productos
          Expanded(
            child: StreamBuilder<List<ProductoModelo>>(
              stream: ProductosServicio().obtenerProductos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const WidgetCargando(mensaje: 'Cargando productos...');
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final productos = snapshot.data ?? [];

                // Filtrar por búsqueda
                final productosFiltrados = _busquedaController.text.isEmpty
                    ? productos
                    : productos
                          .where(
                            (p) => p.nombre.toLowerCase().contains(
                              _busquedaController.text.toLowerCase(),
                            ),
                          )
                          .toList();

                if (productosFiltrados.isEmpty) {
                  return EstadosVacios.sinProductos(
                    onAgregar: () =>
                        RutasApp.ir(context, RutasApp.agregarProducto),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final producto = productosFiltrados[index];
                    return _ProductoTarjeta(
                      producto: producto,
                      onEliminar: () async {
                        final confirmar = await DialogoConfirmacion.eliminar(
                          context,
                          'producto',
                        );
                        if (confirmar == true && producto.id != null) {
                          await ProductosServicio().eliminarProducto(
                            producto.id!,
                          );
                          // ignore: use_build_context_synchronously
                          SnackBarExito.mostrar(context, 'Producto eliminado');
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de tarjeta de producto
class _ProductoTarjeta extends StatelessWidget {
  final ProductoModelo producto;
  final VoidCallback? onEliminar;

  const _ProductoTarjeta({required this.producto, this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final hayStock = producto.stock > 5;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hayStock ? AppColores.exito : AppColores.error,
          child: Icon(Icons.set_meal, color: Colors.white),
        ),
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock: ${producto.stock.toStringAsFixed(2)} kg',
              style: TextStyle(
                color: hayStock ? AppColores.exito : AppColores.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Precios con íconos y alineados
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (producto.precioCompra != null)
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 16,
                        color: AppColores.textoSecundario,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Compra:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColores.textoSecundario,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        FormateadorMoneda.formatear(producto.precioCompra!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Icon(Icons.sell, size: 16, color: AppColores.primario),
                    const SizedBox(width: 4),
                    Text(
                      'Público:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColores.primario,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormateadorMoneda.formatear(producto.precioPublico),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 16,
                      color: AppColores.exito,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mayorista:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColores.exito,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormateadorMoneda.formatear(producto.precioMayorista),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (valor) {
            switch (valor) {
              case 'editar':
                RutasApp.ir(context, RutasApp.editarProducto, args: producto);
                break;
              case 'compra':
                RutasApp.ir(context, RutasApp.registrarCompra, args: producto);
                break;
              case 'eliminar':
                onEliminar?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(
              value: 'compra',
              child: Text('Registrar Compra'),
            ),
            const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}
