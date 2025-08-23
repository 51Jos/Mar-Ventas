// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/venta_modelo.dart';
class VentasServicio {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Referencias a colecciones
  CollectionReference get _ventas => _db.collection('ventas');

  /// Registrar venta
Future<String> registrarVenta(VentaModelo venta) async {
  try {
    return await _db.runTransaction<String>((transaction) async {
      // 1. Obtener snapshots de todos los documentos a leer (lecturas primero)
      final productoSnapshots = <DocumentSnapshot>[];
      for (var item in venta.items) {
        final productoDoc = _db.collection('productos').doc(item.productoId);
        final snapshot = await transaction.get(productoDoc);
        if (!snapshot.exists) {
          throw Exception('Producto ${item.productoNombre} no encontrado');
        }
        productoSnapshots.add(snapshot);
      }

      DocumentSnapshot? clienteSnapshot;
      if (venta.tipoPago == 'credito' && venta.clienteId != null) {
        final clienteDoc = _db.collection('clientes').doc(venta.clienteId);
        clienteSnapshot = await transaction.get(clienteDoc);
        if (!clienteSnapshot.exists) {
          throw Exception('Cliente no encontrado');
        }
      }

      // 2. Realizar escrituras basadas en los snapshots
      for (var i = 0; i < venta.items.length; i++) {
        final item = venta.items[i];
        final snapshot = productoSnapshots[i];
        final stockActual = (snapshot.data() as Map<String, dynamic>)['stock'] ?? 0.0;
        final nuevoStock = stockActual - item.cantidad;

        if (nuevoStock < 0) {
          throw Exception('Stock insuficiente para ${item.productoNombre}');
        }

        final productoDoc = _db.collection('productos').doc(item.productoId);
        transaction.update(productoDoc, {
          'stock': nuevoStock,
          'fechaActualizacion': DateTime.now().toIso8601String(),
        });
      }

      if (venta.tipoPago == 'credito' && venta.clienteId != null && clienteSnapshot != null) {
        final deudaActual = (clienteSnapshot.data() as Map<String, dynamic>)['deudaTotal'] ?? 0.0;
        final clienteDoc = _db.collection('clientes').doc(venta.clienteId);
        transaction.update(clienteDoc, {
          'deudaTotal': deudaActual + venta.saldo,
        });
      }

      // 3. Registrar la venta
      final ventaRef = _ventas.doc();
      transaction.set(ventaRef, venta.toMap());

      return ventaRef.id;
    });
  } catch (e) {
    throw Exception('Error al registrar venta: $e');
  }
}
  /// Obtener ventas del día
  Stream<List<VentaModelo>> obtenerVentasDelDia([DateTime? fecha]) {
    final dia = fecha ?? DateTime.now();
    final inicio = DateTime(dia.year, dia.month, dia.day);
    final fin = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    
    return _ventas
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .where('estado', isEqualTo: 'activa')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VentaModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Obtener todas las ventas
  Stream<List<VentaModelo>> obtenerVentas() {
    return _ventas
        .orderBy('fecha', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VentaModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Obtener ventas por cliente
  Stream<List<VentaModelo>> obtenerVentasCliente(String clienteId) {
    return _ventas
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VentaModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Anular venta
  Future<void> anularVenta(String ventaId) async {
    try {
      final ventaDoc = await _ventas.doc(ventaId).get();
      if (!ventaDoc.exists) {
        throw Exception('Venta no encontrada');
      }
      
      final venta = VentaModelo.fromMap(
        ventaDoc.data() as Map<String, dynamic>,
        ventaDoc.id,
      );
      
      await _db.runTransaction((transaction) async {
        // 1. Devolver stock de productos
        for (var item in venta.items) {
          final productoDoc = _db.collection('productos').doc(item.productoId);
          final productoSnapshot = await transaction.get(productoDoc);
          
          if (productoSnapshot.exists) {
            final stockActual = (productoSnapshot.data() as Map<String, dynamic>)['stock'] ?? 0.0;
            transaction.update(productoDoc, {
              'stock': stockActual + item.cantidad,
              'fechaActualizacion': DateTime.now().toIso8601String(),
            });
          }
        }
        
        // 2. Si era crédito, reducir deuda del cliente
        if (venta.tipoPago == 'credito' && venta.clienteId != null) {
          final clienteDoc = _db.collection('clientes').doc(venta.clienteId);
          final clienteSnapshot = await transaction.get(clienteDoc);
          
          if (clienteSnapshot.exists) {
            final deudaActual = (clienteSnapshot.data() as Map<String, dynamic>)['deudaTotal'] ?? 0.0;
            transaction.update(clienteDoc, {
              'deudaTotal': (deudaActual - venta.saldo) > 0 ? (deudaActual - venta.saldo) : 0,
            });
          }
        }
        
        // 3. Marcar venta como anulada
        transaction.update(_ventas.doc(ventaId), {
          'estado': 'anulada',
        });
      });
    } catch (e) {
      throw Exception('Error al anular venta: $e');
    }
  }

  /// Obtener venta por ID
  Future<VentaModelo?> obtenerVentaPorId(String id) async {
    final doc = await _ventas.doc(id).get();
    if (!doc.exists) return null;
    return VentaModelo.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }
}