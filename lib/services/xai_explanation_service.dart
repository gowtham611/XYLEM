import '../models/prediction_history.dart';
import '../providers/sensor_data_provider.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Service for generating Explainable AI (XAI) explanations for crop predictions
class XAIExplanationService {
  /// Generate comprehensive XAI explanation for a prediction
  static XAIExplanation generateExplanation({
    required String predictedCrop,
    required double confidence,
    required SensorData sensorData,
    required double rainfall,
    BuildContext? context,
  }) {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    
    final featureContributions = _analyzeFeatureContributions(
      predictedCrop,
      sensorData,
      rainfall,
      l10n,
    );

    final favorableFactors = <String>[];
    final limitingFactors = <String>[];

    // Analyze each feature contribution
    for (var feature in featureContributions) {
      if (feature.impact == 'positive' && feature.importance > 0.5) {
        favorableFactors.add(feature.explanation);
      } else if (feature.impact == 'negative' && feature.importance > 0.5) {
        limitingFactors.add(feature.explanation);
      }
    }

    final mainReason = _getMainReason(
      predictedCrop,
      featureContributions,
      confidence,
      l10n,
    );

    final detailedExplanation = _generateDetailedExplanation(
      predictedCrop,
      confidence,
      favorableFactors,
      limitingFactors,
      l10n,
    );

    return XAIExplanation(
      mainReason: mainReason,
      featureContributions: featureContributions,
      favorableFactors: favorableFactors,
      limitingFactors: limitingFactors,
      detailedExplanation: detailedExplanation,
    );
  }

