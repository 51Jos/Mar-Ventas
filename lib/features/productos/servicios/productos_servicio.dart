// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/producto_modelo.dart';
import '../modelos/compra_modelo.dart';

class ProductosServicio {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Referencias a colecciones
  CollectionReference get _productos => _db.collection('productos');
  CollectionReference get _compras => _db.collection('compras');

  // ==================== PRODUCTOS ====================
  
  /// Obtener todos los productos
  Stream<List<ProductoModelo>> obtenerProductos() {
    return _productos
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductoModelo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Crear producto
  Future<void> crearProducto(ProductoModelo producto) async {
    await _productos.add(producto.toMap());
  }

  /// Actualizar producto
  Future<void> actualizarProducto(ProductoModelo producto) async {
    if (producto.id == null) throw Exception('ID del producto requerido');
    await _productos.doc(producto.id).update(producto.toMap());
  }

  /// Eliminar producto (soft delete)
  Future<void> eliminarProducto(String id) async {
    await _productos.doc(id).update({'activo': false});
  }

  /// Actualizar stock
  Future<void> actualizarStock(String productoId, double nuevoStock) async {
    await _productos.doc(productoId).update({
      'stock': nuevoStock,
      'fechaActualizacion': DateTime.now().toIso8601String(),
    });
  }

  // ==================== COMPRAS ====================
  
  /// Registrar compra y actualizar stock
  Future<void> registrarCompra(CompraModelo compra) async {
    // Usar transacción para actualizar stock y registrar compra
    await _db.runTransaction((transaction) async {
      // Obtener producto actual
      final productoDoc = await transaction.get(_productos.doc(compra.productoId));
      
      if (!productoDoc.exists) {
        throw Exception('Producto no encontrado');
      }
      
      final stockActual = (productoDoc.data() as Map<String, dynamic>)['stock'] ?? 0.0;
      final nuevoStock = stockActual + compra.kilos;
      
      // Actualizar stock y precio de compra
      transaction.update(_productos.doc(compra.productoId), {
        'stock': nuevoStock,
        'precioCompra': compra.precioKilo,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });
      
      // Registrar compra
      transaction.set(_compras.doc(), compra.toMap());
    });
  }

  /// Obtener historial de compras
  Stream<List<CompraModelo>> obtenerCompras({String? productoId}) {
    Query query = _compras;

    if (productoId != null) {
      // ignore: avoid_print
      print('🔍 Buscando compras para productoId: $productoId');
      query = query.where('productoId', isEqualTo: productoId);
    }

    return query
        .snapshots()
        .map((snapshot) {
      // ignore: avoid_print
      print('📊 Documentos encontrados: ${snapshot.docs.length}');

      final compras = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // ignore: avoid_print
        print('📄 Doc ID: ${doc.id}, productoId: ${data['productoId']}, producto: ${data['productoNombre']}');
        return CompraModelo.fromMap(data, doc.id);
      }).toList();

      // Ordenar en memoria por fecha descendente
      compras.sort((a, b) => b.fecha.compareTo(a.fecha));

      // Limitar a 50 más recientes
      return compras.take(50).toList();
    });
  }

  /// Buscar productos
  Future<List<ProductoModelo>> buscarProductos(String termino) async {
    final terminoLower = termino.toLowerCase();
    final snapshot = await _productos
        .where('activo', isEqualTo: true)
        .get();
    
    return snapshot.docs
        .map((doc) => ProductoModelo.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .where((producto) => 
            producto.nombre.toLowerCase().contains(terminoLower))
        .toList();
  }
}