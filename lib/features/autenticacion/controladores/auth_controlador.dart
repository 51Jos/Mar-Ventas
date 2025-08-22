import 'package:flutter/material.dart';
import '../servicios/auth_servicio.dart';

class AuthControlador extends ChangeNotifier {
  final AuthServicio _authServicio = AuthServicio();
  
  bool _cargando = false;
  String? _error;
  
  bool get cargando => _cargando;
  String? get error => _error;
  
  /// Login
  Future<bool> login(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authServicio.login(email, password);
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
  
  /// Registrar
  Future<bool> registrar(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authServicio.registrar(email, password);
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
  
  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    await _authServicio.cerrarSesion();
  }
  
  /// Recuperar password
  Future<bool> recuperarPassword(String email) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authServicio.recuperarPassword(email);
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
  
  /// Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}