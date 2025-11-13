import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';
import '../widgets/smart_monitoring_widget.dart';
import '../widgets/esp32_connection_widget.dart';

class SensorDashboard extends StatelessWidget {
  const SensorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorDataProvider>(
      builder: (context, sensorProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const ESP32ConnectionWidget(),
              const SizedBox(height: 16),
              
              // Show data only if connected
              if (sensorProvider.currentData != null) ...[
                _buildCurrentReadings(sensorProvider.currentData!),
                const SizedBox(height: 16),
                _buildParameterStatus(sensorProvider.currentData!),
                const SizedBox(height: 16),
                const SmartMonitoringWidget(),
              ] else ...[
                _buildNoDataCard(sensorProvider),
              ],
              
              const SizedBox(height: 16),
              if (sensorProvider.dataHistory.isNotEmpty)
                _buildDataHistory(sensorProvider.dataHistory),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoDataCard(SensorDataProvider provider) {
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
                provider.connectionStatus == ConnectionStatus.error 
                  ? FontAwesomeIcons.exclamationTriangle
                  : FontAwesomeIcons.microchip,
                size: 48,
                color: provider.connectionStatus == ConnectionStatus.error 
                  ? Colors.red[400]
                  : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                provider.connectionStatus == ConnectionStatus.error
                  ? 'ESP32 Connection Failed'
                  : 'No Sensor Data Available',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: provider.connectionStatus == ConnectionStatus.error 
                    ? Colors.red[600]
                    : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.connectionStatus == ConnectionStatus.error
                  ? 'Check ESP32 connection and IP address'
                  : 'Connect to ESP32 or use test data to start monitoring',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentReadings(SensorData currentData) {
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
                const Icon(FontAwesomeIcons.gauge, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Live Sensor Readings',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'LIVE',
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatTime(currentData.timestamp)}',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildReadingCard('Temperature', '${currentData.temperature.toStringAsFixed(1)}°C', FontAwesomeIcons.thermometer, Colors.red),
                _buildReadingCard('Humidity', '${currentData.humidity.toStringAsFixed(1)}%', FontAwesomeIcons.droplet, Colors.blue),
                _buildReadingCard('Soil pH', currentData.ph.toStringAsFixed(1), FontAwesomeIcons.seedling, Colors.green),
                _buildReadingCard('Moisture', '${currentData.moisture.toStringAsFixed(1)}%', FontAwesomeIcons.water, Colors.teal),
                _buildReadingCard('Nitrogen', '${currentData.nitrogen.toStringAsFixed(0)} ppm', FontAwesomeIcons.leaf, Colors.purple),
                _buildReadingCard('Phosphorus', '${currentData.phosphorus.toStringAsFixed(0)} ppm', FontAwesomeIcons.seedling, Colors.brown),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterStatus(SensorData data) {
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
                const Icon(FontAwesomeIcons.chartLine, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Parameter Status',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildParameterStatusItem('Temperature', data.temperature, '°C', 20, 30, Colors.red),
            _buildParameterStatusItem('Humidity', data.humidity, '%', 50, 70, Colors.blue),
            _buildParameterStatusItem('Soil pH', data.ph, '', 6.0, 7.5, Colors.green),
            _buildParameterStatusItem('Moisture', data.moisture, '%', 40, 70, Colors.teal),
            _buildParameterStatusItem('Nitrogen', data.nitrogen, ' ppm', 30, 100, Colors.purple),
            _buildParameterStatusItem('Phosphorus', data.phosphorus, ' ppm', 20, 50, Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterStatusItem(String name, double value, String unit, double minOptimal, double maxOptimal, Color color) {
    bool isOptimal = value >= minOptimal && value <= maxOptimal;
    Color statusColor = isOptimal ? Colors.green : (value < minOptimal ? Colors.orange : Colors.red);
    String status = isOptimal ? 'OPTIMAL' : (value < minOptimal ? 'LOW' : 'HIGH');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${value.toStringAsFixed(1)}$unit',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${minOptimal.toStringAsFixed(0)}-${maxOptimal.toStringAsFixed(0)}$unit',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: GoogleFonts.roboto(
                fontSize: 10,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataHistory(List<SensorData> history) {
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
                const Icon(FontAwesomeIcons.clockRotateLeft, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data History',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${history.length} readings',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: history.take(8).length,
                itemBuilder: (context, index) {
                  final data = history[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'T: ${data.temperature.toStringAsFixed(1)}°C, H: ${data.humidity.toStringAsFixed(1)}%, pH: ${data.ph.toStringAsFixed(1)}',
                            style: GoogleFonts.roboto(fontSize: 12),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(data.timestamp),
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
