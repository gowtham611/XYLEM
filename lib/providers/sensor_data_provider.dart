import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

/// ─────────────────────────────────────────────────────────────────────────────
/// DATA MODEL
/// ─────────────────────────────────────────────────────────────────────────────
class SensorData {
  final double temperature; // °C (air)
  final double humidity;    // % (air RH)
  final double ph;          // soil pH
  final double moisture;    // % soil moisture (0–100 assumed)
  final double nitrogen;    // N (ppm or mg/kg depending on your sensor)
  final double phosphorus;  // P
  final double potassium;   // K
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.moisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      moisture: (json['moisture'] ?? 0).toDouble(),
      nitrogen: (json['nitrogen'] ?? 0).toDouble(),
      phosphorus: (json['phosphorus'] ?? 0).toDouble(),
      potassium: (json['potassium'] ?? 0).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'moisture': moisture,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ConnectionStatus { disconnected, connecting, connected, error }

/// ─────────────────────────────────────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────────────────────────────────────
class SensorDataProvider with ChangeNotifier {
  /// ── ESP32 HTTP polling (real-time) ─────────────────────────────────────────
  Timer? _realTimeTimer;
  String _esp32Url = '';
  final Duration _realTimeInterval = const Duration(seconds: 3);

  /// ── Connection state ───────────────────────────────────────────────────────
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String _connectionError = '';
  Timer? _simulationTimer;
  int _failedAttempts = 0;
  static const int maxFailedAttempts = 3;
  String _lastConnectionUrl = '';

  /// ── Data ───────────────────────────────────────────────────────────────────
  SensorData? _currentData;
  List<SensorData> _dataHistory = [];
  bool _isSimulationMode = false;
  DateTime? _lastDataReceived;

  /// ── Stats ──────────────────────────────────────────────────────────────────
  int _totalDataPoints = 0;
  double _dataRate = 0.0;
  final List<DateTime> _recentDataTimes = [];

  /// ── Location & Rainfall (OpenWeather + fallback) ──────────────────────────
  double? _lat;
  double? _lon;
  String? _placeName;

  // ⚠️ For production, move this key to .env and load via flutter_dotenv.
  static const String _openWeatherApiKey = 'f932ac201c369d916c02400fd855bf85';

  double? _apiRainfallMm;                // From API (prefer this when fresh)
  DateTime? _apiRainfallFetchedAt;       // Timestamp of API fetch
  double? _estimatedRainfallFromSensors; // Fallback when API not available

  // When API data is stale (> 90 min), we *may* attempt refresh (opt-in).
  final Duration _apiStaleAfter = const Duration(minutes: 90);

  /// ── Getters ────────────────────────────────────────────────────────────────
  SensorData? get currentData => _currentData;
  List<SensorData> get dataHistory => _dataHistory;
  ConnectionStatus get connectionStatus => _connectionStatus;
  String get connectionError => _connectionError;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;
  bool get isSimulationMode => _isSimulationMode;
  DateTime? get lastDataReceived => _lastDataReceived;
  int get totalDataPoints => _totalDataPoints;
  double get dataRate => _dataRate;
  String get connectionUrl => _lastConnectionUrl;

  double? get lat => _lat;
  double? get lon => _lon;
  String? get placeName => _placeName;

  /// Preferred rainfall (API if recent, else fallback), millimeters
  double? get rainfallMm {
    if (_apiRainfallMm != null &&
        _apiRainfallFetchedAt != null &&
        DateTime.now().difference(_apiRainfallFetchedAt!) <= _apiStaleAfter) {
      return _apiRainfallMm;
    }
    return _estimatedRainfallFromSensors;
  }

  /// Debug info: which rainfall source is currently used
  String get rainfallSource {
    final apiFresh = _apiRainfallFetchedAt != null &&
        DateTime.now().difference(_apiRainfallFetchedAt!) <= _apiStaleAfter;
    if (_apiRainfallMm != null && apiFresh) return 'OpenWeather (fresh)';
    if (_apiRainfallMm != null && !apiFresh) return 'OpenWeather (stale)';
    return 'Estimated from sensors';
  }

  /// ── Lifecycle ──────────────────────────────────────────────────────────────
  SensorDataProvider() {
    print('🔌 Sensor provider initialized - waiting for ESP32 connection');
  }

  /// ── Location management ────────────────────────────────────────────────────
  void setLocation({
    required double lat,
    required double lon,
    String? name,
    bool fetchNow = false,
  }) {
    _lat = lat;
    _lon = lon;
    _placeName = name;
    notifyListeners();

    if (fetchNow) {
      _refreshOpenWeatherRainfall(); // fire & forget
    }
  }

