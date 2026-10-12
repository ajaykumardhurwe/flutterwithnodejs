// import 'package:flutter/material.dart';

// class JobScreen extends StatelessWidget {
//   const JobScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text(
//         'Reels Screen',
//         style: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }




















import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/e/'
      '2PACX-1vTKkI65Lp4nufa7kl2M7bLHNgkTV9qGUS4vhOfkf4r-azR_OsHWCTCRP62oboFhfpnVlHSimnw78knn/'
      'pub?gid=1222376249&single=true&output=csv';

  List<Map<String, String>> jobs = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  // CSV parser: handles commas, quoted text, escaped quotes and newlines.
  List<List<String>> parseCsv(String input) {
    final rows = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      if (char == '"') {
        if (inQuotes &&
            i + 1 < input.length &&
            input[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        row.add(field.toString().trim());
        field = StringBuffer();
      } else if ((char == '\n' || char == '\r') &&
          !inQuotes) {
        if (char == '\r' &&
            i + 1 < input.length &&
            input[i + 1] == '\n') {
          i++;
        }

        row.add(field.toString().trim());

        if (row.any((value) => value.isNotEmpty)) {
          rows.add(row);
        }

        row = <String>[];
        field = StringBuffer();
      } else {
        field.write(char);
      }
    }

    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString().trim());

      if (row.any((value) => value.isNotEmpty)) {
        rows.add(row);
      }
    }

    return rows;
  }

  Future<void> loadJobs() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http
          .get(Uri.parse(csvUrl))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Unable to load spreadsheet. HTTP ${response.statusCode}',
        );
      }

      final rows = parseCsv(response.body);

      if (rows.isEmpty) {
        throw Exception('The published spreadsheet is empty.');
      }

      // Normalize header names and remove BOM if present.
      final headers = rows.first.map((value) {
        return value
            .replaceFirst('\uFEFF', '')
            .trim()
            .toLowerCase();
      }).toList();

      String getCell(List<String> row, String column) {
        final index = headers.indexOf(column.toLowerCase());

        if (index < 0 || index >= row.length) {
          return '';
        }

        return row[index].trim();
      }

      final loadedJobs = <Map<String, String>>[];

      for (final row in rows.skip(1)) {
        final job = <String, String>{
          'title': getCell(row, 'Job Title'),
          'description': getCell(row, 'Description'),
          'startDate': getCell(row, 'Start Date'),
          'endDate': getCell(row, 'End Date'),
          'officialLink': getCell(row, 'Official Link'),
          'notificationLink': getCell(row, 'Notification Link'),
        };

        if (job['title']!.isNotEmpty) {
          loadedJobs.add(job);
        }
      }

      if (!mounted) return;

      setState(() {
        jobs = loadedJobs;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> openLink(String link) async {
    final uri = Uri.tryParse(link.trim());

    if (uri == null ||
        !uri.hasAuthority ||
        !['https', 'http'].contains(uri.scheme)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or unavailable link'),
        ),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link'),
        ),
      );
    }
  }

  Widget _dateRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ${value.isEmpty ? 'Not specified' : value}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _jobCard(
    BuildContext context,
    Map<String, String> job,
  ) {
    final theme = Theme.of(context);
    final officialLink = job['officialLink'] ?? '';
    final notificationLink = job['notificationLink'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primaryContainer,
                  foregroundColor:
                      theme.colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.work_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    job['title'] ?? 'Untitled opportunity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if ((job['description'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(job['description']!),
            ],
            const SizedBox(height: 14),
            _dateRow(
              Icons.event_available,
              'Start date',
              job['startDate'] ?? '',
            ),
            const SizedBox(height: 8),
            _dateRow(
              Icons.event_busy,
              'End date',
              job['endDate'] ?? '',
            ),
            if (officialLink.isNotEmpty ||
                notificationLink.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (officialLink.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => openLink(officialLink),
                      icon: const Icon(
                        Icons.open_in_new,
                        size: 18,
                      ),
                      label: const Text('Apply / Official site'),
                    ),
                  if (notificationLink.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () =>
                          openLink(notificationLink),
                      icon: const Icon(
                        Icons.description_outlined,
                        size: 18,
                      ),
                      label: const Text('Notification'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs & Opportunities'),
        actions: [
          IconButton(
            onPressed: loading ? null : loadJobs,
            tooltip: 'Refresh jobs',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load jobs',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: loadJobs,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : jobs.isEmpty
                  ? RefreshIndicator(
                      onRefresh: loadJobs,
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 180),
                          Center(
                            child: Text(
                              'No jobs found in the spreadsheet.',
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadJobs,
                      child: ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          return _jobCard(
                            context,
                            jobs[index],
                          );
                        },
                      ),
                    ),
    );
  }
}
