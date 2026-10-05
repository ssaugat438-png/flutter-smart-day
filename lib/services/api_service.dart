import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/remote_task.dart';

/// Independent service demonstrating REST API consumption using [http.Client].
/// Core reminder scheduling remains 100% offline and never depends on this service.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches remote sample tasks from JSONPlaceholder.
  Future<List<RemoteTask>> fetchRemoteTasks({int limit = 10}) async {
    try {
      final uri = Uri.parse(AppConstants.demoApiUrl);
      debugPrint('ApiService: Requesting $uri ...');

      final response = await _client.get(uri).timeout(
            const Duration(seconds: 8),
            onTimeout: () =>
                throw TimeoutException('Request timed out. Please check your connection.'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        final tasks = jsonList
            .take(limit)
            .map((item) => RemoteTask.fromJson(item as Map<String, dynamic>))
            .toList();
        debugPrint('ApiService: Loaded ${tasks.length} remote tasks.');
        return tasks;
      } else {
        throw HttpException(
            'Failed to fetch tasks (HTTP ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException(
          'Network unavailable. SmartDay works offline, but internet is needed for this demo.');
    } catch (e) {
      debugPrint('ApiService.fetchRemoteTasks error: $e');
      rethrow;
    }
  }
}
