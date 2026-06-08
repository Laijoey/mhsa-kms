import 'dart:convert';
import 'package:http/http.dart' as http;
import '../expert_system/expert_system.dart';

// Configuration
const String _baseUrl = 'http://localhost:3000/api/v1';

// Exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// Models
class AuthSession {
  final String token;
  final String userId;
  final String role;
  final String name;

  AuthSession({
    required this.token,
    required this.userId,
    required this.role,
    required this.name,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
    );
  }
}

class RecommendationResult {
  final String title;
  final String body;
  final List<String> actions;

  RecommendationResult({
    required this.title,
    required this.body,
    required this.actions,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    return RecommendationResult(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      actions: List<String>.from(json['actions'] as List? ?? []),
    );
  }
}

class AssessmentResult {
  final String id;
  final String takenAt;
  final Map<String, int> normalisedScores;
  final Map<String, String> severities;
  final String firedRuleId;
  final String riskLevel;
  final RecommendationResult recommendation;
  final List<String> appliedTacitRules;

  AssessmentResult({
    required this.id,
    required this.takenAt,
    required this.normalisedScores,
    required this.severities,
    required this.firedRuleId,
    required this.riskLevel,
    required this.recommendation,
    required this.appliedTacitRules,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] as String? ?? '',
      takenAt: json['takenAt'] as String? ?? '',
      normalisedScores: {
        'dep': json['normalisedScores']['dep'] as int? ?? 0,
        'anx': json['normalisedScores']['anx'] as int? ?? 0,
        'str': json['normalisedScores']['str'] as int? ?? 0,
      },
      severities: {
        'dep': json['severities']['dep'] as String? ?? 'Normal',
        'anx': json['severities']['anx'] as String? ?? 'Normal',
        'str': json['severities']['str'] as String? ?? 'Normal',
      },
      firedRuleId: json['firedRuleId'] as String? ?? '',
      riskLevel: json['riskLevel'] as String? ?? 'NORMAL',
      recommendation: RecommendationResult.fromJson(json['recommendation'] ?? {}),
      appliedTacitRules: List<String>.from(json['appliedTacitRules'] ?? []),
    );
  }
}

class ProgressEntry {
  final String takenAt;
  final int dep;
  final int anx;
  final int str;
  final String riskLevel;

  ProgressEntry({
    required this.takenAt,
    required this.dep,
    required this.anx,
    required this.str,
    required this.riskLevel,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    return ProgressEntry(
      takenAt: json['takenAt'] as String? ?? '',
      dep: json['normalisedScores']['dep'] as int? ?? 0,
      anx: json['normalisedScores']['anx'] as int? ?? 0,
      str: json['normalisedScores']['str'] as int? ?? 0,
      riskLevel: json['riskLevel'] as String? ?? 'NORMAL',
    );
  }
}

// API Service
class ApiService {
  static AuthSession? _session;

  static AuthSession? get session => _session;
  static bool get isAuthenticated => _session != null;

  static Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_session != null) 'Authorization': 'Bearer ${_session!.token}',
  };

  // Auth
  static Future<AuthSession> login({
    required String role,
    required String identifier,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      '/auth/login',
      body: {
        'role': role,
        'identifier': identifier,
        'password': password,
      },
    );

    _session = AuthSession.fromJson(response);
    return _session!;
  }

  static void logout() {
    _session = null;
  }

  // Assessments
  /// Submit assessment to backend with fallback to local expert system
  static Future<AssessmentResult> submitAssessment(
    List<int> rawAnswers, {
    bool useLocalFallback = true,
  }) async {
    try {
      // Try backend first (primary)
      final response = await _request(
        'POST',
        '/assessments',
        body: {'rawAnswers': rawAnswers},
      );
      return AssessmentResult.fromJson(response);
    } catch (e) {
      // Fallback to local expert system if backend fails
      if (useLocalFallback) {
        print('⚠️ Backend failed: $e. Using local expert system...');
        return _useLocalExpertSystem(rawAnswers);
      }
      rethrow;
    }
  }

  /// Use local expert system (11 sophisticated rules)
  static AssessmentResult _useLocalExpertSystem(List<int> rawAnswers) {
    final result = ExpertSystem.process(rawAnswers);

    return AssessmentResult(
      id: 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
      takenAt: DateTime.now().toIso8601String(),
      normalisedScores: {
        'dep': result['normalisedScores']['depression'] as int,
        'anx': result['normalisedScores']['anxiety'] as int,
        'str': result['normalisedScores']['stress'] as int,
      },
      severities: {
        'dep': result['severities']['depression'] as String,
        'anx': result['severities']['anxiety'] as String,
        'str': result['severities']['stress'] as String,
      },
      firedRuleId: result['firedRuleId'] as String,
      riskLevel: result['riskLevel'] as String,
      recommendation: RecommendationResult(
        title: result['recommendation']['title'] as String,
        body: result['recommendation']['body'] as String,
        actions: List<String>.from(result['recommendation']['actions'] as List),
      ),
      appliedTacitRules: List<String>.from(result['appliedTacitRules'] as List),
    );
  }

  static Future<List<AssessmentResult>> getMyHistory() async {
    final response = await _request('GET', '/assessments/me');
    return (response as List)
        .map((item) => AssessmentResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getHighRiskQueue() async {
    final response = await _request('GET', '/assessments/high-risk');
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }

  static Future<Map<String, dynamic>> getCampusAnalytics() async {
    return await _request('GET', '/analytics/campus');
  }

  // Resources
  static Future<List<Map<String, dynamic>>> getResources() async {
    final response = await _request('GET', '/resources');
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }

  static Future<Map<String, dynamic>> createResource(Map<String, dynamic> data) async {
    return await _request('POST', '/resources', body: data);
  }

  static Future<void> updateResource(String id, Map<String, dynamic> data) async {
    await _request('PUT', '/resources/$id', body: data);
  }

  static Future<void> deleteResource(String id) async {
    await _request('DELETE', '/resources/$id');
  }

  // Rules
  static Future<List<Map<String, dynamic>>> getRules() async {
    final response = await _request('GET', '/rules');
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }

  static Future<void> updateRule(String id, Map<String, dynamic> data) async {
    await _request('PUT', '/rules/$id', body: data);
  }

  // Private helper
  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');

      late http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: _authHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _authHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _authHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _authHeaders);
          break;
        default:
          throw ApiException(400, 'Unknown HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }

      // Parse error response
      String errorMessage = 'Unknown error';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['error'] as String? ?? errorMessage;
      } catch (e) {
        errorMessage = response.body;
      }

      throw ApiException(response.statusCode, errorMessage);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Network error: $e');
    }
  }
}
