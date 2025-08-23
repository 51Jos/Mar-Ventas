import 'package:flutter/material.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/dialogo_confirmacion.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../modelos/venta_modelo.dart';
import '../controladores/ventas_controlador.dart';

class DetalleVentaVista extends StatelessWidget {
  final VentaModelo venta;
  
  const DetalleVentaVista({
    super.key,
    required this.venta,
  });

  @override
  Widget build(BuildContext context) {
    final esAnulada = venta.estado == 'anulada';
    final esCredito = venta.tipoPago == 'credito';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        actions: [
          if (!esAnulada)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () {
                SnackBarExito.info(context, 'Función de impresión en desarrollo');
              },
              tooltip: 'Imprimir',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Estado de la venta
            if (esAnulada)
              Container(
                width: double.infinity,
                padding: Dimensiones.paddingTodo,
                color: AppColores.error,
                child: const Text(
                  'VENTA ANULADA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Información general
            Container(
              width: double.infinity,
              padding: Dimensiones.paddingTodo,
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fecha:',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        FormateadorFecha.fechaHora(venta.fecha),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID Venta:',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        venta.id ?? 'N/A',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Información del cliente
            Card(
              margin: Dimensiones.paddingTodo,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColores.primario,
                  child: Text(
                    venta.clienteNombre[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  venta.clienteNombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (venta.clienteTelefono != null)
                      Text('📞 ${venta.clienteTelefono}'),
                    if (venta.clienteId != null)
                      Text(
                        'Cliente registrado',
                        style: TextStyle(
                          color: AppColores.exito,
                          fontSize: 12,
                        ),
                      )
                    else
                      Text(
                        'Cliente eventual',
                        style: TextStyle(
                          color: AppColores.advertencia,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: venta.clienteId != null
                    ? IconButton(
                        icon: const Icon(Icons.account_circle),
                        onPressed: () {
                          // Navegar a estado de cuenta
                          RutasApp.ir(context, RutasApp.estadoCuenta);
                        },
                      )
                    : null,
              ),
            ),
            
            // Productos vendidos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'PRODUCTOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColores.textoSecundario,
                ),
              ),
            ),
            
            ...venta.items.map((item) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(
                  item.productoNombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: esAnulada ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${item.cantidad} kg × ${FormateadorMoneda.formatear(item.precio)}',
                  style: TextStyle(
                    fontSize: 12,
                    decoration: esAnulada ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormateadorMoneda.formatear(item.total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: esAnulada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.tipoPrecio == 'mayorista'
                            ? AppColores.secundario
                            : AppColores.primario,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.tipoPrecio.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            
            // Información de pago
            Container(
              margin: Dimensiones.paddingTodo,
              padding: Dimensiones.paddingTodo,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tipo de Pago:'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: esCredito
                              ? AppColores.advertencia
                              : AppColores.exito,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          venta.tipoPago.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Método de Pago:'),
                      Text(
                        venta.metodoPago.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (esCredito) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monto Pagado:'),
                        Text(
                          FormateadorMoneda.formatear(venta.montoPagado),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColores.exito,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo Pendiente:'),
                        Text(
                          FormateadorMoneda.formatear(venta.saldo),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColores.error,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Totales
            Container(
              padding: Dimensiones.paddingTodo,
              decoration: BoxDecoration(
                color: esAnulada 
                    ? Colors.grey.shade200
                    // ignore: deprecated_member_use
                    : AppColores.primario.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: esAnulada ? Colors.grey : AppColores.primario,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text(
                        FormateadorMoneda.formatear(venta.subtotal),
                        style: TextStyle(
                          decoration: esAnulada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                  if (venta.descuento > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Descuento:'),
                        Text(
                          '- ${FormateadorMoneda.formatear(venta.descuento)}',
                          style: const TextStyle(color: AppColores.error),
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        FormateadorMoneda.formatear(venta.total),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: esAnulada ? Colors.grey : AppColores.primario,
                          decoration: esAnulada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Observaciones
            if (venta.observaciones != null && venta.observaciones!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: Dimensiones.paddingTodo,
                padding: Dimensiones.paddingTodo,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Observaciones:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venta.observaciones!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            
            // Botón anular
            if (!esAnulada)
              Padding(
                padding: Dimensiones.paddingTodo,
                child: BotonPersonalizado(
                  texto: 'Anular Venta',
                  onPressed: () async {
                    final confirmar = await DialogoConfirmacion.mostrar(
                      context: context,
                      titulo: 'Anular Venta',
                      mensaje: '¿Estás seguro de anular esta venta? Se devolverá el stock y se ajustará la deuda del cliente.',
                      textoConfirmar: 'Anular',
                      esDestructivo: true,
                    );
                    
                    if (confirmar == true && venta.id != null) {
                      final controlador = VentasControlador();
                      final exito = await controlador.anularVenta(venta.id!);
                      
                      if (exito) {
                        // ignore: use_build_context_synchronously
                        SnackBarExito.mostrar(context, 'Venta anulada exitosamente');
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      } else {
                        SnackBarExito.error(
                          // ignore: use_build_context_synchronously
                          context,
                          controlador.error ?? 'Error al anular venta',
                        );
                      }
                    }
                  },
                  color: AppColores.error,
                  icono: Icons.cancel,
                ),
              ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}