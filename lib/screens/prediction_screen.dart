// lib/screens/prediction_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';
import '../services/ml_service.dart';
import '../services/onnx_runtime_service.dart';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';
import '../services/prediction_database_service.dart';
import '../models/prediction_history.dart' as history_model;
import 'package:uuid/uuid.dart';
import '../widgets/xai_explanation_widget.dart';
import 'prediction_history_screen.dart';


class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  CropPrediction? _predictionResult;
  String? _error;
  String? _ortStatus;

  final MLService _mlService = MLService();
  final PredictionDatabaseService _dbService = PredictionDatabaseService();
  final _uuid = const Uuid();

  // Animation controllers for reveal
  late AnimationController _revealController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;
  double _confidenceAnimTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardSlide = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutBack,
    );
    _cardFade = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _checkOnnxRuntime() async {
    setState(() {
      _loading = true;
      _ortStatus = null;
      _error = null;
    });

    try {
      final status = await OnnxRuntimeService.checkOrt();
      if (status['available'] == true) {
        setState(() {
          _ortStatus = '✅ ONNX Runtime ${status['version']} available';
        });
      } else {
        setState(() {
          _ortStatus = '❌ ONNX Runtime not available: ${status['error']}';
        });
      }
    } catch (e) {
      setState(() {
        _ortStatus = '❌ Check failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _runPrediction(SensorData data) async {
    setState(() {
      _loading = true;
      _error = null;
      _predictionResult = null;
    });

    try {
      await _mlService.initializeModel();
      final pred = await _mlService.predictCrop(data, null, context: context);

      // Save to database if prediction has XAI explanation
      if (pred.xaiExplanation != null && pred.sensorInputs != null) {
        await _savePredictionToDatabase(pred);
      }

      // Animate reveal
      setState(() {
        _predictionResult = pred;
        _confidenceAnimTarget = pred.confidence.clamp(0.0, 1.0);
      });
      _revealController.reset();
      _revealController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Save prediction to local JSON database
  Future<void> _savePredictionToDatabase(CropPrediction prediction) async {
    try {
      if (prediction.xaiExplanation == null || prediction.sensorInputs == null) {
        return;
      }

      // Convert alternatives from CropPrediction to history model
      final alternatives = prediction.top3Crops.map((alt) {
        return history_model.AlternativePrediction(
          cropName: alt.name,
          confidence: alt.confidence,
          reason: 'High confidence alternative based on sensor conditions',
        );
      }).toList();

      // Convert soil condition to soil analysis
      final soilAnalysis = history_model.SoilAnalysis(
        overallStatus: prediction.soilCondition.overall,
        issues: prediction.soilCondition.issues,
        recommendations: prediction.soilCondition.recommendations,
        nutrientLevels: {},
      );

      final historyEntry = history_model.PredictionHistory(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        predictedCrop: prediction.cropName,
        confidence: prediction.confidence,
        sensorData: prediction.sensorInputs!,
        explanation: prediction.xaiExplanation!,
        alternatives: alternatives,
        soilAnalysis: soilAnalysis,
      );

      await _dbService.savePrediction(historyEntry);
      debugPrint('✅ Prediction saved to database');
    } catch (e) {
      debugPrint('❌ Failed to save prediction: $e');
    }
  }

  // Start simulation and wait for data, then run prediction
  Future<void> _simulateAndRun(SensorDataProvider provider) async {
    setState(() {
      _loading = true;
      _error = null;
      _predictionResult = null;
    });

    try {
      provider.startSimulation();

      const timeout = Duration(seconds: 3);
      const pollInterval = Duration(milliseconds: 200);
      var waited = Duration.zero;

      while (provider.currentData == null && waited < timeout) {
        await Future.delayed(pollInterval);
        waited += pollInterval;
      }

      if (provider.currentData != null) {
        await _runPrediction(provider.currentData!);
      } else {
        setState(() {
          _error = 'Simulation did not produce data in time.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // --- UI Builders ---

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(FontAwesomeIcons.brain, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.aiCropAdvisorTitle ?? 'AI Crop Advisor',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.smartCropPredictions ?? 'Smart crop predictions · Soil insights · Farming tips',
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _checkOnnxRuntime,
            icon: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline, color: Colors.white),
            tooltip: l10n?.checkOnnxRuntime ?? 'Check ONNX Runtime',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PredictionHistoryScreen()),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'View History',
          ),
        ],
      ),
    );
  }

  Widget _buildControls(SensorDataProvider provider) {
    final l10n = AppLocalizations.of(context);
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(FontAwesomeIcons.play),
            label: Text(_loading ? (l10n?.runningDots ?? 'Running...') : (l10n?.runAIPredictionButton ?? 'Run AI Prediction')),
            onPressed: _loading || provider.currentData == null
                ? null
                : () => _runPrediction(provider.currentData!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _loading ? null : () => _simulateAndRun(provider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            backgroundColor: Colors.green.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(
            children: [
              const Icon(FontAwesomeIcons.bolt, size: 16),
              const SizedBox(width: 8),
              Text(l10n?.simulateButton ?? 'Simulate'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedPredictionCard() {
    if (_predictionResult == null) {
      return _buildEmptyCard();
    }

    // Animated builder for the reveal
    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, _) {
        final slide = _cardSlide.value;
        final fade = _cardFade.value;

        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(0, (1 - slide) * 40),
            child: _PredictionCardBody(
              key: ValueKey(_predictionResult!.cropName + _predictionResult!.confidence.toString()),
              prediction: _predictionResult!,
              confidenceTarget: _confidenceAnimTarget,
              animation: _revealController,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard() {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.seedling, size: 44, color: Colors.grey[500]),
              const SizedBox(height: 8),
              Text(l10n?.noPredictionsYetTitle ?? 'No predictions yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(l10n?.runAIPredictionToSeeResults ?? 'Run the AI prediction to see results', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    final l10n = AppLocalizations.of(context);
    
    if (_error != null) {
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text('${l10n?.predictionError ?? "Prediction error:"} $_error')),
            ],
          ),
        ),
      );
    }

    if (_ortStatus != null) {
      return Card(
        color: _ortStatus!.startsWith('✅') ? Colors.green[50] : Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(_ortStatus!.startsWith('✅') ? Icons.check_circle : Icons.warning,
                  color: _ortStatus!.startsWith('✅') ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(_ortStatus!)),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatus(),
              const SizedBox(height: 12),
              _buildControls(provider),
              const SizedBox(height: 16),
              _buildAnimatedPredictionCard(),
              const SizedBox(height: 16),
              if (provider.currentData == null)
                _buildNoPredictionCard(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoPredictionCard(SensorDataProvider provider) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.brain, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                l10n?.noPredictionDataTitle ?? 'No Prediction Data',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(l10n?.connectSensorsOrStartSimulation ?? 'Connect sensors or start simulation to get predictions', style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: _loading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(FontAwesomeIcons.play),
                label: Text(_loading ? (l10n?.startingDots ?? 'Starting...') : (l10n?.simulateAndRun ?? 'Simulate & Run')),
                onPressed: _loading ? null : () => _simulateAndRun(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep crop recommendations logic (copied to match your original)
  Widget _buildCropRecommendationsCard(SensorData data) {
    final l10n = AppLocalizations.of(context);
    final recommendations = _generateCropRecommendations(data);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(FontAwesomeIcons.seedling, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(l10n?.recommendedCropsTitle ?? 'Recommended Crops', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          ...recommendations.map((crop) => _buildCropRecommendationItem(crop)),
        ]),
      ),
    );
  }

  Widget _buildCropRecommendationItem(Map<String, dynamic> crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.12)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(crop['emoji'], style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(crop['name'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(crop['reason'], style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600])),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
          child: Text('${crop['suitability']}%', style: GoogleFonts.roboto(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  List<Map<String, dynamic>> _generateCropRecommendations(SensorData data) {
    final l10n = AppLocalizations.of(context);
    List<Map<String, dynamic>> recommendations = [];

    if (data.ph >= 6.0 && data.ph <= 7.0 && data.moisture >= 60 && data.nitrogen >= 40) {
      recommendations.add({'name': l10n?.cropTomatoes ?? 'Tomatoes', 'emoji': '🍅', 'reason': l10n?.optimalPHHighNitrogenReason ?? 'Optimal pH and high nitrogen levels', 'suitability': 95});
    }
    if (data.ph >= 5.5 && data.ph <= 6.5 && data.phosphorus >= 20) {
      recommendations.add({'name': l10n?.cropPotatoes ?? 'Potatoes', 'emoji': '🥔', 'reason': l10n?.goodPHPhosphorusReason ?? 'Good pH and phosphorus levels', 'suitability': 88});
    }
    if (data.nitrogen >= 50 && data.moisture >= 70) {
      recommendations.add({'name': l10n?.cropLeafyGreens ?? 'Leafy Greens', 'emoji': '🥬', 'reason': l10n?.highNitrogenMoistureReason ?? 'High nitrogen and moisture content', 'suitability': 92});
    }
    if (data.ph >= 6.0 && data.ph <= 7.0 && data.potassium >= 30) {
      recommendations.add({'name': l10n?.cropPeppers ?? 'Peppers', 'emoji': '🌶️', 'reason': l10n?.goodPHPotassiumReason ?? 'Good pH and potassium levels', 'suitability': 85});
    }
    if (recommendations.isEmpty) {
      recommendations.addAll([
        {'name': l10n?.cropLegumes ?? 'Legumes', 'emoji': '🫘', 'reason': l10n?.nitrogenFixersReason ?? 'Nitrogen fixers, improve soil quality', 'suitability': 70},
        {'name': l10n?.cropHerbs ?? 'Herbs', 'emoji': '🌿', 'reason': l10n?.adaptableToSoilReason ?? 'Adaptable to various soil conditions', 'suitability': 75},
      ]);
    }
    recommendations.sort((a, b) => b['suitability'].compareTo(a['suitability']));
    return recommendations.take(4).toList();
  }

  // small helper reused from your file (AI-like predictions)
  Map<String, dynamic> _generateAIPredictions(SensorData data) {
    String soilQuality = 'Good';
    String growthPotential = 'High';
    String riskLevel = 'Low';
    String seasonMatch = 'Excellent';
    String aiInsight = '';

    if (data.ph >= 6.0 && data.ph <= 7.5 && data.moisture >= 50 && data.nitrogen >= 40) {
      soilQuality = 'Excellent';
      growthPotential = 'Very High';
      aiInsight = 'Optimal conditions detected! Perfect for most vegetable crops.';
    } else if (data.ph >= 5.5 && data.ph <= 8.0 && data.moisture >= 40) {
      soilQuality = 'Good';
      growthPotential = 'High';
      aiInsight = 'Good growing conditions. Consider nutrient supplementation.';
    } else {
      soilQuality = 'Fair';
      growthPotential = 'Moderate';
      riskLevel = 'Medium';
      aiInsight = 'Soil conditions need improvement. Focus on pH and moisture balance.';
    }

    if (data.moisture < 30 || data.moisture > 80) {
      riskLevel = 'High';
      aiInsight = 'Water stress detected! Adjust irrigation immediately.';
    } else if (data.ph < 5.5 || data.ph > 8.0) {
      riskLevel = 'Medium';
    }

    return {
      'soilQuality': soilQuality,
      'growthPotential': growthPotential,
      'riskLevel': riskLevel,
      'seasonMatch': seasonMatch,
      'aiInsight': aiInsight,
    };
  }
}

/// Small widget that displays the prediction details with animations.
/// NEW LOTTIE-BASED PREDICTION CARD UI
/// Prediction card (single unified implementation)
class _PredictionCardBody extends StatefulWidget {
  final CropPrediction prediction;
  final double confidenceTarget;
  final AnimationController animation;

  const _PredictionCardBody({
    super.key,
    required this.prediction,
    required this.confidenceTarget,
    required this.animation,
  });

  @override
  State<_PredictionCardBody> createState() => _PredictionCardBodyState();
}

class _PredictionCardBodyState extends State<_PredictionCardBody> {
  late Animation<double> _confAnim;
  late Animation<double> _popAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _confAnim = Tween<double>(begin: 0.0, end: widget.confidenceTarget).animate(
      CurvedAnimation(parent: widget.animation, curve: const Interval(0.15, 0.85, curve: Curves.easeOut)),
    );
    _popAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: widget.animation, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: widget.animation, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _PredictionCardBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidenceTarget != widget.confidenceTarget) {
      _confAnim = Tween<double>(begin: 0.0, end: widget.confidenceTarget).animate(
        CurvedAnimation(parent: widget.animation, curve: const Interval(0.15, 0.85, curve: Curves.easeOut)),
      );
    }
  }

  String _cropEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('rice')) return '🌾';
    if (n.contains('apple')) return '🍎';
    if (n.contains('banana')) return '🍌';
    if (n.contains('mango')) return '🥭';
    if (n.contains('tomato')) return '🍅';
    if (n.contains('orange')) return '🍊';
    if (n.contains('grape')) return '🍇';
    if (n.contains('watermelon')) return '🍉';
    if (n.contains('coconut')) return '🥥';
    if (n.contains('pomegranate')) return '🍈';
    if (n.contains('papaya')) return '🍈';
    if (n.contains('coffee')) return '☕';
    if (n.contains('cotton')) return '🌼';
    return '🌱';
  }
  
  String _translateCropName(BuildContext context, String cropName) {
    final l10n = AppLocalizations.of(context);
    final name = cropName.toLowerCase();
    
    if (name.contains('rice')) return l10n?.cropRice ?? 'Rice';
    if (name.contains('maize')) return l10n?.cropMaize ?? 'Maize';
    if (name.contains('chickpea')) return l10n?.cropChickpea ?? 'Chickpea';
    if (name.contains('kidneybeans')) return l10n?.cropKidneybeans ?? 'Kidney Beans';
    if (name.contains('pigeonpeas')) return l10n?.cropPigeonpeas ?? 'Pigeon Peas';
    if (name.contains('mothbeans')) return l10n?.cropMothbeans ?? 'Moth Beans';
    if (name.contains('mungbean')) return l10n?.cropMungbean ?? 'Mung Bean';
    if (name.contains('blackgram')) return l10n?.cropBlackgram ?? 'Black Gram';
    if (name.contains('lentil')) return l10n?.cropLentil ?? 'Lentil';
    if (name.contains('pomegranate')) return l10n?.cropPomegranate ?? 'Pomegranate';
    if (name.contains('banana')) return l10n?.cropBanana ?? 'Banana';
    if (name.contains('mango')) return l10n?.cropMango ?? 'Mango';
    if (name.contains('grapes')) return l10n?.cropGrapes ?? 'Grapes';
    if (name.contains('watermelon')) return l10n?.cropWatermelon ?? 'Watermelon';
    if (name.contains('muskmelon')) return l10n?.cropMuskmelon ?? 'Muskmelon';
    if (name.contains('apple')) return l10n?.cropApple ?? 'Apple';
    if (name.contains('orange')) return l10n?.cropOrange ?? 'Orange';
    if (name.contains('papaya')) return l10n?.cropPapaya ?? 'Papaya';
    if (name.contains('coconut')) return l10n?.cropCoconut ?? 'Coconut';
    if (name.contains('cotton')) return l10n?.cropCotton ?? 'Cotton';
    if (name.contains('jute')) return l10n?.cropJute ?? 'Jute';
    if (name.contains('coffee')) return l10n?.cropCoffee ?? 'Coffee';
    
    return cropName;
  }

  @override
  Widget build(BuildContext context) {
    final pred = widget.prediction;
    final top3 = pred.top3Crops;
    final soil = pred.soilCondition;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Card(
        elevation: 14,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Lottie header (nice visual)
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Lottie.asset(
                  'assets/animations/crop_grow.json',
                  frameRate: FrameRate.max,
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 8),

              // Row with crop name + confidence pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // crop emoji badge
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_cropEmoji(pred.cropName), style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  // Name + subtitle
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_translateCropName(context, pred.cropName).toUpperCase(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(AppLocalizations.of(context)?.modelRecommendationSubtitle ?? 'Model recommendation', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600])),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  // Confidence pill (animated)
                  AnimatedBuilder(
                    animation: widget.animation,
                    builder: (_, __) {
                      final percent = (_confAnim.value * 100).clamp(0, 100).toStringAsFixed(0);
                      final bg = _confAnim.value >= 0.7 ? Colors.green.shade600 : (_confAnim.value >= 0.4 ? Colors.orange : Colors.redAccent);
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                        child: Text("${AppLocalizations.of(context)?.confidenceLabel ?? 'Confidence'}: $percent%", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Middle row: radial confidence + top alternatives
              Row(
                children: [
                  // radial gauge
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: AnimatedBuilder(
                      animation: widget.animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _popAnim.value,
                          child: CustomPaint(
                            painter: _RadialConfidencePainter(_confAnim.value),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${((_confAnim.value * 100).clamp(0, 100)).toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(AppLocalizations.of(context)?.confidenceLabel ?? 'Confidence', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Top 3 alternatives with bars
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(AppLocalizations.of(context)?.topAlternatives ?? "Top alternatives", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Column(
                        children: top3.map((alt) {
                          final pct = (alt.confidence * 100).clamp(0.0, 100.0);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(_translateCropName(context, alt.name), style: GoogleFonts.roboto(fontSize: 13))),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 6,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: alt.confidence,
                                      minHeight: 10,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(width: 44, child: Text('${pct.toStringAsFixed(0)}%', textAlign: TextAlign.right, style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700]))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ]),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Soil chips + expandable recommendations
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('${AppLocalizations.of(context)?.soilLabel ?? 'Soil'}: ${soil.overall.toUpperCase()}'), avatar: const Icon(Icons.terrain, size: 16)),
                    if (soil.issues.isNotEmpty) Chip(label: Text('${soil.issues.length} ${AppLocalizations.of(context)?.issuesLabel ?? 'issues'}'), avatar: const Icon(Icons.warning, size: 16)),
                    if (soil.recommendations.isNotEmpty) Chip(label: Text(AppLocalizations.of(context)?.tipsLabel ?? 'Tips'), avatar: const Icon(Icons.lightbulb, size: 16)),
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                      child: Text(pred.confidence > 0.5 ? (AppLocalizations.of(context)?.primaryLabel ?? 'Primary') : (AppLocalizations.of(context)?.advisoryLabel ?? 'Advisory'), style: GoogleFonts.roboto(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              ExpansionTile(
                title: Text(AppLocalizations.of(context)?.viewSoilRecommendationsTitle ?? 'View soil recommendations', style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600)),
                children: [
                  if (soil.issues.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text(AppLocalizations.of(context)?.noMajorSoilIssues ?? 'No major soil issues detected.', style: GoogleFonts.roboto(fontSize: 13))),
                  ...soil.issues.map((s) => ListTile(dense: true, leading: const Icon(Icons.error_outline, color: Colors.orange), title: Text(s, style: GoogleFonts.roboto(fontSize: 13)))),
                  if (soil.issues.isNotEmpty) const Divider(),
                  ...soil.recommendations.map((r) => ListTile(dense: true, leading: const Icon(Icons.check_circle_outline, color: Colors.green), title: Text(r, style: GoogleFonts.roboto(fontSize: 13)))),
                ],
              ),
              
              // Add XAI Explanation if available
              if (pred.xaiExplanation != null)
                XAIExplanationWidget(
                  explanation: pred.xaiExplanation!,
                  cropName: pred.cropName,
                  confidence: pred.confidence,
                ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Custom painter for the radial confidence gauge
class _RadialConfidencePainter extends CustomPainter {
  final double progress; // 0.0 .. 1.0

  _RadialConfidencePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final thickness = size.width * 0.12;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - thickness;

    // background circle
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = Colors.grey.shade200;
    canvas.drawCircle(center, radius, bgPaint);

    // gradient arc paint
    final sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: [Colors.green, Colors.yellow.shade700, Colors.orange, Colors.red],
      stops: const [0.0, 0.45, 0.75, 1.0],
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, arcPaint);

    // small center circle
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - thickness - 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialConfidencePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
