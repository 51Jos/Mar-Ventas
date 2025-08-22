import 'package:flutter/material.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../controladores/productos_controlador.dart';
import '../modelos/producto_modelo.dart';

class ProductoAgregarVista extends StatefulWidget {
  const ProductoAgregarVista({super.key});

  @override
  State<ProductoAgregarVista> createState() => _ProductoAgregarVistaState();
}

class _ProductoAgregarVistaState extends State<ProductoAgregarVista> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ProductosControlador();

  // Controllers
  final _nombreController = TextEditingController();
  final _stockController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioPublicoController = TextEditingController();
  final _precioMayoristaController = TextEditingController();

  double _total = 0;

  void _calcularTotal() {
    final stock = double.tryParse(_stockController.text) ?? 0;
    final precio = double.tryParse(_precioCompraController.text) ?? 0;
    setState(() {
      _total = stock * precio;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _stockController.dispose();
    _precioCompraController.dispose();
    _precioPublicoController.dispose();
    _precioMayoristaController.dispose();
    // No disposear el controlador aquí si lo usas en AnimatedBuilder
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final producto = ProductoModelo(
        nombre: _nombreController.text.trim(),
        stock: double.parse(_stockController.text),
        precioCompra: double.parse(_precioCompraController.text),
        precioPublico: double.parse(_precioPublicoController.text),
        precioMayorista: double.parse(_precioMayoristaController.text),
      );

      final exito = await _controlador.crearProducto(producto);

      if (exito) {
        // ignore: use_build_context_synchronously
        SnackBarExito.mostrar(context, 'Producto agregado exitosamente');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(context, _controlador.error ?? 'Error al guardar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Dimensiones.paddingTodo,
          children: [
            // Nombre
            CampoTextoPersonalizado(
              etiqueta: 'Nombre del Producto',
              controller: _nombreController,
              validador: (valor) => Validadores.requerido(valor),
              icono: Icons.restaurant_menu,
            ),
            Dimensiones.esp16,

            // Stock inicial
            CampoNumero(
              etiqueta: 'Stock Inicial',
              controller: _stockController,
              validador: (valor) => Validadores.numero(valor),
              sufijo: 'kg',
              onChanged: (_) => _calcularTotal(),
            ),
            Dimensiones.esp16,

            // Precio de Compra
            CampoNumero(
              etiqueta: 'Precio de Compra (por kg)',
              controller: _precioCompraController,
              validador: (valor) => Validadores.numero(valor),
              prefijo: 'S/. ',
              onChanged: (_) => _calcularTotal(),
            ),
            Dimensiones.esp16,

            // Precio Público
            CampoNumero(
              etiqueta: 'Precio Público',
              controller: _precioPublicoController,
              validador: (valor) => Validadores.numero(valor),
              prefijo: 'S/. ',
            ),
            Dimensiones.esp16,

            // Precio Mayorista
            CampoNumero(
              etiqueta: 'Precio Mayorista',
              controller: _precioMayoristaController,
              validador: (valor) => Validadores.numero(valor),
              prefijo: 'S/. ',
            ),
            Dimensiones.esp24,

            // Total calculado
            Container(
              padding: Dimensiones.paddingTodo,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL A PAGAR:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'S/. ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Dimensiones.esp32,

            // Botón Guardar
            AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                return BotonPersonalizado(
                  texto: 'Guardar Producto',
                  onPressed: _guardar,
                  cargando: _controlador.cargando,
                  icono: Icons.save,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
