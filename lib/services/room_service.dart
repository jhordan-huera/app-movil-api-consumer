import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room_model.dart';

class RoomService {
  static const String _baseUrl = 'https://hotel-api-silk.vercel.app/api/habitaciones';

  static Future<List<RoomModel>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => RoomModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  static Future<RoomModel> getById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return RoomModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error fetching room with id: $id');
    }
  }

  static Future<RoomModel> create(RoomModel room) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(room.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return RoomModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create room: ${response.body}');
    }
  }

  static Future<RoomModel> update(String id, RoomModel room) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(room.toJson()),
    );

    if (response.statusCode == 200) {
      return RoomModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update room: ${response.body}');
    }
  }

  static Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete room: ${response.body}');
    }
  }
}
