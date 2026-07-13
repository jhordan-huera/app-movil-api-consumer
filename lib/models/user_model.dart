class UserModel {
  final String? idHuesped;
  final String? cedula;
  final String? nombres;
  final String? apellidos;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? nacionalidad;

  UserModel({
    this.idHuesped,
    this.cedula,
    this.nombres,
    this.apellidos,
    this.email,
    this.telefono,
    this.direccion,
    this.nacionalidad,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        idHuesped: json['id_huesped'] as String?,
        cedula: json['cedula'] as String?,
        nombres: json['nombres'] as String?,
        apellidos: json['apellidos'] as String?,
        email: json['email'] as String?,
        telefono: json['telefono'] as String?,
        direccion: json['direccion'] as String?,
        nacionalidad: json['nacionalidad'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id_huesped': idHuesped,
        'cedula': cedula,
        'nombres': nombres,
        'apellidos': apellidos,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'nacionalidad': nacionalidad,
      };
}