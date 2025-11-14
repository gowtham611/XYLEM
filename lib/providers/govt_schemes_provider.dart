import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/govt_schemes_api_service.dart';
import '../services/govt_schemes_translations.dart';

class GovtScheme {
  final String name;
  final String description;
  final String eligibility;
  final String amount;
  final String deadline;
  final String applyLink;
  final String region;
  final String category;
  final String ministry;
  final String status;

  GovtScheme({
    required this.name,
    required this.description,
    required this.eligibility,
    required this.amount,
    required this.deadline,
    required this.applyLink,
    required this.region,
    this.category = 'General',
    this.ministry = 'Government of India',
    this.status = 'Active',
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
      category: json['category'] ?? 'General',
      ministry: json['ministry'] ?? 'Government of India',
      status: json['status'] ?? 'Active',
    );
  }

  /// Get localized content based on language code
  String getLocalizedName(String languageCode) {
    final translation = GovtSchemesTranslations.getTranslation(name, languageCode);
    return translation?['name'] ?? name;
  }

  String getLocalizedDescription(String languageCode) {
    final translation = GovtSchemesTranslations.getTranslation(name, languageCode);
    return translation?['description'] ?? description;
  }

  String getLocalizedEligibility(String languageCode) {
    final translation = GovtSchemesTranslations.getTranslation(name, languageCode);
    return translation?['eligibility'] ?? eligibility;
  }

  String getLocalizedAmount(String languageCode) {
    final translation = GovtSchemesTranslations.getTranslation(name, languageCode);
    return translation?['amount'] ?? amount;
  }

  String getLocalizedDeadline(String languageCode) {
    final translation = GovtSchemesTranslations.getTranslation(name, languageCode);
    return translation?['deadline'] ?? deadline;
  }

  String getLocalizedMinistry(String languageCode) {
    final translation = GovtSchemesTranslations.getTranslation(name, languageCode);
    return translation?['ministry'] ?? ministry;
  }

  String getLocalizedRegion(String languageCode) {
    final translation = GovtSchemesTranslations.getTranslation(name, languageCode);
    return translation?['region'] ?? region;
  }
}

class GovtSchemesProvider with ChangeNotifier {
  List<GovtScheme> _schemes = [];
  List<GovtScheme> _allSchemes = [];
  bool _isLoading = false;
  String _error = '';
  String _currentRegion = '';
  String _selectedCategory = 'All';
  
  List<GovtScheme> get schemes => _schemes;
  List<GovtScheme> get allSchemes => _allSchemes;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentRegion => _currentRegion;
  String get selectedCategory => _selectedCategory;
  
  // Get unique categories
  List<String> get categories {
    final cats = _allSchemes.map((s) => s.category).toSet().toList();
    cats.insert(0, 'All');
    return cats;
  }

  Future<void> fetchSchemes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Get current location to determine region
      await _getCurrentRegion();
      
      // Fetch schemes from API service
      final schemesData = await GovtSchemesApiService.fetchGovernmentSchemes(
        state: _currentRegion.isNotEmpty ? _currentRegion : null,
      );
      
      _allSchemes = schemesData.map((json) => GovtScheme.fromJson(json)).toList();
      _filterSchemes();
      
    } catch (e) {
      _error = 'Failed to fetch schemes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void filterByCategory(String category) {
    _selectedCategory = category;
    _filterSchemes();
    notifyListeners();
  }
  
  void _filterSchemes() {
    if (_selectedCategory == 'All') {
      _schemes = _allSchemes;
    } else {
      _schemes = _allSchemes.where((s) => s.category == _selectedCategory).toList();
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
