import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/govt_schemes_provider.dart';
import '../l10n/app_localizations.dart';

class GovernmentSchemesWidget extends StatefulWidget {
  const GovernmentSchemesWidget({super.key});

  @override
  _GovernmentSchemesWidgetState createState() =>
      _GovernmentSchemesWidgetState();
}

class _GovernmentSchemesWidgetState extends State<GovernmentSchemesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GovtSchemesProvider>(context, listen: false).fetchSchemes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<GovtSchemesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.schemes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.error),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchSchemes(),
                  child: Text(l10n?.retry ?? 'Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.schemes.isEmpty) {
          return Center(
            child: Text(l10n?.noSchemesAvailable ?? 'No schemes available'),
          );
        }

        return Column(
          children: [
            // Category Filter Chips
            if (provider.categories.length > 1)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    final isSelected = provider.selectedCategory == category;
                    final localizedCategory = l10n != null ? _getLocalizedCategory(l10n, category) : category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(localizedCategory),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.filterByCategory(category);
                        },
                        selectedColor: Colors.green[100],
                        checkmarkColor: Colors.green[700],
                      ),
                    );
                  },
                ),
              ),
            
            // Region Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n?.showingSchemes ?? "Showing schemes for"}: ${provider.currentRegion.isNotEmpty ? provider.currentRegion : (l10n?.allIndia ?? "All India")}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.schemes.length} ${l10n?.schemesAvailable ?? "schemes"}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            
            // Schemes List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refreshSchemes(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.schemes.length,
                  itemBuilder: (context, index) {
                    final scheme = provider.schemes[index];
                    return _buildSchemeCard(context, scheme, l10n);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getLocalizedCategory(AppLocalizations l10n, String category) {
    switch (category) {
      case 'All':
        return l10n.allCategories;
      case 'Income Support':
        return l10n.categoryIncomeSupport;
      case 'Insurance':
        return l10n.categoryInsurance;
      case 'Energy & Infrastructure':
        return l10n.categoryEnergy;
      case 'Irrigation':
        return l10n.categoryIrrigation;
      case 'Credit & Finance':
        return l10n.categoryCredit;
      case 'Soil Management':
        return l10n.categorySoilManagement;
      case 'Market Access':
        return l10n.categoryMarketAccess;
      case 'Organic Farming':
        return l10n.categoryOrganicFarming;
      case 'Horticulture':
        return l10n.categoryHorticulture;
      case 'Mechanization':
        return l10n.categoryMechanization;
      case 'FPO Support':
        return l10n.categoryFPOSupport;
      case 'Input Subsidy':
        return l10n.categoryInputSubsidy;
      default:
        return category;
    }
  }

  Widget _buildSchemeCard(BuildContext context, GovtScheme scheme, AppLocalizations? l10n) {
    // Get current locale
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Category Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    scheme.getLocalizedName(languageCode),
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n != null ? _getLocalizedCategory(l10n, scheme.category) : scheme.category,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Description
            Text(
              scheme.getLocalizedDescription(languageCode),
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            
            // Details
            _buildDetailRow(Icons.verified_user, l10n?.eligibility ?? "Eligibility", scheme.getLocalizedEligibility(languageCode)),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.attach_money, l10n?.benefits ?? "Benefits", scheme.getLocalizedAmount(languageCode)),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.calendar_today, l10n?.deadline ?? "Deadline", scheme.getLocalizedDeadline(languageCode)),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.account_balance, l10n?.ministry ?? "Ministry", scheme.getLocalizedMinistry(languageCode)),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.location_city, l10n?.region ?? "Region", scheme.getLocalizedRegion(languageCode)),
            
            const SizedBox(height: 16),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Uri url = Uri.parse(scheme.applyLink);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n?.unableToOpenLink ?? "Unable to open link")),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n?.applyNow ?? "Apply Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[800]),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}