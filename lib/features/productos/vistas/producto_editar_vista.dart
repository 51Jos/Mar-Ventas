import 'package:flutter/material.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../controladores/productos_controlador.dart';
import '../modelos/producto_modelo.dart';

class ProductoEditarVista extends StatefulWidget {
  final ProductoModelo producto;
  
  const ProductoEditarVista({
    super.key,
    required this.producto,
  });

  @override
  State<ProductoEditarVista> createState() => _ProductoEditarVistaState();
}

class _ProductoEditarVistaState extends State<ProductoEditarVista> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ProductosControlador();
  
  late TextEditingController _nombreController;
  late TextEditingController _stockController;
  late TextEditingController _precioPublicoController;
  late TextEditingController _precioMayoristaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _stockController = TextEditingController(text: widget.producto.stock.toString());
    _precioPublicoController = TextEditingController(text: widget.producto.precioPublico.toString());
    _precioMayoristaController = TextEditingController(text: widget.producto.precioMayorista.toString());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _stockController.dispose();
    _precioPublicoController.dispose();
    _precioMayoristaController.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _actualizar() async {
    if (_formKey.currentState!.validate()) {
      final productoActualizado = widget.producto.copyWith(
        nombre: _nombreController.text.trim(),
        stock: double.parse(_stockController.text),
        precioPublico: double.parse(_precioPublicoController.text),
        precioMayorista: double.parse(_precioMayoristaController.text),
      );
      
      final exito = await _controlador.actualizarProducto(productoActualizado);
      
      if (exito) {
        // ignore: use_build_context_synchronously
        SnackBarExito.mostrar(context, 'Producto actualizado');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(context, _controlador.error ?? 'Error al actualizar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Dimensiones.paddingTodo,
          children: [
            // Info del producto
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: Dimensiones.paddingTodo,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    Dimensiones.espacioH(8),
                    Text('Editando: ${widget.producto.nombre}'),
                  ],
                ),
              ),
            ),
            Dimensiones.esp16,
            
            // Nombre
            CampoTextoPersonalizado(
              etiqueta: 'Nombre del Producto',
              controller: _nombreController,
              validador: (valor) => Validadores.requerido(valor),
              icono: Icons.restaurant_menu,
            ),
            Dimensiones.esp16,
            
            // Stock actual
            CampoNumero(
              etiqueta: 'Stock Actual',
              controller: _stockController,
              validador: (valor) => Validadores.numero(valor),
              sufijo: 'kg',
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
            Dimensiones.esp32,
            
            // Botones
            AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                return Column(
                  children: [
                    BotonPersonalizado(
                      texto: 'Actualizar Producto',
                      onPressed: _actualizar,
                      cargando: _controlador.cargando,
                      icono: Icons.update,
                    ),
                    Dimensiones.esp8,
                    BotonPersonalizado(
                      texto: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      secundario: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}