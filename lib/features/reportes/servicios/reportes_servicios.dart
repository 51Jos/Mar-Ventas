// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../ventas/modelos/venta_modelo.dart';
import '../../productos/modelos/producto_modelo.dart';
import '../../clientes/modelos/cliente_modelo.dart';

class ReportesServicio {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtener resumen del día
  Future<ResumenDia> obtenerResumenDelDia() async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);
    
    // Obtener ventas del día
    final ventasSnapshot = await _db.collection('ventas')
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .where('estado', isEqualTo: 'activa')
        .get();
    
    final ventas = ventasSnapshot.docs.map((doc) => 
      VentaModelo.fromMap(doc.data(), doc.id)
    ).toList();
    
    // Calcular totales
    // ignore: avoid_types_as_parameter_names
    final totalVentas = ventas.fold<double>(0, (sum, v) => sum + v.total);
    final ventasContado = ventas.where((v) => v.tipoPago == 'contado').toList();
    final ventasCredito = ventas.where((v) => v.tipoPago == 'credito').toList();
    
    return ResumenDia(
      fecha: hoy,
      totalVentas: totalVentas,
      cantidadVentas: ventas.length,
      // ignore: avoid_types_as_parameter_names
      totalContado: ventasContado.fold<double>(0, (sum, v) => sum + v.total),
      cantidadContado: ventasContado.length,
      // ignore: avoid_types_as_parameter_names
      totalCredito: ventasCredito.fold<double>(0, (sum, v) => sum + v.total),
      cantidadCredito: ventasCredito.length,
    );
  }

  /// Obtener ventas por rango de fechas
  Future<List<VentaModelo>> obtenerVentasPorRango(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final snapshot = await _db.collection('ventas')
        .where('fecha', isGreaterThanOrEqualTo: fechaInicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fechaFin.toIso8601String())
        .where('estado', isEqualTo: 'activa')
        .orderBy('fecha', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => 
      VentaModelo.fromMap(doc.data(), doc.id)
    ).toList();
  }

  /// Obtener productos con stock bajo
  Stream<List<ProductoModelo>> obtenerProductosStockBajo({double limite = 5.0}) {
    return _db.collection('productos')
        .where('activo', isEqualTo: true)
        .where('stock', isLessThanOrEqualTo: limite)
        .orderBy('stock')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => 
        ProductoModelo.fromMap(doc.data(), doc.id)
      ).toList();
    });
  }

  /// Obtener resumen de deudas
  Future<ResumenDeudas> obtenerResumenDeudas() async {
    final clientesSnapshot = await _db.collection('clientes')
        .where('activo', isEqualTo: true)
        .where('deudaTotal', isGreaterThan: 0)
        .get();
    
    final clientes = clientesSnapshot.docs.map((doc) => 
      ClienteModelo.fromMap(doc.data(), doc.id)
    ).toList();
    
    // ignore: avoid_types_as_parameter_names
    final totalDeudas = clientes.fold<double>(0, (sum, c) => sum + c.deudaTotal);
    
    // Ordenar por deuda
    clientes.sort((a, b) => b.deudaTotal.compareTo(a.deudaTotal));
    
    return ResumenDeudas(
      totalDeudas: totalDeudas,
      cantidadDeudores: clientes.length,
      deudores: clientes.take(10).toList(), // Top 10 deudores
    );
  }

  /// Obtener valor del inventario
  Future<ResumenInventario> obtenerResumenInventario() async {
    final productosSnapshot = await _db.collection('productos')
        .where('activo', isEqualTo: true)
        .get();
    
    final productos = productosSnapshot.docs.map((doc) => 
      ProductoModelo.fromMap(doc.data(), doc.id)
    ).toList();
    
    double valorTotal = 0;
    double cantidadTotal = 0;
    
    for (var producto in productos) {
      final valorProducto = producto.stock * (producto.precioCompra ?? producto.precioPublico);
      valorTotal += valorProducto;
      cantidadTotal += producto.stock;
    }
    
    return ResumenInventario(
      valorTotal: valorTotal,
      cantidadProductos: productos.length,
      kilosTotales: cantidadTotal,
      productos: productos,
    );
  }

  /// Obtener productos más vendidos
  Future<List<ProductoVendido>> obtenerProductosMasVendidos({int dias = 30}) async {
    final fechaInicio = DateTime.now().subtract(Duration(days: dias));
    
    final ventasSnapshot = await _db.collection('ventas')
        .where('fecha', isGreaterThanOrEqualTo: fechaInicio.toIso8601String())
        .where('estado', isEqualTo: 'activa')
        .get();
    
    final ventas = ventasSnapshot.docs.map((doc) => 
      VentaModelo.fromMap(doc.data(), doc.id)
    ).toList();
    
    // Agrupar por producto
    Map<String, ProductoVendido> productosMap = {};
    
    for (var venta in ventas) {
      for (var item in venta.items) {
        if (productosMap.containsKey(item.productoId)) {
          productosMap[item.productoId]!.cantidad += item.cantidad;
          productosMap[item.productoId]!.total += item.total;
          productosMap[item.productoId]!.veces += 1;
        } else {
          productosMap[item.productoId] = ProductoVendido(
            productoId: item.productoId,
            productoNombre: item.productoNombre,
            cantidad: item.cantidad,
            total: item.total,
            veces: 1,
          );
        }
      }
    }
    
    // Ordenar por cantidad vendida
    final productosList = productosMap.values.toList();
    productosList.sort((a, b) => b.cantidad.compareTo(a.cantidad));
    
    return productosList.take(10).toList(); // Top 10
  }
}

/// Modelos para reportes
class ResumenDia {
  final DateTime fecha;
  final double totalVentas;
  final int cantidadVentas;
  final double totalContado;
  final int cantidadContado;
  final double totalCredito;
  final int cantidadCredito;

  ResumenDia({
    required this.fecha,
    required this.totalVentas,
    required this.cantidadVentas,
    required this.totalContado,
    required this.cantidadContado,
    required this.totalCredito,
    required this.cantidadCredito,
  });
}

class ResumenDeudas {
  final double totalDeudas;
  final int cantidadDeudores;
  final List<ClienteModelo> deudores;

  ResumenDeudas({
    required this.totalDeudas,
    required this.cantidadDeudores,
    required this.deudores,
  });
}

class ResumenInventario {
  final double valorTotal;
  final int cantidadProductos;
  final double kilosTotales;
  final List<ProductoModelo> productos;

  ResumenInventario({
    required this.valorTotal,
    required this.cantidadProductos,
    required this.kilosTotales,
    required this.productos,
  });
}

class ProductoVendido {
  final String productoId;
  final String productoNombre;
  double cantidad;
  double total;
  int veces;

  ProductoVendido({
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.total,
    required this.veces,
  });
}