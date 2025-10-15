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

  /// Obtener cliente por ID en tiempo real (Stream)
  Stream<ClienteModelo?> obtenerClienteStream(String id) {
    return _clientes.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ClienteModelo.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    });
  }

  // ==================== ABONOS ====================
  
  /// Registrar abono y actualizar deuda
  Future<void> registrarAbono(AbonoModelo abono) async {
    // ignore: avoid_print
    print('💰 Registrando abono para cliente: ${abono.clienteId}');
    // ignore: avoid_print
    print('💵 Monto del abono: ${abono.monto}');

    await _db.runTransaction((transaction) async {
      // Obtener cliente actual
      final clienteDoc = await transaction.get(_clientes.doc(abono.clienteId));

      if (!clienteDoc.exists) {
        throw Exception('Cliente no encontrado');
      }

      final clienteData = clienteDoc.data() as Map<String, dynamic>;
      final deudaActual = (clienteData['deudaTotal'] ?? 0.0).toDouble();
      final nuevaDeuda = deudaActual - abono.monto;

      // ignore: avoid_print
      print('💳 Deuda actual: $deudaActual');
      // ignore: avoid_print
      print('➖ Nueva deuda: $nuevaDeuda');

      // Actualizar deuda del cliente
      transaction.update(_clientes.doc(abono.clienteId), {
        'deudaTotal': nuevaDeuda > 0 ? nuevaDeuda : 0.0,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });

      // Registrar abono
      transaction.set(_abonos.doc(), abono.toMap());

      // ignore: avoid_print
      print('✅ Abono registrado y deuda actualizada exitosamente');
    });
  }

  /// Obtener abonos de un cliente
  Stream<List<AbonoModelo>> obtenerAbonosCliente(String clienteId) {
    return _abonos
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .map((snapshot) {
      final abonos = snapshot.docs.map((doc) {
        return AbonoModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Ordenar en memoria por fecha descendente
      abonos.sort((a, b) => b.fecha.compareTo(a.fecha));

      return abonos;
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