  /// Analyze how each feature contributed to the prediction
  static List<FeatureContribution> _analyzeFeatureContributions(
    String crop,
    SensorData data,
    double rainfall,
    AppLocalizations? l10n,
  ) {
    final contributions = <FeatureContribution>[];

    // Get crop requirements
    final requirements = _getCropRequirements(crop);

    // Helper to get localized crop name
    String getLocalizedCrop(String crop) {
      if (l10n == null) return crop.toUpperCase();
      final cropLower = crop.toLowerCase();
      if (cropLower.contains('rice')) return l10n.cropRice.toUpperCase();
      if (cropLower.contains('maize')) return l10n.cropMaize.toUpperCase();
      if (cropLower.contains('cotton')) return l10n.cropCotton.toUpperCase();
      if (cropLower.contains('wheat')) return l10n.cropWheat.toUpperCase();
      if (cropLower.contains('coffee')) return l10n.cropCoffee.toUpperCase();
      if (cropLower.contains('banana')) return l10n.cropBanana.toUpperCase();
      if (cropLower.contains('mango')) return l10n.cropMango.toUpperCase();
      if (cropLower.contains('coconut')) return l10n.cropCoconut.toUpperCase();
      return crop.toUpperCase();
    }

    final localizedCropName = getLocalizedCrop(crop);

    // Nitrogen analysis
    final nImpact = _calculateImpact(
      data.nitrogen,
      requirements['nitrogen_min'] ?? 0,
      requirements['nitrogen_max'] ?? 100,
      requirements['nitrogen_optimal'] ?? 50,
      l10n?.featureNitrogen ?? 'Nitrogen',
      localizedCropName,
      l10n,
    );
    contributions.add(FeatureContribution(
      featureName: l10n?.featureNitrogen ?? 'Nitrogen (N)',
      value: data.nitrogen,
      importance: 0.85,
      impact: nImpact['impact']!,
      explanation: nImpact['explanation']!,
    ));

    // Phosphorus analysis
    final pImpact = _calculateImpact(
      data.phosphorus,
      requirements['phosphorus_min'] ?? 0,
      requirements['phosphorus_max'] ?? 100,
      requirements['phosphorus_optimal'] ?? 50,
      l10n?.featurePhosphorus ?? 'Phosphorus',
      localizedCropName,
      l10n,
    );
    contributions.add(FeatureContribution(
      featureName: l10n?.featurePhosphorus ?? 'Phosphorus (P)',
      value: data.phosphorus,
      importance: 0.75,
      impact: pImpact['impact']!,
      explanation: pImpact['explanation']!,
    ));

    // Potassium analysis
    final kImpact = _calculateImpact(
      data.potassium,
      requirements['potassium_min'] ?? 0,
      requirements['potassium_max'] ?? 100,
      requirements['potassium_optimal'] ?? 50,
      l10n?.featurePotassium ?? 'Potassium',
      localizedCropName,
      l10n,
    );
    contributions.add(FeatureContribution(
      featureName: l10n?.featurePotassium ?? 'Potassium (K)',
      value: data.potassium,
      importance: 0.75,
      impact: kImpact['impact']!,
      explanation: kImpact['explanation']!,
    ));

    // Temperature analysis
    final tempImpact = _calculateImpact(
      data.temperature,
      requirements['temp_min'] ?? 15,
      requirements['temp_max'] ?? 40,
      requirements['temp_optimal'] ?? 25,
      l10n?.featureTemperature ?? 'Temperature',
      localizedCropName,
      l10n,
    );
    contributions.add(FeatureContribution(
      featureName: l10n?.featureTemperature ?? 'Temperature',
      value: data.temperature,
      importance: 0.90,
      impact: tempImpact['impact']!,
      explanation: tempImpact['explanation']!,
    ));

    // Humidity analysis
    final humidityImpact = _calculateImpact(
      data.humidity,
      requirements['humidity_min'] ?? 40,
      requirements['humidity_max'] ?? 90,
      requirements['humidity_optimal'] ?? 65,
      l10n?.featureHumidity ?? 'Humidity',
      localizedCropName,
      l10n,
    );
    contributions.add(FeatureContribution(
      featureName: l10n?.featureHumidity ?? 'Humidity',
      value: data.humidity,
      importance: 0.70,
      impact: humidityImpact['impact']!,
      explanation: humidityImpact['explanation']!,
    ));

    // pH analysis
    final phImpact = _calculateImpact(
      data.ph,
      requirements['ph_min'] ?? 5.5,
      requirements['ph_max'] ?? 8.0,
      requirements['ph_optimal'] ?? 6.5,
      l10n?.featurePH ?? 'pH Level',
      localizedCropName,
      l10n,
    );
    contributions.add(FeatureContribution(
      featureName: l10n?.featurePH ?? 'Soil pH',
      value: data.ph,
      importance: 0.80,
      impact: phImpact['impact']!,
      explanation: phImpact['explanation']!,
    ));

    // Rainfall analysis
    final rainfallImpact = _calculateImpact(
      rainfall,
      requirements['rainfall_min'] ?? 50,
      requirements['rainfall_max'] ?? 300,
      requirements['rainfall_optimal'] ?? 150,
      l10n?.featureRainfall ?? 'Rainfall',
      localizedCropName,
      l10n,
    );
    contributions.add(FeatureContribution(
      featureName: l10n?.featureRainfall ?? 'Rainfall',
      value: rainfall,
      importance: 0.65,
      impact: rainfallImpact['impact']!,
      explanation: rainfallImpact['explanation']!,
    ));

    // Sort by importance
    contributions.sort((a, b) => b.importance.compareTo(a.importance));

    return contributions;
  }

