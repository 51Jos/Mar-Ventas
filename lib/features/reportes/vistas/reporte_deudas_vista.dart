import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../controladores/reportes_controlador.dart';
import '../../clientes/modelos/cliente_modelo.dart';

class ReporteDeudasVista extends StatefulWidget {
  const ReporteDeudasVista({super.key});

  @override
  State<ReporteDeudasVista> createState() => _ReporteDeudasVistaState();
}

class _ReporteDeudasVistaState extends State<ReporteDeudasVista> {
  String _ordenar = 'monto'; // monto, nombre, fecha
  String _filtro = 'todos'; // todos, alto, medio, bajo
  
  List<ClienteModelo> _filtrarYOrdenar(List<ClienteModelo> clientes) {
    // Filtrar
    List<ClienteModelo> filtrados = clientes;
    switch (_filtro) {
      case 'alto':
        filtrados = clientes.where((c) => c.deudaTotal > 100).toList();
        break;
      case 'medio':
        filtrados = clientes.where((c) => c.deudaTotal > 50 && c.deudaTotal <= 100).toList();
        break;
      case 'bajo':
        filtrados = clientes.where((c) => c.deudaTotal <= 50).toList();
        break;
    }
    
    // Ordenar
    switch (_ordenar) {
      case 'monto':
        filtrados.sort((a, b) => b.deudaTotal.compareTo(a.deudaTotal));
        break;
      case 'nombre':
        filtrados.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'fecha':
        filtrados.sort((a, b) => (b.fechaRegistro ?? DateTime.now())
            .compareTo(a.fechaRegistro ?? DateTime.now()));
        break;
    }
    
    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportesControlador()..cargarResumenDeudas(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reporte de Deudas'),
          actions: [
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
            
            final resumen = controlador.resumenDeudas;
            if (resumen == null) {
              return const Center(child: Text('Error al cargar datos'));
            }
            
            final clientesFiltrados = _filtrarYOrdenar(resumen.deudores);
            
            return Column(
              children: [
                // Resumen total
                Container(
                  width: double.infinity,
                  padding: Dimensiones.paddingTodo,
                  color: AppColores.error,
                  child: Column(
                    children: [
                      const Text(
                        'TOTAL POR COBRAR',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        FormateadorMoneda.formatear(resumen.totalDeudas),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${resumen.cantidadDeudores} cliente(s) con deuda',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Filtros y ordenamiento
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      // Ordenar por
                      Row(
                        children: [
                          const Text('Ordenar por: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'monto',
                                  label: Text('Monto'),
                                  icon: Icon(Icons.attach_money, size: 12),
                                ),
                                ButtonSegment(
                                  value: 'nombre',
                                  label: Text('Nombre'),
                                  icon: Icon(Icons.sort_by_alpha, size: 12),
                                ),
                                ButtonSegment(
                                  value: 'fecha',
                                  label: Text('Fecha'),
                                  icon: Icon(Icons.calendar_today, size: 12),
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
                      // Filtro por monto
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text('Filtrar: '),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Todos'),
                              selected: _filtro == 'todos',
                              onSelected: (_) => setState(() => _filtro = 'todos'),
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: const Text('> S/. 100'),
                              selected: _filtro == 'alto',
                              onSelected: (_) => setState(() => _filtro = 'alto'),
                              selectedColor: Colors.red.shade100,
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: const Text('S/. 50-100'),
                              selected: _filtro == 'medio',
                              onSelected: (_) => setState(() => _filtro = 'medio'),
                              selectedColor: Colors.orange.shade100,
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: const Text('< S/. 50'),
                              selected: _filtro == 'bajo',
                              onSelected: (_) => setState(() => _filtro = 'bajo'),
                              selectedColor: Colors.yellow.shade100,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Estadísticas rápidas
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _EstadisticaCard(
                          titulo: 'Promedio',
                          valor: FormateadorMoneda.formatear(
                            resumen.cantidadDeudores > 0 
                                ? resumen.totalDeudas / resumen.cantidadDeudores 
                                : 0
                          ),
                          color: Colors.blue,
                          icono: Icons.analytics,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _EstadisticaCard(
                          titulo: 'Mayor deuda',
                          valor: FormateadorMoneda.formatear(
                            resumen.deudores.isNotEmpty 
                                ? resumen.deudores.first.deudaTotal 
                                : 0
                          ),
                          color: Colors.red,
                          icono: Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de deudores
                Expanded(
                  child: clientesFiltrados.isEmpty
                      ? const EstadoVacio(
                          titulo: 'Sin deudores',
                          subtitulo: 'No hay clientes con deuda',
                          icono: Icons.celebration,
                        )
                      : ListView.builder(
                          itemCount: clientesFiltrados.length,
                          itemBuilder: (context, index) {
                            final cliente = clientesFiltrados[index];
                            final porcentaje = (cliente.deudaTotal / resumen.totalDeudas * 100);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getColorPorMonto(cliente.deudaTotal),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  cliente.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (cliente.telefono != null)
                                      Text('📞 ${cliente.telefono}'),
                                    Text(
                                      'Registrado: ${FormateadorFecha.relativo(cliente.fechaRegistro ?? DateTime.now())}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    // Barra de progreso
                                    LinearProgressIndicator(
                                      value: porcentaje / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColorPorMonto(cliente.deudaTotal),
                                      ),
                                    ),
                                    Text(
                                      '${porcentaje.toStringAsFixed(1)}% del total',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      FormateadorMoneda.formatear(cliente.deudaTotal),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: _getColorPorMonto(cliente.deudaTotal),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => RutasApp.ir(
                                            context,
                                            RutasApp.estadoCuenta,
                                            args: cliente,
                                          ),
                                          child: const Icon(
                                            Icons.visibility,
                                            size: 20,
                                            color: AppColores.primario,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => RutasApp.ir(
                                            context,
                                            RutasApp.registrarAbono,
                                            args: cliente,
                                          ),
                                          child: const Icon(
                                            Icons.payment,
                                            size: 20,
                                            color: AppColores.exito,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Botón cobrar todo
                if (clientesFiltrados.isNotEmpty)
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
                    child: BotonPersonalizado(
                      texto: 'Enviar Recordatorios',
                      onPressed: () {
                        SnackBarExito.info(context, 'Función en desarrollo');
                      },
                      icono: Icons.notifications,
                      secundario: true,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Color _getColorPorMonto(double monto) {
    if (monto > 100) return Colors.red;
    if (monto > 50) return Colors.orange;
    return Colors.amber;
  }
}

class _EstadisticaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;
  final IconData icono;

  const _EstadisticaCard({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 11,
              // ignore: deprecated_member_use
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}