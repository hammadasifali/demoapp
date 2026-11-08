import 'package:flutter/material.dart';

// --------------------------------------------------
// SCAN STATUS
// --------------------------------------------------

enum ScanStatus { healthy, attention, diseased }

// --------------------------------------------------
// SCAN MODEL
// --------------------------------------------------

class PlantScan {
  final String id;
  final String plantId;
  final String plantName;
  final String diseaseName;
  final DateTime scannedAt;
  final double confidence;
  final String severity;
  final ScanStatus status;

  const PlantScan({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.diseaseName,
    required this.scannedAt,
    required this.confidence,
    required this.severity,
    required this.status,
  });
}

// --------------------------------------------------
// HISTORY PAGE
// --------------------------------------------------

enum _HistoryFilter { all, healthy, attention, diseased }

class HistoryPage extends StatefulWidget {
  final List<PlantScan> scans;
  final ValueChanged<PlantScan>? onScanTap;

  const HistoryPage({super.key, required this.scans, this.onScanTap});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  _HistoryFilter _selectedFilter = _HistoryFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // SUMMARY COUNTS
  // Uses latest scan for each plant.
  // ------------------------------------------------

  Map<ScanStatus, int> get summaryCounts {
    final Map<String, PlantScan> latestScans = {};

    final sorted = [...widget.scans]
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

    for (final scan in sorted) {
      latestScans.putIfAbsent(scan.plantId, () => scan);
    }

    final counts = {
      ScanStatus.healthy: 0,
      ScanStatus.attention: 0,
      ScanStatus.diseased: 0,
    };

    for (final scan in latestScans.values) {
      counts[scan.status] = counts[scan.status]! + 1;
    }

    return counts;
  }

  // ------------------------------------------------
  // FILTER + SEARCH
  // ------------------------------------------------

  List<PlantScan> get filteredScans {
    final query = _searchQuery.toLowerCase().trim();

    final result = widget.scans.where((scan) {
      final matchesSearch =
          scan.plantName.toLowerCase().contains(query) ||
          scan.diseaseName.toLowerCase().contains(query);

      final matchesFilter = switch (_selectedFilter) {
        _HistoryFilter.all => true,
        _HistoryFilter.healthy => scan.status == ScanStatus.healthy,
        _HistoryFilter.attention => scan.status == ScanStatus.attention,
        _HistoryFilter.diseased => scan.status == ScanStatus.diseased,
      };

      return matchesSearch && matchesFilter;
    }).toList();

    result.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

    return result;
  }

  // ------------------------------------------------
  // GROUP SCANS BY DATE
  // ------------------------------------------------

  Map<String, List<PlantScan>> get groupedScans {
    final Map<String, List<PlantScan>> groups = {};

    for (final scan in filteredScans) {
      final date = _dateHeading(scan.scannedAt);

      groups.putIfAbsent(date, () => []);
      groups[date]!.add(scan);
    }

    return groups;
  }

  String _dateHeading(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final scanDate = DateTime(date.year, date.month, date.day);

    if (scanDate == today) return 'Today';
    if (scanDate == yesterday) return 'Yesterday';

    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final counts = summaryCounts;
    final groups = groupedScans;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Track your plants health over time.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SUMMARY CARDS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Healthy',
                        count: counts[ScanStatus.healthy] ?? 0,
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Attention',
                        count: counts[ScanStatus.attention] ?? 0,
                        icon: Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Diseased',
                        count: counts[ScanStatus.diseased] ?? 0,
                        icon: Icons.dangerous,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SEARCH FIELD
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search plant or disease...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // FILTER CHIPS
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', _HistoryFilter.all),
                    _buildFilterChip('Healthy', _HistoryFilter.healthy),
                    _buildFilterChip('Attention', _HistoryFilter.attention),
                    _buildFilterChip('Diseased', _HistoryFilter.diseased),
                  ],
                ),
              ),
            ),

            // HISTORY LIST
            if (groups.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyHistory(
                  hasSearch:
                      _searchQuery.isNotEmpty ||
                      _selectedFilter != _HistoryFilter.all,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (final entry in groups.entries) ...[
                      _DateHeading(title: entry.key, count: entry.value.length),
                      const SizedBox(height: 10),

                      for (final scan in entry.value) ...[
                        _HistoryCard(
                          scan: scan,
                          onTap: widget.onScanTap == null
                              ? null
                              : () => widget.onScanTap!(scan),
                        ),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 12),
                    ],
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, _HistoryFilter filter) {
    final selected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }
}

// --------------------------------------------------
// SUMMARY CARD
// --------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// DATE HEADING
// --------------------------------------------------

class _DateHeading extends StatelessWidget {
  final String title;
  final int count;

  const _DateHeading({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '$count ${count == 1 ? 'scan' : 'scans'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// --------------------------------------------------
// HISTORY CARD
// --------------------------------------------------

class _HistoryCard extends StatelessWidget {
  final PlantScan scan;
  final VoidCallback? onTap;

  const _HistoryCard({required this.scan, this.onTap});

  Color get statusColor {
    switch (scan.status) {
      case ScanStatus.healthy:
        return Colors.green;
      case ScanStatus.attention:
        return Colors.orange;
      case ScanStatus.diseased:
        return Colors.red;
    }
  }

  String get statusText {
    switch (scan.status) {
      case ScanStatus.healthy:
        return 'Healthy';
      case ScanStatus.attention:
        return 'Attention';
      case ScanStatus.diseased:
        return 'Diseased';
    }
  }

  String get formattedTime {
    final hour = scan.scannedAt.hour;
    final minute = scan.scannedAt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    child: Icon(Icons.eco, color: statusColor),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.plantName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                scan.diseaseName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Confidence',
                      value: '${scan.confidence.toStringAsFixed(1)}%',
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(label: 'Severity', value: scan.severity),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (scan.confidence / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: colors.surfaceContainerLow,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View scan result',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: colors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// INFO ITEM
// --------------------------------------------------

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// EMPTY STATE
// --------------------------------------------------

class _EmptyHistory extends StatelessWidget {
  final bool hasSearch;

  const _EmptyHistory({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.history,
              size: 55,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch ? 'No matching scans found' : 'No scan history yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try another plant name or filter.'
                  : 'Your plant scan results will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

final List<PlantScan> sampleScans = [
  PlantScan(
    id: '1',
    plantId: 'mango-1',
    plantName: 'Mango Tree',
    diseaseName: 'Healthy',
    scannedAt: DateTime.now(),
    confidence: 98.5,
    severity: 'None',
    status: ScanStatus.healthy,
  ),
  PlantScan(
    id: '2',
    plantId: 'tomato-1',
    plantName: 'Tomato Plant',
    diseaseName: 'Early Blight',
    scannedAt: DateTime.now().subtract(const Duration(hours: 3)),
    confidence: 94.2,
    severity: 'Moderate',
    status: ScanStatus.attention,
  ),
  PlantScan(
    id: '3',
    plantId: 'lemon-1',
    plantName: 'Lemon Tree',
    diseaseName: 'Citrus Canker',
    scannedAt: DateTime.now().subtract(const Duration(days: 1)),
    confidence: 96.8,
    severity: 'Severe',
    status: ScanStatus.diseased,
  ),
];