  /// Calculate impact of a feature value
  static Map<String, String> _calculateImpact(
    double value,
    double min,
    double max,
    double optimal,
    String featureName,
    String cropName,
    AppLocalizations? l10n,
  ) {
    String impact;
    String explanation;

    if (value < min) {
      impact = 'negative';
      if (l10n != null) {
        explanation = 'ಮೌಲ್ಯ ${value.toStringAsFixed(1)} ಕನಿಷ್ಠ ಅಗತ್ಯಕ್ಕಿಂತ ಕಡಿಮೆಯಾಗಿದೆ (${min.toStringAsFixed(1)})';
      } else {
        explanation = 'Value ${value.toStringAsFixed(1)} is below minimum required (${min.toStringAsFixed(1)})';
      }
    } else if (value > max) {
      impact = 'negative';
      if (l10n != null) {
        explanation = 'ಮೌಲ್ಯ ${value.toStringAsFixed(1)} ಗರಿಷ್ಠ ಅತ್ಯುತ್ತಮವನ್ನು ಮೀರಿದೆ (${max.toStringAsFixed(1)})';
      } else {
        explanation = 'Value ${value.toStringAsFixed(1)} exceeds maximum optimal (${max.toStringAsFixed(1)})';
      }
    } else {
      final deviation = (value - optimal).abs();
      final tolerance = (max - min) * 0.2;

      if (deviation <= tolerance) {
        impact = 'positive';
        if (l10n != null) {
          explanation = 'ಅತ್ಯುತ್ತಮ $featureName ಮಟ್ಟಗಳು $cropName ಕೃಷಿಗೆ ಬಲವಾಗಿ ಒಲವು ತೋರುತ್ತವೆ';
        } else {
          explanation = 'Excellent $featureName levels strongly favor $cropName cultivation';
        }
      } else {
        impact = 'neutral';
        if (l10n != null) {
          explanation = 'ಮೌಲ್ಯ ${value.toStringAsFixed(1)} ಸ್ವೀಕಾರಾರ್ಹವಾಗಿದೆ ಆದರೆ ಅತ್ಯುತ್ತಮವಲ್ಲ';
        } else {
          explanation = 'Value ${value.toStringAsFixed(1)} is acceptable but not optimal';
        }
      }
    }

    return {'impact': impact, 'explanation': explanation};
  }

  /// Get crop-specific requirements (simplified version - should be expanded with real data)
  static Map<String, double> _getCropRequirements(String crop) {
    final cropName = crop.toLowerCase();

    // Default values
    Map<String, double> defaults = {
      'nitrogen_min': 20, 'nitrogen_max': 80, 'nitrogen_optimal': 50,
      'phosphorus_min': 15, 'phosphorus_max': 70, 'phosphorus_optimal': 40,
      'potassium_min': 15, 'potassium_max': 70, 'potassium_optimal': 40,
      'temp_min': 15, 'temp_max': 35, 'temp_optimal': 25,
      'humidity_min': 50, 'humidity_max': 85, 'humidity_optimal': 65,
      'ph_min': 5.5, 'ph_max': 7.5, 'ph_optimal': 6.5,
      'rainfall_min': 50, 'rainfall_max': 200, 'rainfall_optimal': 120,
    };

    // Crop-specific overrides
    if (cropName.contains('rice')) {
      return {...defaults, 'rainfall_min': 100, 'rainfall_optimal': 150, 'humidity_optimal': 75};
    } else if (cropName.contains('cotton')) {
      return {...defaults, 'temp_optimal': 28, 'potassium_optimal': 50};
    } else if (cropName.contains('wheat')) {
      return {...defaults, 'temp_optimal': 20, 'rainfall_optimal': 75};
    } else if (cropName.contains('maize')) {
      return {...defaults, 'nitrogen_optimal': 60, 'temp_optimal': 27};
    } else if (cropName.contains('coffee')) {
      return {...defaults, 'rainfall_optimal': 180, 'ph_optimal': 6.0};
    } else if (cropName.contains('banana')) {
      return {...defaults, 'potassium_optimal': 55, 'humidity_optimal': 80};
    } else if (cropName.contains('mango')) {
      return {...defaults, 'temp_optimal': 30, 'ph_optimal': 6.5};
    } else if (cropName.contains('coconut')) {
      return {...defaults, 'rainfall_optimal': 180, 'humidity_optimal': 80};
    }

    return defaults;
  }

