import 'package:flutter/material.dart';

// -------------------- DATA MODELS --------------------

enum PlantHealth { healthy, diseased, attention }

class PlantSummary {
  final String name;
  final String species;
  final PlantHealth health;

  const PlantSummary({
    required this.name,
    required this.species,
    required this.health,
  });
}

class RecentScan {
  final String plantName;
  final String disease;
  final String date;
  final bool isHealthy;

  const RecentScan({
    required this.plantName,
    required this.disease,
    required this.date,
    required this.isHealthy,
  });
}

class WeatherSummary {
  final double temperature;
  final int humidity;
  final int rainChance;
  final String careTip;

  const WeatherSummary({
    required this.temperature,
    required this.humidity,
    required this.rainChance,
    required this.careTip,
  });
}

// -------------------- HOME PAGE --------------------

class HomePage extends StatelessWidget {
  final String? warning;

  final List<PlantSummary> plants;
  final List<RecentScan> recentScans;
  final WeatherSummary? weather;

  final VoidCallback? onScanTap;
  final VoidCallback? onAddPlant;
  final VoidCallback? onViewAllPlants;
  final VoidCallback? onViewAllScans;
  final VoidCallback? onWeatherTap;
  final ValueChanged<PlantSummary>? onPlantTap;

  const HomePage({
    super.key,
    this.warning,
    this.plants = const [],
    this.recentScans = const [],
    this.weather,
    this.onScanTap,
    this.onAddPlant,
    this.onViewAllPlants,
    this.onViewAllScans,
    this.onWeatherTap,
    this.onPlantTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final healthyCount = plants
        .where((p) => p.health == PlantHealth.healthy)
        .length;

    final diseasedCount = plants
        .where((p) => p.health == PlantHealth.diseased)
        .length;

    final attentionCount = plants
        .where((p) => p.health == PlantHealth.attention)
        .length;

    final latestScans = recentScans.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- WELCOME ----------------
            Text(
              'Welcome to AgriGuard',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Take care of your plants, one leaf at a time.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            // ---------------- WARNING ----------------
            if (warning != null && warning!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              _WarningCard(message: warning!),
            ],

            const SizedBox(height: 24),

            // ---------------- SCAN DISEASE ----------------
            _ScanCard(onTap: onScanTap),

            const SizedBox(height: 26),

            // ---------------- MY PLANTS ----------------
            _SectionHeader(
              title: 'My Plants',
              actionText: 'View All',
              onAction: onViewAllPlants,
            ),
            const SizedBox(height: 12),

            if (plants.isEmpty)
              _EmptyCard(
                icon: Icons.spa_outlined,
                title: 'No plants added yet',
                subtitle: 'Add your first plant to start tracking its health.',
                buttonText: 'Add Plant',
                onPressed: onAddPlant,
              )
            else
              SizedBox(
                height: 145,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: plants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final plant = plants[index];

                    return _PlantCard(
                      plant: plant,
                      onTap: () => onPlantTap?.call(plant),
                    );
                  },
                ),
              ),

            const SizedBox(height: 26),

            // ---------------- PLANT HEALTH ----------------
            Text(
              'Plant Health Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _HealthCard(
                    title: 'Healthy',
                    count: healthyCount,
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HealthCard(
                    title: 'Diseased',
                    count: diseasedCount,
                    icon: Icons.coronavirus_outlined,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HealthCard(
                    title: 'Attention',
                    count: attentionCount,
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // ---------------- WEATHER ----------------
            _SectionHeader(
              title: 'Weather Summary',
              actionText: 'Details',
              onAction: onWeatherTap,
            ),
            const SizedBox(height: 12),

            _WeatherCard(weather: weather),

            const SizedBox(height: 26),

            // ---------------- RECENT SCANS ----------------
            _SectionHeader(
              title: 'Recent Scans',
              actionText: 'View All',
              onAction: recentScans.length > 3 ? onViewAllScans : null,
            ),
            const SizedBox(height: 12),

            if (latestScans.isEmpty)
              const _EmptyCard(
                icon: Icons.document_scanner_outlined,
                title: 'No scans yet',
                subtitle: 'Your recent plant scans will appear here.',
              )
            else
              ...latestScans.map((scan) => _RecentScanTile(scan: scan)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// -------------------- SECTION HEADER --------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionText!)),
      ],
    );
  }
}

// -------------------- WARNING CARD --------------------

class _WarningCard extends StatelessWidget {
  final String message;

  const _WarningCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plant Warning',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- SCAN CARD --------------------

class _ScanCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _ScanCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.document_scanner_outlined,
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(height: 15),
              const Text(
                'Scan Disease',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Photograph a leaf to identify disease.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: primary),
                    const SizedBox(width: 8),
                    Text(
                      'Start Scanning',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- PLANT CARD --------------------

class _PlantCard extends StatelessWidget {
  final PlantSummary plant;
  final VoidCallback? onTap;

  const _PlantCard({required this.plant, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final statusColor = switch (plant.health) {
      PlantHealth.healthy => Colors.green,
      PlantHealth.diseased => Colors.red,
      PlantHealth.attention => Colors.orange,
    };

    final statusText = switch (plant.health) {
      PlantHealth.healthy => 'Healthy',
      PlantHealth.diseased => 'Diseased',
      PlantHealth.attention => 'Needs attention',
    };

    return SizedBox(
      width: 155,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.local_florist, color: colors.primary, size: 30),
                const Spacer(),
                Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  plant.species,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 9),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- HEALTH CARD --------------------

class _HealthCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _HealthCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
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
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- WEATHER CARD --------------------

class _WeatherCard extends StatelessWidget {
  final WeatherSummary? weather;

  const _WeatherCard({this.weather});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (weather == null) {
      return _EmptyCard(
        icon: Icons.cloud_outlined,
        title: 'Weather unavailable',
        subtitle: 'Weather information will appear here when loaded.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, color: colors.primary, size: 34),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather!.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Current temperature',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                Expanded(
                  child: _WeatherMetric(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: '${weather!.humidity}%',
                  ),
                ),
                Expanded(
                  child: _WeatherMetric(
                    icon: Icons.cloud_outlined,
                    label: 'Rain chance',
                    value: '${weather!.rainChance}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco_outlined, color: colors.primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      weather!.careTip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

// -------------------- RECENT SCAN TILE --------------------

class _RecentScanTile extends StatelessWidget {
  final RecentScan scan;

  const _RecentScanTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scan.isHealthy
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.15),
          child: Icon(
            scan.isHealthy ? Icons.check_circle : Icons.warning_rounded,
            color: scan.isHealthy ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          scan.plantName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${scan.disease} • ${scan.date}'),
        trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      ),
    );
  }
}

// -------------------- EMPTY STATE --------------------

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: colors.primary),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onPressed, child: Text(buttonText!)),
          ],
        ],
      ),
    );
  }
}
