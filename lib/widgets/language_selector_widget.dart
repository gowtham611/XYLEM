import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ...languageProvider.supportedLocales.map((locale) {
                final isSelected = languageProvider.currentLocale == locale;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200],
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.language,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  title: Text(
                    languageProvider.getLanguageName(locale.languageCode),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(_getLanguageNativeName(locale.languageCode)),
                  onTap: () {
                    languageProvider.changeLanguage(locale);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'kn':
        return 'ಕನ್ನಡ';
      default:
        return 'English';
    }
  }
}
