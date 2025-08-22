import 'package:flutter/material.dart';
import '../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../compartido/componentes/boton_personalizado.dart';
import '../../../compartido/componentes/snackbar_exito.dart';
import '../../../compartido/tema/colores_app.dart';
import '../../../compartido/tema/dimensiones.dart';
import '../../../compartido/utilidades/validadores.dart';
import '../../../compartido/utilidades/formateador_moneda.dart';
import '../controladores/clientes_controlador.dart';
import '../modelos/cliente_modelo.dart';

class ClienteEditarVista extends StatefulWidget {
  final ClienteModelo cliente;
  
  const ClienteEditarVista({
    super.key,
    required this.cliente,
  });

  @override
  State<ClienteEditarVista> createState() => _ClienteEditarVistaState();
}

class _ClienteEditarVistaState extends State<ClienteEditarVista> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ClientesControlador();
  
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cliente.nombre);
    _telefonoController = TextEditingController(text: widget.cliente.telefono ?? '');
    _direccionController = TextEditingController(text: widget.cliente.direccion ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _actualizar() async {
    if (_formKey.currentState!.validate()) {
      final clienteActualizado = widget.cliente.copyWith(
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
      );
      
      final exito = await _controlador.actualizarCliente(clienteActualizado);
      
      if (exito) {
        // ignore: use_build_context_synchronously
        SnackBarExito.mostrar(context, 'Cliente actualizado');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(context, _controlador.error ?? 'Error al actualizar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Dimensiones.paddingTodo,
          children: [
            // Info de deuda
            if (widget.cliente.tieneDeuda)
              Container(
                padding: Dimensiones.paddingTodo,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColores.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColores.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColores.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deuda actual: ${FormateadorMoneda.formatear(widget.cliente.deudaTotal)}',
                        style: const TextStyle(
                          color: AppColores.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
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
            
            // Dirección
            CampoTextoPersonalizado(
              etiqueta: 'Dirección (opcional)',
              controller: _direccionController,
              icono: Icons.location_on,
              maxLineas: 2,
            ),
            Dimensiones.esp32,
            
            // Botones
            AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                return Column(
                  children: [
                    BotonPersonalizado(
                      texto: 'Actualizar Cliente',
                      onPressed: _actualizar,
                      cargando: _controlador.cargando,
                      icono: Icons.update,
                    ),
                    Dimensiones.esp8,
                    BotonPersonalizado(
                      texto: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      secundario: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}