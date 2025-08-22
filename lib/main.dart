import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marventas/rutas/controlador_rutas.dart';
import 'nucleo/configuracion_firebase.dart';
import 'compartido/tema/tema_app.dart';
import 'rutas/rutas_app.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Orientación solo vertical (opcional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar Firebase
  await ConfigFirebase.inicializar();
  
  // Ejecutar app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pescadería',
      debugShowCheckedModeBanner: false,
      
      // Tema
      theme: TemaApp.tema,
      
      // Rutas
      onGenerateRoute: RutasApp.generarRuta,
      
      // Pantalla inicial según autenticación
      home: const PantallaInicial(),
    );
  }
}

/// Widget que decide qué pantalla mostrar
class PantallaInicial extends StatelessWidget {
  const PantallaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: GuardiasRuta.estadoAuth,
      builder: (context, snapshot) {
        // Mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PantallaCargando();
        }
        
        // Si está autenticado
        if (snapshot.data == true) {
          // Ir al home después del build
          Future.microtask(() {
            // ignore: use_build_context_synchronously
            RutasApp.limpiarEIr(context, RutasApp.home);
          });
          return const PantallaCargando();
        }
        
        // Si no está autenticado
        Future.microtask(() {
          // ignore: use_build_context_synchronously
          RutasApp.limpiarEIr(context, RutasApp.login);
        });
        return const PantallaCargando();
      },
    );
  }
}

/// Pantalla de carga simple
class PantallaCargando extends StatelessWidget {
  const PantallaCargando({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o ícono
            Icon(
              Icons.store,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            
            // Nombre de la app
            Text(
              'Pescadería',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // Indicador de carga
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}