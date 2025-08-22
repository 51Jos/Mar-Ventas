// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marventas/firebase_options.dart';

class ConfigFirebase {
  // Instancias de Firebase
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  
  /// Inicializar Firebase (llamar en main.dart)
  static Future<void> inicializar() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Usa el archivo generado
    );
    
    // Habilitar persistencia offline
    db.settings = const Settings(
      persistenceEnabled: true,
    );
  }
  
  /// Usuario actual
  static User? get usuario => auth.currentUser;
  static String? get usuarioId => auth.currentUser?.uid;
  static Stream<User?> get authStream => auth.authStateChanges();
  
  /// Cerrar sesión
  static Future<void> cerrarSesion() async {
    await auth.signOut();
  }
}