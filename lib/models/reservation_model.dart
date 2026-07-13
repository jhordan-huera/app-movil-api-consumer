class ReservationModel {
  final String? idReserva;
  final String? codigo;
  final String? fechaReserva;
  final String? fechaCheckin;
  final String? fechaCheckout;
  final int? numNoches;
  final String? subtotal;
  final String? impuesto;
  final String? total;
  final String? estado;
  final String? observaciones;
  final String? idHuesped;
  final String? idHabitacion;
  final List<Map<String, dynamic>>? detalles;
  final String? huespedCedula;
  final String? huespedNombre;

  ReservationModel({
    this.idReserva,
    this.codigo,
    this.fechaReserva,
    this.fechaCheckin,
    this.fechaCheckout,
    this.numNoches,
    this.subtotal,
    this.impuesto,
    this.total,
    this.estado,
    this.observaciones,
    this.idHuesped,
    this.idHabitacion,
    this.detalles,
    this.huespedCedula,
    this.huespedNombre,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      idReserva: json['id_reserva'],
      codigo: json['codigo'],
      fechaReserva: json['fecha_reserva'],
      fechaCheckin: json['fecha_checkin'],
      fechaCheckout: json['fecha_checkout'],
      numNoches: json['num_noches'],
      subtotal: json['subtotal'],
      impuesto: json['impuesto'],
      total: json['total'],
      estado: json['estado'],
      observaciones: json['observaciones'],
      idHuesped: json['id_huesped'],
      idHabitacion: json['id_habitacion'],
      huespedCedula: json['huesped_cedula'],
      huespedNombre: json['huesped_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id_reserva': idReserva,
      'codigo': codigo,
      'fecha_reserva': fechaReserva,
      'fecha_checkin': fechaCheckin,
      'fecha_checkout': fechaCheckout,
      'num_noches': numNoches,
      'subtotal': subtotal,
      'impuesto': impuesto,
      'total': total,
      'estado': estado,
      'observaciones': observaciones,
      'id_huesped': idHuesped,
      'id_habitacion': idHabitacion,
    };
    if (detalles != null) {
      map['detalles'] = detalles;
    }
    return map;
  }
}
