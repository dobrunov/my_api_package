import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exceptions.dart';

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {},
  });

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: {...defaultHeaders, ...?headers});
    return _processResponse(response);
  }

  Future<dynamic> _processResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to decode JSON: $e',
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Error ${response.statusCode}: ${response.body}',
      );
    }
  }
}
