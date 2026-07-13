import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  static const String _baseUrl = 'https://hotel-api-silk.vercel.app/api/huespedes';

  static Future<List<UserModel>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load guests');
    }
  }

  static Future<UserModel> getById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error leyendo huésped con id: $id');
    }
  }

  static Future<UserModel> create(UserModel user) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cedula': user.cedula,
        'nombres': user.nombres,
        'apellidos': user.apellidos,
        'email': user.email,
        'telefono': user.telefono,
        'direccion': user.direccion,
        'nacionalidad': user.nacionalidad,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Error creando huésped');
    }
  }

  static Future<UserModel> update(String id, UserModel user) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cedula': user.cedula,
        'nombres': user.nombres,
        'apellidos': user.apellidos,
        'email': user.email,
        'telefono': user.telefono,
        'direccion': user.direccion,
        'nacionalidad': user.nacionalidad,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Error actualizando huésped con id: $id');
    }
  }

  static Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (!(response.statusCode == 200 || response.statusCode == 204)) {
      throw Exception('Error: no se pudo eliminar el huésped con id: $id (status code: ${response.statusCode})');
    }
  }
}