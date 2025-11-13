import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketApiService {
  static const String apiKey =
      "579b464db66ec23bdd000001e9a030581e9a40f5771bdb629e77b4b0";

  static const String resourceId =
      "9ef84268-d588-465a-a308-a864a43d0070";

  static Future<List<Map<String, dynamic>>> fetchAllCrops(String state) async {
    final url = Uri.parse(
      "https://api.data.gov.in/resource/$resourceId"
      "?api-key=$apiKey&format=json&limit=200"
      "&filters[state]=$state",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json["records"]);
    } else {
      throw Exception("Failed to fetch crops");
    }
  }
}
