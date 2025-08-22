import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoTextoPersonalizado extends StatelessWidget {
  final String etiqueta;
  final String? placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final bool obscureText;
  final IconData? icono;
  final Widget? sufijo;
  final bool habilitado;
  final int? maxLineas;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final bool soloLectura;
  final VoidCallback? onTap;

  const CampoTextoPersonalizado({
    super.key,
    required this.etiqueta,
    this.placeholder,
    this.controller,
    this.validador,
    this.tipoTeclado,
    this.obscureText = false,
    this.icono,
    this.sufijo,
    this.habilitado = true,
    this.maxLineas = 1,
    this.inputFormatters,
    this.onChanged,
    this.soloLectura = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validador,
      keyboardType: tipoTeclado,
      obscureText: obscureText,
      enabled: habilitado,
      maxLines: maxLineas,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      readOnly: soloLectura,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: placeholder,
        prefixIcon: icono != null ? Icon(icono) : null,
        suffixIcon: sufijo,
        filled: true,
        fillColor: habilitado ? Colors.white : Colors.grey[100],
      ),
    );
  }
}

/// Versión simple para números
class CampoNumero extends StatelessWidget {
  final String etiqueta;
  final TextEditingController? controller;
  final String? Function(String?)? validador;
  final bool decimal;
  final String? prefijo;
  final String? sufijo;
  final void Function(String)? onChanged;

  const CampoNumero({
    super.key,
    required this.etiqueta,
    this.controller,
    this.validador,
    this.decimal = true,
    this.prefijo,
    this.sufijo,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validador,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixText: prefijo,
        suffixText: sufijo,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}