  Future<void> refreshWeatherNow() async {
    await _refreshOpenWeatherRainfall();
  }

  /// ── Connect to ESP32 for real sensor data ──────────────────────────────────
  Future<void> connectToESP32(String ipAddress, {int port = 80}) async {
    if (_connectionStatus == ConnectionStatus.connecting) return;

    _stopSimulation();
    _stopRealTimePolling();

    _esp32Url = 'http://$ipAddress:$port/sensors';
    _lastConnectionUrl = _esp32Url;
    _connectionStatus = ConnectionStatus.connecting;
    _connectionError = '';
    _failedAttempts = 0;
    _totalDataPoints = 0;
    _recentDataTimes.clear();

    print('🔄 Connecting to real ESP32 at $_esp32Url');
    notifyListeners();

    // Initial fetch to validate connection
    final success = await _fetchSensorData();

    if (success) {
      _connectionStatus = ConnectionStatus.connected;
      _isSimulationMode = false;
      _startRealTimePolling();
      print('✅ Connected to ESP32 - receiving real sensor data');

      // Optionally refresh rainfall right away if we have lat/lon and API looks stale
      if (_lat != null && _lon != null) {
        final stale = _apiRainfallFetchedAt == null ||
            DateTime.now().difference(_apiRainfallFetchedAt!) > _apiStaleAfter;
        if (stale) {
          _refreshOpenWeatherRainfall(); // fire & forget
        }
      }
    } else {
      _connectionStatus = ConnectionStatus.error;
      if (_connectionError.isEmpty) {
        _connectionError = 'Cannot reach ESP32 at $ipAddress:$port';
      }
      print('❌ Failed to connect to ESP32');
    }

    notifyListeners();
  }

  /// ── Polling ────────────────────────────────────────────────────────────────
  void _startRealTimePolling() {
    _realTimeTimer = Timer.periodic(_realTimeInterval, (timer) async {
      final success = await _fetchSensorData();

      if (!success) {
        _failedAttempts++;
        if (_failedAttempts >= maxFailedAttempts) {
          _connectionStatus = ConnectionStatus.error;
          _connectionError =
          'Lost connection to ESP32 - check if device is online';
          _stopRealTimePolling();
          print('❌ ESP32 connection lost');
          notifyListeners();
        }
      } else {
        _failedAttempts = 0;
        if (_connectionStatus != ConnectionStatus.connected) {
          _connectionStatus = ConnectionStatus.connected;
          _connectionError = '';
          print('✅ ESP32 connection restored');
          notifyListeners();
        }
      }
    });
  }

