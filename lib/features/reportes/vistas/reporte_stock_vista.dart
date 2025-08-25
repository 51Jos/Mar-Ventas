import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../rutas/rutas_app.dart';
import '../controladores/reportes_controlador.dart';
import '../../productos/modelos/producto_modelo.dart';

class ReporteStockVista extends StatefulWidget {
  const ReporteStockVista({super.key});

  @override
  State<ReporteStockVista> createState() => _ReporteStockVistaState();
}

class _ReporteStockVistaState extends State<ReporteStockVista> {
  String _ordenar = 'stock'; // stock, nombre, valor
  String _filtro = 'todos'; // todos, critico, bajo, normal, alto
  bool _mostrarValores = true;
  
  List<ProductoModelo> _filtrarYOrdenar(List<ProductoModelo> productos) {
    // Filtrar
    List<ProductoModelo> filtrados = productos;
    switch (_filtro) {
      case 'critico':
        filtrados = productos.where((p) => p.stock <= 2).toList();
        break;
      case 'bajo':
        filtrados = productos.where((p) => p.stock > 2 && p.stock <= 5).toList();
        break;
      case 'normal':
        filtrados = productos.where((p) => p.stock > 5 && p.stock <= 20).toList();
        break;
      case 'alto':
        filtrados = productos.where((p) => p.stock > 20).toList();
        break;
    }
    
    // Ordenar
    switch (_ordenar) {
      case 'stock':
        filtrados.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'nombre':
        filtrados.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'valor':
        filtrados.sort((a, b) {
          final valorA = a.stock * (a.precioCompra ?? a.precioPublico);
          final valorB = b.stock * (b.precioCompra ?? b.precioPublico);
          return valorB.compareTo(valorA);
        });
        break;
    }
    
    return filtrados;
  }
  
  Color _getColorStock(double stock) {
    if (stock <= 2) return AppColores.error;
    if (stock <= 5) return AppColores.advertencia;
    if (stock <= 20) return AppColores.info;
    return AppColores.exito;
  }
  
