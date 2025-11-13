import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';

class YieldPredictionWidget extends StatelessWidget {
  const YieldPredictionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        if (provider.currentData == null) {
          return Container();
        }

        final predictions = _generateYieldPredictions(provider.currentData!);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.chartColumn, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Yield Predictions',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...predictions.map((prediction) => _buildYieldItem(prediction)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildYieldItem(Map<String, dynamic> prediction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(prediction['emoji'], style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction['crop'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Expected: ${prediction['yield']} per hectare',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getConfidenceColor(prediction['confidence']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${prediction['confidence']}%',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateYieldPredictions(SensorData data) {
    List<Map<String, dynamic>> predictions = [];

    // Tomatoes yield prediction
    if (data.ph >= 6.0 && data.ph <= 7.0 && data.nitrogen >= 40) {
      predictions.add({
        'crop': 'Tomatoes',
        'emoji': '🍅',
        'yield': '40-50 tonnes',
        'confidence': 88,
      });
    }

    // Potatoes yield prediction
    if (data.ph >= 5.5 && data.ph <= 6.5 && data.phosphorus >= 20) {
      predictions.add({
        'crop': 'Potatoes',
        'emoji': '🥔',
        'yield': '25-35 tonnes',
        'confidence': 82,
      });
    }

    // Leafy Greens yield prediction
    if (data.nitrogen >= 50 && data.moisture >= 60) {
      predictions.add({
        'crop': 'Leafy Greens',
        'emoji': '🥬',
        'yield': '15-20 tonnes',
        'confidence': 90,
      });
    }

    // Default predictions
    if (predictions.isEmpty) {
      predictions.addAll([
        {
          'crop': 'Mixed Vegetables',
          'emoji': '🥕',
          'yield': '20-30 tonnes',
          'confidence': 70,
        },
        {
          'crop': 'Herbs',
          'emoji': '🌿',
          'yield': '8-12 tonnes',
          'confidence': 75,
        },
      ]);
    }

    return predictions.take(3).toList();
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 85) return Colors.green;
    if (confidence >= 70) return Colors.orange;
    return Colors.red;
  }
}
