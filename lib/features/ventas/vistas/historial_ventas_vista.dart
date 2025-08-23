import 'package:flutter/material.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/componentes/dialogo_confirmacion.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../modelos/venta_modelo.dart';
import '../servicios/ventas_servicio.dart';
import '../controladores/ventas_controlador.dart';

class HistorialVentasVista extends StatefulWidget {
  const HistorialVentasVista({super.key});

  @override
  State<HistorialVentasVista> createState() => _HistorialVentasVistaState();
}

class _HistorialVentasVistaState extends State<HistorialVentasVista> {
  final _ventasServicio = VentasServicio();
  final _ventasControlador = VentasControlador();
  String _filtroEstado = 'todas';
  String _filtroPago = 'todos';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: Dimensiones.paddingTodo,
            color: Colors.grey.shade100,
            child: Column(
              children: [
                // Filtro por estado
                Row(
                  children: [
                    const Text('Estado: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'todas', label: Text('Todas')),
                          ButtonSegment(value: 'activa', label: Text('Activas')),
                          ButtonSegment(value: 'anulada', label: Text('Anuladas')),
                        ],
                        selected: {_filtroEstado},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _filtroEstado = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Filtro por tipo de pago
                Row(
                  children: [
                    const Text('Pago: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'todos', label: Text('Todos')),
                          ButtonSegment(value: 'contado', label: Text('Contado')),
                          ButtonSegment(value: 'credito', label: Text('Crédito')),
                        ],
                        selected: {_filtroPago},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _filtroPago = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de ventas
          Expanded(
            child: StreamBuilder<List<VentaModelo>>(
              stream: _ventasServicio.obtenerVentas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const WidgetCargando(mensaje: 'Cargando historial...');
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                var ventas = snapshot.data ?? [];
                
                // Aplicar filtros
                if (_filtroEstado != 'todas') {
                  ventas = ventas.where((v) => v.estado == _filtroEstado).toList();
                }
                
                if (_filtroPago != 'todos') {
                  ventas = ventas.where((v) => v.tipoPago == _filtroPago).toList();
                }
                
                if (ventas.isEmpty) {
                  return const EstadoVacio(
                    titulo: 'Sin ventas',
                    subtitulo: 'No hay ventas que coincidan con los filtros',
                    icono: Icons.receipt_long,
                  );
                }
                
                // Agrupar por fecha
                Map<String, List<VentaModelo>> ventasPorFecha = {};
                for (var venta in ventas) {
                  final fecha = FormateadorFecha.fechaCorta(venta.fecha);
                  ventasPorFecha[fecha] ??= [];
                  ventasPorFecha[fecha]!.add(venta);
                }
                
                return ListView.builder(
                  itemCount: ventasPorFecha.length,
                  itemBuilder: (context, index) {
                    final fecha = ventasPorFecha.keys.elementAt(index);
                    final ventasDelDia = ventasPorFecha[fecha]!;
                    final totalDia = ventasDelDia
                        .where((v) => v.estado == 'activa')
                        .fold<double>(0, (sum, v) => sum + v.total);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado de fecha
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          // ignore: deprecated_member_use
                          color: AppColores.primario.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                fecha,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                FormateadorMoneda.formatear(totalDia),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.primario,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Ventas del día
                        ...ventasDelDia.map((venta) => Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: venta.estado == 'anulada'
                                  ? Colors.red.shade100
                                  : venta.tipoPago == 'contado'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                              child: Icon(
                                venta.estado == 'anulada'
                                    ? Icons.cancel
                                    : venta.tipoPago == 'contado'
                                        ? Icons.money
                                        : Icons.credit_card,
                                color: venta.estado == 'anulada'
                                    ? Colors.red
                                    : venta.tipoPago == 'contado'
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                            title: Text(
                              venta.clienteNombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: venta.estado == 'anulada'
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${FormateadorFecha.hora(venta.fecha)} • ${venta.metodoPago}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (venta.estado == 'anulada')
                                  const Text(
                                    'ANULADA',
                                    style: TextStyle(
                                      color: AppColores.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              FormateadorMoneda.formatear(venta.total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: venta.estado == 'anulada'
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            onTap: () => _mostrarOpciones(venta),
                          ),
                        )),
                      ],
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
  
  void _mostrarOpciones(VentaModelo venta) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver Detalle'),
            onTap: () {
              Navigator.pop(context);
              RutasApp.ir(context, '/ventas/detalle', args: venta);
            },
          ),
          if (venta.estado == 'activa')
            ListTile(
              leading: const Icon(Icons.cancel, color: AppColores.error),
              title: const Text('Anular Venta'),
              textColor: AppColores.error,
              onTap: () async {
                Navigator.pop(context);
                final confirmar = await DialogoConfirmacion.mostrar(
                  context: context,
                  titulo: 'Anular Venta',
                  mensaje: '¿Estás seguro de anular esta venta? Se devolverá el stock.',
                  esDestructivo: true,
                );
                
                if (confirmar == true && venta.id != null) {
                  final exito = await _ventasControlador.anularVenta(venta.id!);
                  if (exito) {
                    // ignore: use_build_context_synchronously
                    SnackBarExito.mostrar(context, 'Venta anulada');
                  } else {
                    // ignore: use_build_context_synchronously
                    SnackBarExito.error(context, 'Error al anular venta');
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}