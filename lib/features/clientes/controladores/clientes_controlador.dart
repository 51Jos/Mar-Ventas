import 'package:flutter/material.dart';
import '../modelos/cliente_modelo.dart';
import '../modelos/abono_modelo.dart';
import '../servicios/clientes_servicio.dart';

class ClientesControlador extends ChangeNotifier {
  final ClientesServicio _servicio = ClientesServicio();
  
  bool _cargando = false;
  String? _error;
  
  bool get cargando => _cargando;
  String? get error => _error;
  
  // Crear cliente
  Future<bool> crearCliente(ClienteModelo cliente) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.crearCliente(cliente);
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
  
  // Actualizar cliente
  Future<bool> actualizarCliente(ClienteModelo cliente) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.actualizarCliente(cliente);
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
  
  // Eliminar cliente
  Future<bool> eliminarCliente(String id) async {
    try {
      await _servicio.eliminarCliente(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Registrar abono
  Future<bool> registrarAbono(AbonoModelo abono) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.registrarAbono(abono);
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
  
  // Obtener cliente por ID
  Future<ClienteModelo?> obtenerClientePorId(String id) async {
    try {
      return await _servicio.obtenerClientePorId(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
}