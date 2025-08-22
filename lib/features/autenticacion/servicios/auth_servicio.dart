// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';

class AuthServicio {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Login con email y password
  Future<User?> login(String email, String password) async {
    try {
      final resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return resultado.user;
    } catch (e) {
      throw _manejarError(e);
    }
  }
  
  /// Registrar nuevo usuario
  Future<User?> registrar(String email, String password) async {
    try {
      final resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return resultado.user;
    } catch (e) {
      throw _manejarError(e);
    }
  }
  
  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
  
  /// Recuperar contraseña
  Future<void> recuperarPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _manejarError(e);
    }
  }
  
  /// Usuario actual
  User? get usuarioActual => _auth.currentUser;
  
  /// Stream de autenticación
  Stream<User?> get estadoAuth => _auth.authStateChanges();
  
  /// Manejar errores de Firebase
  String _manejarError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Usuario no encontrado';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Este email ya está registrado';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'invalid-email':
          return 'Email inválido';
        case 'user-disabled':
          return 'Usuario deshabilitado';
        default:
          return 'Error: ${error.message}';
      }
    }
    return 'Error desconocido';
  }
}