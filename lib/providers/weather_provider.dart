import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? currentWeather;
  bool isLoading = false;
  String error = "";

  /// WeatherAPI.com key (you provided this)
  static const String _apiKey = "77e3eb6d94484732bd051320251109";

  /// Fetch weather using WeatherAPI.com
  Future<void> fetchWeather() async {
    isLoading = true;
    error = "";
    notifyListeners();

    try {
      final position = await _determinePosition();

      final url =
          "https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=${position.latitude},${position.longitude}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception("Failed to load weather data: ${response.statusCode}");
      }

      final data = json.decode(response.body);

      // WeatherAPI ALWAYS returns rainfall (precip_mm)
      double rainfall =
          (data["current"]["precip_mm"] as num?)?.toDouble() ?? 0.0;

      currentWeather = WeatherData(
        location: data["location"]["name"] ?? "Unknown Location",
        temperature: (data["current"]["temp_c"] as num).toDouble(),
        feelsLike: (data["current"]["feelslike_c"] as num).toDouble(),
        humidity: (data["current"]["humidity"] as num).toDouble(),
        windSpeed: (data["current"]["wind_kph"] as num).toDouble(),
        condition: data["current"]["condition"]["text"],
        timestamp: DateTime.now(),
        rainfall: rainfall,
      );

      if (kDebugMode) {
        print("✅ Weather fetched: ${currentWeather!.location}");
        print("🌧 Rainfall: ${currentWeather!.rainfall} mm");
      }
    } catch (e) {
      error = "Error fetching weather: $e";
      if (kDebugMode) print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Manual refresh
  Future<void> refreshWeather() async {
    await fetchWeather();
  }

  /// Location permission handler
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('❌ Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('❌ Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        '❌ Location permissions are permanently denied. Enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Farming tips based on weather
  List<String> getFarmingRecommendations() {
    if (currentWeather == null) return [];

    final temp = currentWeather!.temperature;
    final humidity = currentWeather!.humidity;
    final condition = currentWeather!.condition.toLowerCase();
    final rainfall = currentWeather!.rainfall;

    List<String> tips = [];

    // Temperature-based suggestions
    if (temp < 20) {
      tips.add("❄️ Cold weather — consider frost protection.");
    } else if (temp > 35) {
      tips.add("🔥 Hot weather — increase irrigation and mulching.");
    } else {
      tips.add("🌿 Temperature is ideal for most crops.");
    }

    // Humidity-based suggestions
    if (humidity > 80) {
      tips.add("💧 High humidity — watch for fungal infections.");
    } else if (humidity < 30) {
      tips.add("🌵 Low humidity — irrigate more often.");
    }

    // Rainfall-based suggestions
    if (rainfall > 5) {
      tips.add("🌧️ Significant rainfall — reduce irrigation today.");
    } else if (rainfall == 0) {
      tips.add("☀️ No rain — maintain regular watering.");
    }

    // Condition-based
    if (condition.contains("rain")) {
      tips.add("🌧️ Rainy — avoid over-watering and fertilizer.");
    } else if (condition.contains("clear")) {
      tips.add("☀️ Clear skies — perfect time for pesticide spraying.");
    } else if (condition.contains("cloud")) {
      tips.add("☁️ Cloudy — stable conditions for most crops.");
    }

    tips.add("📅 Check soil moisture and adjust irrigation daily.");

    return tips;
  }
}
