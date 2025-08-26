import 'package:flutter/material.dart';
import 'package:marventas/compartido/layout/layout_principal.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../../compartido/componentes/widget_cargando.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/dialogo_confirmacion.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../../../compartido/utilidades/formateador_fecha.dart';
import '../../../rutas/rutas_app.dart';
import '../controladores/perfil_controlador.dart';

class PerfilVista extends StatefulWidget {
  const PerfilVista({super.key});

  @override
  State<PerfilVista> createState() => _PerfilVistaState();
}

class _PerfilVistaState extends State<PerfilVista> {
  bool _editando = false;
  bool _cambiandoPassword = false;

  // Controllers para edición
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  // Controllers para cambio de contraseña
  final _passwordActualController = TextEditingController();
  final _passwordNuevoController = TextEditingController();
  final _passwordConfirmarController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _passwordActualController.dispose();
    _passwordNuevoController.dispose();
    _passwordConfirmarController.dispose();
    super.dispose();
  }

  void _iniciarEdicion(PerfilControlador controlador) {
    final usuario = controlador.usuario;
    if (usuario != null) {
      _nombreController.text = usuario.nombre;
      _telefonoController.text = usuario.telefono ?? '';
      _direccionController.text = usuario.direccion ?? '';
      setState(() {
        _editando = true;
      });
    }
  }

  void _cancelarEdicion() {
    setState(() {
      _editando = false;
      _cambiandoPassword = false;
    });
    _passwordActualController.clear();
    _passwordNuevoController.clear();
    _passwordConfirmarController.clear();
  }

  Future<void> _guardarCambios(PerfilControlador controlador) async {
    if (_formKey.currentState!.validate()) {
      final exito = await controlador.actualizarPerfil(
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
      );

      if (exito) {
        // ignore: use_build_context_synchronously
        SnackBarExito.mostrar(context, 'Perfil actualizado');
        setState(() {
          _editando = false;
        });
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(
          context,
          controlador.error ?? 'Error al actualizar',
        );
      }
    }
  }

  Future<void> _cambiarPassword(PerfilControlador controlador) async {
    if (_passwordFormKey.currentState!.validate()) {
      if (_passwordNuevoController.text != _passwordConfirmarController.text) {
        SnackBarExito.error(context, 'Las contraseñas no coinciden');
        return;
      }

      final exito = await controlador.cambiarPassword(
        _passwordActualController.text,
        _passwordNuevoController.text,
      );

      if (exito) {
        // ignore: use_build_context_synchronously
        SnackBarExito.mostrar(context, 'Contraseña actualizada');
        _cancelarEdicion();
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(
          context,
          controlador.error ?? 'Error al cambiar contraseña',
        );
      }
    }
  }

  Future<void> _cerrarSesion(PerfilControlador controlador) async {
    final confirmar = await DialogoConfirmacion.cerrarSesion(context);
    if (confirmar == true) {
      await controlador.cerrarSesion();
      // ignore: use_build_context_synchronously
      RutasApp.limpiarEIr(context, RutasApp.login);
    }
  }

