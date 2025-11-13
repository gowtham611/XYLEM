class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String condition;
  final DateTime timestamp;
  final double rainfall;   // <-- Add this

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.timestamp,
    required this.rainfall,   // <-- Add this
  });
}
