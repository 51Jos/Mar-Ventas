import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../compartido/layout/layout_principal.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../controladores/reportes_controlador.dart';
import '../servicios/reportes_servicios.dart';
import '../../productos/modelos/producto_modelo.dart';

class ReportesDashboardVista extends StatefulWidget {
  const ReportesDashboardVista({super.key});

  @override
  State<ReportesDashboardVista> createState() => _ReportesDashboardVistaState();
}

class _ReportesDashboardVistaState extends State<ReportesDashboardVista> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportesControlador()..cargarTodo(),
      child: LayoutPrincipal(
        titulo: 'Reportes',
        indiceActual: 3,
        child: Consumer<ReportesControlador>(
          builder: (context, controlador, child) {
            if (controlador.cargando) {
              return const WidgetCargando(mensaje: 'Generando reportes...');
            }
            
            return RefreshIndicator(
              onRefresh: () => controlador.cargarTodo(),
              child: ListView(
                padding: Dimensiones.paddingTodo,
                children: [
                  // Fecha actual
                  Center(
                    child: Text(
                      FormateadorFecha.fechaCompleta(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColores.primario,
                      ),
                    ),
                  ),
                  Dimensiones.esp16,
                  
                  // Resumen del día
                  _SeccionResumenDia(resumen: controlador.resumenDia),
                  Dimensiones.esp16,
                  
                  // Resumen de deudas
                  _SeccionDeudas(resumen: controlador.resumenDeudas),
                  Dimensiones.esp16,
                  
                  // Resumen de inventario
                  _SeccionInventario(resumen: controlador.resumenInventario),
                  Dimensiones.esp16,
                  
                  // Productos más vendidos
                  _SeccionProductosMasVendidos(
                    productos: controlador.productosMasVendidos,
                  ),
                  Dimensiones.esp16,
                  
                  // Stock bajo
                  _SeccionStockBajo(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Sección de resumen del día
class _SeccionResumenDia extends StatelessWidget {
  final ResumenDia? resumen;
  
  const _SeccionResumenDia({this.resumen});

  @override
  Widget build(BuildContext context) {
    if (resumen == null) return const SizedBox();
    
    return Card(
      child: Padding(
        padding: Dimensiones.paddingTodo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: AppColores.primario),
                const SizedBox(width: 8),
                const Text(
                  'VENTAS DE HOY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Dimensiones.esp16,
            
            // Total del día
            Container(
              width: double.infinity,
              padding: Dimensiones.paddingTodo,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColores.primario.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    FormateadorMoneda.formatear(resumen!.totalVentas),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColores.primario,
                    ),
                  ),
                  Text(
                    '${resumen?.cantidadVentas} venta(s)',
                    style: const TextStyle(
                      color: AppColores.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
            Dimensiones.esp16,
            
            // Contado vs Crédito
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppColores.exito.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.money, color: AppColores.exito),
                        const Text(
                          'CONTADO',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          FormateadorMoneda.formatear(resumen!.totalContado),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColores.exito,
                          ),
                        ),
                        Text(
                          '${resumen?.cantidadContado} venta(s)',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppColores.advertencia.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.credit_card, color: AppColores.advertencia),
                        const Text(
                          'CRÉDITO',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          FormateadorMoneda.formatear(resumen!.totalCredito),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColores.advertencia,
                          ),
                        ),
                        Text(
                          '${resumen?.cantidadCredito} venta(s)',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Sección de deudas
class _SeccionDeudas extends StatelessWidget {
  final ResumenDeudas? resumen;
  
  const _SeccionDeudas({this.resumen});

  @override
  Widget build(BuildContext context) {
    if (resumen == null) return const SizedBox();
    
    return Card(
      child: Padding(
        padding: Dimensiones.paddingTodo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: AppColores.error),
                    const SizedBox(width: 8),
                    const Text(
                      'CUENTAS POR COBRAR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => RutasApp.ir(context, '/reportes/deudas'),
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            Dimensiones.esp8,
            
            // Total de deudas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColores.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total por cobrar'),
                      Text(
                        FormateadorMoneda.formatear(resumen!.totalDeudas),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColores.error,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Deudores'),
                      Text(
                        '${resumen?.cantidadDeudores}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Top 3 deudores
            if (resumen?.deudores.isNotEmpty ?? false) ...[
              Dimensiones.esp8,
              const Text(
                'Mayores deudores:',
                style: TextStyle(fontSize: 12),
              ),
              ...resumen!.deudores.take(3).map((cliente) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(cliente.nombre),
                trailing: Text(
                  FormateadorMoneda.formatear(cliente.deudaTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColores.error,
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

// Sección de inventario
class _SeccionInventario extends StatelessWidget {
  final ResumenInventario? resumen;
  
  const _SeccionInventario({this.resumen});

  @override
  Widget build(BuildContext context) {
    if (resumen == null) return const SizedBox();
    
    return Card(
      child: Padding(
        padding: Dimensiones.paddingTodo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory, color: AppColores.secundario),
                    const SizedBox(width: 8),
                    const Text(
                      'INVENTARIO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => RutasApp.ir(context, '/reportes/inventario'),
                  child: const Text('Ver detalle'),
                ),
              ],
            ),
            Dimensiones.esp8,
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Valor Total'),
                        Text(
                          FormateadorMoneda.formatear(resumen!.valorTotal),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Total Kilos'),
                        Text(
                          '${resumen!.kilosTotales.toStringAsFixed(2)} kg',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Sección de productos más vendidos
class _SeccionProductosMasVendidos extends StatelessWidget {
  final List<ProductoVendido> productos;
  
  const _SeccionProductosMasVendidos({required this.productos});

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) return const SizedBox();
    
    return Card(
      child: Padding(
        padding: Dimensiones.paddingTodo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColores.exito),
                const SizedBox(width: 8),
                const Text(
                  'MÁS VENDIDOS (30 días)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Dimensiones.esp8,
            
            ...productos.take(5).map((producto) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(producto.productoNombre),
              subtitle: Text('${producto.cantidad.toStringAsFixed(2)} kg vendidos'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FormateadorMoneda.formatear(producto.total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${producto.veces} venta(s)',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Sección de stock bajo
class _SeccionStockBajo extends StatelessWidget {
  const _SeccionStockBajo();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductoModelo>>(
      stream: ReportesServicio().obtenerProductosStockBajo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }
        
        final productos = snapshot.data!;
        
        return Card(
          child: Padding(
            padding: Dimensiones.paddingTodo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: AppColores.advertencia),
                    const SizedBox(width: 8),
                    const Text(
                      'STOCK BAJO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Dimensiones.esp8,
                
                ...productos.map((producto) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(producto.nombre),
                  subtitle: Text(
                    'Stock: ${producto.stock.toStringAsFixed(2)} kg',
                    style: TextStyle(
                      color: producto.stock <= 2 ? AppColores.error : AppColores.advertencia,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    color: AppColores.primario,
                    onPressed: () => RutasApp.ir(context, RutasApp.registrarCompra, args: producto),
                    tooltip: 'Registrar compra',
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}