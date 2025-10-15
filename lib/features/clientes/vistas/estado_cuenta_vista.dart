import 'package:flutter/material.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../modelos/cliente_modelo.dart';
import '../modelos/abono_modelo.dart';
import '../servicios/clientes_servicio.dart';
import '../../../compartido/servicios/whatsapp_servicio.dart';
import '../../../compartido/componentes/snackbar_exito.dart';

class EstadoCuentaVista extends StatelessWidget {
  final ClienteModelo cliente;

  const EstadoCuentaVista({
    super.key,
    required this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClienteModelo?>(
      stream: ClientesServicio().obtenerClienteStream(cliente.id!),
      initialData: cliente,
      builder: (context, clienteSnapshot) {
        final clienteActual = clienteSnapshot.data ?? cliente;

        return StreamBuilder<List<AbonoModelo>>(
          stream: ClientesServicio().obtenerAbonosCliente(clienteActual.id!),
          builder: (context, abonosSnapshot) {
            final abonos = abonosSnapshot.data ?? [];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Estado de Cuenta'),
                actions: [
                  // Botón WhatsApp
                  IconButton(
                    icon: const Icon(Icons.chat),
                    color: Colors.green,
                    onPressed: () async {
                      if (!WhatsAppServicio.validarTelefono(clienteActual.telefono)) {
                        SnackBarExito.advertencia(
                          context,
                          'El cliente no tiene un número de teléfono válido',
                        );
                        return;
                      }

                      final exito = await WhatsAppServicio.enviarEstadoCuenta(
                        cliente: clienteActual,
                        abonos: abonos,
                        nombreNegocio: 'Marventas',
                      );

                      if (!exito && context.mounted) {
                        SnackBarExito.error(
                          context,
                          'No se pudo abrir WhatsApp',
                        );
                      }
                    },
                    tooltip: 'Enviar por WhatsApp',
                  ),
                  if (clienteActual.tieneDeuda)
                    IconButton(
                      icon: const Icon(Icons.payment),
                      onPressed: () => RutasApp.ir(
                        context,
                        RutasApp.registrarAbono,
                        args: clienteActual,
                      ),
                      tooltip: 'Registrar Abono',
                    ),
                ],
              ),
          body: Column(
        children: [
          // Info del cliente
          Container(
            width: double.infinity,
            padding: Dimensiones.paddingTodo,
            color: AppColores.primario,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    clienteActual.nombre.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColores.primario,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clienteActual.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (clienteActual.telefono != null)
                  Text(
                    '📞 ${clienteActual.telefono}',
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
          
          // Estado de deuda
          Container(
            width: double.infinity,
            padding: Dimensiones.paddingTodo,
            color: clienteActual.tieneDeuda
                // ignore: deprecated_member_use
                ? AppColores.error.withOpacity(0.1)
                // ignore: deprecated_member_use
                : AppColores.exito.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  clienteActual.tieneDeuda ? 'DEUDA ACTUAL' : 'ESTADO',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  clienteActual.tieneDeuda
                      ? FormateadorMoneda.formatear(clienteActual.deudaTotal)
                      : 'SIN DEUDA ✓',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: clienteActual.tieneDeuda ? AppColores.error : AppColores.exito,
                  ),
                ),
              ],
            ),
          ),
          
          // Título de historial
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: const Text(
              'HISTORIAL DE ABONOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColores.textoSecundario,
              ),
            ),
          ),
          
          // Lista de abonos
          Expanded(
            child: abonos.isEmpty
                ? const EstadoVacio(
                    titulo: 'Sin abonos registrados',
                    subtitulo: 'Los pagos aparecerán aquí',
                    icono: Icons.payment_outlined,
                  )
                : Builder(
                    builder: (context) {
                      final totalAbonado = abonos.fold<double>(0, (sum, a) => sum + a.monto);

                      return Column(
                        children: [
                          // Resumen
                          Container(
                            padding: const EdgeInsets.all(12),
                            // ignore: deprecated_member_use
                            color: AppColores.primario.withOpacity(0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total abonado (${abonos.length} pagos):'),
                                Text(
                                  FormateadorMoneda.formatear(totalAbonado),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColores.exito,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Lista de abonos
                          Expanded(
                            child: ListView.builder(
                              itemCount: abonos.length,
                              itemBuilder: (context, index) {
                                final abono = abonos[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    // ignore: deprecated_member_use
                                    backgroundColor: AppColores.exito.withOpacity(0.2),
                                    child: const Icon(
                                      Icons.arrow_downward,
                                      color: AppColores.exito,
                                    ),
                                  ),
                                  title: Text(
                                    FormateadorMoneda.formatear(abono.monto),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColores.exito,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(FormateadorFecha.fechaHora(abono.fecha)),
                                      if (abono.observaciones != null && abono.observaciones!.isNotEmpty)
                                        Text(
                                          abono.observaciones!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Text(
                                    FormateadorFecha.relativo(abono.fecha),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColores.textoSecundario,
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

      // FAB para agregar abono
      floatingActionButton: clienteActual.tieneDeuda
          ? FloatingActionButton.extended(
              onPressed: () => RutasApp.ir(
                context,
                RutasApp.registrarAbono,
                args: clienteActual,
              ),
              icon: const Icon(Icons.payment),
              label: const Text('Registrar Abono'),
              backgroundColor: AppColores.exito,
            )
          : null,
            );
          },
        );
      },
    );
  }
}