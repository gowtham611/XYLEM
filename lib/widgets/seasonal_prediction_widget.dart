import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SeasonalPredictionWidget extends StatelessWidget {
  const SeasonalPredictionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final seasonalData = _getSeasonalRecommendations(currentMonth);

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
                const Icon(FontAwesomeIcons.calendarDays, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Seasonal Predictions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[50]!, Colors.amber[100]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(seasonalData['icon'], style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seasonalData['season'],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        Text(
                          seasonalData['description'],
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...seasonalData['tips'].map<Widget>((tip) => _buildTipItem(tip)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(Map<String, dynamic> tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip['emoji'], style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tip['description'],
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getSeasonalRecommendations(int month) {
    if (month >= 3 && month <= 5) {
      // Spring
      return {
        'season': 'Spring Season',
        'icon': '🌱',
        'description': 'Perfect time for planting most vegetables and crops',
        'tips': [
          {'emoji': '🌱', 'title': 'Start Planting', 'description': 'Begin with cool-season crops like lettuce, peas, and radishes'},
          {'emoji': '🌡️', 'title': 'Temperature Watch', 'description': 'Monitor for last frost dates in your area'},
          {'emoji': '💧', 'title': 'Soil Preparation', 'description': 'Prepare soil with compost and organic matter'},
        ],
      };
    } else if (month >= 6 && month <= 8) {
      // Summer
      return {
        'season': 'Summer Season',
        'icon': '☀️',
        'description': 'Peak growing season with high temperatures',
        'tips': [
          {'emoji': '💧', 'title': 'Irrigation Focus', 'description': 'Increase watering frequency during hot days'},
          {'emoji': '🌿', 'title': 'Heat-Tolerant Crops', 'description': 'Plant tomatoes, peppers, and heat-loving vegetables'},
          {'emoji': '🏠', 'title': 'Shade Protection', 'description': 'Provide shade during extreme heat periods'},
        ],
      };
    } else if (month >= 9 && month <= 11) {
      // Fall/Autumn
      return {
        'season': 'Autumn Season',
        'icon': '🍂',
        'description': 'Harvest season and winter crop preparation',
        'tips': [
          {'emoji': '🥕', 'title': 'Root Vegetables', 'description': 'Perfect time for carrots, radishes, and turnips'},
          {'emoji': '🌾', 'title': 'Harvest Time', 'description': 'Harvest summer crops before first frost'},
          {'emoji': '🍃', 'title': 'Cover Crops', 'description': 'Plant cover crops to improve soil for next season'},
        ],
      };
    } else {
      // Winter
      return {
        'season': 'Winter Season',
        'icon': '❄️',
        'description': 'Planning and greenhouse farming season',
        'tips': [
          {'emoji': '🏠', 'title': 'Greenhouse Growing', 'description': 'Consider protected cultivation for winter crops'},
          {'emoji': '📋', 'title': 'Season Planning', 'description': 'Plan next year\'s crop rotation and varieties'},
          {'emoji': '🛠️', 'title': 'Equipment Maintenance', 'description': 'Service and maintain farming equipment'},
        ],
      };
    }
  }
}