  /// Determine the main reason for the prediction
  static String _getMainReason(
    String crop,
    List<FeatureContribution> contributions,
    double confidence,
    AppLocalizations? l10n,
  ) {
    final positiveFeatures = contributions
        .where((c) => c.impact == 'positive' && c.importance > 0.7)
        .toList();

    // Get localized crop name
    String getLocalizedCrop(String crop) {
      if (l10n == null) return crop.toUpperCase();
      final cropLower = crop.toLowerCase();
      if (cropLower.contains('rice')) return l10n.cropRice.toUpperCase();
      if (cropLower.contains('maize')) return l10n.cropMaize.toUpperCase();
      if (cropLower.contains('cotton')) return l10n.cropCotton.toUpperCase();
      if (cropLower.contains('wheat')) return l10n.cropWheat.toUpperCase();
      return crop.toUpperCase();
    }

    final localizedCropName = getLocalizedCrop(crop);

    if (positiveFeatures.isEmpty) {
      return l10n != null 
        ? 'ಒಟ್ಟಾರೆ ಸಂವೇದಕ ವಿಶ್ಲೇಷಣೆಯ ಆಧಾರದ ಮೇಲೆ, ಪರಿಸ್ಥಿತಿಗಳು ಅತ್ಯುತ್ತಮವಾಗಿಲ್ಲದಿದ್ದರೂ'
        : 'Based on overall sensor analysis, though conditions are not optimal';
    }

    if (confidence >= 0.8) {
      final topFeature = positiveFeatures.first;
      return l10n != null
        ? 'ಅತ್ಯುತ್ತಮ ${topFeature.featureName} ಮಟ್ಟಗಳು $localizedCropName ಕೃಷಿಗೆ ಬಲವಾಗಿ ಒಲವು ತೋರುತ್ತವೆ'
        : 'Excellent ${topFeature.featureName} levels strongly favor $localizedCropName cultivation';
    } else if (confidence >= 0.6) {
      final features = positiveFeatures.take(2).map((f) => f.featureName).join(l10n != null ? ' ಮತ್ತು ' : ' and ');
      return l10n != null
        ? '$features ನ ಉತ್ತಮ ಸಂಯೋಜನೆಯು $localizedCropName ಗೆ ಬೆಂಬಲ ನೀಡುತ್ತದೆ'
        : 'Good combination of $features supports $localizedCropName';
    } else {
      return l10n != null
        ? '${positiveFeatures.first.featureName} ಮತ್ತು ಒಟ್ಟಾರೆ ಪರಿಸ್ಥಿತಿಗಳ ಆಧಾರದ ಮೇಲೆ ಮಧ್ಯಮ ಹೊಂದಾಣಿಕೆ'
        : 'Moderate match based on ${positiveFeatures.first.featureName} and overall conditions';
    }
  }

