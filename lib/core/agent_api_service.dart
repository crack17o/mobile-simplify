import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service API Agent (Simplify).
/// Base: https://simplify-back.onrender.com ou localhost:8000
/// Pour MVP: mock si baseUrl vide ou appel échoue.
class AgentApiService {
  static const String _baseUrl = 'https://simplify-back.onrender.com';

  final String? accessToken;
  final bool useMock;

  AgentApiService({this.accessToken, this.useMock = true});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  /// POST /api/auth/login/ — username + password
  Future<Map<String, dynamic>?> login({required String username, required String password}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final isAgent = password == '1234' || username.contains('agent');
      return {
        'access': 'mock_jwt_${username}_${DateTime.now().millisecondsSinceEpoch}',
        'refresh': 'mock_refresh_$username',
        'user': {
          'id': isAgent ? 2 : 1,
          'username': username,
          'email': '$username@example.com',
          'role': isAgent ? 'AGENT' : 'ADMIN',
          'phone': '',
          'is_active': true,
        },
      };
    }
    try {
      final r = await http.post(
        Uri.parse('$_baseUrl/api/auth/login/'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  /// POST /api/agent/customers/ — créer un client
  Future<Map<String, dynamic>?> createCustomer({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? email,
    String? initialPin,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'id': 'C${DateTime.now().millisecondsSinceEpoch % 10000}', 'phone_number': phoneNumber, 'first_name': firstName, 'last_name': lastName};
    }
    try {
      final body = <String, dynamic>{
        'phone_number': phoneNumber,
        'first_name': firstName,
        'last_name': lastName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (initialPin != null && initialPin.length == 4) 'initial_pin': initialPin,
      };
      final r = await http.post(
        Uri.parse('$_baseUrl/api/agent/customers/'),
        headers: _headers,
        body: jsonEncode(body),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  /// GET /api/agent/customers/?phone=...&search=...
  Future<List<Map<String, dynamic>>> getCustomers({String? phone, String? search}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return [
        {'id': 1, 'phone_number': '243812345678', 'first_name': 'Jean', 'last_name': 'Mukendi', 'email': 'jean@example.com'},
        {'id': 2, 'phone_number': '243899887766', 'first_name': 'Marie', 'last_name': 'Kabila', 'email': null},
      ].where((c) {
        if (phone != null && phone.isNotEmpty) return (c['phone_number'] as String).contains(phone);
        if (search != null && search.isNotEmpty) {
          final s = search.toLowerCase();
          return (c['first_name'] as String).toLowerCase().contains(s) ||
              (c['last_name'] as String).toLowerCase().contains(s) ||
              (c['phone_number'] as String).contains(s);
        }
        return true;
      }).toList();
    }
    try {
      var uri = Uri.parse('$_baseUrl/api/agent/customers/');
      if (phone != null || search != null) {
        uri = uri.replace(queryParameters: {
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (search != null && search.isNotEmpty) 'search': search,
        });
      }
      final r = await http.get(uri, headers: _headers);
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data['results'] != null) return List<Map<String, dynamic>>.from((data['results'] as List).map((e) => e as Map<String, dynamic>));
      }
    } catch (_) {}
    return [];
  }

  /// POST /api/agent/wallet/deposit/
  Future<Map<String, dynamic>?> deposit({required String phone, required double amount, String? reference}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {'status': 'success', 'reference': reference ?? 'DEP-${DateTime.now().millisecondsSinceEpoch}', 'amount': amount};
    }
    try {
      final body = <String, dynamic>{'phone': phone, 'amount': amount, if (reference != null && reference.isNotEmpty) 'reference': reference};
      final r = await http.post(Uri.parse('$_baseUrl/api/agent/wallet/deposit/'), headers: _headers, body: jsonEncode(body));
      if (r.statusCode >= 200 && r.statusCode < 300) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  /// POST /api/agent/wallet/withdraw/
  Future<Map<String, dynamic>?> withdraw({required String phone, required double amount, String? reference}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {'status': 'success', 'reference': reference ?? 'WDR-${DateTime.now().millisecondsSinceEpoch}', 'amount': amount};
    }
    try {
      final body = <String, dynamic>{'phone': phone, 'amount': amount, if (reference != null && reference.isNotEmpty) 'reference': reference};
      final r = await http.post(Uri.parse('$_baseUrl/api/agent/wallet/withdraw/'), headers: _headers, body: jsonEncode(body));
      if (r.statusCode >= 200 && r.statusCode < 300) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  /// GET /api/wallet/summary/?phone=<phone>
  Future<Map<String, dynamic>?> getWalletSummary(String phone) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'balance_cdf': 1250000, 'balance_usd': 450, 'currency': 'CDF'};
    }
    try {
      final r = await http.get(Uri.parse('$_baseUrl/api/wallet/summary/').replace(queryParameters: {'phone': phone}), headers: _headers);
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  /// GET /api/score/?phone=<phone>
  Future<Map<String, dynamic>?> getScore(String phone) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'score': 65, 'risk_band': 'B', 'recommended_max_loan': 300000};
    }
    try {
      final r = await http.get(Uri.parse('$_baseUrl/api/score/').replace(queryParameters: {'phone': phone}), headers: _headers);
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  /// GET /api/loans/eligibility/?phone=<phone>
  Future<Map<String, dynamic>?> getEligibility(String phone) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'eligible': true, 'score': 65, 'max_loan': 300000, 'guarantee_percent': 10};
    }
    try {
      final r = await http.get(Uri.parse('$_baseUrl/api/loans/eligibility/').replace(queryParameters: {'phone': phone}), headers: _headers);
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }
}
