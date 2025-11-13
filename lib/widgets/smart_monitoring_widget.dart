import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';

class SmartMonitoringWidget extends StatelessWidget {
  const SmartMonitoringWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        final currentData = provider.currentData;
        
        if (currentData == null) {
          return _buildNoDataCard();
        }
        
        final alerts = _generateAlerts(currentData);
        final recommendations = _generateRecommendations(currentData);
        
        return Column(
          children: [
            _buildMonitoringHeader(alerts.length),
            const SizedBox(height: 16),
            if (alerts.isNotEmpty) ...[
              _buildAlertsSection(alerts),
              const SizedBox(height: 16),
            ],
            _buildRecommendationsSection(recommendations),
            const SizedBox(height: 16),
            _buildParameterStatusGrid(currentData),
          ],
        );
      },
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.seedling,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Connect ESP32 Sensors',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Start monitoring your crop parameters',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonitoringHeader(int alertCount) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: alertCount > 0 
                ? [Colors.orange[400]!, Colors.orange[600]!]
                : [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                alertCount > 0 ? FontAwesomeIcons.exclamationTriangle : FontAwesomeIcons.shieldHalved,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Monitoring System',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    alertCount > 0 
                        ? '$alertCount parameter${alertCount > 1 ? 's' : ''} need${alertCount == 1 ? 's' : ''} attention'
                        : 'All parameters are optimal',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                alertCount > 0 ? 'ALERTS' : 'HEALTHY',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(List<MonitoringAlert> alerts) {
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
                const Icon(FontAwesomeIcons.bell, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Active Alerts',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(MonitoringAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getAlertColor(alert.severity).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getAlertIcon(alert.severity),
            color: _getAlertColor(alert.severity),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getAlertColor(alert.severity),
                  ),
                ),
                Text(
                  alert.message,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<String> recommendations) {
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
                const Icon(FontAwesomeIcons.lightbulb, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Smart Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((recommendation) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterStatusGrid(SensorData data) {
    final parameters = [
      {'name': 'Temperature', 'value': '${data.temperature.toStringAsFixed(1)}°C', 'status': _getTemperatureStatus(data.temperature), 'icon': FontAwesomeIcons.thermometer},
      {'name': 'Humidity', 'value': '${data.humidity.toStringAsFixed(1)}%', 'status': _getHumidityStatus(data.humidity), 'icon': FontAwesomeIcons.droplet},
      {'name': 'Soil pH', 'value': data.ph.toStringAsFixed(1), 'status': _getPhStatus(data.ph), 'icon': FontAwesomeIcons.seedling},
      {'name': 'Moisture', 'value': '${data.moisture.toStringAsFixed(1)}%', 'status': _getMoistureStatus(data.moisture), 'icon': FontAwesomeIcons.water},
      {'name': 'Nitrogen', 'value': '${data.nitrogen.toStringAsFixed(0)} ppm', 'status': _getNitrogenStatus(data.nitrogen), 'icon': FontAwesomeIcons.leaf},
      {'name': 'Status', 'value': 'Monitoring', 'status': ParameterStatus.optimal, 'icon': FontAwesomeIcons.chartLine}, // ✅ Removed light reference
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parameter Status',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: parameters.length,
              itemBuilder: (context, index) {
                final param = parameters[index];
                return _buildParameterCard(param);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(Map<String, dynamic> param) {
    final status = param['status'] as ParameterStatus;
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                param['icon'] as IconData,
                color: statusColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  param['name'] as String,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.name.toUpperCase(),
                  style: GoogleFonts.roboto(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            param['value'] as String,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // Alert Generation Logic
  List<MonitoringAlert> _generateAlerts(SensorData data) {
    List<MonitoringAlert> alerts = [];

    // Temperature alerts
    if (data.temperature > 35) {
      alerts.add(MonitoringAlert(
        title: 'High Temperature Alert',
        message: 'Temperature is ${data.temperature.toStringAsFixed(1)}°C. Plants may be stressed.',
        severity: AlertSeverity.warning,
      ));
    } else if (data.temperature < 15) {
      alerts.add(MonitoringAlert(
        title: 'Low Temperature Alert',
        message: 'Temperature is ${data.temperature.toStringAsFixed(1)}°C. Risk of frost damage.',
        severity: AlertSeverity.critical,
      ));
    }

    // Humidity alerts
    if (data.humidity > 85) {
      alerts.add(MonitoringAlert(
        title: 'High Humidity Alert',
        message: 'Humidity is ${data.humidity.toStringAsFixed(1)}%. Risk of fungal diseases.',
        severity: AlertSeverity.warning,
      ));
    } else if (data.humidity < 30) {
      alerts.add(MonitoringAlert(
        title: 'Low Humidity Alert',
        message: 'Humidity is ${data.humidity.toStringAsFixed(1)}%. Plants may need more water.',
        severity: AlertSeverity.info,
      ));
    }

    // pH alerts
    if (data.ph > 8.0) {
      alerts.add(MonitoringAlert(
        title: 'Soil Too Alkaline',
        message: 'pH is ${data.ph.toStringAsFixed(1)}. Add organic matter to reduce pH.',
        severity: AlertSeverity.warning,
      ));
    } else if (data.ph < 5.5) {
      alerts.add(MonitoringAlert(
        title: 'Soil Too Acidic',
        message: 'pH is ${data.ph.toStringAsFixed(1)}. Add lime to increase pH.',
        severity: AlertSeverity.warning,
      ));
    }

    // Moisture alerts
    if (data.moisture < 25) {
      alerts.add(MonitoringAlert(
        title: 'Low Soil Moisture',
        message: 'Moisture is ${data.moisture.toStringAsFixed(1)}%. Irrigation needed.',
        severity: AlertSeverity.critical,
      ));
    } else if (data.moisture > 80) {
      alerts.add(MonitoringAlert(
        title: 'Soil Waterlogged',
        message: 'Moisture is ${data.moisture.toStringAsFixed(1)}%. Risk of root rot.',
        severity: AlertSeverity.warning,
      ));
    }

    return alerts;
  }

  List<String> _generateRecommendations(SensorData data) {
    List<String> recommendations = [];

    // Temperature recommendations
    if (data.temperature > 35) {
      recommendations.add('Provide shade during peak hours (11 AM - 3 PM)');
      recommendations.add('Increase watering frequency to cool the soil');
    } else if (data.temperature < 15) {
      recommendations.add('Cover plants with protective sheets during night');
      recommendations.add('Water plants during warmer parts of the day');
    }

    // Humidity recommendations
    if (data.humidity > 85) {
      recommendations.add('Improve air circulation around plants');
      recommendations.add('Apply preventive fungicide spray');
    } else if (data.humidity < 30) {
      recommendations.add('Mulch around plants to retain moisture');
      recommendations.add('Use drip irrigation system');
    }

    // pH recommendations
    if (data.ph > 8.0) {
      recommendations.add('Add organic compost to lower soil pH');
    } else if (data.ph < 5.5) {
      recommendations.add('Add agricultural lime to raise pH');
    }

    // Default recommendations
    if (recommendations.isEmpty) {
      recommendations.addAll([
        'Parameters are optimal - continue current care routine',
        'Monitor plants daily for any changes',
        'Maintain consistent watering schedule',
      ]);
    }

    return recommendations;
  }

  // Status calculation methods
  ParameterStatus _getTemperatureStatus(double temp) {
    if (temp >= 20 && temp <= 30) return ParameterStatus.optimal;
    if ((temp >= 15 && temp < 20) || (temp > 30 && temp <= 35)) return ParameterStatus.warning;
    return ParameterStatus.critical;
  }

  ParameterStatus _getHumidityStatus(double humidity) {
    if (humidity >= 50 && humidity <= 70) return ParameterStatus.optimal;
    if ((humidity >= 40 && humidity < 50) || (humidity > 70 && humidity <= 85)) return ParameterStatus.warning;
    return ParameterStatus.critical;
  }

  ParameterStatus _getPhStatus(double ph) {
    if (ph >= 6.0 && ph <= 7.5) return ParameterStatus.optimal;
    if ((ph >= 5.5 && ph < 6.0) || (ph > 7.5 && ph <= 8.0)) return ParameterStatus.warning;
    return ParameterStatus.critical;
  }

  ParameterStatus _getMoistureStatus(double moisture) {
    if (moisture >= 40 && moisture <= 70) return ParameterStatus.optimal;
    if ((moisture >= 25 && moisture < 40) || (moisture > 70 && moisture <= 80)) return ParameterStatus.warning;
    return ParameterStatus.critical;
  }

  ParameterStatus _getNitrogenStatus(double nitrogen) {
    if (nitrogen >= 30) return ParameterStatus.optimal;
    if (nitrogen >= 20) return ParameterStatus.warning;
    return ParameterStatus.critical;
  }

  // Helper methods
  Color _getStatusColor(ParameterStatus status) {
    switch (status) {
      case ParameterStatus.optimal: return Colors.green;
      case ParameterStatus.warning: return Colors.orange;
      case ParameterStatus.critical: return Colors.red;
    }
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info: return Colors.blue;
      case AlertSeverity.warning: return Colors.orange;
      case AlertSeverity.critical: return Colors.red;
    }
  }

  IconData _getAlertIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info: return FontAwesomeIcons.circleInfo;
      case AlertSeverity.warning: return FontAwesomeIcons.triangleExclamation;
      case AlertSeverity.critical: return FontAwesomeIcons.circleExclamation;
    }
  }
}

// Supporting classes
class MonitoringAlert {
  final String title;
  final String message;
  final AlertSeverity severity;

  MonitoringAlert({
    required this.title,
    required this.message,
    required this.severity,
  });
}

enum AlertSeverity { info, warning, critical }
enum ParameterStatus { optimal, warning, critical }
