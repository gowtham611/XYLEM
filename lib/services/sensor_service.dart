import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../providers/sensor_data_provider.dart';

class SensorService {
  Timer? _timer;
  WebSocketChannel? _webSocketChannel;
  StreamSubscription? _webSocketSubscription;
  
  final StreamController<SensorData> _sensorController = StreamController<SensorData>.broadcast();
  final StreamController<SensorData> _averageController = StreamController<SensorData>.broadcast();
  
  Stream<SensorData> get sensorDataStream => _sensorController.stream;
  Stream<SensorData> get averageDataStream => _averageController.stream;
  
  bool _isConnected = false;
  String? _espIP;
  String _connectionType = 'none';

  // HTTP Connection
  Future<void> connect(String espIP) async {
    _espIP = espIP;
    _connectionType = 'http';
    
    // Test HTTP connection
    final response = await http.get(
      Uri.parse('http://$espIP/sensors'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      _isConnected = true;
      _startHTTPDataCollection();
    } else {
      throw Exception('Failed to connect to ESP32');
    }
  }

  // WebSocket Connection
  Future<void> connectWebSocket(String espIP) async {
    _espIP = espIP;
    _connectionType = 'websocket';
    
    try {
      _webSocketChannel = WebSocketChannel.connect(
        Uri.parse('ws://$espIP:81'),
      );
      
      _webSocketSubscription = _webSocketChannel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data);
            
            if (jsonData['status'] == 'connected') {
              _isConnected = true;
            } else if (jsonData['type'] == 'sensor_data') {
              final sensorData = SensorData(
                ph: jsonData['ph']?.toDouble() ?? 0.0,
                temperature: jsonData['temperature']?.toDouble() ?? 0.0,
                humidity: jsonData['humidity']?.toDouble() ?? 0.0,
                moisture: jsonData['moisture']?.toDouble() ?? 0.0,
                nitrogen: jsonData['nitrogen']?.toInt() ?? 0,
                phosphorus: jsonData['phosphorus']?.toInt() ?? 0,
                potassium: jsonData['potassium']?.toInt() ?? 0,
                timestamp: DateTime.now(),
              );
              
              _sensorController.add(sensorData);
              _averageController.add(sensorData); // For simplicity, same data
            }
          } catch (e) {
            print('WebSocket data parsing error: $e');
          }
        },
        onError: (error) {
          _isConnected = false;
          throw Exception('WebSocket error: $error');
        },
        onDone: () {
          _isConnected = false;
        },
      );
      
    } catch (e) {
      throw Exception('WebSocket connection failed: $e');
    }
  }

  void _startHTTPDataCollection() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isConnected || _espIP == null) return;
      
      try {
        // Simulate sensor data for now (replace with real HTTP calls)
        final currentData = SensorData(
          ph: 6.5 + (DateTime.now().millisecond % 100) / 100.0,
          temperature: 25.0 + (DateTime.now().millisecond % 50) / 10.0,
          humidity: 60.0 + (DateTime.now().millisecond % 200) / 10.0,
          moisture: 45.0 + (DateTime.now().millisecond % 300) / 10.0,
          nitrogen: 50 + (DateTime.now().millisecond % 50),
          phosphorus: 30 + (DateTime.now().millisecond % 40),
          potassium: 40 + (DateTime.now().millisecond % 60),
          timestamp: DateTime.now(),
        );
        
        _sensorController.add(currentData);
        
        // Send average data every 5 seconds
        if (timer.tick % 5 == 0) {
          _averageController.add(currentData);
        }
        
      } catch (e) {
        print('HTTP data collection error: $e');
      }
    });
  }

  void disconnect() {
    _timer?.cancel();
    _webSocketSubscription?.cancel();
    _webSocketChannel?.sink.close();
    _isConnected = false;
    _connectionType = 'none';
  }

  void dispose() {
    disconnect();
    _sensorController.close();
    _averageController.close();
  }
}
