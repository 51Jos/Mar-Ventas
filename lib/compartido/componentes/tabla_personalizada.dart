import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

class TablaPersonalizada extends StatelessWidget {
  final List<String> columnas;
  final List<List<Widget>> filas;
  final List<double>? anchoColumnas;
  final bool mostrarIndice;

  const TablaPersonalizada({
    super.key,
    required this.columnas,
    required this.filas,
    this.anchoColumnas,
    this.mostrarIndice = false,
  });

  @override
  Widget build(BuildContext context) {
    // Agregar columna de índice si es necesario
    final columnasFinales = mostrarIndice ? ['#', ...columnas] : columnas;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          columnWidths: _construirAnchoColumnas(),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          children: [
            // Cabecera
            TableRow(
              decoration: const BoxDecoration(
                color: AppColores.primario,
              ),
              children: columnasFinales.map((columna) {
                return TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      columna,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            // Filas de datos
            ...filas.asMap().entries.map((entry) {
              final index = entry.key;
              final fila = entry.value;
              
              // Agregar índice si es necesario
              final filaFinal = mostrarIndice 
                  ? [
                      Text(
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      ...fila
                    ] 
                  : fila;
              
              return TableRow(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.white : Colors.grey.shade50,
                ),
                children: filaFinal.map((celda) {
                  return TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: celda,
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Map<int, TableColumnWidth>? _construirAnchoColumnas() {
    if (anchoColumnas == null) return null;
    
    final map = <int, TableColumnWidth>{};
    
    // Si hay índice, agregar ancho fijo para esa columna
    if (mostrarIndice) {
      map[0] = const FixedColumnWidth(50);
      
      // Ajustar los demás anchos
      for (int i = 0; i < anchoColumnas!.length; i++) {
        map[i + 1] = FlexColumnWidth(anchoColumnas![i]);
      }
    } else {
      for (int i = 0; i < anchoColumnas!.length; i++) {
        map[i] = FlexColumnWidth(anchoColumnas![i]);
      }
    }
    
    return map;
  }
}

/// Tabla simple para datos básicos
class TablaSimple extends StatelessWidget {
  final List<Map<String, dynamic>> datos;
  final List<String> columnas;
  final Map<String, String> etiquetas;

  const TablaSimple({
    super.key,
    required this.datos,
    required this.columnas,
    this.etiquetas = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No hay datos para mostrar'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColores.primario),
        columns: columnas.map((col) {
          return DataColumn(
            label: Text(
              etiquetas[col] ?? col,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
        rows: datos.map((fila) {
          return DataRow(
            cells: columnas.map((col) {
              final valor = fila[col];
              return DataCell(
                Text(valor?.toString() ?? ''),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}