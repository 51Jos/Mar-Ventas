import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../compartido/componentes/dropdown_personalizado.dart';
import '../../../../compartido/tema/colores_app.dart';
import '../../../../compartido/utilidades/formateador_moneda.dart';
import '../../../productos/modelos/producto_modelo.dart';
import '../../../productos/servicios/productos_servicio.dart';

class ProductoSelectorVenta extends StatefulWidget {
  final Function(ProductoModelo) onProductoSeleccionado;
  
  const ProductoSelectorVenta({
    super.key,
    required this.onProductoSeleccionado,
  });

  @override
  State<ProductoSelectorVenta> createState() => _ProductoSelectorVentaState();
}

class _ProductoSelectorVentaState extends State<ProductoSelectorVenta> {
  final _productosServicio = ProductosServicio();
  ProductoModelo? _productoSeleccionado;
  List<ProductoModelo> _productos = [];
  StreamSubscription? _productosSub;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() {
    _productosServicio.obtenerProductos().listen((lista) {
      setState(() {
        // Solo productos con stock
        _productos = lista.where((p) => p.stock > 0).toList();
      });
    });
  }
  
  @override
  void dispose() {
    _productosSub?.cancel(); // 👈 muy importante
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownPersonalizado<ProductoModelo>(
          etiqueta: 'Seleccionar Producto',
          valor: _productoSeleccionado,
          items: _productos.map((producto) {
            return DropdownItem(
              valor: producto,
              texto: '${producto.nombre} (${producto.stock.toStringAsFixed(2)} kg)',
            );
          }).toList(),
          onChanged: (producto) {
            if (producto != null) {
              setState(() {
                _productoSeleccionado = producto;
              });
              widget.onProductoSeleccionado(producto);
            }
          },
          icono: Icons.restaurant_menu,
        ),
        
        // Información del producto seleccionado
        if (_productoSeleccionado != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stock disponible:',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_productoSeleccionado!.stock.toStringAsFixed(2)} kg',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _productoSeleccionado!.stock > 5 
                            ? AppColores.exito 
                            : AppColores.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Precio Público:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          FormateadorMoneda.formatear(_productoSeleccionado!.precioPublico),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Precio Mayorista:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          FormateadorMoneda.formatear(_productoSeleccionado!.precioMayorista),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColores.secundario,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}