import 'package:flutter/material.dart';

import 'history_page.dart';

class ScanResultPage extends StatefulWidget {
  final PlantScan scan;

  // Optional navigation callbacks
  final VoidCallback? onReportOnMap;
  final VoidCallback? onAskExpert;
  final VoidCallback? onRescan;

  // Optional information from your backend
  final List<String>? treatmentSteps;
  final List<String>? possibleDiagnoses;
  final List<String>? preventionTips;

  const ScanResultPage({
    super.key,
    required this.scan,
    this.onReportOnMap,
    this.onAskExpert,
    this.onRescan,
    this.treatmentSteps,
    this.possibleDiagnoses,
    this.preventionTips,
  });

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  bool _showTreatment = false;
  bool _showPossibilities = false;
  bool _showPrevention = false;

  Color get statusColor {
    switch (widget.scan.status) {
      case ScanStatus.healthy:
        return Colors.green;
      case ScanStatus.attention:
        return Colors.orange;
      case ScanStatus.diseased:
        return Colors.red;
    }
  }

  String get statusText {
    switch (widget.scan.status) {
      case ScanStatus.healthy:
        return 'Healthy Plant';
      case ScanStatus.attention:
        return 'Needs Attention';
      case ScanStatus.diseased:
        return 'Disease Detected';
    }
  }

  IconData get statusIcon {
    switch (widget.scan.status) {
      case ScanStatus.healthy:
        return Icons.check_circle;
      case ScanStatus.attention:
        return Icons.warning_amber_rounded;
      case ScanStatus.diseased:
        return Icons.coronavirus_outlined;
    }
  }

  List<String> get treatments => widget.treatmentSteps ?? _defaultTreatments;

  List<String> get possibilities =>
      widget.possibleDiagnoses ?? _defaultPossibilities;

  List<String> get prevention => widget.preventionTips ?? _defaultPrevention;

  // Generic fallback recommendations.
  // Replace these with disease-specific information from your API.
  List<String> get _defaultTreatments {
    if (widget.scan.status == ScanStatus.healthy) {
      return [
        'Continue regular watering according to the plant needs.',
        'Provide suitable sunlight and maintain healthy soil.',
        'Inspect leaves regularly for early signs of disease.',
      ];
    }

    if (widget.scan.status == ScanStatus.attention) {
      return [
        'Inspect the affected leaves carefully.',
        'Avoid excessive watering and improve air circulation.',
        'Remove severely damaged leaves using clean tools.',
        'Monitor the plant and consult an agricultural expert '
            'before applying treatment products.',
      ];
    }

    return [
      'Isolate the affected plant when practical to reduce '
          'the risk of spreading disease.',
      'Remove severely affected plant material using clean tools.',
      'Avoid watering directly over the leaves.',
      'Confirm the diagnosis with an agricultural expert.',
      'Use only a treatment recommended for the confirmed disease '
          'and suitable for your crop.',
    ];
  }

  List<String> get _defaultPossibilities {
    if (widget.scan.status == ScanStatus.healthy) {
      return [
        'No visible disease detected in this scan.',
        'Early-stage symptoms may not be visible yet.',
        'Environmental stress can sometimes resemble disease.',
      ];
    }

    return [
      'Nutrient deficiency',
      'Watering or drainage problems',
      'Environmental stress',
      'Another disease with similar visual symptoms',
    ];
  }

