import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:noodle/services/storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    if(_refreshToken == null){
      return false;
    } else {
      await refreshToken();
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
      NoodleStorage.saveUsername(username);
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
        if(rememberMe){
          NoodleStorage.saveRefreshToken(_refreshToken!);
          // debugPrint(response.body);
          _resetTokenRefreshTimer();
        }
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
  
  Future<List<FileMetadata>> searchFiles(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?query=$query'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => FileMetadata.fromJson(item)).toList();
    } else {
      throw Exception('Search failed: ${response.statusCode}');
    }
  }

Future<void> uploadInMemory(File file, String serverPath) async {
  // Получаем имя файла из пути
  String fileName = serverPath.split('/').last;
  
  // Проверяем наличие расширения в serverPath
  if (!fileName.contains('.')) {
    // Если расширения нет, добавляем из оригинального файла
    final originalName = file.path.split('/').last;
    final extension = originalName.contains('.') 
        ? '.${originalName.split('.').last}'
        : '';
    fileName = '$fileName$extension';
    
    // Обновляем полный путь
    final pathParts = serverPath.split('/');
    pathParts[pathParts.length - 1] = fileName;
    serverPath = pathParts.join('/');
  }

  final bytes = await file.readAsBytes();
  
  final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));
  
  request.headers['Authorization'] = 'Bearer $accessToken';
  
  request.files.add(http.MultipartFile.fromBytes(
    'file',
    bytes,
    filename: fileName, // Используем обработанное имя файла
  ));
  
  request.fields['filename'] = serverPath; // Полный путь с учетом возможного изменения

  try {
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    
    if (response.statusCode != 200) {
      throw Exception('Upload failed with status ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Upload error: $e');
    rethrow; // Пробрасываем исключение дальше для обработки
  }
}

Future<bool> deleteFile({
  required String filePath,
}) async {
  try {
    // 1. Формируем URL с query-параметром
    final uri = Uri.parse('$_baseUrl/delete_file').replace(
      queryParameters: {'filename': filePath},
    );

    // 2. Отправляем DELETE запрос
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // 3. Обрабатываем ответ
    if (response.statusCode == 200) {
      debugPrint('File deleted successfully: $filePath');
      return true;
    } else if (response.statusCode == 404) {
      debugPrint('File not found: $filePath');
      return false;
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to delete file: ${errorData['detail']}');
    }
  } on http.ClientException catch (e) {
    debugPrint('Network error while deleting file: $e');
    return false;
  } on FormatException catch (e) {
    debugPrint('Invalid server response: $e');
    return false;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    return false;
  }
}

Future<bool> deleteFolder({
  required String folderPath,
}) async {
  try {
    // 1. Проверяем, что путь не пустой (соответствует min_length=1 на сервере)
    if (folderPath.isEmpty) {
      throw ArgumentError('Folder path cannot be empty');
    }

    // 2. Формируем URL с query-параметром
    final uri = Uri.parse('$_baseUrl/delete_folder').replace(
      queryParameters: {'folder_path': folderPath},
    );

    // 3. Отправляем DELETE запрос
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // 4. Обрабатываем ответ
    if (response.statusCode == 200) {
      debugPrint('Folder deleted successfully: $folderPath');
      return true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to delete folder: ${errorData['detail'] ?? 'Unknown error'}');
    }
  } on ArgumentError catch (e) {
    debugPrint('Validation error: $e');
    return false;
  } on http.ClientException catch (e) {
    debugPrint('Network error while deleting folder: $e');
    return false;
  } on FormatException catch (e) {
    debugPrint('Invalid server response: $e');
    return false;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    return false;
  }
}

