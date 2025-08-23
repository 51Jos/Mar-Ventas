import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/componentes/dialogo_confirmacion.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../../clientes/modelos/cliente_modelo.dart';
import '../../clientes/servicios/clientes_servicio.dart';
import '../../productos/modelos/producto_modelo.dart';
import '../controladores/ventas_controlador.dart';
import '../componentes/nueva_venta/cliente_selector.dart';
import '../componentes/nueva_venta/producto_selector.dart';
import '../componentes/nueva_venta/tipo_pago_selector.dart';

class NuevaVentaVista extends StatefulWidget {
  const NuevaVentaVista({super.key});

  @override
  State<NuevaVentaVista> createState() => _NuevaVentaVistaState();
}

class _NuevaVentaVistaState extends State<NuevaVentaVista> {
  final _cantidadController = TextEditingController();
  final _montoPagadoController = TextEditingController();
  final _observacionesController = TextEditingController();

  ProductoModelo? _productoSeleccionado;
  String _tipoPrecio = 'publico';
  ClienteModelo? _clienteExistente;
  String? _clienteNuevoNombre;
  String? _clienteNuevoTelefono;

  @override
  void dispose() {
    _cantidadController.dispose();
    _montoPagadoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _agregarProducto(VentasControlador controlador) {
    if (_productoSeleccionado == null) {
      SnackBarExito.advertencia(context, 'Selecciona un producto');
      return;
    }

    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    if (cantidad <= 0) {
      SnackBarExito.advertencia(context, 'Ingresa una cantidad válida');
      return;
    }

    if (cantidad > _productoSeleccionado!.stock) {
      SnackBarExito.advertencia(context, 'Stock insuficiente');
      return;
    }

    controlador.agregarItem(_productoSeleccionado!, cantidad, _tipoPrecio);

    // Limpiar campos
    setState(() {
      _productoSeleccionado = null;
      _cantidadController.clear();
      _tipoPrecio = 'publico';
    });

    SnackBarExito.mostrar(context, 'Producto agregado');
  }

  Future<void> _confirmarVenta(VentasControlador controlador) async {
    // Validar que hay productos
    if (controlador.itemsVenta.isEmpty) {
      SnackBarExito.advertencia(context, 'Agrega al menos un producto');
      return;
    }

    // Validar cliente
    final nombreCliente = _clienteExistente?.nombre ?? _clienteNuevoNombre;
    if (nombreCliente == null || nombreCliente.isEmpty) {
      SnackBarExito.advertencia(context, 'Ingresa el nombre del cliente');
      return;
    }

    // Si es crédito, validar monto pagado
    double montoPagado = 0;
    if (controlador.tipoPago == 'credito') {
      montoPagado = double.tryParse(_montoPagadoController.text) ?? 0;
      if (montoPagado < 0) {
        SnackBarExito.advertencia(context, 'Ingresa un monto válido');
        return;
      }
    }

    // Confirmar venta
    final confirmar = await DialogoConfirmacion.mostrar(
      context: context,
      titulo: 'Confirmar Venta',
      mensaje:
          '¿Deseas registrar esta venta por ${FormateadorMoneda.formatear(controlador.total)}?',
      textoConfirmar: 'Registrar',
    );

    if (confirmar != true) return;

    // Si es cliente nuevo, crearlo primero
    if (_clienteExistente == null && _clienteNuevoNombre != null) {
      final nuevoCliente = ClienteModelo(
        nombre: _clienteNuevoNombre!,
        telefono: _clienteNuevoTelefono,
        fechaRegistro: DateTime.now(),
      );
      final clienteId = await ClientesServicio().crearCliente(nuevoCliente);
      _clienteExistente = nuevoCliente.copyWith(id: clienteId);
      controlador.seleccionarCliente(
        _clienteExistente,
      ); // Actualiza el controlador
      await Future.delayed(Duration.zero); // Forza sincronización
    }

    // Registrar venta
    final exito = await controlador.registrarVenta(
      clienteNombre: nombreCliente,
      clienteTelefono: _clienteExistente?.telefono ?? _clienteNuevoTelefono,
      montoPagado: montoPagado,
      observaciones: _observacionesController.text.trim(),
    );

    if (exito) {
      // ignore: use_build_context_synchronously
      SnackBarExito.mostrar(context, 'Venta registrada exitosamente');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      SnackBarExito.error(
        // ignore: use_build_context_synchronously
        context,
        controlador.error ?? 'Error al registrar venta',
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VentasControlador(),
      child: Consumer<VentasControlador>(
        builder: (context, controlador, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nueva Venta'),
              actions: [
                if (controlador.itemsVenta.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () async {
                      final confirmar = await DialogoConfirmacion.mostrar(
                        context: context,
                        titulo: 'Limpiar Venta',
                        mensaje: '¿Deseas eliminar todos los productos?',
                      );
                      if (confirmar == true) {
                        controlador.limpiarVenta();
                      }
                    },
                  ),
              ],
            ),
            body: Column(
              children: [
                // Formulario
                Expanded(
                  child: ListView(
                    padding: Dimensiones.paddingTodo,
                    children: [
                      // Cliente
                      ClienteSelector(
                        onClienteSeleccionado: (cliente) {
                          setState(() {
                            _clienteExistente = cliente;
                          });
                          controlador.seleccionarCliente(cliente);
                        },
                        onClienteNuevo: (nombre, telefono) {
                          setState(() {
                            _clienteNuevoNombre = nombre;
                            _clienteNuevoTelefono = telefono;
                          });
                        },
                      ),
                      Dimensiones.esp16,

                      // Producto
                      ProductoSelectorVenta(
                        onProductoSeleccionado: (producto) {
                          setState(() {
                            _productoSeleccionado = producto;
                          });
                        },
                      ),

                      if (_productoSeleccionado != null) ...[
                        Dimensiones.esp16,

                        // Cantidad y tipo precio
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CampoNumero(
                                etiqueta: 'Cantidad (kg)',
                                controller: _cantidadController,
                                validador: (v) => Validadores.numero(v),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tipo Precio',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment(
                                        value: 'publico',
                                        label: Text('Público'),
                                      ),
                                      ButtonSegment(
                                        value: 'mayorista',
                                        label: Text('Mayorista'),
                                      ),
                                    ],
                                    selected: {_tipoPrecio},
                                    onSelectionChanged:
                                        (Set<String> newSelection) {
                                          setState(() {
                                            _tipoPrecio = newSelection.first;
                                          });
                                        },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Dimensiones.esp16,

                        // Botón agregar
                        BotonPersonalizado(
                          texto: 'Agregar Producto',
                          onPressed: () => _agregarProducto(controlador),
                          icono: Icons.add_shopping_cart,
                          secundario: true,
                        ),
                      ],

                      // Lista de productos agregados
                      if (controlador.itemsVenta.isNotEmpty) ...[
                        Dimensiones.esp24,
                        const Text(
                          'Productos en la Venta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Dimensiones.esp8,
                        ...controlador.itemsVenta.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Card(
                            child: ListTile(
                              title: Text(item.productoNombre),
                              subtitle: Text(
                                '${item.cantidad} kg × ${FormateadorMoneda.formatear(item.precio)} (${item.tipoPrecio})',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    FormateadorMoneda.formatear(item.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColores.error,
                                    ),
                                    onPressed: () =>
                                        controlador.quitarItem(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],

                      Dimensiones.esp24,

                      // Tipo de pago
                      TipoPagoSelector(
                        tipoPago: controlador.tipoPago,
                        metodoPago: controlador.metodoPago,
                        onTipoPagoChanged: controlador.cambiarTipoPago,
                        onMetodoPagoChanged: controlador.cambiarMetodoPago,
                      ),

                      // Monto pagado si es crédito
                      if (controlador.tipoPago == 'credito') ...[
                        Dimensiones.esp16,
                        CampoNumero(
                          etiqueta: 'Monto Pagado (Inicial)',
                          controller: _montoPagadoController,
                          prefijo: 'S/. ',
                        ),
                      ],

                      Dimensiones.esp16,

                      // Observaciones
                      CampoTextoPersonalizado(
                        etiqueta: 'Observaciones (opcional)',
                        controller: _observacionesController,
                        maxLineas: 2,
                        icono: Icons.note,
                      ),
                    ],
                  ),
                ),

                // Resumen y botón confirmar
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            FormateadorMoneda.formatear(controlador.total),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColores.primario,
                            ),
                          ),
                        ],
                      ),
                      Dimensiones.esp16,
                      BotonPersonalizado(
                        texto: 'Confirmar Venta',
                        onPressed: controlador.cargando
                            ? null
                            : () => _confirmarVenta(controlador),
                        cargando: controlador.cargando,
                        icono: Icons.check_circle,
                        color: AppColores.exito,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
