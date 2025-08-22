import 'package:flutter/material.dart';

class WrapperResponsivo extends StatelessWidget {
  final Widget movil;
  final Widget? tablet;
  final Widget? escritorio;

  const WrapperResponsivo({
    super.key,
    required this.movil,
    this.tablet,
    this.escritorio,
  });

  // Breakpoints simples
  static bool esMobil(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool esTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool esEscritorio(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    // Escritorio
    if (ancho >= 1200 && escritorio != null) {
      return escritorio!;
    }
    // Tablet
    else if (ancho >= 600 && tablet != null) {
      return tablet!;
    }
    // Móvil
    else {
      return movil;
    }
  }
}

/// Helper para centrar contenido en pantallas grandes
class ContenedorResponsivo extends StatelessWidget {
  final Widget child;
  final double maxAncho;

  const ContenedorResponsivo({
    super.key,
    required this.child,
    this.maxAncho = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxAncho),
        child: child,
      ),
    );
  }
}

/// Grid responsivo
class GridResponsivo extends StatelessWidget {
  final List<Widget> children;
  final double espaciado;

  const GridResponsivo({
    super.key,
    required this.children,
    this.espaciado = 16,
  });

  @override
  Widget build(BuildContext context) {
    int columnas;
    
    if (WrapperResponsivo.esMobil(context)) {
      columnas = 1;
    } else if (WrapperResponsivo.esTablet(context)) {
      columnas = 2;
    } else {
      columnas = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: espaciado,
        mainAxisSpacing: espaciado,
        childAspectRatio: 1,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}