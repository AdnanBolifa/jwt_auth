// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_auth/data/api_config.dart';
import 'package:jwt_auth/data/problem_config.dart';
import 'package:jwt_auth/data/report_config.dart';
import 'package:jwt_auth/data/solution_config.dart';
import 'package:jwt_auth/screens/login.dart';
import 'package:jwt_auth/services/auth_service.dart';

class ApiService {
  Future<void> addReport(String name, acc, phone, place, sector,
      List<int> problems, List<int> solution) async {
    // Create a map to represent the request body
    Map<String, dynamic> requestBody = {
      'name': name,
      'phone': phone,
      'account': acc,
      'place': place,
      'sector': sector,
      'note': 'xzxxxx',
      'problem': problems,
      'solutions': solution,
    };

    final accessToken = await AuthService().getAccessToken();

    final response = await http.post(Uri.parse(APIConfig.addUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 201) {
      print("Report added successfully");
    } else {
      throw Exception('Failed to add report: ${response.statusCode}');
    }
  }

  Future<void> updateReport(
      String name, acc, phone, place, sector, int? id) async {
    // Create a map to represent the request body
    Map<String, dynamic> requestBody = {
      'name': name,
      'phone': phone,
      'account': acc,
      'place': place,
      'sector': sector,
    };

    final accessToken = await AuthService().getAccessToken();
    print('======================');
    print(id);
    final response = await http.put(Uri.parse('${APIConfig.updateUrl}$id/edit'),
        body: jsonEncode(requestBody),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      print("updated updated successfully");
    } else {
      throw Exception('Failed to add report: ${response.statusCode}');
    }
  }

  Future<List<Report>> getReports(context) async {
    final List<Report> users = [];
    final authService = AuthService();

    Future<http.Response> retryApiRequest() async {
      final accessToken = await authService.getAccessToken();
      final response =
          await http.get(Uri.parse(APIConfig.reportsUrl), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 401) {
        await authService.getNewAccessToken();
        return retryApiRequest();
      } else if (response.statusCode != 200) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
        authService.logout();
      }

      return response;
    }

    final response = await retryApiRequest();

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseMap =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = responseMap['results'];

        for (var user in data) {
          final userName = user['name'] as String;
          final mobile = user['phone'] as String;
          final acc = user['account'] as String;
          final sector = user['sector'] as String;
          final place = user['place'] as String;
          final id = user['id'] as int;
          final createdAt = user['created_at'] as String;

          final lastComment = user['last_comment'] != null
              ? user['last_comment']['comment']
              : '';

          users.add(Report(
              userName: userName,
              mobile: mobile,
              acc: acc,
              sector: sector,
              place: place,
              id: id,
              createdAt: createdAt,
              lastComment: lastComment));
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response content: ${response.body}');
    }

    return users;
  }

  Future<List<Problem>> fetchProblems() async {
    List<Problem> problems = [];
    final response = await http.get(Uri.parse(APIConfig.problemsUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseMap =
          jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> results = responseMap['results'];

      for (var item in results) {
        problems.add(Problem.fromJson(item));
      }

      return problems;
    } else {
      throw Exception('Failed to fetch item names');
    }
  }

  Future<List<Solution>> fetchSolutions() async {
    List<Solution> solutions = [];
    final response = await http.get(Uri.parse(APIConfig.solutionsUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseMap =
          jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> results = responseMap['results'];

      for (var item in results) {
        solutions.add(Solution.fromJson(item));
      }

      return solutions;
    } else {
      throw Exception('Failed to fetch item names');
    }
  }
}
