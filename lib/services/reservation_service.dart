import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';

class ReservationService {
  static const String _baseUrl = 'https://hotel-api-silk.vercel.app/api/reservas';

  static Future<List<ReservationModel>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ReservationModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load reservations');
    }
  }

  static Future<ReservationModel> getById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final reservaJson = jsonResponse['reserva'] as Map<String, dynamic>;
      final detallesList = jsonResponse['detalles'] as List<dynamic>;
      
      if (detallesList.isNotEmpty) {
        reservaJson['id_habitacion'] = detallesList[0]['id_habitacion'];
      }
      reservaJson['detalles'] = detallesList;

      return ReservationModel.fromJson(reservaJson);
    } else {
      throw Exception('Error fetching reservation with id: $id');
    }
  }

  static Future<ReservationModel> create(ReservationModel reservation) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservation.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ReservationModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  static Future<ReservationModel> update(String id, ReservationModel reservation) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservation.toJson()),
    );

    if (response.statusCode == 200) {
      return ReservationModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update reservation: ${response.body}');
    }
  }

  static Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete reservation: ${response.body}');
    }
  }
}
