import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "f932ac201c369d916c02400fd855bf85";

  /// Fetch rainfall using OpenWeather One Call 3.0 API
  /// Returns rainfall in mm (scaled for model compatibility)
  static Future<double> getRainfall(double lat, double lon) async {
    try {
      final url =
          "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print("❌ Weather API Error: ${response.statusCode} ${response.body}");
        return 0.0;
      }

      final data = jsonDecode(response.body);

      double totalRain = 0.0;

      // Last 24 hours + next 24 hours = 48 hourly entries
      if (data["hourly"] != null) {
        for (int i = 0; i < 48 && i < data["hourly"].length; i++) {
          final hour = data["hourly"][i];
          if (hour["rain"] != null &&
              hour["rain"]["1h"] != null &&
              hour["rain"]["1h"] is num) {
            totalRain += (hour["rain"]["1h"] as num).toDouble();
          }
        }
      }

      print("🌧️ Raw rainfall (48h): $totalRain mm");

      // Model was trained on *monthly* rainfall (0–300mm)
      final scaledRainfall = totalRain * 3;

      print("🌧️ Final rainfall sent to model: $scaledRainfall mm");

      return scaledRainfall;
    } catch (e) {
      print("❌ Rainfall fetch exception: $e");
      return 0.0;
    }
  }
}
