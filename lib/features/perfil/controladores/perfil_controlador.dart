/// Controlador del perfil de usuario

import 'package:flutter/material.dart';
import '../modelos/usuario_modelo.dart';
import '../servicios/perfil_servicio.dart';

class PerfilControlador extends ChangeNotifier {
  final PerfilServicio _servicio = PerfilServicio();
  
  UsuarioModelo? _usuario;
  EstadisticasUsuario? _estadisticas;
  bool _cargando = false;
  String? _error;
  
  // Getters
  UsuarioModelo? get usuario => _usuario;
  EstadisticasUsuario? get estadisticas => _estadisticas;
  bool get cargando => _cargando;
  String? get error => _error;
  
  // Cargar perfil
  Future<void> cargarPerfil() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      _usuario = await _servicio.obtenerPerfil();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }
  
  // Cargar estadísticas
  Future<void> cargarEstadisticas() async {
    try {
      _estadisticas = await _servicio.obtenerEstadisticas();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Actualizar perfil
  Future<bool> actualizarPerfil({
    required String nombre,
    String? telefono,
    String? direccion,
  }) async {
    if (_usuario == null) return false;
    
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      final usuarioActualizado = _usuario!.copyWith(
        nombre: nombre,
        telefono: telefono,
        direccion: direccion,
      );
      
      await _servicio.actualizarPerfil(usuarioActualizado);
      _usuario = usuarioActualizado;
      
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
  
  // Cambiar contraseña
  Future<bool> cambiarPassword(String passwordActual, String passwordNuevo) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    
    try {
      await _servicio.cambiarPassword(passwordActual, passwordNuevo);
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
  
  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _servicio.cerrarSesion();
  }
  
  // Cargar todo
  Future<void> inicializar() async {
    await Future.wait([
      cargarPerfil(),
      cargarEstadisticas(),
    ]);
  }
  
}