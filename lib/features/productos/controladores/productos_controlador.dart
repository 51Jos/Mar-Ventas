import 'dart:async';

import 'package:flutter/material.dart';
import '../modelos/producto_modelo.dart';
import '../modelos/compra_modelo.dart';
import '../servicios/productos_servicio.dart';

class ProductosControlador extends ChangeNotifier {
  final ProductosServicio _servicio = ProductosServicio();
  
  List<ProductoModelo> _productos = [];
  List<CompraModelo> _compras = [];
  bool _cargando = false;
  String? _error;
  String _busqueda = '';
  StreamSubscription? _productosSub;
  StreamSubscription? _comprasSub;

  // Getters
  List<ProductoModelo> get productos => _busqueda.isEmpty
      ? _productos
      : _productos.where((p) => 
          p.nombre.toLowerCase().contains(_busqueda.toLowerCase())).toList();
  
  List<CompraModelo> get compras => _compras;
  bool get cargando => _cargando;
  String? get error => _error;

  // Inicializar escucha de productos
  void inicializar() {
    _productosSub = _servicio.obtenerProductos().listen(
      (lista) {
        _productos = lista;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // Buscar productos
  void buscar(String termino) {
    _busqueda = termino;
    notifyListeners();
  }

  // Crear producto
  Future<bool> crearProducto(ProductoModelo producto) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.crearProducto(producto);
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

  // Actualizar producto
  Future<bool> actualizarProducto(ProductoModelo producto) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.actualizarProducto(producto);
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

  // Eliminar producto
  Future<bool> eliminarProducto(String id) async {
    try {
      await _servicio.eliminarProducto(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Registrar compra
  Future<bool> registrarCompra(CompraModelo compra) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.registrarCompra(compra);
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

  // Cargar historial de compras
  void cargarCompras({String? productoId}) {
    _comprasSub?.cancel(); // Cancela la suscripción anterior
    _comprasSub = _servicio.obtenerCompras(productoId: productoId).listen(
      (lista) {
        _compras = lista;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // Obtener producto por ID
  ProductoModelo? obtenerProductoPorId(String id) {
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _productosSub?.cancel();
    _comprasSub?.cancel();
    super.dispose();
  }
}