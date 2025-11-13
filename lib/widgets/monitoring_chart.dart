import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/sensor_data_provider.dart';

class MonitoringChart extends StatefulWidget {
  final SensorData sensorData;

  const MonitoringChart({
    super.key,
    required this.sensorData,
  });

  @override
  _MonitoringChartState createState() => _MonitoringChartState();
}

class _MonitoringChartState extends State<MonitoringChart> {
  List<SensorData> historicalData = [];
  String selectedParameter = 'temperature';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MonitoringChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Add new data point
    if (widget.sensorData != oldWidget.sensorData) {
      setState(() {
        historicalData.add(widget.sensorData);
        
        // Keep only last 20 data points
        if (historicalData.length > 20) {
          historicalData.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Parameter selector
            Row(
              children: [
                Text(
                  'Monitor Parameter:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedParameter,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'temperature', child: Text('Temperature (°C)')),
                      DropdownMenuItem(value: 'humidity', child: Text('Humidity (%)')),
                      DropdownMenuItem(value: 'ph', child: Text('pH Level')),
                      DropdownMenuItem(value: 'moisture', child: Text('Soil Moisture (%)')),
                      DropdownMenuItem(value: 'nitrogen', child: Text('Nitrogen (mg/kg)')),
                      DropdownMenuItem(value: 'phosphorus', child: Text('Phosphorus (mg/kg)')),
                      DropdownMenuItem(value: 'potassium', child: Text('Potassium (mg/kg)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedParameter = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Chart
            SizedBox(
              height: 200,
              child: historicalData.length < 2 
                ? const Center(
                    child: Text(
                      'Collecting data...\nMinimum 2 data points needed for chart',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < historicalData.length) {
                                return Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getDataPoints(),
                          isCurved: true,
                          color: _getParameterColor(),
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _getParameterColor().withOpacity(0.1),
                          ),
                        ),
                      ],
                      minY: _getMinY(),
                      maxY: _getMaxY(),
                    ),
                  ),
            ),
            
            const SizedBox(height: 20),
            
            // Current value display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getParameterColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current ${_getParameterName()}:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${_getCurrentValue().toStringAsFixed(1)} ${_getParameterUnit()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getParameterColor(),
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

  List<FlSpot> _getDataPoints() {
    List<FlSpot> spots = [];
    for (int i = 0; i < historicalData.length; i++) {
      double value = _getParameterValue(historicalData[i]);
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  double _getParameterValue(SensorData data) {
    switch (selectedParameter) {
      case 'temperature':
        return data.temperature;
      case 'humidity':
        return data.humidity;
      case 'ph':
        return data.ph;
      case 'moisture':
        return data.moisture;
      case 'nitrogen':
        return data.nitrogen.toDouble();
      case 'phosphorus':
        return data.phosphorus.toDouble();
      case 'potassium':
        return data.potassium.toDouble();
      default:
        return 0.0;
    }
  }

  double _getCurrentValue() {
    return _getParameterValue(widget.sensorData);
  }

  String _getParameterName() {
    switch (selectedParameter) {
      case 'temperature':
        return 'Temperature';
      case 'humidity':
        return 'Humidity';
      case 'ph':
        return 'pH Level';
      case 'moisture':
        return 'Soil Moisture';
      case 'nitrogen':
        return 'Nitrogen';
      case 'phosphorus':
        return 'Phosphorus';
      case 'potassium':
        return 'Potassium';
      default:
        return 'Parameter';
    }
  }

  String _getParameterUnit() {
    switch (selectedParameter) {
      case 'temperature':
        return '°C';
      case 'humidity':
      case 'moisture':
        return '%';
      case 'ph':
        return 'pH';
      case 'nitrogen':
      case 'phosphorus':
      case 'potassium':
        return 'mg/kg';
      default:
        return '';
    }
  }

  Color _getParameterColor() {
    switch (selectedParameter) {
      case 'temperature':
        return Colors.red;
      case 'humidity':
        return Colors.blue;
      case 'ph':
        return Colors.purple;
      case 'moisture':
        return Colors.cyan;
      case 'nitrogen':
        return Colors.green;
      case 'phosphorus':
        return Colors.orange;
      case 'potassium':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  double _getMinY() {
    if (historicalData.isEmpty) return 0;
    
    List<double> values = historicalData.map(_getParameterValue).toList();
    double min = values.reduce((a, b) => a < b ? a : b);
    
    // Add some padding
    return min - (min * 0.1);
  }

  double _getMaxY() {
    if (historicalData.isEmpty) return 100;
    
    List<double> values = historicalData.map(_getParameterValue).toList();
    double max = values.reduce((a, b) => a > b ? a : b);
    
    // Add some padding
    return max + (max * 0.1);
  }
}
