import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppVersionInfo {
  final String status; // 'first_install', 'updated', 'same_version'
  final String version;
  final int versionCode;
  final int? oldVersionCode;

  AppVersionInfo({
    required this.status,
    required this.version,
    required this.versionCode,
    this.oldVersionCode,
  });

  factory AppVersionInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppVersionInfo(
      status: map['status'] as String? ?? 'unknown',
      version: map['version'] as String? ?? 'unknown',
      versionCode: (map['versionCode'] as num?)?.toInt() ?? 0,
      oldVersionCode: (map['oldVersionCode'] as num?)?.toInt(),
    );
  }

  bool get isFirstInstall => status == 'first_install';
  bool get isUpdated => status == 'updated';
  bool get isSameVersion => status == 'same_version';

  @override
  String toString() =>
      'AppVersionInfo(status: $status, version: $version, versionCode: $versionCode, oldVersionCode: $oldVersionCode)';
}

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.klasio/channel');

  static final NativeService _instance = NativeService._internal();
  factory NativeService() => _instance;
  NativeService._internal();

  Future<AppVersionInfo?> getAppVersion() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('get-app-version');
      if (result != null) {
        return AppVersionInfo.fromMap(result);
      }
    } on PlatformException catch (e) {
      debugPrint('Error en getAppVersion: ${e.message}');
    }
    return null;
  }

  Future<File?> optimizeImage(
    String imagePath, {
    int quality = 80,
    int maxWidth = 1920,
    int maxHeight = 2560,
  }) async {
    try {
      final String? newPath = await _channel.invokeMethod<String>('optimizeImage', {
        'imagePath': imagePath,
        'quality': quality,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      });

      if (newPath != null && newPath.isNotEmpty) {
        final file = File(newPath);
        if (await file.exists()) {
          return file;
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Error en optimizeImage: ${e.message}');
    }
    return null;
  }

  Future<String?> optimizeImagePath(
    String imagePath, {
    int quality = 80,
    int maxWidth = 1920,
    int maxHeight = 2560,
  }) async {
    try {
      return await _channel.invokeMethod<String>('optimizeImage', {
        'imagePath': imagePath,
        'quality': quality,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      });
    } on PlatformException catch (e) {
      debugPrint('Error en optimizeImagePath: ${e.message}');
      return null;
    }
  }

  Future<String?> extractTextFromImage(String imagePath) async {
    try {
      return await _channel.invokeMethod<String>('extractTextFromImage', {
        'imagePath': imagePath,
      });
    } on PlatformException catch (e) {
      debugPrint('Error en extractTextFromImage: ${e.message}');
      return null;
    }
  }

  Future<void> restartApp() async {
    try {
      await _channel.invokeMethod('restart_app');
    } on PlatformException catch (e) {
      debugPrint('Error en restartApp: ${e.message}');
    }
  }

  Future<void> installApk(String filePath) async {
    try {
      await _channel.invokeMethod('installApk', {'filePath': filePath});
    } on PlatformException catch (e) {
      debugPrint('Error en installApk: ${e.message}');
    }
  }

  Future<void> saveKeyValue(String key, bool value) async {
    try {
      await _channel.invokeMethod('save-key-value', {
        'key': key,
        'value': value,
      });
    } on PlatformException catch (e) {
      debugPrint('Error en saveKeyValue: ${e.message}');
    }
  }

  Future<bool> getKeyValue(String key) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('get-key-value', {'key': key});
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error en getKeyValue: ${e.message}');
      return false;
    }
  }

  Future<bool> setExecutable(String path) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('setExecutable', {'path': path});
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error en setExecutable: ${e.message}');
      return false;
    }
  }

  Future<List<String>> pickMultipleImages() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod<List<dynamic>>('pickMultipleImages');
      return result?.map((e) => e.toString()).toList() ?? [];
    } on PlatformException catch (e) {
      debugPrint('Error en pickMultipleImages: ${e.message}');
      return [];
    }
  }

  Future<String?> pickFolder() async {
    try {
      return await _channel.invokeMethod<String>('pickFolder');
    } on PlatformException catch (e) {
      debugPrint('Error en pickFolder: ${e.message}');
      return null;
    }
  }

  Future<Uint8List?> getBytesFromUri(String uri) async {
    try {
      final dynamic result = await _channel.invokeMethod('getBytesFromUri', {'uri': uri});
      if (result is Uint8List) {
        return result;
      } else if (result is List<dynamic>) {
        return Uint8List.fromList(result.cast<int>());
      }
    } on PlatformException catch (e) {
      debugPrint('Error en getBytesFromUri: ${e.message}');
    }
    return null;
  }

  Future<void> copyUriToDirectory({
    required String sourceUri,
    required String outputDirPath,
    required String fileName,
  }) async {
    try {
      await _channel.invokeMethod('copyUriToDirectory', {
        'sourceUri': sourceUri,
        'outputDirPath': outputDirPath,
        'fileName': fileName,
      });
    } on PlatformException catch (e) {
      debugPrint('Error en copyUriToDirectory: ${e.message}');
    }
  }

  Future<void> clearCache() async {
    try {
      await _channel.invokeMethod('clearCache');
    } on PlatformException catch (e) {
      debugPrint('Error en clearCache: ${e.message}');
    }
  }

  Future<void> ttsSpeak(
    String text, {
    String language = 'es',
    double pitch = 1.0,
    double rate = 1.0,
  }) async {
    try {
      await _channel.invokeMethod('ttsSpeak', {
        'text': text,
        'language': language,
        'pitch': pitch,
        'rate': rate,
      });
    } on PlatformException catch (e) {
      debugPrint('Error en ttsSpeak: ${e.message}');
    }
  }

  Future<void> ttsStop() async {
    try {
      await _channel.invokeMethod('ttsStop');
    } on PlatformException catch (e) {
      debugPrint('Error en ttsStop: ${e.message}');
    }
  }

  Future<bool> ttsIsSpeaking() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('ttsIsSpeaking');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error en ttsIsSpeaking: ${e.message}');
      return false;
    }
  }

  Future<bool> saveImageToGallery(String imagePath, {String? title}) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('saveImageToGallery', {
        'imagePath': imagePath,
        'title': title ?? 'captura',
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error en saveImageToGallery: ${e.message}');
      return false;
    }
  }

  Future<String?> saveTextToFile(String text, {String? fileName}) async {
    try {
      return await _channel.invokeMethod<String>('saveTextToFile', {
        'text': text,
        'fileName': fileName ?? 'notas.txt',
      });
    } on PlatformException catch (e) {
      debugPrint('Error en saveTextToFile: ${e.message}');
      return null;
    }
  }
}
