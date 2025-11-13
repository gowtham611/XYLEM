import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';
import '../l10n/app_localizations.dart';

class ESP32ConnectionWidget extends StatefulWidget {
  const ESP32ConnectionWidget({super.key});

  @override
  _ESP32ConnectionWidgetState createState() => _ESP32ConnectionWidgetState();
}

class _ESP32ConnectionWidgetState extends State<ESP32ConnectionWidget> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');
  final TextEditingController _portController = TextEditingController(text: '80');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
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
                    Icon(
                      _getStatusIcon(provider),
                      color: _getStatusColor(provider.connectionStatus),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.sensorConnection ?? 'Sensor Connection',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(provider.connectionStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(provider.connectionStatus),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        provider.getStatusText(),
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: _getStatusColor(provider.connectionStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Current status display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(provider.connectionStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(provider.connectionStatus).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${provider.getConnectionInfo()}',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(provider.connectionStatus),
                        ),
                      ),
                      if (provider.isConnected && provider.totalDataPoints > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Data Points: ${provider.totalDataPoints} | Rate: ${provider.dataRate.toStringAsFixed(1)}/min',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (provider.connectionStatus == ConnectionStatus.disconnected && !provider.isSimulationMode) ...[
                  // Connection form
                  Text(
                    'Connect to ESP32 for real sensor data:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _ipController,
                          decoration: InputDecoration(
                            labelText: 'ESP32 IP Address',
                            hintText: '192.168.4.1',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _portController,
                          decoration: InputDecoration(
                            labelText: 'Port',
                            hintText: '80',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          style: GoogleFonts.roboto(fontSize: 14),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final ip = _ipController.text.trim();
                            final port = int.tryParse(_portController.text) ?? 80;
                            if (ip.isNotEmpty) {
                              provider.connectToESP32(ip, port: port);
                            }
                          },
                          icon: const Icon(FontAwesomeIcons.microchip),
                          label: const Text('Connect to ESP32'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.startSimulation,
                          icon: const Icon(FontAwesomeIcons.play),
                          label: const Text('Use Test Data'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ] else if (provider.isSimulationMode) ...[
                  // Simulation mode active
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.play, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Test Data Mode Active',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: provider.toggleSimulation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Stop Test'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Using simulated sensor data for testing purposes.',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                ] else if (provider.isConnected) ...[
                  // ESP32 connected
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.microchip, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'ESP32 Connected',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: provider.refreshData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size(40, 32),
                                  ),
                                  child: const Icon(Icons.refresh, size: 16),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: provider.disconnect,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text('Disconnect'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Receiving live data from ESP32 every 3 seconds.',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                ] else if (provider.connectionStatus == ConnectionStatus.connecting) ...[
                  // Connecting state
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Connecting to ESP32...',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (provider.connectionError.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connection Error:',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                provider.connectionError,
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Show current data only if connected
                if (provider.currentData != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.database, color: Colors.blue, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Latest Sensor Reading:',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const Spacer(),
                            if (provider.lastDataReceived != null)
                              Text(
                                _formatTime(provider.lastDataReceived!),
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: Colors.blue[600],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Temperature: ${provider.currentData!.temperature.toStringAsFixed(1)}°C | '
                          'Humidity: ${provider.currentData!.humidity.toStringAsFixed(1)}% | '
                          'pH: ${provider.currentData!.ph.toStringAsFixed(1)} | '
                          'Moisture: ${provider.currentData!.moisture.toStringAsFixed(1)}%',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SensorDataProvider provider) {
    if (provider.isSimulationMode) {
      return FontAwesomeIcons.play;
    }
    
    switch (provider.connectionStatus) {
      case ConnectionStatus.connected:
        return FontAwesomeIcons.microchip;
      case ConnectionStatus.connecting:
        return FontAwesomeIcons.spinner;
      case ConnectionStatus.error:
        return FontAwesomeIcons.exclamationTriangle;
      case ConnectionStatus.disconnected:
        return FontAwesomeIcons.plug;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
