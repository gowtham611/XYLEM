import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/govt_schemes_provider.dart';

class GovernmentSchemesWidget extends StatefulWidget {
  const GovernmentSchemesWidget({super.key});

  @override
  _GovernmentSchemesWidgetState createState() => _GovernmentSchemesWidgetState();
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
    return Consumer<GovtSchemesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Searching schemes for your region...'),
              ],
            ),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchSchemes(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.schemes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No schemes found for your region'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refreshSchemes(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshSchemes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.schemes.length,
            itemBuilder: (context, index) {
              final scheme = provider.schemes[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scheme.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildSchemeDetail('Eligibility', scheme.eligibility),
                      _buildSchemeDetail('Amount', scheme.amount),
                      _buildSchemeDetail('Deadline', scheme.deadline),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Open scheme application link
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening application form...')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSchemeDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
