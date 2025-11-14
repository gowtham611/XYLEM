import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/prediction_database_service.dart';
import '../models/prediction_history.dart';
import '../widgets/xai_explanation_widget.dart';
import '../l10n/app_localizations.dart';

/// Screen to display prediction history from local JSON database
class PredictionHistoryScreen extends StatefulWidget {
  const PredictionHistoryScreen({super.key});

  @override
  State<PredictionHistoryScreen> createState() => _PredictionHistoryScreenState();
}

class _PredictionHistoryScreenState extends State<PredictionHistoryScreen> {
  final PredictionDatabaseService _dbService = PredictionDatabaseService();
  List<PredictionHistory> _predictions = [];
  bool _loading = true;
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() => _loading = true);
    try {
      final predictions = await _dbService.getAllPredictions();
      final stats = await _dbService.getStatistics();
      setState(() {
        _predictions = predictions;
        _statistics = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.errorLoadingPredictions ?? 'Error loading predictions: $e')),
        );
      }
    }
  }

  Future<void> _deletePrediction(String id) async {
    try {
      await _dbService.deletePrediction(id);
      await _loadPredictions();
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.predictionDeleted ?? 'Prediction deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.errorDeletingPrediction ?? 'Error deleting prediction: $e')),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.clearAllPredictions ?? 'Clear All Predictions?'),
          content: Text(l10n?.clearAllConfirmation ?? 'This will permanently delete all prediction history. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n?.deleteAll ?? 'Delete All'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _dbService.clearAllPredictions();
        await _loadPredictions();
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.allPredictionsCleared ?? 'All predictions cleared')),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.errorClearingPredictions ?? 'Error clearing predictions: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.predictionHistory ?? 'Prediction History', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          if (_predictions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: l10n?.clearAll ?? 'Clear all',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _predictions.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildStatistics(),
                    Expanded(child: _buildPredictionsList()),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n?.noPredictionHistory ?? 'No Prediction History',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.runPredictionsToSeeHistory ?? 'Run some predictions to see them here',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    if (_statistics == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n?.statistics ?? 'Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                l10n?.total ?? 'Total',
                '${_statistics!['totalPredictions']}',
                Icons.list_alt,
              ),
              _buildStatCard(
                l10n?.avgConfidence ?? 'Avg Confidence',
                '${(_statistics!['averageConfidence'] * 100).toStringAsFixed(0)}%',
                Icons.percent,
              ),
              _buildStatCard(
                l10n?.topCrop ?? 'Top Crop',
                _statistics!['mostPredictedCrop'].toString().split(' ')[0].toUpperCase(),
                Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.roboto(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        return _buildPredictionCard(prediction);
      },
    );
  }

  Widget _buildPredictionCard(PredictionHistory prediction) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final confidenceColor = prediction.confidence >= 0.7
        ? Colors.green
        : prediction.confidence >= 0.5
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: confidenceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.agriculture, color: confidenceColor, size: 24),
          ),
          title: Text(
            prediction.predictedCrop.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                dateFormat.format(prediction.timestamp),
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: confidenceColor),
                  const SizedBox(width: 4),
                  Text(
                    'Confidence: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: confidenceColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deletePrediction(prediction.id),
            tooltip: l10n?.delete ?? 'Delete',
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sensor Data
                  Text(
                    '📊 ${l10n?.sensorData ?? 'Sensor Data'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSensorChip('N', prediction.sensorData.nitrogen),
                      _buildSensorChip('P', prediction.sensorData.phosphorus),
                      _buildSensorChip('K', prediction.sensorData.potassium),
                      _buildSensorChip('Temp', prediction.sensorData.temperature, '°C'),
                      _buildSensorChip('Humidity', prediction.sensorData.humidity, '%'),
                      _buildSensorChip('pH', prediction.sensorData.ph),
                      _buildSensorChip('Rain', prediction.sensorData.rainfall, 'mm'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Alternatives
                  if (prediction.alternatives.isNotEmpty) ...[
                    Text(
                      '🌾 ${l10n?.alternativeCrops ?? 'Alternative Crops'}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...prediction.alternatives.map((alt) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                alt.cropName.toUpperCase(),
                                style: GoogleFonts.roboto(fontSize: 13),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(alt.confidence * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // XAI Explanation
                  XAIExplanationWidget(
                    explanation: prediction.explanation,
                    cropName: prediction.predictedCrop,
                    confidence: prediction.confidence,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorChip(String label, double value, [String unit = '']) {
    return Chip(
      label: Text(
        '$label: ${value.toStringAsFixed(1)}$unit',
        style: GoogleFonts.roboto(fontSize: 11),
      ),
      backgroundColor: Colors.grey.shade100,
      visualDensity: VisualDensity.compact,
    );
  }
}
