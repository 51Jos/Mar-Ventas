import 'package:flutter/material.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/dropdown_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../controladores/productos_controlador.dart';
import '../modelos/producto_modelo.dart';
import '../modelos/compra_modelo.dart';

class RegistrarCompraVista extends StatefulWidget {
  final ProductoModelo? producto;

  const RegistrarCompraVista({super.key, this.producto});

  @override
  State<RegistrarCompraVista> createState() => _RegistrarCompraVistaState();
}

class _RegistrarCompraVistaState extends State<RegistrarCompraVista> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ProductosControlador();

  // Controllers
  final _proveedorController = TextEditingController();
  final _kilosController = TextEditingController();
  final _precioKiloController = TextEditingController();

  ProductoModelo? _productoSeleccionado;
  DateTime _fechaCompra = DateTime.now();
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _productoSeleccionado = widget.producto;
    _controlador.inicializar();
  }

  @override
  void dispose() {
    _proveedorController.dispose();
    _kilosController.dispose();
    _precioKiloController.dispose();
    _controlador.dispose();
    super.dispose();
  }

  void _calcularTotal() {
    final kilos = double.tryParse(_kilosController.text) ?? 0;
    final precio = double.tryParse(_precioKiloController.text) ?? 0;
    setState(() {
      _total = kilos * precio;
    });
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaCompra,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _fechaCompra = fecha;
      });
    }
  }

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      if (_productoSeleccionado == null) {
        SnackBarExito.error(context, 'Selecciona un producto');
        return;
      }

      final compra = CompraModelo(
        productoId: _productoSeleccionado!.id!,
        productoNombre: _productoSeleccionado!.nombre,
        proveedor: _proveedorController.text.trim(),
        kilos: double.parse(_kilosController.text),
        precioKilo: double.parse(_precioKiloController.text),
        fecha: _fechaCompra,
      );

      final exito = await _controlador.registrarCompra(compra);

      if (exito) {
        // ignore: use_build_context_synchronously
        SnackBarExito.mostrar(context, 'Compra registrada y stock actualizado');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(
          context,
          _controlador.error ?? 'Error al registrar',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Compra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Dimensiones.paddingTodo,
          children: [
            // Selector de producto
            if (widget.producto == null)
              AnimatedBuilder(
                animation: _controlador,
                builder: (context, child) {
                  return DropdownPersonalizado<ProductoModelo>(
                    etiqueta: 'Producto',
                    valor: _productoSeleccionado,
                    items: _controlador.productos.map((p) {
                      return DropdownItem(
                        valor: p,
                        texto:
                            '${p.nombre} (Stock: ${p.stock.toStringAsFixed(2)} kg)',
                      );
                    }).toList(),
                    onChanged: (producto) {
                      setState(() {
                        _productoSeleccionado = producto;
                      });
                    },
                    validador: (valor) =>
                        valor == null ? 'Selecciona un producto' : null,
                    icono: Icons.restaurant_menu,
                  );
                },
              )
            else
              Card(
                // ignore: deprecated_member_use
                color: AppColores.primario.withOpacity(0),
                child: ListTile(
                  leading: const Icon(
                    Icons.restaurant_menu,
                    color: AppColores.primario,
                  ),
                  title: Text(widget.producto!.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock actual: ${widget.producto!.stock.toStringAsFixed(2)} kg',
                      ),
                      if (widget.producto!.precioCompra != null)
                        Text(
                          'Último precio de compra: ${FormateadorMoneda.formatear(widget.producto!.precioCompra!)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColores.textoSecundario,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            Dimensiones.esp16,

            // Proveedor
            CampoTextoPersonalizado(
              etiqueta: 'Proveedor',
              controller: _proveedorController,
              validador: (valor) => Validadores.requerido(valor),
              icono: Icons.business,
            ),
            Dimensiones.esp16,

            // Kilos
            CampoNumero(
              etiqueta: 'Cantidad',
              controller: _kilosController,
              validador: (valor) => Validadores.numero(valor),
              sufijo: 'kg',
              onChanged: (_) => _calcularTotal(),
            ),
            Dimensiones.esp16,

            // Precio por kilo
            CampoNumero(
              etiqueta: 'Precio por Kilo',
              controller: _precioKiloController,
              validador: (valor) => Validadores.numero(valor),
              prefijo: 'S/. ',
              onChanged: (_) => _calcularTotal(),
            ),
            Dimensiones.esp16,

            // Fecha
            CampoTextoPersonalizado(
              etiqueta: 'Fecha de Compra',
              controller: TextEditingController(
                text:
                    '${_fechaCompra.day}/${_fechaCompra.month}/${_fechaCompra.year}',
              ),
              soloLectura: true,
              icono: Icons.calendar_today,
              onTap: _seleccionarFecha,
            ),
            Dimensiones.esp24,

            // Total
            Container(
              padding: Dimensiones.paddingTodo,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColores.exito.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColores.exito),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    FormateadorMoneda.formatear(_total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColores.exito,
                    ),
                  ),
                ],
              ),
            ),
            Dimensiones.esp24,

            // Botón Registrar
            AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                return BotonPersonalizado(
                  texto: 'Registrar Compra',
                  onPressed: _registrar,
                  cargando: _controlador.cargando,
                  icono: Icons.add_shopping_cart,
                  color: AppColores.exito,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
