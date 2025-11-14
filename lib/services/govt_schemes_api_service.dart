import 'dart:convert';
import 'package:http/http.dart' as http;

class GovtSchemesApiService {
  // Government of India Data Portal API
  static const String _dataGovApiKey = 'YOUR_DATA_GOV_API_KEY'; // Get from https://data.gov.in/
  static const String _dataGovBaseUrl = 'https://api.data.gov.in';
  
  // Alternative: Using public government portals (no key required)
  static const String _pmksyUrl = 'https://pmksy.gov.in/';
  static const String _pmfbyUrl = 'https://pmfby.gov.in/';
  static const String _pmkisanUrl = 'https://pmkisan.gov.in/';
  
  // Flag to check if API key is configured
  static bool get isConfigured => _dataGovApiKey.isNotEmpty && _dataGovApiKey.length > 20;

  /// Fetches government agricultural schemes
  /// Returns a comprehensive list of central and state schemes
  static Future<List<Map<String, dynamic>>> fetchGovernmentSchemes({
    String? state,
    String? category,
  }) async {
    try {
      // For now, we'll use curated data from reliable government sources
      // In production, integrate with official APIs when available
      
      final schemes = await _getComprehensiveSchemesList(state: state);
      
      if (category != null) {
        return schemes.where((scheme) => 
          scheme['category']?.toString().toLowerCase() == category.toLowerCase()
        ).toList();
      }
      
      return schemes;
    } catch (e) {
      print('⚠️ Error fetching government schemes: $e');
      return _getFallbackSchemes(state: state);
    }
  }

  /// Fetches schemes specifically for a state
  static Future<List<Map<String, dynamic>>> fetchStateSchemes(String state) async {
    try {
      final allSchemes = await _getComprehensiveSchemesList(state: state);
      
      return allSchemes.where((scheme) =>
        scheme['region'] == state || scheme['region'] == 'All India'
      ).toList();
    } catch (e) {
      print('⚠️ Error fetching state schemes: $e');
      return _getFallbackSchemes(state: state);
    }
  }

