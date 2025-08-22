import 'package:flutter/material.dart';
import '../tema/colores_app.dart';
import '../../rutas/rutas_app.dart';
import '../../nucleo/configuracion_firebase.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = ConfigFirebase.usuario;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Cabecera del drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColores.primario,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.store,
                    size: 35,
                    color: AppColores.primario,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pescadería',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  usuario?.email ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Opciones del menú
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              RutasApp.reemplazar(context, RutasApp.home);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Productos'),
            onTap: () {
              Navigator.pop(context);
              RutasApp.reemplazar(context, RutasApp.productos);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Ventas'),
            onTap: () {
              Navigator.pop(context);
              RutasApp.reemplazar(context, RutasApp.ventas);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              RutasApp.reemplazar(context, RutasApp.clientes);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.pop(context);
              RutasApp.reemplazar(context, RutasApp.reportes);
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              RutasApp.ir(context, RutasApp.perfil);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.logout, color: AppColores.error),
            title: const Text('Cerrar Sesión'),
            textColor: AppColores.error,
            onTap: () async {
              Navigator.pop(context);
              await ConfigFirebase.cerrarSesion();
              // ignore: use_build_context_synchronously
              RutasApp.limpiarEIr(context, RutasApp.login);
            },
          ),
        ],
      ),
    );
  }
}