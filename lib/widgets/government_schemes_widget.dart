import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/govt_schemes_provider.dart';

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
    return Consumer<GovtSchemesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.error),
                ElevatedButton(
                    onPressed: () => provider.fetchSchemes(),
                    child: const Text("Retry")),
              ],
            ),
          );
        }

        if (provider.schemes.isEmpty) {
          return const Center(
            child: Text("No schemes available"),
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
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.name,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(scheme.description),
                      const SizedBox(height: 12),
                      Text("Eligibility: ${scheme.eligibility}"),
                      Text("Benefits: ${scheme.amount}"),
                      Text("Deadline: ${scheme.deadline}"),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Uri url = Uri.parse(scheme.applyLink);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Unable to open link")),
                              );
                            }
                          },
                          child: const Text("Apply Now"),
                        ),
                      )
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
}
