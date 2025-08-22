import 'package:flutter/material.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../../../rutas/rutas_app.dart';
import '../controladores/auth_controlador.dart';

class LoginVista extends StatefulWidget {
  const LoginVista({super.key});

  @override
  State<LoginVista> createState() => _LoginVistaState();
}

class _LoginVistaState extends State<LoginVista> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authControlador = AuthControlador();
  
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final exito = await _authControlador.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (exito) {
        // ignore: use_build_context_synchronously
        RutasApp.limpiarEIr(context, RutasApp.home);
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(context, _authControlador.error ?? 'Error al iniciar sesión');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Dimensiones.paddingTodo,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Icon(
                      Icons.store,
                      size: 80,
                      color: AppColores.primario,
                    ),
                    Dimensiones.esp16,
                    
                    // Título
                    const Text(
                      'Pescadería',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColores.primario,
                      ),
                    ),
                    Dimensiones.esp8,
                    
                    const Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColores.textoSecundario,
                      ),
                    ),
                    Dimensiones.esp32,
                    
                    // Campo Email
                    CampoTextoPersonalizado(
                      etiqueta: 'Email',
                      placeholder: 'correo@ejemplo.com',
                      controller: _emailController,
                      validador: Validadores.email,
                      tipoTeclado: TextInputType.emailAddress,
                      icono: Icons.email_outlined,
                    ),
                    Dimensiones.esp16,
                    
                    // Campo Password
                    CampoTextoPersonalizado(
                      etiqueta: 'Contraseña',
                      placeholder: '••••••',
                      controller: _passwordController,
                      validador: Validadores.password,
                      obscureText: !_mostrarPassword,
                      icono: Icons.lock_outline,
                      sufijo: IconButton(
                        icon: Icon(
                          _mostrarPassword 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarPassword = !_mostrarPassword;
                          });
                        },
                      ),
                    ),
                    Dimensiones.esp8,
                    
                    // Olvidé mi contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          RutasApp.ir(context, '${RutasApp.login}/recuperar');
                        },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    Dimensiones.esp24,
                    
                    // Botón Login
                    AnimatedBuilder(
                      animation: _authControlador,
                      builder: (context, child) {
                        return BotonPersonalizado(
                          texto: 'Iniciar Sesión',
                          onPressed: _login,
                          cargando: _authControlador.cargando,
                          icono: Icons.login,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}