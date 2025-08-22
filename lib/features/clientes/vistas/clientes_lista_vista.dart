import 'package:flutter/material.dart';
import '../../../compartido/layout/layout_principal.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/estado_vacio.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/componentes/dialogo_confirmacion.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../../rutas/rutas_app.dart';
import '../modelos/cliente_modelo.dart';
import '../servicios/clientes_servicio.dart';

class ClientesListaVista extends StatefulWidget {
  const ClientesListaVista({super.key});

  @override
  State<ClientesListaVista> createState() => _ClientesListaVistaState();
}

class _ClientesListaVistaState extends State<ClientesListaVista> {
  final _busquedaController = TextEditingController();
  String _filtro = 'todos'; // todos, con_deuda, sin_deuda
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      titulo: 'Clientes',
      indiceActual: 2,
      child: Column(
        children: [
          // Buscador y filtros
          Container(
            padding: Dimensiones.paddingTodo,
            child: Column(
              children: [
                // Buscador
                CampoTextoPersonalizado(
                  etiqueta: 'Buscar cliente',
                  controller: _busquedaController,
                  icono: Icons.search,
                  onChanged: (valor) {
                    setState(() {
                      _busqueda = valor;
                    });
                  },
                ),
                const SizedBox(height: 8),
                
                // Filtros
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Todos'),
                        selected: _filtro == 'todos',
                        onSelected: (_) => setState(() => _filtro = 'todos'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Con Deuda'),
                        selected: _filtro == 'con_deuda',
                        // ignore: deprecated_member_use
                        selectedColor: AppColores.error.withOpacity(0.3),
                        onSelected: (_) => setState(() => _filtro = 'con_deuda'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Sin Deuda'),
                        selected: _filtro == 'sin_deuda',
                        // ignore: deprecated_member_use
                        selectedColor: AppColores.exito.withOpacity(0.3),
                        onSelected: (_) => setState(() => _filtro = 'sin_deuda'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de clientes
          Expanded(
            child: StreamBuilder<List<ClienteModelo>>(
              stream: _filtro == 'con_deuda' 
                  ? ClientesServicio().obtenerClientesConDeuda()
                  : ClientesServicio().obtenerClientes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const WidgetCargando(mensaje: 'Cargando clientes...');
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                var clientes = snapshot.data ?? [];
                
                // Aplicar filtros
                if (_filtro == 'sin_deuda') {
                  clientes = clientes.where((c) => !c.tieneDeuda).toList();
                }
                
                // Aplicar búsqueda
                if (_busqueda.isNotEmpty) {
                  clientes = clientes.where((c) => 
                    c.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
                    (c.telefono?.contains(_busqueda) ?? false)
                  ).toList();
                }
                
                if (clientes.isEmpty) {
                  return EstadosVacios.sinClientes(
                    onAgregar: () => RutasApp.ir(context, RutasApp.agregarCliente),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return _ClienteTarjeta(cliente: cliente);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de tarjeta de cliente
class _ClienteTarjeta extends StatelessWidget {
  final ClienteModelo cliente;

  const _ClienteTarjeta({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cliente.tieneDeuda ? AppColores.error : AppColores.exito,
          child: Text(
            cliente.nombre.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          cliente.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
              Text('📞 ${cliente.telefono}'),
            Text(
              cliente.tieneDeuda 
                  ? 'Deuda: ${FormateadorMoneda.formatear(cliente.deudaTotal)}'
                  : 'Sin deuda',
              style: TextStyle(
                color: cliente.tieneDeuda ? AppColores.error : AppColores.exito,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (valor) async {
            switch (valor) {
              case 'detalle':
                RutasApp.ir(context, RutasApp.estadoCuenta, args: cliente);
                break;
              case 'editar':
                RutasApp.ir(context, '/clientes/editar', args: cliente);
                break;
              case 'abono':
                if (cliente.tieneDeuda) {
                  RutasApp.ir(context, RutasApp.registrarAbono, args: cliente);
                } else {
                  SnackBarExito.info(context, 'El cliente no tiene deuda');
                }
                break;
              case 'eliminar':
                final confirmar = await DialogoConfirmacion.eliminar(context, 'cliente');
                if (confirmar == true && cliente.id != null) {
                  await ClientesServicio().eliminarCliente(cliente.id!);
                  // ignore: use_build_context_synchronously
                  SnackBarExito.mostrar(context, 'Cliente eliminado');
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'detalle', child: Text('Ver Estado de Cuenta')),
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            if (cliente.tieneDeuda)
              const PopupMenuItem(value: 'abono', child: Text('Registrar Abono')),
            const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}