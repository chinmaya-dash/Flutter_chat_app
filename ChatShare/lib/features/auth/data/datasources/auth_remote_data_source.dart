// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:chatshare/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl;

  AuthRemoteDataSource({required this.baseUrl});

  Future<UserModel> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({'email':email, 'password':password}),
      headers: {'Content-Type': 'application/json'}
    );

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }

  Future<UserModel> register({required String username, required String email, required String password}) async {
    final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'}
    );

    print(response.body);

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }
}