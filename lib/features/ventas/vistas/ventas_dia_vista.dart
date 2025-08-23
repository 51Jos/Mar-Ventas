import 'package:flutter/material.dart';
import '../../../compartido/layout/layout_principal.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../modelos/venta_modelo.dart';
import '../servicios/ventas_servicio.dart';

class VentasDiaVista extends StatelessWidget {
  const VentasDiaVista({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      titulo: 'Ventas',
      indiceActual: 1,
      acciones: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => RutasApp.ir(context, '/ventas/historial'),
          tooltip: 'Historial',
        ),
      ],
      child: StreamBuilder<List<VentaModelo>>(
        stream: VentasServicio().obtenerVentasDelDia(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WidgetCargando(mensaje: 'Cargando ventas...');
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final ventas = snapshot.data ?? [];
          
          if (ventas.isEmpty) {
            return EstadosVacios.sinVentas();
          }
          
          // Calcular totales
          final totalVentas = ventas.fold<double>(
            0, (sum, v) => sum + v.total,
          );
          final ventasContado = ventas.where((v) => v.tipoPago == 'contado').length;
          final ventasCredito = ventas.where((v) => v.tipoPago == 'credito').length;
          final totalContado = ventas
              .where((v) => v.tipoPago == 'contado')
              .fold<double>(0, (sum, v) => sum + v.total);
          final totalCredito = ventas
              .where((v) => v.tipoPago == 'credito')
              .fold<double>(0, (sum, v) => sum + v.total);
          
          return Column(
            children: [
              // Fecha actual
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppColores.primario,
                child: Text(
                  FormateadorFecha.fechaCompleta(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Estadísticas
              Container(
                padding: Dimensiones.paddingTodo,
                child: Row(
                  children: [
                    Expanded(
                      child: _EstadisticaTarjeta(
                        titulo: 'Total Ventas',
                        valor: ventas.length.toString(),
                        subtitulo: FormateadorMoneda.formatear(totalVentas),
                        color: AppColores.primario,
                        icono: Icons.shopping_cart,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EstadisticaTarjeta(
                        titulo: 'Contado',
                        valor: ventasContado.toString(),
                        subtitulo: FormateadorMoneda.formatear(totalContado),
                        color: AppColores.exito,
                        icono: Icons.money,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EstadisticaTarjeta(
                        titulo: 'Crédito',
                        valor: ventasCredito.toString(),
                        subtitulo: FormateadorMoneda.formatear(totalCredito),
                        color: AppColores.advertencia,
                        icono: Icons.credit_card,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de ventas
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: ventas.length,
                  itemBuilder: (context, index) {
                    final venta = ventas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: venta.tipoPago == 'contado'
                              // ignore: deprecated_member_use
                              ? AppColores.exito.withOpacity(0.2)
                              // ignore: deprecated_member_use
                              : AppColores.advertencia.withOpacity(0.2),
                          child: Icon(
                            venta.tipoPago == 'contado'
                                ? Icons.money
                                : Icons.credit_card,
                            color: venta.tipoPago == 'contado'
                                ? AppColores.exito
                                : AppColores.advertencia,
                          ),
                        ),
                        title: Text(
                          venta.clienteNombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${venta.items.length} producto(s) • ${venta.metodoPago}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              FormateadorFecha.hora(venta.fecha),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColores.textoSecundario,
                              ),
                            ),
                            if (venta.tipoPago == 'credito' && venta.saldo > 0)
                              Text(
                                'Saldo: ${FormateadorMoneda.formatear(venta.saldo)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColores.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              FormateadorMoneda.formatear(venta.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: venta.tipoPago == 'contado'
                                    ? AppColores.exito
                                    : AppColores.advertencia,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                venta.tipoPago.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => RutasApp.ir(
                          context,
                          '/ventas/detalle',
                          args: venta,
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
    );
  }
}

// Widget de tarjeta de estadística
class _EstadisticaTarjeta extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final Color color;
  final IconData icono;

  const _EstadisticaTarjeta({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
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
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              // ignore: deprecated_member_use
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              // ignore: deprecated_member_use
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}