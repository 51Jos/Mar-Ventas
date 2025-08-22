import 'package:flutter/material.dart';
import '../tema/colores_app.dart';
import '../../rutas/rutas_app.dart';

class LayoutPrincipal extends StatefulWidget {
  final Widget child;
  final String titulo;
  final int indiceActual;
  final bool mostrarMenuInferior;
  final List<Widget>? acciones;

  const LayoutPrincipal({
    super.key,
    required this.child,
    required this.titulo,
    this.indiceActual = 0,
    this.mostrarMenuInferior = true,
    this.acciones,
  });

  @override
  State<LayoutPrincipal> createState() => _LayoutPrincipalState();
}

class _LayoutPrincipalState extends State<LayoutPrincipal> {
  void _onItemTapped(int index) {
    String ruta;
    switch (index) {
      case 0:
        ruta = RutasApp.productos;
        break;
      case 1:
        ruta = RutasApp.ventas;
        break;
      case 2:
        ruta = RutasApp.clientes;
        break;
      case 3:
        ruta = RutasApp.reportes;
        break;
      case 4:
        ruta = RutasApp.perfil;
        break;
      default:
        ruta = RutasApp.productos;
    }
    
    if (ModalRoute.of(context)?.settings.name != ruta) {
      RutasApp.reemplazar(context, ruta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        actions: widget.acciones,
      ),
      body: widget.child,
      bottomNavigationBar: widget.mostrarMenuInferior
          ? BottomNavigationBar(
              currentIndex: widget.indiceActual,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColores.primario,
              unselectedItemColor: AppColores.gris,
              items: const [                
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory),
                  label: 'Productos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Ventas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Clientes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Reportes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            )
          : null,
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    // Botón flotante según la pantalla
    switch (widget.indiceActual) {
      case 0: // Productos
        return FloatingActionButton(
          onPressed: () => RutasApp.ir(context, RutasApp.agregarProducto),
          tooltip: 'Agregar Producto',
          child: const Icon(Icons.add),
        );
      case 1: // Ventas
        return FloatingActionButton(
          onPressed: () => RutasApp.ir(context, RutasApp.nuevaVenta),
          tooltip: 'Nueva Venta',
          child: const Icon(Icons.add_shopping_cart),
        );
      case 2: // Clientes
        return FloatingActionButton(
          onPressed: () => RutasApp.ir(context, RutasApp.agregarCliente),
          tooltip: 'Agregar Cliente',
          child: const Icon(Icons.person_add),
        );
      default:
        return null;
    }
  }
}