class RoomModel {
  final String? idHabitacion;
  final String? numero;
  final String? tipo;
  final int? piso;
  final String? precioNoche;
  final int? capacidad;
  final String? descripcion;
  final String? estado;
  final String? createdAt;
  final String? updatedAt;

  RoomModel({
    this.idHabitacion,
    this.numero,
    this.tipo,
    this.piso,
    this.precioNoche,
    this.capacidad,
    this.descripcion,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      idHabitacion: json['id_habitacion'],
      numero: json['numero'],
      tipo: json['tipo'],
      piso: json['piso'],
      precioNoche: json['precio_noche'],
      capacidad: json['capacidad'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_habitacion': idHabitacion,
      'numero': numero,
      'tipo': tipo,
      'piso': piso,
      'precio_noche': precioNoche,
      'capacidad': capacidad,
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}
