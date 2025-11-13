import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GovtScheme {
  final String name;
  final String description;
  final String eligibility;
  final String amount;
  final String deadline;
  final String applyLink;
  final String region;

  GovtScheme({
    required this.name,
    required this.description,
    required this.eligibility,
    required this.amount,
    required this.deadline,
    required this.applyLink,
    required this.region,
  });

  factory GovtScheme.fromJson(Map<String, dynamic> json) {
    return GovtScheme(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      eligibility: json['eligibility'] ?? '',
      amount: json['amount'] ?? '',
      deadline: json['deadline'] ?? '',
      applyLink: json['apply_link'] ?? '',
      region: json['region'] ?? '',
    );
  }
}

class GovtSchemesProvider with ChangeNotifier {
  List<GovtScheme> _schemes = [];
  bool _isLoading = false;
  String _error = '';
  String _currentRegion = '';
  
  // Demo schemes data (replace with actual API)
  final List<Map<String, dynamic>> _demoSchemes = [
    {
      'name': 'PM-KUSUM Solar Pump Subsidy',
      'description': 'Solar pump installation subsidy for farmers',
      'eligibility': 'All farmers with agricultural land',
      'amount': '65% subsidy up to ₹4.8 lakh',
      'deadline': '31st December 2025',
      'apply_link': 'https://pmkusum.mnre.gov.in/',
      'region': 'Karnataka',
    },
    {
      'name': 'Pradhan Mantri Fasal Bima Yojana',
      'description': 'Crop insurance scheme for farmers',
      'eligibility': 'All farmers growing crops',
      'amount': 'Premium subsidy up to 90%',
      'deadline': 'Ongoing',
      'apply_link': 'https://pmfby.gov.in/',
      'region': 'All India',
    },
    {
      'name': 'Karnataka Raitha Siri Scheme',
      'description': 'Agricultural input subsidy for Karnataka farmers',
      'eligibility': 'Karnataka farmers with land records',
      'amount': '₹10,000 per hectare',
      'deadline': '30th June 2025',
      'apply_link': 'https://raitamitra.karnataka.gov.in/',
      'region': 'Karnataka',
    },
    {
      'name': 'Micro Irrigation Scheme',
      'description': 'Drip and sprinkler irrigation subsidy',
      'eligibility': 'Small and marginal farmers',
      'amount': '55% subsidy for drip/sprinkler',
      'deadline': '31st March 2026',
      'apply_link': 'https://pmksy.gov.in/',
      'region': 'All India',
    },
  ];

  List<GovtScheme> get schemes => _schemes;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentRegion => _currentRegion;

  Future<void> fetchSchemes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Get current location to determine region
      await _getCurrentRegion();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Filter schemes based on region or show all
      final relevantSchemes = _demoSchemes.where((scheme) {
        return scheme['region'] == 'All India' || 
               scheme['region'] == _currentRegion ||
               _currentRegion.isEmpty;
      }).toList();
      
      _schemes = relevantSchemes.map((json) => GovtScheme.fromJson(json)).toList();
      
    } catch (e) {
      _error = 'Failed to fetch schemes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getCurrentRegion() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _currentRegion = 'Karnataka'; // Default
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _currentRegion = 'Karnataka'; // Default
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        _currentRegion = placemarks.first.administrativeArea ?? 'Karnataka';
      } else {
        _currentRegion = 'Karnataka'; // Default
      }
    } catch (e) {
      _currentRegion = 'Karnataka'; // Default fallback
    }
  }

  Future<void> refreshSchemes() async {
    await fetchSchemes();
  }
}
