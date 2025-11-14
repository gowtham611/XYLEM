# Government Schemes API Integration

## Overview
The XYLEM app now includes comprehensive government agricultural schemes information with real data from various central and state government programs.

## Features

### ✅ Included Schemes (2025)

#### Central Government Schemes:
1. **PM-KISAN** - ₹6,000/year direct income support
2. **PM Fasal Bima Yojana (PMFBY)** - Crop insurance
3. **PM-KUSUM** - Solar pump subsidy
4. **PMKSY** - Irrigation infrastructure support
5. **Kisan Credit Card (KCC)** - Subsidized credit
6. **Soil Health Card Scheme** - Free soil testing
7. **e-NAM** - National Agriculture Market access
8. **Paramparagat Krishi Vikas Yojana** - Organic farming
9. **National Horticulture Mission** - Horticulture support
10. **SMAM** - Agricultural mechanization subsidy
11. **Interest Subvention Scheme** - Loan interest subsidy
12. **FPO Formation** - Farmer Producer Organization support

#### State Schemes (Karnataka):
1. **Karnataka Raitha Siri** - ₹10,000/hectare input subsidy
2. **Krishi Bhagya** - Irrigation infrastructure (farm ponds, bore wells)
3. **Bhoochetana** - Soil health improvement

#### State Schemes (Tamil Nadu):
1. **TN FPO Grant** - Support for Farmer Producer Companies

## Implementation Details

### Service Architecture
```
lib/services/govt_schemes_api_service.dart
├── fetchGovernmentSchemes() - Get all schemes
├── fetchStateSchemes(state) - State-specific schemes
├── categorizeSchemes() - Group by category
└── filterByEligibility() - Custom filtering
```

### Data Structure
Each scheme contains:
- **name** - Scheme title
- **description** - What it offers
- **eligibility** - Who can apply
- **amount** - Financial benefits
- **deadline** - Application deadline
- **apply_link** - Official portal URL
- **region** - All India / State name
- **category** - Type (Insurance, Credit, etc.)
- **ministry** - Implementing department
- **status** - Active/Inactive

### Categories Available:
- Income Support
- Insurance
- Energy & Infrastructure
- Irrigation
- Credit & Finance
- Soil Management
- Market Access
- Organic Farming
- Horticulture
- Mechanization
- FPO Support
- Input Subsidy

## User Interface Features

### 🎯 Category Filtering
- Filter chips to browse schemes by category
- "All" option to see everything
- Dynamic counting of schemes in each category

### 📍 Location-Based Display
- Automatically detects user's state using GPS
- Shows relevant state schemes + all-India schemes
- Displays current location at top

### 🔄 Pull-to-Refresh
- Swipe down to update schemes list
- Refreshes location data

### 📱 Scheme Cards Show:
- Scheme name with category badge
- Full description
- Eligibility criteria
- Benefit amount
- Application deadline
- Implementing ministry
- Geographic coverage
- Direct "Apply Now" button

## How It Works

1. **On App Launch**
   - Provider requests location permission
   - Detects user's state (e.g., Karnataka)
   - Loads relevant schemes

2. **Scheme Loading**
   - Fetches all schemes from API service
   - Filters based on user's location
   - Shows both state-specific and national schemes

3. **Category Filtering**
   - User taps category chip
   - List filters to show only that category
   - Counter updates dynamically

4. **Application**
   - User taps "Apply Now"
   - Opens official government portal
   - User completes application online

## Data Sources

### Current Implementation:
- Curated list of official government schemes
- Based on data from:
  - PM-KISAN portal
  - PM Fasal Bima Yojana website
  - PM-KUSUM portal
  - Karnataka Raitha Mitra
  - Other official government sources

### Future API Integration:
- data.gov.in API (when available)
- State agriculture department APIs
- Real-time scheme updates
- Dynamic eligibility checking

## Customization

### Adding New Schemes
Edit `lib/services/govt_schemes_api_service.dart`:

```dart
{
  'name': 'New Scheme Name',
  'description': 'What it offers',
  'eligibility': 'Who can apply',
  'amount': '₹X lakh',
  'deadline': 'Date',
  'apply_link': 'https://...',
  'region': 'State Name or All India',
  'category': 'Category Type',
  'ministry': 'Implementing Ministry',
  'status': 'Active',
  'last_updated': DateTime.now().toIso8601String(),
}
```

### Adding New States
Add state-specific sections:

```dart
if (state == null || state == 'Your State') ...[
  {
    // State scheme details
  },
],
```

### Adding New Categories
Just add new schemes with new category names. The UI automatically:
- Detects unique categories
- Creates filter chips
- Groups schemes accordingly

## Benefits for Farmers

1. **Discover Benefits** - Learn about all available schemes
2. **Check Eligibility** - Clear criteria listed
3. **Direct Application** - One-tap access to portals
4. **Location-Aware** - See relevant schemes first
5. **Organized View** - Filter by type of support needed
6. **Up-to-Date Info** - Latest 2025 schemes included

## Technical Notes

### Location Detection:
- Uses Geolocator package
- Requests location permission
- Falls back to "Karnataka" if denied
- Uses reverse geocoding for state name

### Error Handling:
- Shows user-friendly error messages
- Retry button for failed loads
- Graceful fallback if location unavailable

### Performance:
- Loads schemes asynchronously
- Caches in provider state
- Fast filtering (in-memory)
- Minimal network calls

## Official Portals Linked

All "Apply Now" buttons link to official government websites:
- https://pmkisan.gov.in/
- https://pmfby.gov.in/
- https://pmkusum.mnre.gov.in/
- https://pmksy.gov.in/
- https://www.enam.gov.in/
- https://raitamitra.karnataka.gov.in/
- And more...

## Maintenance

### Updating Schemes:
1. Check official portals quarterly
2. Update deadlines in service file
3. Add new schemes as announced
4. Mark expired schemes as inactive

### State Coverage:
Currently optimized for:
- All India schemes (12)
- Karnataka (3)
- Tamil Nadu (1)

To add more states, follow the pattern in `_getComprehensiveSchemesList()`.

## Future Enhancements

- [ ] Bookmark favorite schemes
- [ ] Application status tracking
- [ ] Notification for deadlines
- [ ] Kannada translations for scheme details
- [ ] Document checklist for each scheme
- [ ] Success stories from beneficiaries

---

**Last Updated:** November 14, 2025
**Total Schemes:** 16+
**Coverage:** All India + Karnataka + Tamil Nadu
