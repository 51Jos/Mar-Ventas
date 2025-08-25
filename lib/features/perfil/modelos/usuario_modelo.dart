/// Modelo de usuario para el perfil

class UsuarioModelo {
  final String id;
  final String email;
  final String nombre;
  final String? telefono;
  final String? direccion;
  final String rol;
  final DateTime fechaRegistro;
  final String? fotoUrl;
  
  UsuarioModelo({
    required this.id,
    required this.email,
    required this.nombre,
    this.telefono,
    this.direccion,
    required this.rol,
    required this.fechaRegistro,
    this.fotoUrl,
  });
  
  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'telefono': telefono ?? '',
      'direccion': direccion ?? '',
      'rol': rol,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'fotoUrl': fotoUrl,
    };
  }
  
  // Crear desde Firebase
  factory UsuarioModelo.fromMap(Map<String, dynamic> map, String id) {
    return UsuarioModelo(
      id: id,
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? 'Usuario',
      telefono: map['telefono'],
      direccion: map['direccion'],
      rol: map['rol'] ?? 'vendedor',
      fechaRegistro: map['fechaRegistro'] != null 
          ? DateTime.parse(map['fechaRegistro'])
          : DateTime.now(),
      fotoUrl: map['fotoUrl'],
    );
  }
  
  // Copiar con cambios
  UsuarioModelo copyWith({
    String? nombre,
    String? telefono,
    String? direccion,
    String? fotoUrl,
  }) {
    return UsuarioModelo(
      id: id,
      email: email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      rol: rol,
      fechaRegistro: fechaRegistro,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}