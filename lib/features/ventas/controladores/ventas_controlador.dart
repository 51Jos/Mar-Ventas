import 'package:flutter/material.dart';
import '../modelos/venta_modelo.dart';
import '../servicios/ventas_servicio.dart';
import '../../productos/modelos/producto_modelo.dart';
import '../../clientes/modelos/cliente_modelo.dart';

class VentasControlador extends ChangeNotifier {
  final VentasServicio _servicio = VentasServicio();
  
  // Estado
  bool _cargando = false;
  String? _error;
  final List<ItemVenta> _itemsVenta = [];
  ClienteModelo? _clienteSeleccionado;
  String _tipoPago = 'contado';
  String _metodoPago = 'efectivo';
  double _descuento = 0;
  
  // Getters
  bool get cargando => _cargando;
  String? get error => _error;
  List<ItemVenta> get itemsVenta => _itemsVenta;
  ClienteModelo? get clienteSeleccionado => _clienteSeleccionado;
  String get tipoPago => _tipoPago;
  String get metodoPago => _metodoPago;
  double get descuento => _descuento;
  
  double get subtotal => _itemsVenta.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal - _descuento;
  
  // Agregar item a la venta
  void agregarItem(ProductoModelo producto, double cantidad, String tipoPrecio) {
    final precio = tipoPrecio == 'mayorista' 
        ? producto.precioMayorista 
        : producto.precioPublico;
    
    // Verificar si ya existe el producto
    final index = _itemsVenta.indexWhere((item) => item.productoId == producto.id);
    
    if (index != -1) {
      // Si existe, actualizar cantidad
      final itemExistente = _itemsVenta[index];
      _itemsVenta[index] = ItemVenta(
        productoId: itemExistente.productoId,
        productoNombre: itemExistente.productoNombre,
        cantidad: itemExistente.cantidad + cantidad,
        precio: precio,
        tipoPrecio: tipoPrecio,
      );
    } else {
      // Si no existe, agregar nuevo
      _itemsVenta.add(ItemVenta(
        productoId: producto.id!,
        productoNombre: producto.nombre,
        cantidad: cantidad,
        precio: precio,
        tipoPrecio: tipoPrecio,
      ));
    }
    notifyListeners();
  }
  
  // Quitar item de la venta
  void quitarItem(int index) {
    _itemsVenta.removeAt(index);
    notifyListeners();
  }
  
  // Actualizar cantidad de item
  void actualizarCantidad(int index, double nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      quitarItem(index);
    } else {
      final item = _itemsVenta[index];
      _itemsVenta[index] = ItemVenta(
        productoId: item.productoId,
        productoNombre: item.productoNombre,
        cantidad: nuevaCantidad,
        precio: item.precio,
        tipoPrecio: item.tipoPrecio,
      );
      notifyListeners();
    }
  }
  
  // Seleccionar cliente
  void seleccionarCliente(ClienteModelo? cliente) {
    _clienteSeleccionado = cliente;
    notifyListeners();
  }
  
  // Cambiar tipo de pago
  void cambiarTipoPago(String tipo) {
    _tipoPago = tipo;
    notifyListeners();
  }
  
  // Cambiar método de pago
  void cambiarMetodoPago(String metodo) {
    _metodoPago = metodo;
    notifyListeners();
  }
  
  // Aplicar descuento
  void aplicarDescuento(double descuento) {
    _descuento = descuento;
    notifyListeners();
  }
  
  // Limpiar venta
  void limpiarVenta() {
    _itemsVenta.clear();
    _clienteSeleccionado = null;
    _tipoPago = 'contado';
    _metodoPago = 'efectivo';
    _descuento = 0;
    notifyListeners();
  }
  
  // Registrar venta
  Future<bool> registrarVenta({
    required String clienteNombre,
    String? clienteTelefono,
    double montoPagado = 0,
    String? observaciones,
  }) async {
    if (_itemsVenta.isEmpty) {
      _error = 'Agrega al menos un producto';
      notifyListeners();
      return false;
    }
    
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      final venta = VentaModelo(
        clienteId: _clienteSeleccionado?.id,
        clienteNombre: clienteNombre,
        clienteTelefono: clienteTelefono,
        items: _itemsVenta,
        tipoPago: _tipoPago,
        metodoPago: _metodoPago,
        montoPagado: _tipoPago == 'contado' ? total : montoPagado,
        descuento: _descuento,
        fecha: DateTime.now(),
        observaciones: observaciones,
      );
      
      await _servicio.registrarVenta(venta);
      
      limpiarVenta();
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }
  
  // Anular venta
  Future<bool> anularVenta(String ventaId) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.anularVenta(ventaId);
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
      return false;
    }
  }
  
}