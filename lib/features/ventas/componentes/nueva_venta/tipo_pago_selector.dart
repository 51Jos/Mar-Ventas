import 'package:flutter/material.dart';
import '../../../../compartido/tema/colores_app.dart';
import '../../../../compartido/tema/dimensiones.dart';

class TipoPagoSelector extends StatelessWidget {
  final String tipoPago;
  final String metodoPago;
  final Function(String) onTipoPagoChanged;
  final Function(String) onMetodoPagoChanged;
  
  const TipoPagoSelector({
    super.key,
    required this.tipoPago,
    required this.metodoPago,
    required this.onTipoPagoChanged,
    required this.onMetodoPagoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipo de pago
        const Text(
          'Tipo de Pago',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Dimensiones.esp8,
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => onTipoPagoChanged('contado'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: tipoPago == 'contado' 
                        ? AppColores.exito 
                        : Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.money,
                        size: 20,
                        color: tipoPago == 'contado' 
                            ? Colors.white 
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CONTADO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tipoPago == 'contado' 
                              ? Colors.white 
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onTipoPagoChanged('credito'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: tipoPago == 'credito' 
                        ? AppColores.advertencia 
                        : Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 20,
                        color: tipoPago == 'credito' 
                            ? Colors.white 
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CRÉDITO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tipoPago == 'credito' 
                              ? Colors.white 
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        Dimensiones.esp16,
        
        // Método de pago
        const Text(
          'Método de Pago',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Dimensiones.esp8,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetodoPagoChip(
              label: 'Efectivo',
              icono: Icons.money,
              selected: metodoPago == 'efectivo',
              onSelected: () => onMetodoPagoChanged('efectivo'),
            ),
            _MetodoPagoChip(
              label: 'Yape',
              icono: Icons.phone_android,
              selected: metodoPago == 'yape',
              onSelected: () => onMetodoPagoChanged('yape'),
              color: Colors.purple,
            ),
            _MetodoPagoChip(
              label: 'Plin',
              icono: Icons.phone_android,
              selected: metodoPago == 'plin',
              onSelected: () => onMetodoPagoChanged('plin'),
              color: Colors.teal,
            ),
            _MetodoPagoChip(
              label: 'Transferencia',
              icono: Icons.account_balance,
              selected: metodoPago == 'transferencia',
              onSelected: () => onMetodoPagoChanged('transferencia'),
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetodoPagoChip extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;
  
  const _MetodoPagoChip({
    required this.label,
    required this.icono,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 16,
            color: selected ? Colors.white : (color ?? AppColores.primario),
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color ?? AppColores.primario,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}