Future<bool> renameFile({
  required String currentPath,
  required String newName,
}) async {
  try {
    // 1. Проверяем и нормализуем параметры
    if (currentPath.isEmpty || newName.isEmpty) {
      throw ArgumentError('Path and new name cannot be empty');
    }

    // 2. Формируем новый путь (заменяем последнюю часть пути)
    final pathParts = currentPath.split('/');
    pathParts.removeLast(); // Удаляем старое имя файла
    final newPath = '${pathParts.join('/')}/$newName';

    // 3. Формируем тело запроса
    final requestBody = json.encode({
      'source_path': currentPath,
      'destination_path': newPath,
    });

    // 4. Отправляем PUT запрос
    final response = await http.put(
      Uri.parse('$_baseUrl/move_file'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    // 5. Обрабатываем ответ
    if (response.statusCode == 200) {
      debugPrint('File renamed from $currentPath to $newPath');
      return true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to rename file: ${errorData['detail'] ?? 'Unknown error'}');
    }
  } on ArgumentError catch (e) {
    debugPrint('Validation error: $e');
    return false;
  } on http.ClientException catch (e) {
    debugPrint('Network error while renaming file: $e');
    return false;
  } on FormatException catch (e) {
    debugPrint('Invalid server response: $e');
    return false;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    return false;
  }
}

Future<File?> downloadFileToDownloads({
  required String filePath,
}) async {
  try {
    // 1. Проверка разрешений (сохраняя ваш стиль)
    if (!await _requestStoragePermission()) {
      debugPrint('Storage permission not granted');
      return null;
    }

    // 2. Получение директории загрузок (как в вашем коде)
    final Directory? downloadsDir = await _getDownloadsDirectory();
    if (downloadsDir == null) {
      debugPrint('Downloads directory not available');
      return null;
    }

    // 3. Формирование URL (ваш вариант с небольшой оптимизацией)
    final uri = Uri.parse('$_baseUrl/download').replace(
      queryParameters: {'filename': filePath},
    );

    // 4. Отправка запроса (сохраняя ваши заголовки)
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    // 5. Обработка ответа (ваш стиль с дополнительным логированием)
    if (response.statusCode == 200) {
      final fileName = filePath.split('/').last;
      final file = File('${downloadsDir.path}/$fileName');
      
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('File saved to: ${file.path}');
      
      return file;
    } else {
      debugPrint('Server error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Download failed: $e');
    return null;
  }
}

Future<bool> _requestStoragePermission() async {
  if (!Platform.isAndroid) return true;

  try {
    // Упрощенная проверка для Android (сохраняя вашу логику)
    if (await Permission.storage.isGranted) return true;
    
    final status = await Permission.storage.request();
    if (status.isGranted) return true;

    // Дополнительная проверка для Android 11+
    if (await Permission.manageExternalStorage.isGranted) return true;
    
    final managerStatus = await Permission.manageExternalStorage.request();
    if (managerStatus.isGranted) return true;

    await openAppSettings();
    return false;
  } catch (e) {
    debugPrint('Permission error: $e');
    return false;
  }
}

Future<Directory?> _getDownloadsDirectory() async {
  try {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir;
      return await getExternalStorageDirectory();
    }
    return await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  } catch (e) {
    debugPrint('Directory error: $e');
    return null;
  }
}

  Future<void> createFolder(String folderPath) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/create_folder'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization' : 'Bearer ${accessToken}'
          },
          body: jsonEncode(folderPath)
            // body: jsonEncode(_refreshToken)
        );
    
    
      
      if ((response.statusCode / 100).round()  == 2) {
        debugPrint("${response.statusCode},${response.body}");
      }else{
        throw Exception('Folder creating failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Folder creating error: $e');
    }
  }

  Future<List<dynamic>> listFiles({
    required String path,
  }) async {
    
    try {
      Uri  uri = Uri.parse("$_baseUrl/list");

      if(path.isNotEmpty){
        uri = uri.replace(
          queryParameters: {'path': path},
        );
      }
      debugPrint("api get: ${uri}");
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        
        final List<dynamic> parsedList = json.decode(response.body);

        // 2. Преобразуем каждый элемент в Map вручную
        final List<Map<String, dynamic>> items = parsedList.map((dynamic item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            throw FormatException('Элемент не является Map<String, dynamic>', item);
          }
        }).toList();

        debugPrint("List body: ${response.body}");  
        List<AbstractMeta> metaList = items.map((item) {
          return item.containsKey('is_folder')
              ? FolderMetadata.fromJson(item)
              : FileMetadata.fromJson(item);
        }).toList();
        return metaList;
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


  Future<void> logout() async {
    if (_refreshToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "refresh_token":_refreshToken
        })
          // body: jsonEncode(_refreshToken)
      );

      if ((response.statusCode / 100).round()  == 2) {
        _accessToken = null;
        _refreshToken = null;
        NoodleStorage.deleteRefreshToken();
        _tokenRefreshTimer?.cancel();
        debugPrint("${response.statusCode},${response.body}");
      } else {
        debugPrint("${response.statusCode},${response.body}");
      }
    } catch (e) {
      debugPrint('Log out error: $e');
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
        body: jsonEncode({
          "refresh_token":_refreshToken
        })
          // body: jsonEncode(_refreshToken)
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