import 'package:flutter/material.dart';
import '../../../../compartido/componentes/campo_texto_personalizado.dart';
import '../../../../compartido/tema/colores_app.dart';
import '../../../../compartido/tema/dimensiones.dart';
import '../../../clientes/modelos/cliente_modelo.dart';
import '../../../clientes/servicios/clientes_servicio.dart';

class ClienteSelector extends StatefulWidget {
  final Function(ClienteModelo?) onClienteSeleccionado;
  final Function(String nombre, String? telefono) onClienteNuevo;
  
  const ClienteSelector({
    super.key,
    required this.onClienteSeleccionado,
    required this.onClienteNuevo,
  });

  @override
  State<ClienteSelector> createState() => _ClienteSelectorState();
}

class _ClienteSelectorState extends State<ClienteSelector> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _clientesServicio = ClientesServicio();
  
  ClienteModelo? _clienteSeleccionado;
  List<ClienteModelo> _clientesSugeridos = [];
  bool _mostrarSugerencias = false;
  bool _esNuevoCliente = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _buscarClientes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _clientesSugeridos = [];
        _mostrarSugerencias = false;
      });
      return;
    }

    // Buscar clientes en Firebase
    final snapshot = await _clientesServicio.obtenerClientes().first;
    final clientes = snapshot.where((c) => 
      c.nombre.toLowerCase().contains(query.toLowerCase())
    ).toList();

    setState(() {
      _clientesSugeridos = clientes;
      _mostrarSugerencias = clientes.isNotEmpty;
      _esNuevoCliente = clientes.isEmpty;
    });

    // Notificar si es cliente nuevo
    if (_esNuevoCliente) {
      widget.onClienteNuevo(
        _nombreController.text,
        _telefonoController.text.isEmpty ? null : _telefonoController.text,
      );
    }
  }

  void _seleccionarCliente(ClienteModelo cliente) {
    setState(() {
      _clienteSeleccionado = cliente;
      _nombreController.text = cliente.nombre;
      _telefonoController.text = cliente.telefono ?? '';
      _mostrarSugerencias = false;
      _esNuevoCliente = false;
    });
    
    widget.onClienteSeleccionado(cliente);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de nombre
        CampoTextoPersonalizado(
          etiqueta: 'Cliente',
          controller: _nombreController,
          icono: Icons.person,
          onChanged: (valor) {
            _buscarClientes(valor);
            if (_clienteSeleccionado != null) {
              setState(() {
                _clienteSeleccionado = null;
              });
              widget.onClienteSeleccionado(null);
            }
          },
        ),
        
        // Lista de sugerencias
        if (_mostrarSugerencias)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _clientesSugeridos.length,
              itemBuilder: (context, index) {
                final cliente = _clientesSugeridos[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cliente.tieneDeuda 
                        // ignore: deprecated_member_use
                        ? AppColores.error.withOpacity(0.2)
                        // ignore: deprecated_member_use
                        : AppColores.exito.withOpacity(0.2),
                    child: Text(
                      cliente.nombre[0].toUpperCase(),
                      style: TextStyle(
                        color: cliente.tieneDeuda 
                            ? AppColores.error 
                            : AppColores.exito,
                      ),
                    ),
                  ),
                  title: Text(cliente.nombre),
                  subtitle: cliente.telefono != null 
                      ? Text(cliente.telefono!)
                      : null,
                  trailing: cliente.tieneDeuda
                      ? Text(
                          'Debe: S/. ${cliente.deudaTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColores.error,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () => _seleccionarCliente(cliente),
                );
              },
            ),
          ),
        
        Dimensiones.esp8,
        
        // Campo de teléfono
        CampoTextoPersonalizado(
          etiqueta: 'Teléfono (opcional)',
          controller: _telefonoController,
          icono: Icons.phone,
          tipoTeclado: TextInputType.phone,
          habilitado: _clienteSeleccionado == null,
          onChanged: (_) {
            if (_esNuevoCliente) {
              widget.onClienteNuevo(
                _nombreController.text,
                _telefonoController.text.isEmpty ? null : _telefonoController.text,
              );
            }
          },
        ),
        
        // Indicador de estado
        if (_clienteSeleccionado != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColores.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColores.info),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColores.info, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Cliente registrado${_clienteSeleccionado!.tieneDeuda ? " - Tiene deuda pendiente" : ""}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          )
        else if (_esNuevoCliente && _nombreController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColores.advertencia.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColores.advertencia),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_add, color: AppColores.advertencia, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Cliente nuevo - Se agregará automáticamente',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}