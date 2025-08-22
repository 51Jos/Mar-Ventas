import 'package:flutter/material.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../controladores/clientes_controlador.dart';
import '../modelos/cliente_modelo.dart';

class ClienteAgregarVista extends StatefulWidget {
  const ClienteAgregarVista({super.key});

  @override
  State<ClienteAgregarVista> createState() => _ClienteAgregarVistaState();
}

class _ClienteAgregarVistaState extends State<ClienteAgregarVista> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ClientesControlador();
  
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final cliente = ClienteModelo(
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        fechaRegistro: DateTime.now(),
      );
      
      final exito = await _controlador.crearCliente(cliente);
      
      if (exito) {
        // ignore: use_build_context_synchronously
        SnackBarExito.mostrar(context, 'Cliente agregado exitosamente');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(context, _controlador.error ?? 'Error al guardar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Dimensiones.paddingTodo,
          children: [
            // Nombre
            CampoTextoPersonalizado(
              etiqueta: 'Nombre del Cliente',
              controller: _nombreController,
              validador: (valor) => Validadores.requerido(valor, 'El nombre es requerido'),
              icono: Icons.person,
            ),
            Dimensiones.esp16,
            
            // Teléfono
            CampoTextoPersonalizado(
              etiqueta: 'Teléfono',
              controller: _telefonoController,
              validador: Validadores.telefono,
              tipoTeclado: TextInputType.phone,
              icono: Icons.phone,
            ),
            Dimensiones.esp16,
            
            // Dirección (opcional)
            CampoTextoPersonalizado(
              etiqueta: 'Dirección (opcional)',
              controller: _direccionController,
              icono: Icons.location_on,
              maxLineas: 2,
            ),
            Dimensiones.esp32,
            
            // Botón Guardar
            AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                return BotonPersonalizado(
                  texto: 'Guardar Cliente',
                  onPressed: _guardar,
                  cargando: _controlador.cargando,
                  icono: Icons.save,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}