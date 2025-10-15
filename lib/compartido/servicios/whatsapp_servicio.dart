import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import '../../features/clientes/modelos/cliente_modelo.dart';
import '../../features/clientes/modelos/abono_modelo.dart';
import '../utilidades/formateador_moneda.dart';
import '../utilidades/formateador_fecha.dart';

class WhatsAppServicio {
  /// Enviar resumen de estado de cuenta por WhatsApp
  static Future<bool> enviarEstadoCuenta({
    required ClienteModelo cliente,
    required List<AbonoModelo> abonos,
    String? nombreNegocio,
  }) async {
    if (cliente.telefono == null || cliente.telefono!.isEmpty) {
      throw Exception('El cliente no tiene número de teléfono registrado');
    }

    final mensaje = _generarMensajeEstadoCuenta(
      cliente: cliente,
      abonos: abonos,
      nombreNegocio: nombreNegocio,
    );

    return await _enviarMensaje(
      telefono: cliente.telefono!,
      mensaje: mensaje,
    );
  }

  /// Enviar recordatorio de deuda
  static Future<bool> enviarRecordatorioDeuda({
    required ClienteModelo cliente,
    String? nombreNegocio,
    String? mensajePersonalizado,
  }) async {
    if (cliente.telefono == null || cliente.telefono!.isEmpty) {
      throw Exception('El cliente no tiene número de teléfono registrado');
    }

    final mensaje = _generarMensajeRecordatorio(
      cliente: cliente,
      nombreNegocio: nombreNegocio,
      mensajePersonalizado: mensajePersonalizado,
    );

    return await _enviarMensaje(
      telefono: cliente.telefono!,
      mensaje: mensaje,
    );
  }

  /// Enviar confirmación de abono
  static Future<bool> enviarConfirmacionAbono({
    required ClienteModelo cliente,
    required AbonoModelo abono,
    required double deudaRestante,
    String? nombreNegocio,
  }) async {
    if (cliente.telefono == null || cliente.telefono!.isEmpty) {
      throw Exception('El cliente no tiene número de teléfono registrado');
    }

    final mensaje = _generarMensajeAbono(
      cliente: cliente,
      abono: abono,
      deudaRestante: deudaRestante,
      nombreNegocio: nombreNegocio,
    );

    return await _enviarMensaje(
      telefono: cliente.telefono!,
      mensaje: mensaje,
    );
  }

  /// Método privado para enviar mensaje por WhatsApp
  static Future<bool> _enviarMensaje({
    required String telefono,
    required String mensaje,
  }) async {
    try {
      // Limpiar el número de teléfono
      String telefonoLimpio = telefono.replaceAll(RegExp(r'[^\d]'), '');

      // Si no empieza con 51 (código de Perú), agregarlo
      if (!telefonoLimpio.startsWith('51')) {
        telefonoLimpio = '51$telefonoLimpio';
      }

      // Crear el link de WhatsApp
      final link = WhatsAppUnilink(
        phoneNumber: '+$telefonoLimpio',
        text: mensaje,
      );

      final url = Uri.parse(link.toString());

      // ignore: avoid_print
      print('📱 Abriendo WhatsApp: $url');

      // Lanzar WhatsApp
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error al enviar mensaje por WhatsApp: $e');
      return false;
    }
  }

