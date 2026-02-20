import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  String get _backendUrl {
    if (kReleaseMode) {
      // TODO: Replace with production URL
      return 'http://your-production-url.com';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loginWithKakao() async {
    try {
      _isLoading = true;
      notifyListeners();

      final url = '$_backendUrl/api/auth/kakao?platform=mobile';
      final callbackUrlScheme = 'heartsignal';

      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
      );

      // Extract token from result URL
      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];
      // Assuming backend redirects to heartsignal://callback?token=...

      if (token != null) {
        await _saveToken(token);
        await _fetchCurrentUser(token);
      } else {
        throw Exception('Token not found in callback URL');
      }
    } catch (e) {
      debugPrint('Kakao Login Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$_backendUrl/api/auth/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      await _storage.delete(key: 'auth_token');
      _currentUser = null;
    } catch (e) {
      debugPrint('Logout Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      final token = await _getToken();
      if (token != null) {
        await _fetchCurrentUser(token);
      }
    } catch (e) {
      debugPrint('Check Login Status Error: $e');
      // If fetch failed (e.g. invalid token), clear token
      await _storage.delete(key: 'auth_token');
      _currentUser = null;
    }
  }

  Future<void> _fetchCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$_backendUrl/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        _currentUser = User.fromJson(jsonResponse['data']);
        debugPrint(
          'CurrentUser loaded: ${_currentUser?.isOnboarded}',
        ); // Debug log
        notifyListeners();
      } else {
        throw Exception('Failed to parse user data: ${response.body}');
      }
    } else {
      throw Exception('Failed to fetch user info');
    }
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> completeOnboarding(
    String guardianContact,
    String birthdate,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.patch(
        Uri.parse('$_backendUrl/api/users/me/onboarding'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'guardian_contact': guardianContact,
          'birthdate': birthdate,
        }),
      );

      if (response.statusCode == 200) {
        await _fetchCurrentUser(token);
      } else {
        throw Exception('Failed to complete onboarding: ${response.body}');
      }
    } catch (e) {
      debugPrint('Onboarding Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      if (token != null) {
        final response = await http.delete(
          Uri.parse('$_backendUrl/api/users/me'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to delete account: ${response.body}');
        }
      }

      await _storage.delete(key: 'auth_token');
      _currentUser = null;
    } catch (e) {
      debugPrint('Delete Account Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
