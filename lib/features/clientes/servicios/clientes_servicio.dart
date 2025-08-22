// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/cliente_modelo.dart';
import '../modelos/abono_modelo.dart';

class ClientesServicio {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Referencias a colecciones
  CollectionReference get _clientes => _db.collection('clientes');
  CollectionReference get _abonos => _db.collection('abonos');

  // ==================== CLIENTES ====================
  
  /// Obtener todos los clientes
  Stream<List<ClienteModelo>> obtenerClientes() {
    return _clientes
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClienteModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Obtener clientes con deuda
  Stream<List<ClienteModelo>> obtenerClientesConDeuda() {
    return _clientes
        .where('activo', isEqualTo: true)
        .where('deudaTotal', isGreaterThan: 0)
        .orderBy('deudaTotal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClienteModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Crear cliente
  Future<String> crearCliente(ClienteModelo cliente) async {
    final doc = await _clientes.add(cliente.toMap());
    return doc.id;
  }

  /// Actualizar cliente
  Future<void> actualizarCliente(ClienteModelo cliente) async {
    if (cliente.id == null) throw Exception('ID del cliente requerido');
    await _clientes.doc(cliente.id).update(cliente.toMap());
  }

  /// Eliminar cliente (soft delete)
  Future<void> eliminarCliente(String id) async {
    await _clientes.doc(id).update({'activo': false});
  }

  /// Obtener cliente por ID
  Future<ClienteModelo?> obtenerClientePorId(String id) async {
    final doc = await _clientes.doc(id).get();
    if (!doc.exists) return null;
    return ClienteModelo.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  // ==================== ABONOS ====================
  
  /// Registrar abono y actualizar deuda
  Future<void> registrarAbono(AbonoModelo abono) async {
    await _db.runTransaction((transaction) async {
      // Obtener cliente actual
      final clienteDoc = await transaction.get(_clientes.doc(abono.clienteId));
      
      if (!clienteDoc.exists) {
        throw Exception('Cliente no encontrado');
      }
      
      final deudaActual = (clienteDoc.data() as Map<String, dynamic>)['deudaTotal'] ?? 0.0;
      final nuevaDeuda = deudaActual - abono.monto;
      
      // Actualizar deuda del cliente
      transaction.update(_clientes.doc(abono.clienteId), {
        'deudaTotal': nuevaDeuda > 0 ? nuevaDeuda : 0,
      });
      
      // Registrar abono
      transaction.set(_abonos.doc(), abono.toMap());
    });
  }

  /// Obtener abonos de un cliente
  Stream<List<AbonoModelo>> obtenerAbonosCliente(String clienteId) {
    return _abonos
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AbonoModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Obtener todos los abonos
  Stream<List<AbonoModelo>> obtenerAbonos() {
    return _abonos
        .orderBy('fecha', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AbonoModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Actualizar deuda del cliente (usado desde ventas)
  Future<void> actualizarDeuda(String clienteId, double montoAgregar) async {
    final clienteDoc = await _clientes.doc(clienteId).get();
    if (!clienteDoc.exists) return;
    
    final deudaActual = (clienteDoc.data() as Map<String, dynamic>)['deudaTotal'] ?? 0.0;
    await _clientes.doc(clienteId).update({
      'deudaTotal': deudaActual + montoAgregar,
    });
  }
}