  /// Generar mensaje de estado de cuenta
  static String _generarMensajeEstadoCuenta({
    required ClienteModelo cliente,
    required List<AbonoModelo> abonos,
    String? nombreNegocio,
  }) {
    final negocio = nombreNegocio ?? 'Marventas';
    final fecha = FormateadorFecha.fechaCompleta(DateTime.now());

    final buffer = StringBuffer();
    buffer.writeln('🧾 *ESTADO DE CUENTA*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('📍 *$negocio*');
    buffer.writeln('📅 Fecha: $fecha');
    buffer.writeln('');
    buffer.writeln('👤 *Cliente:* ${cliente.nombre}');
    buffer.writeln('');

    if (cliente.tieneDeuda) {
      buffer.writeln('💳 *DEUDA ACTUAL*');
      buffer.writeln(FormateadorMoneda.formatear(cliente.deudaTotal));
    } else {
      buffer.writeln('✅ *SIN DEUDA*');
      buffer.writeln('¡Su cuenta está al día!');
    }

    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');

    if (abonos.isNotEmpty) {
      final totalAbonado = abonos.fold<double>(0, (sum, a) => sum + a.monto);

      buffer.writeln('');
      buffer.writeln('📊 *HISTORIAL DE PAGOS*');
      buffer.writeln('');
      buffer.writeln('Total abonado: ${FormateadorMoneda.formatear(totalAbonado)}');
      buffer.writeln('Cantidad de pagos: ${abonos.length}');
      buffer.writeln('');

      // Mostrar últimos 5 abonos
      final abonosRecientes = abonos.take(5).toList();
      buffer.writeln('📝 *Últimos pagos:*');

      for (var abono in abonosRecientes) {
        buffer.writeln('');
        buffer.writeln('• ${FormateadorMoneda.formatear(abono.monto)}');
        buffer.writeln('  ${FormateadorFecha.fechaHora(abono.fecha)}');
        if (abono.observaciones != null && abono.observaciones!.isNotEmpty) {
          buffer.writeln('  _${abono.observaciones}_');
        }
      }

      if (abonos.length > 5) {
        buffer.writeln('');
        buffer.writeln('... y ${abonos.length - 5} pagos más');
      }
    }

    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('Gracias por su preferencia 🙏');
    buffer.writeln('');
    buffer.writeln('_Enviado desde ${negocio}_');

    return buffer.toString();
  }

  /// Generar mensaje de recordatorio de deuda
  static String _generarMensajeRecordatorio({
    required ClienteModelo cliente,
    String? nombreNegocio,
    String? mensajePersonalizado,
  }) {
    final negocio = nombreNegocio ?? 'Marventas';
    final buffer = StringBuffer();
    buffer.writeln('👋 Hola *${cliente.nombre}*');
    buffer.writeln('');

    if (mensajePersonalizado != null && mensajePersonalizado.isNotEmpty) {
      buffer.writeln(mensajePersonalizado);
      buffer.writeln('');
    }

    buffer.writeln('💳 Le recordamos que tiene una deuda pendiente:');
    buffer.writeln('');
    buffer.writeln('*${FormateadorMoneda.formatear(cliente.deudaTotal)}*');
    buffer.writeln('');
    buffer.writeln('Agradecemos su pronta atención. 🙏');
    buffer.writeln('');
    buffer.writeln('Para cualquier consulta, estamos a su disposición.');
    buffer.writeln('');
    buffer.writeln('Saludos,');
    buffer.writeln('*$negocio*');

    return buffer.toString();
  }

  /// Generar mensaje de confirmación de abono
  static String _generarMensajeAbono({
    required ClienteModelo cliente,
    required AbonoModelo abono,
    required double deudaRestante,
    String? nombreNegocio,
  }) {
    final negocio = nombreNegocio ?? 'Marventas';
    final fecha = FormateadorFecha.fechaHora(abono.fecha);

    final buffer = StringBuffer();
    buffer.writeln('✅ *PAGO RECIBIDO*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('Hola *${cliente.nombre}*,');
    buffer.writeln('');
    buffer.writeln('Confirmamos el pago recibido:');
    buffer.writeln('');
    buffer.writeln('💰 *Monto:* ${FormateadorMoneda.formatear(abono.monto)}');
    buffer.writeln('📅 *Fecha:* $fecha');

    if (abono.observaciones != null && abono.observaciones!.isNotEmpty) {
      buffer.writeln('📝 *Nota:* ${abono.observaciones}');
    }

    buffer.writeln('');

    if (deudaRestante > 0) {
      buffer.writeln('💳 *Saldo pendiente:*');
      buffer.writeln(FormateadorMoneda.formatear(deudaRestante));
    } else {
      buffer.writeln('🎉 *¡Deuda saldada completamente!*');
      buffer.writeln('Su cuenta está al día.');
    }

    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('Gracias por su pago 🙏');
    buffer.writeln('');
    buffer.writeln('_${negocio}_');

    return buffer.toString();
  }

  /// Validar que el teléfono sea válido
  static bool validarTelefono(String? telefono) {
    if (telefono == null || telefono.isEmpty) return false;

    // Limpiar el número
    final telefonoLimpio = telefono.replaceAll(RegExp(r'[^\d]'), '');

    // Debe tener al menos 9 dígitos
    return telefonoLimpio.length >= 9;
  }
}