  String _getEstadoStock(double stock) {
    if (stock <= 2) return 'CRÍTICO';
    if (stock <= 5) return 'BAJO';
    if (stock <= 20) return 'NORMAL';
    return 'ALTO';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportesControlador()..cargarResumenInventario(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reporte de Inventario'),
          actions: [
            IconButton(
              icon: Icon(_mostrarValores ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _mostrarValores = !_mostrarValores;
                });
              },
              tooltip: _mostrarValores ? 'Ocultar valores' : 'Mostrar valores',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                SnackBarExito.info(context, 'Función de exportación en desarrollo');
              },
              tooltip: 'Exportar',
            ),
          ],
        ),
        body: Consumer<ReportesControlador>(
          builder: (context, controlador, child) {
            if (controlador.cargando) {
              return const WidgetCargando(mensaje: 'Generando reporte...');
            }
            
            final resumen = controlador.resumenInventario;
            if (resumen == null) {
              return const Center(child: Text('Error al cargar datos'));
            }
            
            final productosFiltrados = _filtrarYOrdenar(resumen.productos);
            
            // Calcular estadísticas por categoría
            final criticos = resumen.productos.where((p) => p.stock <= 2).length;
            final bajos = resumen.productos.where((p) => p.stock > 2 && p.stock <= 5).length;
            final normales = resumen.productos.where((p) => p.stock > 5 && p.stock <= 20).length;
            final altos = resumen.productos.where((p) => p.stock > 20).length;
            
            return Column(
              children: [
                // Resumen total
                Container(
                  padding: Dimensiones.paddingTodo,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColores.primario, AppColores.secundario],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'VALOR TOTAL',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _mostrarValores 
                                    ? FormateadorMoneda.formatear(resumen.valorTotal)
                                    : '****',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'TOTAL KILOS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '${resumen.kilosTotales.toStringAsFixed(2)} kg',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'PRODUCTOS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '${resumen.cantidadProductos}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Indicadores de estado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _IndicadorEstado(
                            label: 'Crítico',
                            cantidad: criticos,
                            color: AppColores.error,
                          ),
                          _IndicadorEstado(
                            label: 'Bajo',
                            cantidad: bajos,
                            color: AppColores.advertencia,
                          ),
                          _IndicadorEstado(
                            label: 'Normal',
                            cantidad: normales,
                            color: AppColores.info,
                          ),
                          _IndicadorEstado(
                            label: 'Alto',
                            cantidad: altos,
                            color: AppColores.exito,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Filtros
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      // Ordenar
                      Row(
                        children: [
                          const Text('Ordenar: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'stock',
                                  label: Text('Stock'),
                                  icon: Icon(Icons.inventory, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'nombre',
                                  label: Text('Nombre'),
                                  icon: Icon(Icons.sort_by_alpha, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'valor',
                                  label: Text('Valor'),
                                  icon: Icon(Icons.attach_money, size: 16),
                                ),
                              ],
                              selected: {_ordenar},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _ordenar = newSelection.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Filtro por estado
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text('Filtrar: '),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text('Todos (${resumen.cantidadProductos})'),
                              selected: _filtro == 'todos',
                              onSelected: (_) => setState(() => _filtro = 'todos'),
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: Text('Crítico ($criticos)'),
                              selected: _filtro == 'critico',
                              onSelected: (_) => setState(() => _filtro = 'critico'),
                              // ignore: deprecated_member_use
                              selectedColor: AppColores.error.withOpacity(0.2),
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: Text('Bajo ($bajos)'),
                              selected: _filtro == 'bajo',
                              onSelected: (_) => setState(() => _filtro = 'bajo'),
                              // ignore: deprecated_member_use
                              selectedColor: AppColores.advertencia.withOpacity(0.2),
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: Text('Normal ($normales)'),
                              selected: _filtro == 'normal',
                              onSelected: (_) => setState(() => _filtro = 'normal'),
                              // ignore: deprecated_member_use
                              selectedColor: AppColores.info.withOpacity(0.2),
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: Text('Alto ($altos)'),
                              selected: _filtro == 'alto',
                              onSelected: (_) => setState(() => _filtro = 'alto'),
                              // ignore: deprecated_member_use
                              selectedColor: AppColores.exito.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de productos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      final valorProducto = producto.stock * (producto.precioCompra ?? producto.precioPublico);
                      final porcentajeStock = (producto.stock / resumen.kilosTotales * 100);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColorStock(producto.stock),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            producto.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: 14,
                                    color: _getColorStock(producto.stock),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${producto.stock.toStringAsFixed(2)} kg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getColorStock(producto.stock),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: _getColorStock(producto.stock).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getEstadoStock(producto.stock),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getColorStock(producto.stock),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_mostrarValores)
                                Text(
                                  'Valor: ${FormateadorMoneda.formatear(valorProducto)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${porcentajeStock.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'del total',
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Precios
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            'Precio Compra',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            FormateadorMoneda.formatear(
                                              producto.precioCompra ?? 0
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Precio Público',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            FormateadorMoneda.formatear(
                                              producto.precioPublico
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColores.primario,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Precio Mayorista',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            FormateadorMoneda.formatear(
                                              producto.precioMayorista
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColores.secundario,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Acciones
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => RutasApp.ir(
                                          context,
                                          RutasApp.editarProducto,
                                          args: producto,
                                        ),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Editar'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => RutasApp.ir(
                                          context,
                                          RutasApp.registrarCompra,
                                          args: producto,
                                        ),
                                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                                        label: const Text('Comprar'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColores.exito,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Resumen inferior
                Container(
                  padding: Dimensiones.paddingTodo,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Productos mostrados: ${productosFiltrados.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (_mostrarValores)
                            Text(
                              'Valor promedio: ${FormateadorMoneda.formatear(
                                productosFiltrados.isNotEmpty 
                                    ? productosFiltrados.fold<double>(
                                        0, 
                                        (sum, p) => sum + p.stock * (p.precioCompra ?? p.precioPublico)
                                      ) / productosFiltrados.length
                                    : 0
                              )}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      BotonPersonalizado(
                        texto: 'Exportar',
                        onPressed: () {
                          SnackBarExito.info(context, 'Función en desarrollo');
                        },
                        icono: Icons.download,
                        expandido: false,
                        secundario: true,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Widget indicador de estado
class _IndicadorEstado extends StatelessWidget {
  final String label;
  final int cantidad;
  final Color color;

  const _IndicadorEstado({
    required this.label,
    required this.cantidad,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $cantidad',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}