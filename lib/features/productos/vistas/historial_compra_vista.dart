import 'package:flutter/material.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../controladores/productos_controlador.dart';
import '../modelos/compra_modelo.dart';

class HistorialComprasVista extends StatefulWidget {
  final String? productoId;
  
  const HistorialComprasVista({
    super.key,
    this.productoId,
  });

  @override
  State<HistorialComprasVista> createState() => _HistorialComprasVistaState();
}

class _HistorialComprasVistaState extends State<HistorialComprasVista> {
  final _controlador = ProductosControlador();
  String? _filtroProveedor;
  
  @override
  void initState() {
    super.initState();
    _controlador.cargarCompras(productoId: widget.productoId);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
      ),
      body: Column(
        children: [
          // Filtros
          if (_controlador.compras.isNotEmpty)
            Container(
              padding: Dimensiones.paddingTodo,
              color: Colors.grey.shade100,
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
            ),
          
          // Lista de compras
          Expanded(
            child: AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                if (_controlador.cargando) {
                  return const WidgetCargando(mensaje: 'Cargando historial...');
                }
                
                if (comprasFiltradas.isEmpty) {
                  return const EstadoVacio(
                    titulo: 'Sin compras registradas',
                    subtitulo: 'Las compras aparecerán aquí',
                    icono: Icons.history,
                  );
                }
                
                // Calcular totales
                final totalCompras = comprasFiltradas.fold<double>(
                  0, (sum, c) => sum + c.total,
                );
                final totalKilos = comprasFiltradas.fold<double>(
                  0, (sum, c) => sum + c.kilos,
                );
                
                return Column(
                  children: [
                    // Resumen
                    Container(
                      padding: Dimensiones.paddingTodo,
                      // ignore: deprecated_member_use
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
                                compra.productoNombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Proveedor: ${compra.proveedor}'),
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