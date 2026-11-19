import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/resep.dart';

class ApiService {
  static const String apiUrl = 'https://dummyjson.com/recipes';

  static Future<List<Resep>> getResep() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List recipes = data['recipes'];

      return recipes.map((e) => Resep.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  static Future<Resep> getSingleResep(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Resep.fromJson(data);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
