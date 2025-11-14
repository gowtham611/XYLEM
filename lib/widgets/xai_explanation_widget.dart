import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction_history.dart';
import '../l10n/app_localizations.dart';

/// Widget to display XAI (Explainable AI) explanation for crop prediction
class XAIExplanationWidget extends StatelessWidget {
  final XAIExplanation explanation;
  final String cropName;
  final double confidence;

  const XAIExplanationWidget({
    super.key,
    required this.explanation,
    required this.cropName,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localizedCropName = _getLocalizedCropName(context, cropName);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.psychology, color: Colors.purple.shade600, size: 24),
          ),
          title: Text(
            '🧠 ${l10n != null ? l10n.xaiWhyCrop(localizedCropName) : 'Why $localizedCropName?'}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade700,
            ),
          ),
          subtitle: Text(
            explanation.mainReason,
            style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[700]),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature Contributions
                  Text(
                    '📊 ${l10n?.xaiFeatureAnalysis ?? 'Feature Analysis'}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...explanation.featureContributions.map((feature) {
                    return _buildFeatureBar(context, feature);
                  }),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Favorable Factors
                  if (explanation.favorableFactors.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.xaiFavorableConditions ?? 'Favorable Conditions',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...explanation.favorableFactors.map((factor) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.arrow_right, color: Colors.green.shade400, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                factor,
                                style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Limiting Factors
                  if (explanation.limitingFactors.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.xaiLimitingFactors ?? 'Limiting Factors',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...explanation.limitingFactors.map((factor) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.arrow_right, color: Colors.orange.shade400, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                factor,
                                style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  const Divider(),
                  const SizedBox(height: 12),

                  // Detailed Explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.xaiAIInsight ?? 'AI Insight',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          explanation.detailedExplanation,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBar(BuildContext context, FeatureContribution feature) {
    final l10n = AppLocalizations.of(context);
    Color barColor;
    IconData icon;

    switch (feature.impact) {
      case 'positive':
        barColor = Colors.green;
        icon = Icons.trending_up;
        break;
      case 'negative':
        barColor = Colors.red;
        icon = Icons.trending_down;
        break;
      default:
        barColor = Colors.grey;
        icon = Icons.trending_flat;
    }

    // Map feature names to localized strings
    String localizedFeatureName;
    switch (feature.featureName.toLowerCase()) {
      case 'nitrogen':
      case 'nitrogen (n)':
        localizedFeatureName = l10n?.featureNitrogen ?? feature.featureName;
        break;
      case 'phosphorus':
      case 'phosphorus (p)':
        localizedFeatureName = l10n?.featurePhosphorus ?? feature.featureName;
        break;
      case 'potassium':
      case 'potassium (k)':
        localizedFeatureName = l10n?.featurePotassium ?? feature.featureName;
        break;
      case 'temperature':
        localizedFeatureName = l10n?.featureTemperature ?? feature.featureName;
        break;
      case 'humidity':
        localizedFeatureName = l10n?.featureHumidity ?? feature.featureName;
        break;
      case 'ph':
      case 'ph level':
        localizedFeatureName = l10n?.featurePH ?? feature.featureName;
        break;
      case 'rainfall':
        localizedFeatureName = l10n?.featureRainfall ?? feature.featureName;
        break;
      default:
        localizedFeatureName = feature.featureName;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: barColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$localizedFeatureName: ${feature.value.toStringAsFixed(1)}',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(feature.importance * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: feature.importance,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              feature.explanation,
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get localized crop name based on the current locale
  String _getLocalizedCropName(BuildContext context, String cropName) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return cropName.toUpperCase();

    // Map English crop names to localized versions
    final cropLower = cropName.toLowerCase();
    switch (cropLower) {
      case 'rice':
        return l10n.cropRice.toUpperCase();
      case 'maize':
        return l10n.cropMaize.toUpperCase();
      case 'chickpea':
        return l10n.cropChickpea.toUpperCase();
      case 'kidneybeans':
      case 'kidney beans':
        return l10n.cropKidneybeans.toUpperCase();
      case 'pigeonpeas':
      case 'pigeon peas':
        return l10n.cropPigeonpeas.toUpperCase();
      case 'mothbeans':
      case 'moth beans':
        return l10n.cropMothbeans.toUpperCase();
      case 'mungbean':
      case 'mung bean':
        return l10n.cropMungbean.toUpperCase();
      case 'blackgram':
      case 'black gram':
        return l10n.cropBlackgram.toUpperCase();
      case 'lentil':
        return l10n.cropLentil.toUpperCase();
      case 'pomegranate':
        return l10n.cropPomegranate.toUpperCase();
      case 'banana':
        return l10n.cropBanana.toUpperCase();
      case 'mango':
        return l10n.cropMango.toUpperCase();
      case 'grapes':
        return l10n.cropGrapes.toUpperCase();
      case 'watermelon':
        return l10n.cropWatermelon.toUpperCase();
      case 'muskmelon':
        return l10n.cropMuskmelon.toUpperCase();
      case 'apple':
        return l10n.cropApple.toUpperCase();
      case 'orange':
        return l10n.cropOrange.toUpperCase();
      case 'papaya':
        return l10n.cropPapaya.toUpperCase();
      case 'coconut':
        return l10n.cropCoconut.toUpperCase();
      case 'cotton':
        return l10n.cropCotton.toUpperCase();
      case 'jute':
        return l10n.cropJute.toUpperCase();
      case 'coffee':
        return l10n.cropCoffee.toUpperCase();
      default:
        return cropName.toUpperCase();
    }
  }
}
