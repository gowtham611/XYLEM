import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';
import '../widgets/esp32_connection_widget.dart';
import '../widgets/sensor_charts_widget.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMonitoringHeader(),
              const SizedBox(height: 16),
              const ESP32ConnectionWidget(),
              const SizedBox(height: 16),
              if (provider.currentData != null) ...[
                _buildLiveReadingsCard(provider.currentData!),
                const SizedBox(height: 16),
                _buildSensorStatusGrid(provider.currentData!),
                const SizedBox(height: 16),
                const SensorChartsWidget(),
                const SizedBox(height: 16),
                _buildDataHistoryCard(provider.dataHistory),
              ] else ...[
                _buildNoSensorCard(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonitoringHeader() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
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
              child: const Icon(
                FontAwesomeIcons.chartLine,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real-Time Monitoring',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Live sensor data from your ESP32 devices',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildNoSensorCard() {
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
                FontAwesomeIcons.microchip,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Sensor Data',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Connect your ESP32 sensors to start monitoring',
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

  Widget _buildLiveReadingsCard(SensorData data) {
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
                const Icon(FontAwesomeIcons.satellite, color: Colors.green, size: 20), // ✅ Fixed icon
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatTime(data.timestamp)}',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildSensorTile('Temperature', '${data.temperature.toStringAsFixed(1)}°C', FontAwesomeIcons.thermometer, Colors.red),
                _buildSensorTile('Humidity', '${data.humidity.toStringAsFixed(1)}%', FontAwesomeIcons.droplet, Colors.blue),
                _buildSensorTile('Soil pH', '${data.ph.toStringAsFixed(1)}%', FontAwesomeIcons.seedling, Colors.green),
                _buildSensorTile('Moisture', '${data.moisture.toStringAsFixed(1)}%', FontAwesomeIcons.water, Colors.teal),
                _buildSensorTile('Nitrogen', '${data.nitrogen.toStringAsFixed(0)} ppm', FontAwesomeIcons.leaf, Colors.purple),
                _buildSensorTile('Phosphorus', '${data.phosphorus.toStringAsFixed(0)} ppm', FontAwesomeIcons.seedling, Colors.brown),
                _buildSensorTile('Potassium', '${data.potassium.toStringAsFixed(0)} ppm', FontAwesomeIcons.seedling, Colors.yellow),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorStatusGrid(SensorData data) {
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
                const Icon(FontAwesomeIcons.gaugeHigh, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sensor Status Analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusItem('Temperature', data.temperature, '°C', 20, 30, Colors.red),
            _buildStatusItem('Humidity', data.humidity, '%', 50, 70, Colors.blue),
            _buildStatusItem('Soil pH', data.ph, '', 6.0, 7.5, Colors.green),
            _buildStatusItem('Soil Moisture', data.moisture, '%', 40, 70, Colors.teal),
            _buildStatusItem('Nitrogen', data.nitrogen, ' ppm', 30, 100, Colors.purple),
            _buildStatusItem('Phosphorus', data.phosphorus, ' ppm', 20, 50, Colors.brown),
            _buildStatusItem('Potassium', data.potassium, ' ppm', 20, 50, Colors.yellow),

          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String name, double value, String unit, double minOptimal, double maxOptimal, Color color) {
    bool isOptimal = value >= minOptimal && value <= maxOptimal;
    Color statusColor = isOptimal ? Colors.green : (value < minOptimal ? Colors.orange : Colors.red);
    String status = isOptimal ? 'OPTIMAL' : (value < minOptimal ? 'LOW' : 'HIGH');
    double percentage = ((value - minOptimal) / (maxOptimal - minOptimal)).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${value.toStringAsFixed(1)}$unit',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
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
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${minOptimal.toStringAsFixed(0)}$unit',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                'Optimal Range',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '${maxOptimal.toStringAsFixed(0)}$unit',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataHistoryCard(List<SensorData> history) {
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
                const Icon(FontAwesomeIcons.clockRotateLeft, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Recent Data Log',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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
              height: 200,
              child: ListView.builder(
                itemCount: history.take(10).length,
                itemBuilder: (context, index) {
                  final data = history[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'T: ${data.temperature.toStringAsFixed(1)}°C • H: ${data.humidity.toStringAsFixed(1)}% • pH: ${data.ph.toStringAsFixed(1)}',
                                style: GoogleFonts.roboto(fontSize: 12),
                              ),
                              Text(
                                'N: ${data.nitrogen.toStringAsFixed(0)}ppm • P: ${data.phosphorus.toStringAsFixed(0)}ppm • K: ${data.potassium.toStringAsFixed(0)}ppm • M: ${data.moisture.toStringAsFixed(1)}%',
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
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
