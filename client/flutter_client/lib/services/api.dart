import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:noodle/services/storage.dart';

import 'package:noodle/structs/meta_data_structs.dart';

import 'dart:io';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _baseUrl = const String.fromEnvironment('API_URL');
    if (_baseUrl.isEmpty) {
      throw Exception('API_URL is not defined in dart-define');
    }
    
  }

  
  Future<bool> tryStartSession() async {
    _refreshToken = await NoodleStorage.getRefreshToken();
    print("Acces tok before: ${accessToken}, ${_refreshToken}");
    if(_refreshToken == null){
      return false;
    } else {
      await refreshToken();
      print("Acces tok after: ${accessToken}, ${_refreshToken}");
      _initTokenRefreshTimer();
      return true;
    }
  }

  bool checkSession(){
    return _refreshToken != null;
  }

  late final String _baseUrl;
  String? _accessToken;
  String? _refreshToken;
  Timer? _tokenRefreshTimer;

  Future<bool> register(String username, String password, bool rememberMe) async {

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': hashPassword(password),
        }),
      );

      if ((response.statusCode / 100).round() == 2) {
        return await login(username, password, rememberMe);
        
      } else {
        throw Exception('Registration failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      
      rethrow;
    }
  }

  Future<bool> login(String username, String password, bool rememberMe) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': hashPassword(password),
          'remember_me': rememberMe,
        }),
      );

      if ((response.statusCode / 100).round()  == 2) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        // debugPrint('Response: ${data}');
        NoodleStorage.saveRefreshToken(_refreshToken!);
        // print(response.body);
        _resetTokenRefreshTimer();
        return true;
      } else {
        
        throw Exception('Login failed: ${response.statusCode}, ${response.body}');
        
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  Future<void> uploadInMemory(File file, String serverPath) async {
    final fullPath = serverPath;
    final bytes = await file.readAsBytes();
    
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));
    
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization' : 'Bearer ${accessToken}'
    });
    print("Headers: ${accessToken}");
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fullPath,
    ));
    
    try {
      final response = await request.send();
      
      // Читаем ответ сервера
      final responseData = await response.stream.bytesToString();
      
      print('Status: ${response.statusCode}');
      print('Response: $responseData');
    } catch (e) {
      print('Upload error: $e');
    }
  }

  Future<List<dynamic>> listFiles({
    String path = "",
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/list").replace(
        queryParameters: {'path': path},
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = json.decode(response.body);
        debugPrint(response.body);
        return items.map((item) {
          return item['type'] == 'file'
              ? FileMetadata.fromJson(item)
              : FolderMetadata.fromJson(item);
        }).toList();
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid server response: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> refreshToken() async {
    if (_refreshToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        // body: jsonEncode({
        //   "access_token":_refreshToken
        // })
          body: jsonEncode(_refreshToken)
      );

      if ((response.statusCode / 100).round()  == 2) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        debugPrint("${response.statusCode},${response.body}");
      } else {
        debugPrint("${response.statusCode},${response.body}");
        _accessToken = null;
        _refreshToken = null;
        NoodleStorage.deleteRefreshToken();
        _tokenRefreshTimer?.cancel();
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      _accessToken = null;
      _tokenRefreshTimer?.cancel();
    }
  }

  void _initTokenRefreshTimer() {
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (_accessToken != null) {
        refreshToken();
      }
    });
  }

  void _resetTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _initTokenRefreshTimer();
  }

  String? get accessToken => _accessToken;

  void dispose() {
    _tokenRefreshTimer?.cancel();
  }
}