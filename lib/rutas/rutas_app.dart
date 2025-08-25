import 'package:flutter/material.dart';
import 'package:marventas/features/autenticacion/vistas/recuperar_password_vista.dart';
import 'package:marventas/features/clientes/modelos/cliente_modelo.dart';
import 'package:marventas/features/clientes/vistas/cliente_agregar_vista.dart';
import 'package:marventas/features/clientes/vistas/cliente_editar_vista.dart';
import 'package:marventas/features/clientes/vistas/clientes_lista_vista.dart';
import 'package:marventas/features/clientes/vistas/estado_cuenta_vista.dart';
import 'package:marventas/features/clientes/vistas/registrar_abono_vista.dart';
import 'package:marventas/features/productos/vistas/historial_compra_vista.dart';
import 'package:marventas/features/productos/vistas/producto_agregar_vista.dart';
import 'package:marventas/features/productos/vistas/producto_editar_vista.dart';
import 'package:marventas/features/productos/vistas/productos_lista_vista.dart';
import 'package:marventas/features/productos/vistas/registrar_compra_vista.dart';
import 'package:marventas/features/reportes/vistas/reporte_deudas_vista.dart';
import 'package:marventas/features/reportes/vistas/reporte_venta_vistas.dart';
import 'package:marventas/features/reportes/vistas/reportes_dashboard_vista.dart';
import 'package:marventas/features/ventas/modelos/venta_modelo.dart';
import 'package:marventas/features/ventas/vistas/detalle_venta_vista.dart';
import 'package:marventas/features/ventas/vistas/historial_ventas_vista.dart';
import 'package:marventas/features/ventas/vistas/nueva_venta_vista.dart';
import 'package:marventas/features/ventas/vistas/ventas_dia_vista.dart';
// Importar las vistas cuando las crees
import '../features/autenticacion/vistas/login_vista.dart';
// import '../features/productos/vistas/productos_lista_vista.dart';
// import '../features/ventas/vistas/nueva_venta_vista.dart';
// import '../features/clientes/vistas/clientes_lista_vista.dart';
// import '../features/reportes/vistas/reportes_dashboard_vista.dart';

class RutasApp {
  // ==================== NOMBRES DE RUTAS ====================
  static const String login = '/login';
  static const String home = '/home';
  static const String productos = '/productos';
  static const String ventas = '/ventas';
  static const String clientes = '/clientes';
  static const String reportes = '/reportes';
  static const String perfil = '/perfil';

  // Rutas secundarias
  static const String agregarProducto = '/productos/agregar';
  static const String editarProducto = '/productos/editar';
  static const String registrarCompra = '/productos/compra';
  static const String historialCompras = '/productos/historial';
  static const String nuevaVenta = '/ventas/nueva';
  static const String historialVentas = '/ventas/historial';
  static const String detalleVenta = '/ventas/detalle';
  static const String agregarCliente = '/clientes/agregar';
  static const String editarCliente = '/clientes/editar';
  static const String estadoCuenta = '/clientes/estado-cuenta';
  static const String registrarAbono = '/clientes/abono';
  static const String reportesVentas = '/reportes/ventas';
  static const String reportesInventario = '/reportes/inventario';
  static const String reportesDeudas = '/reportes/deudas';

  // ==================== GENERADOR DE RUTAS ====================
  static Route<dynamic> generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginVista());

      case '/login/recuperar':
        return MaterialPageRoute(
          builder: (_) => const RecuperarPasswordVista(),
        );

      // productos
      case home:
        return MaterialPageRoute(builder: (_) => const ProductosListaVista());

      case productos:
        return MaterialPageRoute(builder: (_) => const ProductosListaVista());

      case agregarProducto:
        return MaterialPageRoute(builder: (_) => const ProductoAgregarVista());

      case editarProducto:
        final producto = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ProductoEditarVista(producto: producto as dynamic),
        );

      case registrarCompra:
        final producto = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => RegistrarCompraVista(producto: producto as dynamic),
        );

      case historialCompras: // Reutilizamos esta ruta para historial de compras
        return MaterialPageRoute(builder: (_) => const HistorialComprasVista());

      //=======================Ventas=======================

       case ventas:
        return MaterialPageRoute(
          builder: (_) => const VentasDiaVista(),
        );
        
      case nuevaVenta:
        return MaterialPageRoute(
          builder: (_) => const NuevaVentaVista(),
        );
        
      case historialVentas:
        return MaterialPageRoute(
          builder: (_) => const HistorialVentasVista(),
        );

      case detalleVenta:
        final venta = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => DetalleVentaVista(venta: venta as VentaModelo),
        );

      //===================== Clientes =====================

      case clientes:
        return MaterialPageRoute(builder: (_) => const ClientesListaVista());

      case agregarCliente:
        return MaterialPageRoute(builder: (_) => const ClienteAgregarVista());

      case editarCliente:
        final cliente = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ClienteEditarVista(cliente: cliente as ClienteModelo),
        );

      case estadoCuenta:
        final cliente = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => EstadoCuentaVista(cliente: cliente as ClienteModelo),
        );

      case registrarAbono:
        final cliente = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => RegistrarAbonoVista(cliente: cliente as ClienteModelo),
        );

      // ==================== REPORTES ====================

      case reportes:
        return MaterialPageRoute(
          builder: (_) => const ReportesDashboardVista(),
        );

       case reportesVentas:
        return MaterialPageRoute(
          builder: (_) => const ReporteVentasVista(),
        );

        case reportesDeudas:
        return MaterialPageRoute(
          builder: (_) => const ReporteDeudasVista(),
        );

      // ==================== PERFIL ====================

      case perfil:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Perfil - Por implementar')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
    }
  }

  // ==================== NAVEGACIÓN HELPER ====================
  static Future<T?> ir<T>(BuildContext context, String ruta, {Object? args}) {
    return Navigator.pushNamed<T>(context, ruta, arguments: args);
  }

  static Future<T?> reemplazar<T>(
    BuildContext context,
    String ruta, {
    Object? args,
  }) {
    return Navigator.pushReplacementNamed<T, T>(context, ruta, arguments: args);
  }

  static Future<T?> limpiarEIr<T>(
    BuildContext context,
    String ruta, {
    Object? args,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      ruta,
      (route) => false,
      arguments: args,
    );
  }

  static void volver<T>(BuildContext context, [T? resultado]) {
    Navigator.pop(context, resultado);
  }
}
