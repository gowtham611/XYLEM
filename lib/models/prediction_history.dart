/// Model for storing prediction history with XAI explanations
class PredictionHistory {
  final String id;
  final DateTime timestamp;
  final String predictedCrop;
  final double confidence;
  final SensorInputs sensorData;
  final XAIExplanation explanation;
  final List<AlternativePrediction> alternatives;
  final SoilAnalysis soilAnalysis;

  PredictionHistory({
    required this.id,
    required this.timestamp,
    required this.predictedCrop,
    required this.confidence,
    required this.sensorData,
    required this.explanation,
    required this.alternatives,
    required this.soilAnalysis,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'predictedCrop': predictedCrop,
    'confidence': confidence,
    'sensorData': sensorData.toJson(),
    'explanation': explanation.toJson(),
    'alternatives': alternatives.map((e) => e.toJson()).toList(),
    'soilAnalysis': soilAnalysis.toJson(),
  };

  factory PredictionHistory.fromJson(Map<String, dynamic> json) => PredictionHistory(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    predictedCrop: json['predictedCrop'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    sensorData: SensorInputs.fromJson(json['sensorData'] as Map<String, dynamic>),
    explanation: XAIExplanation.fromJson(json['explanation'] as Map<String, dynamic>),
    alternatives: (json['alternatives'] as List)
        .map((e) => AlternativePrediction.fromJson(e as Map<String, dynamic>))
        .toList(),
    soilAnalysis: SoilAnalysis.fromJson(json['soilAnalysis'] as Map<String, dynamic>),
  );
}

/// Sensor input data for the prediction
class SensorInputs {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double temperature;
  final double humidity;
  final double ph;
  final double rainfall;

  SensorInputs({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
  });

  Map<String, dynamic> toJson() => {
    'nitrogen': nitrogen,
    'phosphorus': phosphorus,
    'potassium': potassium,
    'temperature': temperature,
    'humidity': humidity,
    'ph': ph,
    'rainfall': rainfall,
  };

  factory SensorInputs.fromJson(Map<String, dynamic> json) => SensorInputs(
    nitrogen: (json['nitrogen'] as num).toDouble(),
    phosphorus: (json['phosphorus'] as num).toDouble(),
    potassium: (json['potassium'] as num).toDouble(),
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    ph: (json['ph'] as num).toDouble(),
    rainfall: (json['rainfall'] as num).toDouble(),
  );
}

/// XAI (Explainable AI) explanation for why this crop was predicted
class XAIExplanation {
  final String mainReason;
  final List<FeatureContribution> featureContributions;
  final List<String> favorableFactors;
  final List<String> limitingFactors;
  final String detailedExplanation;

  XAIExplanation({
    required this.mainReason,
    required this.featureContributions,
    required this.favorableFactors,
    required this.limitingFactors,
    required this.detailedExplanation,
  });

  Map<String, dynamic> toJson() => {
    'mainReason': mainReason,
    'featureContributions': featureContributions.map((e) => e.toJson()).toList(),
    'favorableFactors': favorableFactors,
    'limitingFactors': limitingFactors,
    'detailedExplanation': detailedExplanation,
  };

  factory XAIExplanation.fromJson(Map<String, dynamic> json) => XAIExplanation(
    mainReason: json['mainReason'] as String,
    featureContributions: (json['featureContributions'] as List)
        .map((e) => FeatureContribution.fromJson(e as Map<String, dynamic>))
        .toList(),
    favorableFactors: List<String>.from(json['favorableFactors'] as List),
    limitingFactors: List<String>.from(json['limitingFactors'] as List),
    detailedExplanation: json['detailedExplanation'] as String,
  );
}

/// Feature contribution for XAI - shows how much each sensor reading influenced the prediction
class FeatureContribution {
  final String featureName;
  final double value;
  final double importance; // 0.0 to 1.0
  final String impact; // positive, negative, neutral
  final String explanation;

  FeatureContribution({
    required this.featureName,
    required this.value,
    required this.importance,
    required this.impact,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'featureName': featureName,
    'value': value,
    'importance': importance,
    'impact': impact,
    'explanation': explanation,
  };

  factory FeatureContribution.fromJson(Map<String, dynamic> json) => FeatureContribution(
    featureName: json['featureName'] as String,
    value: (json['value'] as num).toDouble(),
    importance: (json['importance'] as num).toDouble(),
    impact: json['impact'] as String,
    explanation: json['explanation'] as String,
  );
}

/// Alternative prediction option
class AlternativePrediction {
  final String cropName;
  final double confidence;
  final String reason;

  AlternativePrediction({
    required this.cropName,
    required this.confidence,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'cropName': cropName,
    'confidence': confidence,
    'reason': reason,
  };

  factory AlternativePrediction.fromJson(Map<String, dynamic> json) => AlternativePrediction(
    cropName: json['cropName'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    reason: json['reason'] as String,
  );
}

/// Soil analysis result
class SoilAnalysis {
  final String overallStatus;
  final List<String> issues;
  final List<String> recommendations;
  final Map<String, String> nutrientLevels;

  SoilAnalysis({
    required this.overallStatus,
    required this.issues,
    required this.recommendations,
    required this.nutrientLevels,
  });

  Map<String, dynamic> toJson() => {
    'overallStatus': overallStatus,
    'issues': issues,
    'recommendations': recommendations,
    'nutrientLevels': nutrientLevels,
  };

  factory SoilAnalysis.fromJson(Map<String, dynamic> json) => SoilAnalysis(
    overallStatus: json['overallStatus'] as String,
    issues: List<String>.from(json['issues'] as List),
    recommendations: List<String>.from(json['recommendations'] as List),
    nutrientLevels: Map<String, String>.from(json['nutrientLevels'] as Map),
  );
}