  List<String> get _defaultPrevention => [
    'Inspect plants regularly.',
    'Keep tools and gardening equipment clean.',
    'Maintain proper spacing between plants.',
    'Avoid overwatering.',
    'Remove fallen and infected plant debris.',
  ];

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleAction(VoidCallback? callback, String message) {
    if (callback != null) {
      callback();
    } else {
      _showActionMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Scan Result'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RESULT CARD
              _buildAnimatedResultCard(context),

              const SizedBox(height: 24),

              // TREATMENT BUTTON
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _showTreatment = !_showTreatment;
                    });
                  },
                  icon: Icon(
                    _showTreatment
                        ? Icons.keyboard_arrow_up
                        : Icons.medical_services_outlined,
                  ),
                  label: Text(
                    _showTreatment ? 'Hide Treatment' : 'View Treatment',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              // TREATMENT DETAILS
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showTreatment
                    ? _buildTreatmentSection(context)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // QUICK ACTIONS
              Text(
                'Take Action',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      title: 'Report on Map',
                      subtitle: 'Mark plant location',
                      icon: Icons.location_on_outlined,
                      color: Colors.teal,
                      onTap: () => _handleAction(
                        widget.onReportOnMap,
                        'Connect your Plant Map page here.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      title: 'Ask Expert',
                      subtitle: 'Get expert advice',
                      icon: Icons.support_agent,
                      color: Colors.blue,
                      onTap: () => _handleAction(
                        widget.onAskExpert,
                        'Connect your Ask Expert page here.',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // OTHER POSSIBILITIES
              _buildExpandableSection(
                context,
                title: 'Other Possibilities',
                subtitle: 'What else could cause these symptoms?',
                icon: Icons.search,
                isExpanded: _showPossibilities,
                onTap: () {
                  setState(() {
                    _showPossibilities = !_showPossibilities;
                  });
                },
                children: [
                  for (final item in possibilities) _BulletItem(text: item),
                  const SizedBox(height: 8),
                  Text(
                    'These are general possibilities, not confirmed '
                    'diagnoses. An expert may need to inspect the plant.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // PREVENTION
              _buildExpandableSection(
                context,
                title: 'Prevention Tips',
                subtitle: 'Protect your plant from future problems',
                icon: Icons.shield_outlined,
                isExpanded: _showPrevention,
                onTap: () {
                  setState(() {
                    _showPrevention = !_showPrevention;
                  });
                },
                children: [
                  for (final item in prevention) _BulletItem(text: item),
                ],
              ),

              const SizedBox(height: 24),

              // RESCAN BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleAction(
                    widget.onRescan,
                    'Connect your Scan page here.',
                  ),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Scan Again'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  'AI-generated results are estimates. '
                  'Confirm important diagnoses with an expert.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // ANIMATED RESULT CARD
  // ------------------------------------------------

  Widget _buildAnimatedResultCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            // STATUS ICON
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 38),
            ),

            const SizedBox(height: 14),

            Text(
              statusText,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              widget.scan.plantName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.scan.diseaseName,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 22),

            // CONFIDENCE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AI Confidence'),
                Text(
                  '${widget.scan.confidence.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 9),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (widget.scan.confidence / 100).clamp(0.0, 1.0),
                minHeight: 9,
                backgroundColor: colors.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),

            const SizedBox(height: 20),

            // SEVERITY AND DATE
            Row(
              children: [
                Expanded(
                  child: _ResultInfo(
                    icon: Icons.analytics_outlined,
                    label: 'Severity',
                    value: widget.scan.severity,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultInfo(
                    icon: Icons.calendar_today_outlined,
                    label: 'Scan Date',
                    value: _formatDate(widget.scan.scannedAt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // TREATMENT SECTION
  // ------------------------------------------------

  Widget _buildTreatmentSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_information_outlined, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Recommended Treatment',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 14),

          for (int i = 0; i < treatments.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      treatments[i],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          Text(
            'Treatment recommendations should be matched '
            'to the confirmed disease, crop, and local guidance.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // EXPANDABLE SECTION
  // ------------------------------------------------

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: Icon(icon, color: colors.primary, size: 26),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// --------------------------------------------------
// ACTION BUTTON
// --------------------------------------------------

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// RESULT INFORMATION
// --------------------------------------------------

class _ResultInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResultInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 19),
          const SizedBox(height: 7),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// BULLET ITEM
// --------------------------------------------------

class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 19, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
