import 'package:flutter/material.dart';

class CabeceraApp extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? acciones;
  final bool mostrarVolver;
  final VoidCallback? onVolver;
  final Widget? leading;

  const CabeceraApp({
    super.key,
    required this.titulo,
    this.acciones,
    this.mostrarVolver = true,
    this.onVolver,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      centerTitle: true,
      automaticallyImplyLeading: mostrarVolver,
      leading: leading ?? (mostrarVolver && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onVolver ?? () => Navigator.pop(context),
            )
          : null),
      actions: acciones,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}