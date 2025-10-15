import 'package:flutter/material.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../controladores/productos_controlador.dart';
import '../modelos/compra_modelo.dart';
import '../modelos/producto_modelo.dart';

class DetalleProductoVista extends StatefulWidget {
  final ProductoModelo producto;

  const DetalleProductoVista({
    super.key,
    required this.producto,
  });

  @override
  State<DetalleProductoVista> createState() => _DetalleProductoVistaState();
}

class _DetalleProductoVistaState extends State<DetalleProductoVista> {
  final _controlador = ProductosControlador();
  String? _filtroProveedor;

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print('🚀 Iniciando detalle de producto: ${widget.producto.nombre}');
    // ignore: avoid_print
    print('🔑 ID del producto: ${widget.producto.id}');

    if (widget.producto.id != null) {
      _controlador.cargarCompras(productoId: widget.producto.id);
    } else {
      // ignore: avoid_print
      print('⚠️ El producto no tiene ID!');
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  List<CompraModelo> get comprasFiltradas {
    if (_filtroProveedor == null || _filtroProveedor == 'Todos') {
      return _controlador.compras;
    }
    return _controlador.compras
        .where((c) => c.proveedor == _filtroProveedor)
        .toList();
  }

  List<String> get proveedores {
    final lista = ['Todos'];
    final proveedoresUnicos = _controlador.compras
        .map((c) => c.proveedor)
        .toSet()
        .toList();
    lista.addAll(proveedoresUnicos);
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final hayStock = widget.producto.stock > 5;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              RutasApp.ir(context, RutasApp.editarProducto, args: widget.producto);
            },
            tooltip: 'Editar producto',
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () {
              RutasApp.ir(context, RutasApp.registrarCompra, args: widget.producto);
            },
            tooltip: 'Registrar compra',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del producto
          Container(
            width: double.infinity,
            padding: Dimensiones.paddingTodo,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColores.primario,
                  AppColores.primario.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Nombre del producto
                Text(
                  widget.producto.nombre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Stock
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: hayStock ? AppColores.exito : AppColores.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ${widget.producto.stock.toStringAsFixed(2)} kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Precios
          Container(
            padding: Dimensiones.paddingTodo,
            color: Colors.grey.shade50,
            child: Column(
              children: [
                const Text(
                  'PRECIOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Precio de compra
                    if (widget.producto.precioCompra != null)
                      _PrecioCard(
                        titulo: 'Compra',
                        precio: widget.producto.precioCompra!,
                        icono: Icons.inventory,
                        color: AppColores.textoSecundario,
                      ),
                    // Precio público
                    _PrecioCard(
                      titulo: 'Público',
                      precio: widget.producto.precioPublico,
                      icono: Icons.sell,
                      color: AppColores.primario,
                    ),
                    // Precio mayorista
                    _PrecioCard(
                      titulo: 'Mayorista',
                      precio: widget.producto.precioMayorista,
                      icono: Icons.shopping_cart,
                      color: AppColores.exito,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sección de historial de compras
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'HISTORIAL DE COMPRAS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Filtro de proveedor
          AnimatedBuilder(
            animation: _controlador,
            builder: (context, child) {
              if (_controlador.compras.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 20),
                      const SizedBox(width: 8),
                      const Text('Proveedor:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _filtroProveedor ?? 'Todos',
                          isExpanded: true,
                          items: proveedores.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p),
                            );
                          }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              _filtroProveedor = valor;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Lista de compras
          Expanded(
            child: AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                if (_controlador.cargando) {
                  return const WidgetCargando(mensaje: 'Cargando historial...');
                }

                if (_controlador.error != null) {
                  return Center(
                    child: Padding(
                      padding: Dimensiones.paddingTodo,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColores.error),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar historial',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controlador.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColores.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (comprasFiltradas.isEmpty) {
                  return const EstadoVacio(
                    titulo: 'Sin compras registradas',
                    subtitulo: 'Las compras de este producto aparecerán aquí',
                    icono: Icons.history,
                  );
                }

                // Calcular totales
                final totalCompras = comprasFiltradas.fold<double>(
                  0,
                  (sum, c) => sum + c.total,
                );
                final totalKilos = comprasFiltradas.fold<double>(
                  0,
                  (sum, c) => sum + c.kilos,
                );

                return Column(
                  children: [
                    // Resumen
                    Container(
                      padding: Dimensiones.paddingTodo,
                      color: AppColores.primario.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Total Comprado',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${totalKilos.toStringAsFixed(2)} kg',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Total Gastado',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                FormateadorMoneda.formatear(totalCompras),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Lista
                    Expanded(
                      child: ListView.builder(
                        itemCount: comprasFiltradas.length,
                        itemBuilder: (context, index) {
                          final compra = comprasFiltradas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColores.primario,
                                child: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                compra.proveedor,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${compra.kilos} kg × ${FormateadorMoneda.formatear(compra.precioKilo)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    FormateadorFecha.relativo(compra.fecha),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColores.textoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    FormateadorMoneda.formatear(compra.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar cada precio
class _PrecioCard extends StatelessWidget {
  final String titulo;
  final double precio;
  final IconData icono;
  final Color color;

  const _PrecioCard({
    required this.titulo,
    required this.precio,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          FormateadorMoneda.formatear(precio),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
