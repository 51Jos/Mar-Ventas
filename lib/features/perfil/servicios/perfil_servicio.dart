/// Servicio para manejar el perfil del usuario

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/usuario_modelo.dart';

class PerfilServicio {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  CollectionReference get _usuarios => _db.collection('usuarios');
  
  /// Obtener usuario actual
  User? get usuarioAuth => _auth.currentUser;
  
  /// Obtener datos del perfil
  Future<UsuarioModelo?> obtenerPerfil() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final doc = await _usuarios.doc(user.uid).get();
      
      if (!doc.exists) {
        // Si no existe, crear perfil básico
        final nuevoPerfil = UsuarioModelo(
          id: user.uid,
          email: user.email ?? '',
          nombre: user.displayName ?? 'Usuario',
          telefono: user.phoneNumber,
          fechaRegistro: DateTime.now(),
          rol: 'admin',
        );
        
        await _usuarios.doc(user.uid).set(nuevoPerfil.toMap());
        return nuevoPerfil;
      }
      
      return UsuarioModelo.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }
  
  /// Actualizar perfil
  Future<void> actualizarPerfil(UsuarioModelo usuario) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');
      
      await _usuarios.doc(user.uid).update(usuario.toMap());
      
      // Actualizar displayName en Auth si cambió el nombre
      if (user.displayName != usuario.nombre) {
        await user.updateDisplayName(usuario.nombre);
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }
  
  /// Cambiar contraseña
  Future<void> cambiarPassword(String passwordActual, String passwordNuevo) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');
      
      // Re-autenticar antes de cambiar password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordActual,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(passwordNuevo);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Contraseña actual incorrecta');
      } else if (e.code == 'weak-password') {
        throw Exception('La nueva contraseña es muy débil');
      } else {
        throw Exception('Error al cambiar contraseña: ${e.message}');
      }
    }
  }
  
  /// Obtener estadísticas del usuario
  Future<EstadisticasUsuario> obtenerEstadisticas() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No hay sesión activa');
      
      final hoy = DateTime.now();
      final inicioMes = DateTime(hoy.year, hoy.month, 1);
      
      // Ventas del mes
      final ventasSnapshot = await _db.collection('ventas')
          .where('fecha', isGreaterThanOrEqualTo: inicioMes.toIso8601String())
          .where('estado', isEqualTo: 'activa')
          .get();
      
      final ventasMes = ventasSnapshot.docs.length;
      final totalVentasMes = ventasSnapshot.docs.fold<double>(
        0,
        (sum, doc) => sum + (doc.data()['total'] ?? 0).toDouble(),
      );
      
      // Clientes activos
      final clientesSnapshot = await _db.collection('clientes')
          .where('activo', isEqualTo: true)
          .get();
      
      final totalClientes = clientesSnapshot.docs.length;
      
      // Productos activos
      final productosSnapshot = await _db.collection('productos')
          .where('activo', isEqualTo: true)
          .get();
      
      final totalProductos = productosSnapshot.docs.length;
      
      return EstadisticasUsuario(
        ventasMes: ventasMes,
        totalVentasMes: totalVentasMes,
        clientesActivos: totalClientes,
        productosActivos: totalProductos,
      );
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
  
  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}

/// Modelo de estadísticas
class EstadisticasUsuario {
  final int ventasMes;
  final double totalVentasMes;
  final int clientesActivos;
  final int productosActivos;
  
  EstadisticasUsuario({
    required this.ventasMes,
    required this.totalVentasMes,
    required this.clientesActivos,
    required this.productosActivos,
  });
}