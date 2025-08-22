/// Vista para registrar abono

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
import '../modelos/abono_modelo.dart';

class RegistrarAbonoVista extends StatefulWidget {
  final ClienteModelo cliente;
  
  const RegistrarAbonoVista({
    super.key,
    required this.cliente,
  });

  @override
  State<RegistrarAbonoVista> createState() => _RegistrarAbonoVistaState();
}

class _RegistrarAbonoVistaState extends State<RegistrarAbonoVista> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ClientesControlador();
  
  final _montoController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  double get deudaActual => widget.cliente.deudaTotal;
  double _montoAbono = 0;

  @override
  void dispose() {
    _montoController.dispose();
    _observacionesController.dispose();
    _controlador.dispose();
    super.dispose();
  }

  void _calcularRestante() {
    setState(() {
      _montoAbono = double.tryParse(_montoController.text) ?? 0;
    });
  }

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      final monto = double.parse(_montoController.text);
      
      if (monto > deudaActual) {
        SnackBarExito.advertencia(context, 'El abono no puede ser mayor a la deuda');
        return;
      }
      
      final abono = AbonoModelo(
        clienteId: widget.cliente.id!,
        clienteNombre: widget.cliente.nombre,
        monto: monto,
        fecha: DateTime.now(),
        observaciones: _observacionesController.text.trim(),
      );
      
      final exito = await _controlador.registrarAbono(abono);
      
      if (exito) {
        final restante = deudaActual - monto;
        if (restante <= 0) {
          // ignore: use_build_context_synchronously
          SnackBarExito.mostrar(context, '¡Deuda saldada completamente!');
        } else {
          // ignore: use_build_context_synchronously
          SnackBarExito.mostrar(context, 'Abono registrado. Resta: ${FormateadorMoneda.formatear(restante)}');
        }
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        SnackBarExito.error(context, _controlador.error ?? 'Error al registrar abono');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restante = deudaActual - _montoAbono;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Abono'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Dimensiones.paddingTodo,
          children: [
            // Info del cliente
            Card(
              // ignore: deprecated_member_use
              color: AppColores.primario.withOpacity(0.1),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColores.primario,
                  child: Text(
                    widget.cliente.nombre.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  widget.cliente.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Teléfono: ${widget.cliente.telefono ?? "No registrado"}'),
              ),
            ),
            Dimensiones.esp16,
            
            // Deuda actual
            Container(
              padding: Dimensiones.paddingTodo,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColores.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColores.error),
              ),
              child: Column(
                children: [
                  const Text(
                    'DEUDA ACTUAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    FormateadorMoneda.formatear(deudaActual),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColores.error,
                    ),
                  ),
                ],
              ),
            ),
            Dimensiones.esp24,
            
            // Monto del abono
            CampoNumero(
              etiqueta: 'Monto del Abono',
              controller: _montoController,
              validador: (valor) => Validadores.mayorQueCero(valor),
              prefijo: 'S/. ',
              onChanged: (_) => _calcularRestante(),
            ),
            Dimensiones.esp8,
            
            // Botones rápidos
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: Text('S/. ${(deudaActual * 0.25).toStringAsFixed(0)}'),
                  onPressed: () {
                    _montoController.text = (deudaActual * 0.25).toStringAsFixed(2);
                    _calcularRestante();
                  },
                ),
                ActionChip(
                  label: Text('S/. ${(deudaActual * 0.5).toStringAsFixed(0)}'),
                  onPressed: () {
                    _montoController.text = (deudaActual * 0.5).toStringAsFixed(2);
                    _calcularRestante();
                  },
                ),
                ActionChip(
                  label: const Text('TOTAL'),
                  backgroundColor: AppColores.exito,
                  onPressed: () {
                    _montoController.text = deudaActual.toStringAsFixed(2);
                    _calcularRestante();
                  },
                ),
              ],
            ),
            Dimensiones.esp16,
            
            // Observaciones
            CampoTextoPersonalizado(
              etiqueta: 'Observaciones (opcional)',
              controller: _observacionesController,
              maxLineas: 2,
              icono: Icons.note,
            ),
            Dimensiones.esp24,
            
            // Restante
            if (_montoAbono > 0)
              Container(
                padding: Dimensiones.paddingTodo,
                decoration: BoxDecoration(
                  color: restante <= 0 
                      // ignore: deprecated_member_use
                      ? AppColores.exito.withOpacity(0.1)
                      // ignore: deprecated_member_use
                      : AppColores.advertencia.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: restante <= 0 ? AppColores.exito : AppColores.advertencia,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restante <= 0 ? 'DEUDA SALDADA' : 'RESTANTE:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      restante <= 0 
                          ? '✓ Completado'
                          : FormateadorMoneda.formatear(restante),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: restante <= 0 ? AppColores.exito : AppColores.advertencia,
                      ),
                    ),
                  ],
                ),
              ),
            Dimensiones.esp24,
            
            // Botón Registrar
            AnimatedBuilder(
              animation: _controlador,
              builder: (context, child) {
                return BotonPersonalizado(
                  texto: 'Registrar Abono',
                  onPressed: _registrar,
                  cargando: _controlador.cargando,
                  icono: Icons.payment,
                  color: AppColores.exito,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}