  /// ── Fetch real sensor data from ESP32 ──────────────────────────────────────
  Future<bool> _fetchSensorData() async {
    try {
      final response = await http
          .get(
        Uri.parse(_esp32Url),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final sensorData = SensorData.fromJson(jsonData);

        _processSensorData(sensorData);
        _lastDataReceived = DateTime.now();
        _totalDataPoints++;

        // Track data rate (last 60s events)
        _recentDataTimes.add(DateTime.now());
        _recentDataTimes.removeWhere(
                (time) => DateTime.now().difference(time).inMinutes > 1);
        _dataRate = _recentDataTimes.length.toDouble();

        print(
            '📡 ESP32 Data: T=${sensorData.temperature.toStringAsFixed(1)}°C, '
                'H=${sensorData.humidity.toStringAsFixed(1)}%, '
                'pH=${sensorData.ph.toStringAsFixed(1)}');

        return true;
      } else {
        _connectionError = 'ESP32 returned HTTP ${response.statusCode}';
        print('❌ ESP32 HTTP Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _connectionError = 'Cannot reach ESP32: ${e.toString()}';
      print('❌ ESP32 Connection Error: $e');
      return false;
    }
  }

  void _stopRealTimePolling() {
    _realTimeTimer?.cancel();
    _realTimeTimer = null;
  }

  /// Manual refresh (ESP32 or simulation)
  Future<void> refreshData() async {
    if (_isSimulationMode) {
      _generateSimulatedData();
    } else if (_esp32Url.isNotEmpty) {
      print('🔄 Manual refresh from ESP32...');
      await _fetchSensorData();
    }
  }

  /// ── Simulation mode ────────────────────────────────────────────────────────
  void startSimulation() {
    if (_isSimulationMode) return;

    _stopRealTimePolling();

    _isSimulationMode = true;
    _connectionStatus = ConnectionStatus.connected;
    _connectionError = '';
    _lastConnectionUrl = 'Simulation Mode';
    _totalDataPoints = 0;
    _recentDataTimes.clear();

    _simulationTimer =
        Timer.periodic(_realTimeInterval, (_) => _generateSimulatedData());

    // Initial data point
    _generateSimulatedData();

    print('🎯 Simulation mode started for testing');
    notifyListeners();
  }

  void _generateSimulatedData() {
    final random = Random();
    final now = DateTime.now();

    // Diurnal cycles
    double baseTemp = 25.0 + sin(now.hour / 24.0 * 2 * pi) * 5.0;
    double baseHumidity = 60.0 + cos(now.hour / 24.0 * 2 * pi) * 15.0;

    final temperature = (baseTemp + (random.nextDouble() - 0.5) * 2.0)
        .clamp(15.0, 40.0)
        .toDouble();
    final humidity = (baseHumidity + (random.nextDouble() - 0.5) * 5.0)
        .clamp(30.0, 90.0)
        .toDouble();
    final ph =
    (6.8 + (random.nextDouble() - 0.5) * 0.3).clamp(5.5, 8.5).toDouble();
    final moisture =
    (55.0 + (random.nextDouble() - 0.5) * 8.0).clamp(20.0, 80.0).toDouble();
    final nitrogen =
    (45.0 + (random.nextDouble() - 0.5) * 10.0).clamp(20.0, 100.0).toDouble();
    final phosphorus =
    (25.0 + (random.nextDouble() - 0.5) * 6.0).clamp(10.0, 50.0).toDouble();
    final potassium =
    (35.0 + (random.nextDouble() - 0.5) * 8.0).clamp(15.0, 100.0).toDouble();

    final sensorData = SensorData(
      temperature: temperature,
      humidity: humidity,
      ph: ph,
      moisture: moisture,
      nitrogen: nitrogen,
      phosphorus: phosphorus,
      potassium: potassium,
      timestamp: now,
    );

    _processSensorData(sensorData);
    _lastDataReceived = now;
    _totalDataPoints++;

    // Update data rate
    _recentDataTimes.add(now);
    _recentDataTimes.removeWhere(
            (time) => DateTime.now().difference(time).inMinutes > 1);
    _dataRate = _recentDataTimes.length.toDouble();

    print('🎲 Simulated data: T=${temperature.toStringAsFixed(1)}°C, '
        'H=${humidity.toStringAsFixed(1)}%');
  }

  /// ── Process a new sensor record (real or simulated) ────────────────────────
  void _processSensorData(SensorData sensorData) {
    _currentData = sensorData;
    _dataHistory.insert(0, sensorData);

    // Keep last 100 readings
    if (_dataHistory.length > 100) {
      _dataHistory = _dataHistory.take(100).toList();
    }

    // Keep an updated fallback rainfall estimate from sensors
    _estimatedRainfallFromSensors =
        _estimateRainfallFromSensors(sensorData).clamp(0.0, 500.0);

    // Optionally refresh API rainfall in background if stale and we have lat/lon
    final apiStale = _apiRainfallFetchedAt == null ||
        DateTime.now().difference(_apiRainfallFetchedAt!) > _apiStaleAfter;
    if (apiStale && _lat != null && _lon != null) {
      _refreshOpenWeatherRainfall(); // fire & forget
    }

    notifyListeners();
  }

  /// ── Disconnect & cleanup ───────────────────────────────────────────────────
  void disconnect() {
    _stopRealTimePolling();
    _stopSimulation();

    _connectionStatus = ConnectionStatus.disconnected;
    _connectionError = '';
    _esp32Url = '';
    _lastConnectionUrl = '';
    _failedAttempts = 0;
    _recentDataTimes.clear();
    _currentData = null;

    print('🔌 Disconnected - no sensor data');
    notifyListeners();
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isSimulationMode = false;
  }

  void toggleSimulation() {
    if (_isSimulationMode) {
      _stopSimulation();
      _connectionStatus = ConnectionStatus.disconnected;
      _lastConnectionUrl = '';
      _currentData = null;
      print('⏹️ Simulation stopped');
    } else {
      disconnect();
      startSimulation();
    }
    notifyListeners();
  }

  void clearHistory() {
    _dataHistory.clear();
    _totalDataPoints = 0;
    _dataRate = 0.0;
    _recentDataTimes.clear();
    notifyListeners();
  }

  String getConnectionInfo() {
    if (_isSimulationMode) return 'Simulation Mode Active';
    if (_lastConnectionUrl.isNotEmpty) return _lastConnectionUrl;
    return 'No ESP32 Connection';
  }

  String getStatusText() {
    if (_isSimulationMode) return 'SIMULATION';
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return 'ESP32 CONNECTED';
      case ConnectionStatus.connecting:
        return 'CONNECTING TO ESP32';
      case ConnectionStatus.error:
        return 'ESP32 ERROR';
      case ConnectionStatus.disconnected:
        return 'ESP32 OFFLINE';
    }
  }

  String getConnectionQuality() {
    if (!isConnected) return 'No Connection';
    if (_dataRate > 15) return 'Excellent';
    if (_dataRate > 10) return 'Good';
    if (_dataRate > 5) return 'Fair';
    if (_dataRate > 0) return 'Poor';
    return 'No Data';
  }

  /// ───────────────────────────────────────────────────────────────────────────
  /// RAINFALL: OpenWeather → fallback estimator (from sensors)
  /// ───────────────────────────────────────────────────────────────────────────

  /// Heuristic fallback when API data is not available.
  /// Returns a rough rainfall in mm/day using air humidity and soil moisture.
  double _estimateRainfallFromSensors(SensorData d) {
    // Normalize inputs
    final h = d.humidity.clamp(0, 100) / 100.0; // 0..1
    final sm = (d.moisture.clamp(0, 100) - 30) / 70.0; // 0 at 30%, 1 at 100%
    final smClamped = sm.clamp(0.0, 1.0);

    // Base: if humidity high and soil wet, assume more rainfall
    // Scale: 0..200 mm/day (cap later to 500)
    final est = (h * 120.0) + (smClamped * 100.0) - 20.0;

    // Small boost for cooler temps (often rainy/cloudy conditions)
    final tempBoost = (25.0 - d.temperature).clamp(0.0, 8.0) * 2.5;

    final mm = max(0.0, est + tempBoost);
    return mm;
  }

  /// Try to fetch rainfall from OpenWeather. Prefers One Call Daily rain,
  /// falls back to Current rain[1h]/rain[3h]/0 if not present.
  Future<void> _refreshOpenWeatherRainfall() async {
    if (_lat == null || _lon == null) return;
    try {
      // First try: One Call Daily (requires appropriate OpenWeather plan)
      final oneCallUri = Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall'
              '?lat=${_lat!.toStringAsFixed(6)}'
              '&lon=${_lon!.toStringAsFixed(6)}'
              '&exclude=minutely,hourly,alerts'
              '&units=metric'
              '&appid=$_openWeatherApiKey');

      double? rainDaily;

      try {
        final oneCallRes = await http
            .get(oneCallUri)
            .timeout(const Duration(seconds: 6));
        if (oneCallRes.statusCode == 200) {
          final data = json.decode(oneCallRes.body);
          if (data is Map && data['daily'] is List && (data['daily'] as List).isNotEmpty) {
            final d0 = (data['daily'] as List).first;
            // daily.rain is in mm for that day if provided
            if (d0 is Map && d0['rain'] != null) {
              rainDaily = (d0['rain'] as num).toDouble();
            }
          }
        }
      } catch (_) {
        // Ignore One Call failures and try "weather" endpoint next
      }

      // Fallback: current weather endpoint with rain.1h / rain.3h
      if (rainDaily == null) {
        final currentUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather'
                '?lat=${_lat!.toStringAsFixed(6)}'
                '&lon=${_lon!.toStringAsFixed(6)}'
                '&units=metric'
                '&appid=$_openWeatherApiKey');

        final currentRes = await http
            .get(currentUri)
            .timeout(const Duration(seconds: 6));

        if (currentRes.statusCode == 200) {
          final data = json.decode(currentRes.body);
          if (data is Map && data['rain'] is Map) {
            final r = data['rain'] as Map;
            if (r['1h'] != null) {
              rainDaily = (r['1h'] as num).toDouble(); // mm in last 1 hour
            } else if (r['3h'] != null) {
              rainDaily =
                  (r['3h'] as num).toDouble(); // mm in last 3 hours (approx)
            } else {
              rainDaily = 0.0;
            }
          } else {
            rainDaily = 0.0;
          }
        }
      }

      // If both failed, keep old value (don’t overwrite with null)
      if (rainDaily != null) {
        _apiRainfallMm = rainDaily;
        _apiRainfallFetchedAt = DateTime.now();
        if (kDebugMode) {
          print('🌧️ OpenWeather rainfall updated: ${_apiRainfallMm} mm '
              '(source=${rainfallSource})');
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ OpenWeather fetch failed: $e');
      }
      // Don’t overwrite existing API value on failure
    }
  }

  /// ── Cleanup ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _stopRealTimePolling();
    _stopSimulation();
    super.dispose();
  }
}
