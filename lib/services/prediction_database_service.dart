import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/prediction_history.dart';

/// Service for managing prediction history using local JSON storage
class PredictionDatabaseService {
  static const String _fileName = 'prediction_history.json';
  
  /// Get the file path for storing predictions
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  /// Save a prediction to the database
  Future<void> savePrediction(PredictionHistory prediction) async {
    try {
      final file = await _localFile;
      
      // Read existing predictions
      List<PredictionHistory> predictions = await getAllPredictions();
      
      // Add new prediction at the beginning
      predictions.insert(0, prediction);
      
      // Keep only last 100 predictions to manage storage
      if (predictions.length > 100) {
        predictions = predictions.take(100).toList();
      }
      
      // Convert to JSON and save
      final jsonList = predictions.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      debugPrint('✅ Prediction saved to database: ${prediction.predictedCrop}');
    } catch (e) {
      debugPrint('❌ Error saving prediction: $e');
      rethrow;
    }
  }

  /// Get all predictions from the database
  Future<List<PredictionHistory>> getAllPredictions() async {
    try {
      final file = await _localFile;
      
      // Check if file exists
      if (!await file.exists()) {
        return [];
      }
      
      // Read file contents
      final contents = await file.readAsString();
      
      // Parse JSON
      final jsonList = json.decode(contents) as List;
      return jsonList
          .map((json) => PredictionHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error reading predictions: $e');
      return [];
    }
  }

  /// Get predictions for a specific date range
  Future<List<PredictionHistory>> getPredictionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allPredictions = await getAllPredictions();
    return allPredictions.where((p) {
      return p.timestamp.isAfter(start) && p.timestamp.isBefore(end);
    }).toList();
  }

  /// Get predictions for a specific crop
  Future<List<PredictionHistory>> getPredictionsByCrop(String cropName) async {
    final allPredictions = await getAllPredictions();
    return allPredictions
        .where((p) => p.predictedCrop.toLowerCase() == cropName.toLowerCase())
        .toList();
  }

  /// Get recent predictions (last n)
  Future<List<PredictionHistory>> getRecentPredictions(int count) async {
    final allPredictions = await getAllPredictions();
    return allPredictions.take(count).toList();
  }

  /// Get prediction statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final allPredictions = await getAllPredictions();
    
    if (allPredictions.isEmpty) {
      return {
        'totalPredictions': 0,
        'averageConfidence': 0.0,
        'mostPredictedCrop': 'None',
        'cropsDistribution': <String, int>{},
      };
    }

    // Calculate statistics
    final totalPredictions = allPredictions.length;
    final averageConfidence = allPredictions
        .map((p) => p.confidence)
        .reduce((a, b) => a + b) / totalPredictions;

    // Crop distribution
    final cropCounts = <String, int>{};
    for (var prediction in allPredictions) {
      cropCounts[prediction.predictedCrop] =
          (cropCounts[prediction.predictedCrop] ?? 0) + 1;
    }

    // Most predicted crop
    String mostPredictedCrop = 'None';
    int maxCount = 0;
    cropCounts.forEach((crop, count) {
      if (count > maxCount) {
        maxCount = count;
        mostPredictedCrop = crop;
      }
    });

    return {
      'totalPredictions': totalPredictions,
      'averageConfidence': averageConfidence,
      'mostPredictedCrop': mostPredictedCrop,
      'cropsDistribution': cropCounts,
      'highConfidencePredictions': allPredictions.where((p) => p.confidence >= 0.7).length,
      'lowConfidencePredictions': allPredictions.where((p) => p.confidence < 0.5).length,
    };
  }

  /// Delete a specific prediction by ID
  Future<void> deletePrediction(String id) async {
    try {
      final predictions = await getAllPredictions();
      predictions.removeWhere((p) => p.id == id);
      
      final file = await _localFile;
      final jsonList = predictions.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      debugPrint('✅ Prediction deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting prediction: $e');
      rethrow;
    }
  }

  /// Clear all predictions
  Future<void> clearAllPredictions() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ All predictions cleared');
      }
    } catch (e) {
      debugPrint('❌ Error clearing predictions: $e');
      rethrow;
    }
  }

  /// Export predictions as JSON string
  Future<String> exportPredictionsAsJson() async {
    final predictions = await getAllPredictions();
    final jsonList = predictions.map((p) => p.toJson()).toList();
    return json.encode(jsonList);
  }

  /// Import predictions from JSON string
  Future<void> importPredictionsFromJson(String jsonString) async {
    try {
      final jsonList = json.decode(jsonString) as List;
      final predictions = jsonList
          .map((json) => PredictionHistory.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final file = await _localFile;
      final jsonOutput = predictions.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(jsonOutput));
      
      debugPrint('✅ Predictions imported successfully');
    } catch (e) {
      debugPrint('❌ Error importing predictions: $e');
      rethrow;
    }
  }
}