  /// Comprehensive list of government agricultural schemes (2025)
  static Future<List<Map<String, dynamic>>> _getComprehensiveSchemesList({String? state}) async {
    return [
      // Central Government Schemes
      {
        'name': 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
        'description': 'Direct income support of ₹6,000 per year to all farmer families in three equal installments of ₹2,000 each.',
        'eligibility': 'All landholding farmer families across India',
        'amount': '₹6,000 per year',
        'deadline': 'Ongoing',
        'apply_link': 'https://pmkisan.gov.in/',
        'region': 'All India',
        'category': 'Income Support',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'PM Fasal Bima Yojana (PMFBY)',
        'description': 'Comprehensive crop insurance scheme providing financial support to farmers in case of crop loss due to natural calamities, pests & diseases.',
        'eligibility': 'All farmers growing notified crops in notified areas',
        'amount': 'Premium: 2% for Kharif, 1.5% for Rabi, 5% for horticulture crops',
        'deadline': 'Season-based enrollment',
        'apply_link': 'https://pmfby.gov.in/',
        'region': 'All India',
        'category': 'Insurance',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'PM-KUSUM (Solar Pump Scheme)',
        'description': 'Provides financial support for installation of solar pumps and grid-connected solar power plants in rural areas.',
        'eligibility': 'All farmers',
        'amount': '30% subsidy by Central Govt + 30% by State + 30% loan, farmer pays 10%',
        'deadline': '31st March 2026',
        'apply_link': 'https://pmkusum.mnre.gov.in/',
        'region': 'All India',
        'category': 'Energy & Infrastructure',
        'ministry': 'Ministry of New & Renewable Energy',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Pradhan Mantri Krishi Sinchayee Yojana (PMKSY)',
        'description': 'Focuses on expanding cultivable area with assured irrigation, improving water use efficiency, and adopting precision-irrigation.',
        'eligibility': 'All farmers',
        'amount': 'Up to 55% subsidy for drip/sprinkler irrigation',
        'deadline': 'Ongoing',
        'apply_link': 'https://pmksy.gov.in/',
        'region': 'All India',
        'category': 'Irrigation',
        'ministry': 'Ministry of Jal Shakti',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Kisan Credit Card (KCC)',
        'description': 'Provides farmers with timely access to credit for their cultivation and other needs at concessional interest rates.',
        'eligibility': 'All farmers including tenant farmers, sharecroppers',
        'amount': 'Credit limit based on land holding and crop pattern',
        'deadline': 'Ongoing',
        'apply_link': 'https://www.nabard.org/content1.aspx?id=523&catid=8&mid=489',
        'region': 'All India',
        'category': 'Credit & Finance',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Soil Health Card Scheme',
        'description': 'Provides soil health cards to farmers which carry crop-wise recommendations of nutrients and fertilizers required for individual farms.',
        'eligibility': 'All farmers',
        'amount': 'Free soil testing',
        'deadline': 'Ongoing',
        'apply_link': 'https://soilhealth.dac.gov.in/',
        'region': 'All India',
        'category': 'Soil Management',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'National Agriculture Market (e-NAM)',
        'description': 'Pan-India electronic trading portal which networks the existing APMC mandis to create a unified national market for agricultural commodities.',
        'eligibility': 'All farmers',
        'amount': 'Free registration and trading',
        'deadline': 'Ongoing',
        'apply_link': 'https://www.enam.gov.in/',
        'region': 'All India',
        'category': 'Market Access',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Paramparagat Krishi Vikas Yojana (PKVY)',
        'description': 'Promotes organic farming and provides assistance for certification and marketing of organic produce.',
        'eligibility': 'Farmers practicing or willing to adopt organic farming',
        'amount': '₹50,000 per hectare over 3 years',
        'deadline': 'Ongoing',
        'apply_link': 'https://pgsindia-ncof.gov.in/',
        'region': 'All India',
        'category': 'Organic Farming',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'National Horticulture Mission',
        'description': 'Provides support for holistic growth of horticulture sector covering fruits, vegetables, root & tuber crops, mushrooms, spices, flowers, aromatics, cashew and cocoa.',
        'eligibility': 'Individual farmers, groups, FPOs',
        'amount': 'Varies by component (40-50% subsidy)',
        'deadline': 'Ongoing',
        'apply_link': 'https://midh.gov.in/',
        'region': 'All India',
        'category': 'Horticulture',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Sub-Mission on Agricultural Mechanization (SMAM)',
        'description': 'Promotes farm mechanization to increase productivity, reduce drudgery and wastage, and improve the economic condition of farmers.',
        'eligibility': 'Individual farmers, Custom Hiring Centers, FPOs',
        'amount': '40-50% subsidy on agricultural machinery',
        'deadline': 'Ongoing',
        'apply_link': 'https://agrimachinery.nic.in/',
        'region': 'All India',
        'category': 'Mechanization',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      
      // Karnataka State Schemes
      if (state == null || state == 'Karnataka') ...[
        {
          'name': 'Karnataka Raitha Siri Scheme',
          'description': 'Comprehensive agricultural package providing support for seeds, fertilizers, and agricultural inputs.',
          'eligibility': 'All farmers in Karnataka with valid land records',
          'amount': '₹10,000 per hectare (up to 10 hectares)',
          'deadline': '30th June 2025',
          'apply_link': 'https://raitamitra.karnataka.gov.in/',
          'region': 'Karnataka',
          'category': 'Input Subsidy',
          'ministry': 'Karnataka Agriculture Department',
          'status': 'Active',
          'last_updated': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Krishi Bhagya Scheme',
          'description': 'Provides assistance for creation of irrigation infrastructure including farm ponds, bore wells, and lift irrigation.',
          'eligibility': 'Small and marginal farmers in Karnataka',
          'amount': 'Up to ₹2 lakh for farm pond, ₹1 lakh for bore well',
          'deadline': 'Ongoing',
          'apply_link': 'https://raitamitra.karnataka.gov.in/',
          'region': 'Karnataka',
          'category': 'Irrigation',
          'ministry': 'Karnataka Agriculture Department',
          'status': 'Active',
          'last_updated': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Bhoochetana Scheme',
          'description': 'Soil health improvement program with focus on micro-nutrient management and soil testing.',
          'eligibility': 'All farmers in Karnataka',
          'amount': 'Free soil testing and micro-nutrient kits',
          'deadline': 'Ongoing',
          'apply_link': 'https://raitamitra.karnataka.gov.in/',
          'region': 'Karnataka',
          'category': 'Soil Management',
          'ministry': 'Karnataka Agriculture Department',
          'status': 'Active',
          'last_updated': DateTime.now().toIso8601String(),
        },
      ],
      
      // Tamil Nadu State Schemes
      if (state == null || state == 'Tamil Nadu') ...[
        {
          'name': 'Tamil Nadu Farmer Producer Companies Grant',
          'description': 'Financial assistance to Farmer Producer Companies for infrastructure development and working capital.',
          'eligibility': 'Registered Farmer Producer Companies in Tamil Nadu',
          'amount': 'Up to ₹10 lakh',
          'deadline': 'Ongoing',
          'apply_link': 'https://www.tn.gov.in/scheme/department_wise/4',
          'region': 'Tamil Nadu',
          'category': 'FPO Support',
          'ministry': 'Tamil Nadu Agriculture Department',
          'status': 'Active',
          'last_updated': DateTime.now().toIso8601String(),
        },
      ],
      
      // Additional Universal Schemes
      {
        'name': 'Interest Subvention Scheme',
        'description': 'Provides short-term crop loans to farmers at subsidized interest rates.',
        'eligibility': 'Farmers availing crop loans up to ₹3 lakh',
        'amount': '2% interest subvention, additional 3% for prompt repayment',
        'deadline': 'Ongoing',
        'apply_link': 'https://www.nabard.org/',
        'region': 'All India',
        'category': 'Credit & Finance',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Formation and Promotion of FPOs',
        'description': 'Support for formation of 10,000 new Farmer Producer Organizations (FPOs) with financial assistance.',
        'eligibility': 'Groups of farmers forming FPOs',
        'amount': '₹15-33 lakh per FPO over 5 years',
        'deadline': '31st December 2027',
        'apply_link': 'https://www.nabard.org/',
        'region': 'All India',
        'category': 'FPO Support',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
    ];
  }

  /// Fallback schemes when API is unavailable
  static List<Map<String, dynamic>> _getFallbackSchemes({String? state}) {
    return [
      {
        'name': 'PM-KISAN',
        'description': 'Direct income support of ₹6,000 per year to farmer families',
        'eligibility': 'All landholding farmers',
        'amount': '₹6,000 per year',
        'deadline': 'Ongoing',
        'apply_link': 'https://pmkisan.gov.in/',
        'region': 'All India',
        'category': 'Income Support',
        'ministry': 'Ministry of Agriculture',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'name': 'PM Fasal Bima Yojana',
        'description': 'Comprehensive crop insurance scheme',
        'eligibility': 'All farmers',
        'amount': 'Low premium with high coverage',
        'deadline': 'Season-based',
        'apply_link': 'https://pmfby.gov.in/',
        'region': 'All India',
        'category': 'Insurance',
        'ministry': 'Ministry of Agriculture',
        'status': 'Active',
        'last_updated': DateTime.now().toIso8601String(),
      },
    ];
  }

  /// Categorizes schemes by type
  static Map<String, List<Map<String, dynamic>>> categorizeSchemes(
    List<Map<String, dynamic>> schemes
  ) {
    final categories = <String, List<Map<String, dynamic>>>{};
    
    for (var scheme in schemes) {
      final category = scheme['category']?.toString() ?? 'Other';
      categories.putIfAbsent(category, () => []).add(scheme);
    }
    
    return categories;
  }

  /// Filters schemes by eligibility criteria
  static List<Map<String, dynamic>> filterByEligibility(
    List<Map<String, dynamic>> schemes,
    {bool? isSmallFarmer, bool? hasDrip, String? cropType}
  ) {
    return schemes.where((scheme) {
      // Add custom filtering logic based on farmer profile
      return true; // For now, return all
    }).toList();
  }
}
