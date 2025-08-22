import 'package:flutter/material.dart';

class DropdownPersonalizado<T> extends StatelessWidget {
  final String etiqueta;
  final T? valor;
  final List<DropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validador;
  final IconData? icono;
  final bool habilitado;

  const DropdownPersonalizado({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.items,
    required this.onChanged,
    this.validador,
    this.icono,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: valor,
      onChanged: habilitado ? onChanged : null,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: icono != null ? Icon(icono) : null,
        filled: true,
        fillColor: habilitado ? Colors.white : Colors.grey[100],
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item.valor,
          child: Row(
            children: [
              if (item.icono != null) ...[
                Icon(item.icono, size: 20),
                const SizedBox(width: 8),
              ],
              Text(item.texto),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Clase para los items del dropdown
class DropdownItem<T> {
  final T valor;
  final String texto;
  final IconData? icono;

  DropdownItem({
    required this.valor,
    required this.texto,
    this.icono,
  });
}

/// Dropdown simple para strings
class DropdownSimple extends StatelessWidget {
  final String etiqueta;
  final String? valor;
  final List<String> opciones;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validador;

  const DropdownSimple({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.onChanged,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valor,
      onChanged: onChanged,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        filled: true,
        fillColor: Colors.white,
      ),
      items: opciones.map((opcion) {
        return DropdownMenuItem<String>(
          value: opcion,
          child: Text(opcion),
        );
      }).toList(),
    );
  }
}