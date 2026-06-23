import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Handles authentication: login, register, auto-login, logout.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _api = ApiService();

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _api.isLoggedIn && _currentUser != null;

  /// Try auto-login from stored token.
  Future<bool> tryAutoLogin() async {
    await _api.init();
    if (!_api.isLoggedIn) return false;
    try {
      _currentUser = Map<String, dynamic>.from(await _api.get('/api/auth/me'));
      return true;
    } catch (_) {
      await _api.clearToken();
      return false;
    }
  }

  /// Login with email + password.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    await _api.setToken(data['token']);
    _currentUser = Map<String, dynamic>.from(data['user']);
    return _currentUser!;
  }

  /// Register a new account.
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final data = await _api.post('/api/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    await _api.setToken(data['token']);
    _currentUser = Map<String, dynamic>.from(data['user']);
    return _currentUser!;
  }

  /// Logout: clear token + user.
  Future<void> logout() async {
    await _api.clearToken();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  /// Refresh current user from server.
  Future<Map<String, dynamic>> refreshUser() async {
    _currentUser = Map<String, dynamic>.from(await _api.get('/api/auth/me'));
    return _currentUser!;
  }

  /// Update profile.
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? bio,
    String? location,
    String? website,
  }) async {
    _currentUser = Map<String, dynamic>.from(await _api.put('/api/profile', body: {
      'name': name,
      'bio': bio ?? '',
      'location': location ?? '',
      'website': website ?? '',
    }));
    return _currentUser!;
  }
}
