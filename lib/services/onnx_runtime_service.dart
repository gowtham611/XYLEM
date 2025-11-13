import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, MethodChannel, PlatformException;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class OnnxRuntimeService {
  static const MethodChannel _channel = MethodChannel('oggrow/onnx_runtime');

  /// Check if ONNX Runtime is available and return version info.
  static Future<Map<String, dynamic>> checkOrt() async {
    try {
      final res = await _channel.invokeMethod('checkOrt');
      return {
        'available': true,
        'message': res?.toString() ?? 'Unknown response',
      };
    } on PlatformException catch (e) {
      return {'available': false, 'error': e.message ?? 'Platform exception'};
    }
  }

  /// Copies an asset model to a writable path and returns the file path.
  static Future<String> ensureModelFile(String assetPath, {String? filename}) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final dir = await getApplicationSupportDirectory();
    final outFile = File('${dir.path}/${filename ?? assetPath.split('/').last}');
    await outFile.writeAsBytes(bytes, flush: true);
    return outFile.path;
  }

  /// Initialize native ONNX runtime with a local model path.
  static Future<bool> initialize(String modelFilePath) async {
    try {
      final res = await _channel.invokeMethod('initialize', {'modelPath': modelFilePath});
      debugPrint('🧠 ONNX initialize response: $res');

      // ✅ Handle both String and bool results safely
      if (res == true) return true;
      if (res is String && res.toLowerCase().contains('success')) return true;

      return false;
    } on PlatformException catch (e) {
      debugPrint('❌ ONNX initialize error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected ONNX init error: $e');
      return false;
    }
  }

  /// Predict by sending a flat list of doubles and the shape.
  static Future<List<double>> predict({
    required List<double> inputs,
    required List<int> shape,
    String? inputName,
  }) async {
    final args = <String, dynamic>{
      'inputs': inputs,
      'shape': shape,
      'inputName': inputName,
    };

    try {
      final res = await _channel.invokeMethod<List<dynamic>>('predict', args);
      if (res == null) return <double>[];
      return res.map((e) => (e as num).toDouble()).toList();
    } on PlatformException catch (e) {
      debugPrint('❌ ONNX predict error: ${e.message}');
      return <double>[];
    } catch (e) {
      debugPrint('❌ Unexpected ONNX predict error: $e');
      return <double>[];
    }
  }

  /// Dispose ONNX resources
  static Future<bool> dispose() async {
    try {
      final res = await _channel.invokeMethod('dispose');
      debugPrint('🧹 ONNX dispose response: $res');
      if (res == true) return true;
      if (res is String && res.toLowerCase().contains('disposed')) return true;
      return false;
    } on PlatformException catch (e) {
      debugPrint('⚠️ ONNX dispose error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('⚠️ Unexpected dispose error: $e');
      return false;
    }
  }
}