@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => PerfilControlador()..inicializar(),
    child: LayoutPrincipal(
      titulo: 'Mi Perfil',
      indiceActual: 4,
      // Acciones del AppBar controladas por el estado actual
      acciones: [
        Consumer<PerfilControlador>(
          builder: (context, controlador, _) {
            // Si está cambiando password: solo mostrar "Cancelar"
            if (_cambiandoPassword) {
              return IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancelar',
                onPressed: _cancelarEdicion,
              );
            }

            // Si está editando: mostrar "Guardar" y "Cancelar"
            if (_editando) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'Guardar',
                    onPressed: () => _guardarCambios(controlador),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cancelar',
                    onPressed: _cancelarEdicion,
                  ),
                ],
              );
            }

            // Estado normal: mostrar "Editar perfil"
            return IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _iniciarEdicion(controlador),
              tooltip: 'Editar perfil',
            );
          },
        ),
      ],

      // Contenido principal
      child: Consumer<PerfilControlador>(
        builder: (context, controlador, child) {
          if (controlador.cargando && controlador.usuario == null) {
            return const WidgetCargando(mensaje: 'Cargando perfil...');
          }

          final usuario = controlador.usuario;

          if (usuario == null) {
            return const Center(child: Text('Error al cargar perfil'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cabecera del perfil
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColores.primario, AppColores.secundario],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          usuario.nombre.isNotEmpty
                              ? usuario.nombre[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColores.primario,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nombre
                      Text(
                        usuario.nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Email
                      Text(
                        usuario.email,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      // Rol
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          usuario.rol.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Formulario de edición
                if (_editando)
                  Padding(
                    padding: Dimensiones.paddingTodo,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EDITAR INFORMACIÓN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColores.textoSecundario,
                            ),
                          ),
                          Dimensiones.esp16,
                          CampoTextoPersonalizado(
                            etiqueta: 'Nombre',
                            controller: _nombreController,
                            validador: (v) => Validadores.requerido(v),
                            icono: Icons.person,
                          ),
                          Dimensiones.esp16,
                          CampoTextoPersonalizado(
                            etiqueta: 'Teléfono',
                            controller: _telefonoController,
                            validador: Validadores.telefono,
                            tipoTeclado: TextInputType.phone,
                            icono: Icons.phone,
                          ),
                          Dimensiones.esp16,
                          CampoTextoPersonalizado(
                            etiqueta: 'Dirección',
                            controller: _direccionController,
                            icono: Icons.location_on,
                            maxLineas: 2,
                          ),
                          Dimensiones.esp24,
                          Row(
                            children: [
                              Expanded(
                                child: BotonPersonalizado(
                                  texto: 'Guardar',
                                  onPressed: () => _guardarCambios(controlador),
                                  cargando: controlador.cargando,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BotonPersonalizado(
                                  texto: 'Cancelar',
                                  onPressed: _cancelarEdicion,
                                  secundario: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Cambiar contraseña
                if (_cambiandoPassword)
                  Padding(
                    padding: Dimensiones.paddingTodo,
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CAMBIAR CONTRASEÑA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColores.textoSecundario,
                            ),
                          ),
                          Dimensiones.esp16,
                          CampoTextoPersonalizado(
                            etiqueta: 'Contraseña Actual',
                            controller: _passwordActualController,
                            validador: (v) => Validadores.requerido(v),
                            obscureText: true,
                            icono: Icons.lock_outline,
                          ),
                          Dimensiones.esp16,
                          CampoTextoPersonalizado(
                            etiqueta: 'Nueva Contraseña',
                            controller: _passwordNuevoController,
                            validador: Validadores.password,
                            obscureText: true,
                            icono: Icons.lock,
                          ),
                          Dimensiones.esp16,
                          CampoTextoPersonalizado(
                            etiqueta: 'Confirmar Nueva Contraseña',
                            controller: _passwordConfirmarController,
                            validador: Validadores.password,
                            obscureText: true,
                            icono: Icons.lock,
                          ),
                          Dimensiones.esp24,
                          Row(
                            children: [
                              Expanded(
                                child: BotonPersonalizado(
                                  texto: 'Cambiar',
                                  onPressed: () => _cambiarPassword(controlador),
                                  cargando: controlador.cargando,
                                  color: AppColores.advertencia,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BotonPersonalizado(
                                  texto: 'Cancelar',
                                  onPressed: _cancelarEdicion,
                                  secundario: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Información del perfil (cuando no está editando ni cambiando password)
                if (!_editando && !_cambiandoPassword)
                  Padding(
                    padding: Dimensiones.paddingTodo,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INFORMACIÓN PERSONAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColores.textoSecundario,
                          ),
                        ),
                        Dimensiones.esp16,
                        _InfoItem(
                          icono: Icons.email,
                          titulo: 'Email',
                          valor: usuario.email,
                        ),
                        _InfoItem(
                          icono: Icons.phone,
                          titulo: 'Teléfono',
                          valor: usuario.telefono ?? 'No registrado',
                        ),
                        _InfoItem(
                          icono: Icons.location_on,
                          titulo: 'Dirección',
                          valor: usuario.direccion ?? 'No registrada',
                        ),
                        _InfoItem(
                          icono: Icons.calendar_today,
                          titulo: 'Miembro desde',
                          valor: FormateadorFecha.fechaCompleta(
                            usuario.fechaRegistro,
                          ),
                        ),
                        Dimensiones.esp32,

                        // Botones de acción
                        BotonPersonalizado(
                          texto: 'Cambiar Contraseña',
                          onPressed: () {
                            setState(() {
                              _cambiandoPassword = true;
                            });
                          },
                          icono: Icons.lock,
                          secundario: true,
                        ),
                        Dimensiones.esp8,
                        BotonPersonalizado(
                          texto: 'Cerrar Sesión',
                          onPressed: () => _cerrarSesion(controlador),
                          icono: Icons.logout,
                          color: AppColores.error,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
}


// Widget de información
class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _InfoItem({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icono, color: AppColores.primario, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColores.textoSecundario,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
