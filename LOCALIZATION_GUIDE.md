# Kannada Multilingual Support Guide

## ✅ What's Already Set Up

Your app already has the foundation for Kannada multilingual support:

1. ✅ `l10n.yaml` configuration file
2. ✅ `app_en.arb` - English translations
3. ✅ `app_kn.arb` - Kannada translations (ಕನ್ನಡ)
4. ✅ Auto-generated localization files
5. ✅ Language provider for state management
6. ✅ Language selector widget

## 🎯 How to Use Localization in Your Screens

### Step 1: Import AppLocalizations

In any screen where you want to use localized strings, add this import:

```dart
import '../l10n/app_localizations.dart';
```

### Step 2: Get the Localization Object

Inside your widget's `build` method, get the localization object:

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  
  // Now use l10n to access translated strings
  return Text(l10n?.dashboard ?? 'Dashboard');
}
```

### Step 3: Use Localized Strings

Replace hardcoded strings with localized ones:

**Before:**
```dart
Text('Dashboard')
```

**After:**
```dart
Text(l10n?.dashboard ?? 'Dashboard')
```

## 📝 Complete Example: Updating a Screen

Here's how to update your `home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // Get localization
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'Smart Agriculture Pro'),
      ),
      body: Column(
        children: [
          Text(l10n?.goodMorning ?? 'Good Morning, Farmer!'),
          Text(l10n?.farmStatus ?? 'Your farm is looking great today.'),
          
          // Dashboard cards
          Card(
            child: ListTile(
              title: Text(l10n?.temperature ?? 'Temperature'),
              subtitle: Text('25°C'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(l10n?.humidity ?? 'Humidity'),
              subtitle: Text('65%'),
            ),
          ),
          
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n?.startMonitoring ?? 'Start Monitoring'),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 How to Add New Translations

### 1. Add to English (app_en.arb)

```json
{
  "newKey": "English Text"
}
```

### 2. Add to Kannada (app_kn.arb)

```json
{
  "newKey": "ಕನ್ನಡ ಪಠ್ಯ"
}
```

### 3. Run Code Generation

After adding new strings, run:

```bash
flutter gen-l10n
```

Or just save the file and it will auto-generate.

### 4. Use in Your Code

```dart
Text(l10n?.newKey ?? 'Fallback Text')
```

## 📱 Available Translations

Here are all the currently available translation keys:

| Key | English | Kannada |
|-----|---------|---------|
| `appTitle` | Smart Agriculture Pro | ಸ್ಮಾರ್ಟ್ ಕೃಷಿ ಪ್ರೋ |
| `dashboard` | Dashboard | ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ |
| `sensors` | Sensors | ಸಂವೇದಕಗಳು |
| `assistant` | Assistant | ಸಹಾಯಕ |
| `weather` | Weather | ಹವಾಮಾನ |
| `market` | Market | ಮಾರುಕಟ್ಟೆ |
| `schemes` | Schemes | ಯೋಜನೆಗಳು |
| `goodMorning` | Good Morning, Farmer! | ಶುಭೋದಯ, ರೈತರೇ! |
| `temperature` | Temperature | ತಾಪಮಾನ |
| `humidity` | Humidity | ಆರ್ದ್ರತೆ |
| `soilHealth` | Soil Health | ಮಣ್ಣಿನ ಆರೋಗ್ಯ |
| `startMonitoring` | Start Monitoring | ಮಾನಿಟರಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ |
| `stopMonitoring` | Stop Monitoring | ಮಾನಿಟರಿಂಗ್ ನಿಲ್ಲಿಸಿ |
| `selectLanguage` | Select Language | ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ |

## 🌐 How Users Change Language

Users can change the language in two ways:

### 1. Using the Language Button

The home screen already has a language button in the app bar. When clicked, it shows a language selector dialog.

### 2. Programmatically

```dart
Provider.of<LanguageProvider>(context, listen: false)
    .changeLanguage(const Locale('kn')); // Switch to Kannada

Provider.of<LanguageProvider>(context, listen: false)
    .changeLanguage(const Locale('en')); // Switch to English
```

## 🎨 Example: Complete Widget with Localization

```dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class DashboardCard extends StatelessWidget {
  final String sensorType;
  final String value;
  
  const DashboardCard({
    required this.sensorType,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Map sensor types to localized strings
    String getLocalizedSensorName() {
      switch (sensorType) {
        case 'temperature':
          return l10n?.temperature ?? 'Temperature';
        case 'humidity':
          return l10n?.humidity ?? 'Humidity';
        case 'soilHealth':
          return l10n?.soilHealth ?? 'Soil Health';
        default:
          return sensorType;
      }
    }
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              getLocalizedSensorName(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🚀 Quick Testing

1. Run your app: `flutter run`
2. Click the language button in the app bar
3. Select "ಕನ್ನಡ" (Kannada)
4. All text should switch to Kannada!

## 📋 Checklist for Adding Localization to a Screen

- [ ] Import `AppLocalizations`: `import '../l10n/app_localizations.dart';`
- [ ] Get l10n object: `final l10n = AppLocalizations.of(context);`
- [ ] Replace all hardcoded strings with `l10n?.keyName ?? 'Fallback'`
- [ ] Test in both English and Kannada

## ⚠️ Common Mistakes to Avoid

1. **Forgetting the null safety operator (`?.`)**
   ```dart
   // ❌ Wrong
   Text(l10n.dashboard)
   
   // ✅ Correct
   Text(l10n?.dashboard ?? 'Dashboard')
   ```

2. **Not providing a fallback**
   ```dart
   // ❌ Risky (could show null)
   Text(l10n?.dashboard)
   
   // ✅ Safe (always shows something)
   Text(l10n?.dashboard ?? 'Dashboard')
   ```

3. **Hardcoding strings instead of using localization**
   ```dart
   // ❌ Wrong
   Text('Dashboard')
   
   // ✅ Correct
   Text(l10n?.dashboard ?? 'Dashboard')
   ```

## 🔄 Regenerating Localization Files

If you manually edit the ARB files or they get out of sync, run:

```bash
flutter clean
flutter pub get
flutter gen-l10n
```

## 📚 Additional Resources

- [Flutter Internationalization Documentation](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
