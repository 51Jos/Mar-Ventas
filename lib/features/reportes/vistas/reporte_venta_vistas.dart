import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../controladores/reportes_controlador.dart';
import '../../ventas/modelos/venta_modelo.dart';

class ReporteVentasVista extends StatefulWidget {
  const ReporteVentasVista({super.key});

  @override
  State<ReporteVentasVista> createState() => _ReporteVentasVistaState();
}

class _ReporteVentasVistaState extends State<ReporteVentasVista> {
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaFin = DateTime.now();
  
  Future<void> _seleccionarFechaInicio(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: _fechaFin,
    );
    
    if (fecha != null) {
      setState(() {
        _fechaInicio = fecha;
      });
      _cargarReporte();
    }
  }
  
  Future<void> _seleccionarFechaFin(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: _fechaInicio,
      lastDate: DateTime.now(),
    );
    
    if (fecha != null) {
      setState(() {
        _fechaFin = fecha;
      });
      _cargarReporte();
    }
  }
  
  void _cargarReporte() {
    Provider.of<ReportesControlador>(context, listen: false)
        .cargarVentasPorRango(_fechaInicio, _fechaFin);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controlador = ReportesControlador();
        controlador.cargarVentasPorRango(_fechaInicio, _fechaFin);
        return controlador;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reporte de Ventas'),
        ),
        body: Consumer<ReportesControlador>(
          builder: (context, controlador, child) {
            return Column(
              children: [
                // Selector de fechas
                Container(
                  padding: Dimensiones.paddingTodo,
                  color: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Período del reporte:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarFechaInicio(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColores.grisClaro),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Desde', style: TextStyle(fontSize: 10)),
                                        Text(
                                          FormateadorFecha.fechaCorta(_fechaInicio),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarFechaFin(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColores.grisClaro),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Hasta', style: TextStyle(fontSize: 10)),
                                        Text(
                                          FormateadorFecha.fechaCorta(_fechaFin),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Botones rápidos
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Hoy'),
                            onPressed: () {
                              setState(() {
                                _fechaInicio = DateTime.now();
                                _fechaFin = DateTime.now();
                              });
                              _cargarReporte();
                            },
                          ),
                          ActionChip(
                            label: const Text('Esta semana'),
                            onPressed: () {
                              final ahora = DateTime.now();
                              setState(() {
                                _fechaInicio = ahora.subtract(Duration(days: ahora.weekday - 1));
                                _fechaFin = ahora;
                              });
                              _cargarReporte();
                            },
                          ),
                          ActionChip(
                            label: const Text('Este mes'),
                            onPressed: () {
                              final ahora = DateTime.now();
                              setState(() {
                                _fechaInicio = DateTime(ahora.year, ahora.month, 1);
                                _fechaFin = ahora;
                              });
                              _cargarReporte();
                            },
                          ),
                          ActionChip(
                            label: const Text('30 días'),
                            onPressed: () {
                              setState(() {
                                _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
                                _fechaFin = DateTime.now();
                              });
                              _cargarReporte();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Contenido del reporte
                Expanded(
                  child: controlador.cargando
                      ? const WidgetCargando(mensaje: 'Generando reporte...')
                      : _ContenidoReporte(
                          ventas: controlador.ventasRango,
                          fechaInicio: _fechaInicio,
                          fechaFin: _fechaFin,
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

class _ContenidoReporte extends StatelessWidget {
  final List<VentaModelo> ventas;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  
  const _ContenidoReporte({
    required this.ventas,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  Widget build(BuildContext context) {
    if (ventas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay ventas en este período',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${FormateadorFecha.fechaCorta(fechaInicio)} - ${FormateadorFecha.fechaCorta(fechaFin)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    // Calcular estadísticas
    final totalVentas = ventas.fold<double>(0, (sum, v) => sum + v.total);
    final ventasContado = ventas.where((v) => v.tipoPago == 'contado').toList();
    final ventasCredito = ventas.where((v) => v.tipoPago == 'credito').toList();
    final totalContado = ventasContado.fold<double>(0, (sum, v) => sum + v.total);
    final totalCredito = ventasCredito.fold<double>(0, (sum, v) => sum + v.total);
    
    // Agrupar por método de pago
    Map<String, double> porMetodo = {};
    for (var venta in ventas) {
      porMetodo[venta.metodoPago] = (porMetodo[venta.metodoPago] ?? 0) + venta.total;
    }
    
    return ListView(
      padding: Dimensiones.paddingTodo,
      children: [
        // Resumen general
        Card(
          color: AppColores.primario,
          child: Padding(
            padding: Dimensiones.paddingTodo,
            child: Column(
              children: [
                const Text(
                  'TOTAL DEL PERÍODO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  FormateadorMoneda.formatear(totalVentas),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${ventas.length} venta(s) registrada(s)',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Estadísticas por tipo de pago
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.money, color: AppColores.exito, size: 32),
                      const SizedBox(height: 8),
                      const Text('CONTADO'),
                      Text(
                        FormateadorMoneda.formatear(totalContado),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColores.exito,
                        ),
                      ),
                      Text('${ventasContado.length} ventas'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card, color: AppColores.advertencia, size: 32),
                      const SizedBox(height: 8),
                      const Text('CRÉDITO'),
                      Text(
                        FormateadorMoneda.formatear(totalCredito),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColores.advertencia,
                        ),
                      ),
                      Text('${ventasCredito.length} ventas'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Por método de pago
        Card(
          child: Padding(
            padding: Dimensiones.paddingTodo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POR MÉTODO DE PAGO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...porMetodo.entries.map((entry) => ListTile(
                  dense: true,
                  title: Text(entry.key.toUpperCase()),
                  trailing: Text(
                    FormateadorMoneda.formatear(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botón exportar
        BotonPersonalizado(
          texto: 'Exportar Reporte',
          onPressed: () {
            SnackBarExito.info(context, 'Función de exportación en desarrollo');
          },
          icono: Icons.download,
          secundario: true,
        ),
      ],
    );
  }
}