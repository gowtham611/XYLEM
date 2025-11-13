import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/sensor_data_provider.dart';
import 'onnx_runtime_service.dart';

class CropPrediction {
  final String cropName;
  final double confidence;
  final List<AlternativeCrop> alternativeCrops;
  final List<AlternativeCrop> top3Crops;
  final SoilCondition soilCondition;

  CropPrediction({
    required this.cropName,
    required this.confidence,
    required this.alternativeCrops,
    required this.top3Crops,
    required this.soilCondition,
  });
}

class AlternativeCrop {
  final String name;
  final double confidence;

  AlternativeCrop({required this.name, required this.confidence});
}

class SoilCondition {
  final String overall;
  final List<String> issues;
  final List<String> recommendations;

  SoilCondition({
    required this.overall,
    required this.issues,
    required this.recommendations,
  });
}

class MLService {
  bool _isInitialized = false;
  static const String weatherApiKey = "f932ac201c369d916c02400fd855bf85";

  static const List<String> cropLabels = [
    'rice', 'maize', 'chickpea', 'kidneybeans', 'pigeonpeas',
    'mothbeans', 'mungbean', 'blackgram', 'lentil', 'pomegranate',
    'banana', 'mango', 'grapes', 'watermelon', 'muskmelon', 'apple',
    'orange', 'papaya', 'coconut', 'cotton', 'jute', 'coffee'
  ];

  /// Initialize ONNX model
  Future<void> initializeModel() async {
    if (_isInitialized) return;

    try {
      final modelPath = await OnnxRuntimeService.ensureModelFile(
        "assets/models/crop_prediction_model_ir9.onnx",
      );

      debugPrint("🧠 Initializing ONNX model from: $modelPath");
      final ok = await OnnxRuntimeService.initialize(modelPath);

      _isInitialized = ok;
      if (ok) {
        debugPrint("✅ ONNX model initialized successfully.");
      } else {
        debugPrint("❌ ONNX model initialization failed.");
      }
    } catch (e) {
      debugPrint("❌ ONNX init error: $e");
      _isInitialized = false;
    }
  }

  /// Fetch rainfall from OpenWeather API
  Future<double?> getRainfall(double lat, double lon) async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$weatherApiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint("⚠️ Rainfall API error: ${response.statusCode}");
        return null;
      }

      final data = json.decode(response.body);

      if (data["rain"] != null && data["rain"]["1h"] != null) {
        return (data["rain"]["1h"] as num).toDouble();
      }

      if (data["rain"] != null && data["rain"]["3h"] != null) {
        return (data["rain"]["3h"] as num).toDouble() / 3.0;
      }

      debugPrint("ℹ️ No rain data, fallback = 0 mm");
      return 0.0;
    } catch (e) {
      debugPrint("❌ Rainfall fetch error: $e");
      return null;
    }
  }

  /// Main prediction
  Future<CropPrediction> predictCrop(SensorData data, double? rainfall) async {
    if (!_isInitialized) {
      await initializeModel();
      if (!_isInitialized) return _fallbackPrediction(data);
    }

    try {
      rainfall ??= 0.0;
      debugPrint("🌧️ Using rainfall = $rainfall mm");

      /// Order MUST match model: N, P, K, temp, humidity, pH, rainfall
      final inputs = <double>[
        data.nitrogen,
        data.phosphorus,
        data.potassium,
        data.temperature,
        data.humidity,
        data.ph,
        rainfall,
      ];

      final shape = [1, 7];
      debugPrint("🌾 Sending inputs to ONNX: $inputs, shape: $shape");

      final output = await OnnxRuntimeService.predict(
        inputs: inputs,
        shape: shape,
        inputName: "float_input",
      );

      if (output.isEmpty) return _fallbackPrediction(data);

      debugPrint("🧩 Raw ONNX output: $output");

      final probs = output;
      final maxVal = probs.reduce((a, b) => a > b ? a : b);
      final maxIdx = probs.indexOf(maxVal);

      final cropName =
      maxIdx >= 0 && maxIdx < cropLabels.length ? cropLabels[maxIdx] : "unknown";

      debugPrint("🌱 Final Prediction: $cropName (confidence=$maxVal)");

      /// Top 3 predicted crops
      final top3 = _extractTop3(probs, maxIdx);

      return CropPrediction(
        cropName: cropName,
        confidence: maxVal,
        alternativeCrops: _getAlternativeCrops(data),
        top3Crops: top3,
        soilCondition: _analyzeSoilCondition(data),
      );
    } catch (e) {
      debugPrint("❌ ONNX prediction error: $e");
      return _fallbackPrediction(data);
    }
  }

  /// -------- TOP-3 FIXED VERSION --------
  List<AlternativeCrop> _extractTop3(List<double> probs, int predictedIdx) {
    final indexed = List.generate(
      probs.length,
          (i) => {"idx": i, "prob": probs[i]},
    );

    indexed.sort(
          (a, b) =>
          (b["prob"] as double).compareTo(a["prob"] as double),
    );

    return indexed
        .take(3)
        .where((e) => (e["idx"] as int) != predictedIdx)
        .map(
          (e) => AlternativeCrop(
        name: cropLabels[e["idx"] as int],
        confidence: (e["prob"] as double),
      ),
    )
        .toList();
  }

  /// Fallback rule-based prediction
  CropPrediction _fallbackPrediction(SensorData data) {
    return CropPrediction(
      cropName: "cotton",
      confidence: 0.5,
      alternativeCrops: _getAlternativeCrops(data),
      top3Crops: [],
      soilCondition: _analyzeSoilCondition(data),
    );
  }

  List<AlternativeCrop> _getAlternativeCrops(SensorData data) {
    return [
      AlternativeCrop(name: "maize", confidence: 0.35),
      AlternativeCrop(name: "wheat", confidence: 0.30),
      AlternativeCrop(name: "pigeonpeas", confidence: 0.25),
    ];
  }

  SoilCondition _analyzeSoilCondition(SensorData data) {
    List<String> issues = [];
    String overall = "optimal";

    if (data.ph < 6.0 || data.ph > 7.5) issues.add("pH imbalance detected");
    if (data.moisture < 30) issues.add("Low soil moisture");
    if (data.nitrogen < 40) issues.add("Low nitrogen levels");

    if (issues.length > 2) {
      overall = "critical";
    } else if (issues.isNotEmpty) {
      overall = "warning";
    }

    return SoilCondition(
      overall: overall,
      issues: issues,
      recommendations: _getRecommendations(issues),
    );
  }

  List<String> _getRecommendations(List<String> issues) {
    List<String> rec = [];

    if (issues.any((e) => e.contains("pH"))) rec.add("Apply lime or sulfur");
    if (issues.any((e) => e.contains("moisture"))) rec.add("Adjust irrigation schedule");
    if (issues.any((e) => e.contains("nitrogen"))) {
      rec.add("Apply nitrogen-based fertilizer");
    }

    return rec;
  }
}
