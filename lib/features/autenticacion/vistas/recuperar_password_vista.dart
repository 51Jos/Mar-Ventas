import 'package:flutter/material.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../controladores/auth_controlador.dart';

class RecuperarPasswordVista extends StatefulWidget {
  const RecuperarPasswordVista({super.key});

  @override
  State<RecuperarPasswordVista> createState() => _RecuperarPasswordVistaState();
}

class _RecuperarPasswordVistaState extends State<RecuperarPasswordVista> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authControlador = AuthControlador();
  bool _enviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _recuperar() async {
    if (_formKey.currentState!.validate()) {
      final exito = await _authControlador.recuperarPassword(
        _emailController.text.trim(),
      );
      
      if (exito) {
        setState(() {
          _enviado = true;
        });
        SnackBarExito.mostrar(
          // ignore: use_build_context_synchronously
          context, 
          'Correo enviado. Revisa tu bandeja de entrada',
        );
      } else {
        SnackBarExito.error(
          // ignore: use_build_context_synchronously
          context, 
          _authControlador.error ?? 'Error al enviar correo',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColores.primario),
      ),
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
                    // Ícono
                    Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: AppColores.primario,
                    ),
                    Dimensiones.esp24,
                    
                    // Título
                    const Text(
                      'Recuperar Contraseña',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColores.texto,
                      ),
                    ),
                    Dimensiones.esp16,
                    
                    // Descripción
                    Text(
                      _enviado 
                          ? 'Te hemos enviado un correo con las instrucciones para restablecer tu contraseña.'
                          : 'Ingresa tu email y te enviaremos instrucciones para restablecer tu contraseña.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColores.textoSecundario,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Dimensiones.esp32,
                    
                    if (!_enviado) ...[
                      // Campo Email
                      CampoTextoPersonalizado(
                        etiqueta: 'Email',
                        placeholder: 'correo@ejemplo.com',
                        controller: _emailController,
                        validador: Validadores.email,
                        tipoTeclado: TextInputType.emailAddress,
                        icono: Icons.email_outlined,
                      ),
                      Dimensiones.esp24,
                      
                      // Botón Enviar
                      AnimatedBuilder(
                        animation: _authControlador,
                        builder: (context, child) {
                          return BotonPersonalizado(
                            texto: 'Enviar Instrucciones',
                            onPressed: _recuperar,
                            cargando: _authControlador.cargando,
                            icono: Icons.send,
                          );
                        },
                      ),
                    ] else ...[
                      // Mensaje de éxito
                      Container(
                        padding: Dimensiones.paddingTodo,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppColores.exito.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColores.exito),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColores.exito,
                            ),
                            Dimensiones.espacioH(12),
                            const Expanded(
                              child: Text(
                                'Correo enviado exitosamente',
                                style: TextStyle(color: AppColores.exito),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Dimensiones.esp24,
                      
                      // Botón volver al login
                      BotonPersonalizado(
                        texto: 'Volver al Login',
                        onPressed: () => Navigator.pop(context),
                        secundario: true,
                      ),
                    ],
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