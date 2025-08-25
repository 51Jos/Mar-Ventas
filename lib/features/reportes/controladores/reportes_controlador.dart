/// Controlador para reportes

import 'package:flutter/material.dart';
import '../servicios/reportes_servicios.dart';
import '../../ventas/modelos/venta_modelo.dart';

class ReportesControlador extends ChangeNotifier {
  final ReportesServicio _servicio = ReportesServicio();
  
  bool _cargando = false;
  String? _error;
  
  ResumenDia? _resumenDia;
  ResumenDeudas? _resumenDeudas;
  ResumenInventario? _resumenInventario;
  List<ProductoVendido> _productosMasVendidos = [];
  List<VentaModelo> _ventasRango = [];
  
  // Getters
  bool get cargando => _cargando;
  String? get error => _error;
  ResumenDia? get resumenDia => _resumenDia;
  ResumenDeudas? get resumenDeudas => _resumenDeudas;
  ResumenInventario? get resumenInventario => _resumenInventario;
  List<ProductoVendido> get productosMasVendidos => _productosMasVendidos;
  List<VentaModelo> get ventasRango => _ventasRango;
  
  // Cargar resumen del día
  Future<void> cargarResumenDia() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      _resumenDia = await _servicio.obtenerResumenDelDia();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }
  
  // Cargar resumen de deudas
  Future<void> cargarResumenDeudas() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      _resumenDeudas = await _servicio.obtenerResumenDeudas();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }
  
  // Cargar resumen de inventario
  Future<void> cargarResumenInventario() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      _resumenInventario = await _servicio.obtenerResumenInventario();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }
  
  // Cargar productos más vendidos
  Future<void> cargarProductosMasVendidos({int dias = 30}) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      _productosMasVendidos = await _servicio.obtenerProductosMasVendidos(dias: dias);
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }
  
  // Cargar ventas por rango
  Future<void> cargarVentasPorRango(DateTime inicio, DateTime fin) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      _ventasRango = await _servicio.obtenerVentasPorRango(inicio, fin);
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }
  
  // Cargar todo
  Future<void> cargarTodo() async {
    await Future.wait([
      cargarResumenDia(),
      cargarResumenDeudas(),
      cargarResumenInventario(),
      cargarProductosMasVendidos(),
    ]);
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}