  /// Generate detailed explanation text
  static String _generateDetailedExplanation(
    String crop,
    double confidence,
    List<String> favorable,
    List<String> limiting,
    AppLocalizations? l10n,
  ) {
    StringBuffer explanation = StringBuffer();

    // Get localized crop name
    String getLocalizedCrop(String crop) {
      if (l10n == null) return crop.toUpperCase();
      final cropLower = crop.toLowerCase();
      if (cropLower.contains('rice')) return l10n.cropRice.toUpperCase();
      if (cropLower.contains('maize')) return l10n.cropMaize.toUpperCase();
      if (cropLower.contains('cotton')) return l10n.cropCotton.toUpperCase();
      return crop.toUpperCase();
    }

    final localizedCropName = getLocalizedCrop(crop);

    explanation.write(
      l10n != null
        ? 'AI ಮಾದರಿಯು ${(confidence * 100).toStringAsFixed(1)}% ವಿಶ್ವಾಸದೊಂದಿಗೆ $localizedCropName ಅನ್ನು ಮುನ್ಸೂಚಿಸಿದೆ. '
        : 'The AI model predicted $localizedCropName with ${(confidence * 100).toStringAsFixed(1)}% confidence. '
    );

    if (favorable.isNotEmpty) {
      explanation.write(l10n != null ? '\n\nಅನುಕೂಲಕರ ಪರಿಸ್ಥಿತಿಗಳು:\n' : '\n\nFavorable conditions:\n');
      for (var factor in favorable) {
        explanation.write('• $factor\n');
      }
    }

    if (limiting.isNotEmpty) {
      explanation.write(l10n != null ? '\n\nಸೀಮಿತಗೊಳಿಸುವ ಅಂಶಗಳು:\n' : '\n\nLimiting factors:\n');
      for (var factor in limiting) {
        explanation.write('• $factor\n');
      }
    }

    if (confidence >= 0.7) {
      explanation.write(
        '\n\nRecommendation: Strong match! Your soil and climate conditions are well-suited for ${crop.toUpperCase()} cultivation.'
      );
    } else if (confidence >= 0.5) {
      explanation.write(
        '\n\nRecommendation: Moderate match. Consider soil amendments and climate management for optimal results.'
      );
    } else {
      explanation.write(
        '\n\nRecommendation: Low confidence. Consider alternative crops or significant soil improvements before planting ${crop.toUpperCase()}.'
      );
    }

    return explanation.toString();
  }

  /// Generate soil analysis
  static SoilAnalysis generateSoilAnalysis(SensorData data) {
    final issues = <String>[];
    final recommendations = <String>[];
    final nutrientLevels = <String, String>{};

    // Analyze nitrogen
    if (data.nitrogen < 30) {
      nutrientLevels['Nitrogen'] = 'Low';
      issues.add('Nitrogen levels are below optimal range');
      recommendations.add('Apply nitrogen-rich fertilizers (Urea, Ammonium Nitrate)');
    } else if (data.nitrogen < 50) {
      nutrientLevels['Nitrogen'] = 'Moderate';
    } else {
      nutrientLevels['Nitrogen'] = 'Good';
    }

    // Analyze phosphorus
    if (data.phosphorus < 25) {
      nutrientLevels['Phosphorus'] = 'Low';
      issues.add('Phosphorus levels need improvement');
      recommendations.add('Add phosphate fertilizers (DAP, SSP)');
    } else if (data.phosphorus < 45) {
      nutrientLevels['Phosphorus'] = 'Moderate';
    } else {
      nutrientLevels['Phosphorus'] = 'Good';
    }

    // Analyze potassium
    if (data.potassium < 25) {
      nutrientLevels['Potassium'] = 'Low';
      issues.add('Potassium deficiency detected');
      recommendations.add('Apply potash fertilizers (MOP, SOP)');
    } else if (data.potassium < 45) {
      nutrientLevels['Potassium'] = 'Moderate';
    } else {
      nutrientLevels['Potassium'] = 'Good';
    }

    // Analyze pH
    if (data.ph < 6.0) {
      issues.add('Soil is too acidic');
      recommendations.add('Apply lime to increase pH');
    } else if (data.ph > 7.5) {
      issues.add('Soil is too alkaline');
      recommendations.add('Apply sulfur or organic matter to reduce pH');
    }

    // Analyze moisture
    if (data.moisture < 40) {
      issues.add('Low soil moisture detected');
      recommendations.add('Improve irrigation or add mulch to retain moisture');
    } else if (data.moisture > 80) {
      issues.add('Excess soil moisture');
      recommendations.add('Improve drainage to prevent waterlogging');
    }

    final overallStatus = issues.isEmpty ? 'Optimal' : (issues.length <= 2 ? 'Good' : 'Needs Improvement');

    return SoilAnalysis(
      overallStatus: overallStatus,
      issues: issues,
      recommendations: recommendations,
      nutrientLevels: nutrientLevels,
    );
  }
}
