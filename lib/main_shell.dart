import 'package:demoapp/pages/map_page.dart';
import 'package:demoapp/pages/scan_result_page.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
import 'pages/history_page.dart';
import 'pages/weather_page.dart';
import 'pages/settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const Color forestGreen = Color(0xFF245C3A);
  static const Color leafGreen = Color(0xFF4F8A50);
  static const Color lightGreen = Color(0xFFE8F1E5);
  static const Color cream = Color(0xFFFAFAF4);

  @override
  Widget build(BuildContext context) {
    // Pages are created here so context is available.
    final List<Widget> pages = [
      HomePage(
        warning: null,

        plants: const [
          PlantSummary(
            name: 'Tomato',
            species: 'Tomato plant',
            health: PlantHealth.healthy,
          ),
          PlantSummary(
            name: 'Pepper',
            species: 'Bell pepper',
            health: PlantHealth.attention,
          ),
          PlantSummary(
            name: 'Potato',
            species: 'Potato plant',
            health: PlantHealth.diseased,
          ),
        ],

        recentScans: const [
          RecentScan(
            plantName: 'Tomato',
            disease: 'Healthy',
            date: 'Today',
            isHealthy: true,
          ),
          RecentScan(
            plantName: 'Pepper',
            disease: 'Bacterial Spot',
            date: 'Yesterday',
            isHealthy: false,
          ),
        ],

        weather: const WeatherSummary(
          temperature: 28.5,
          humidity: 65,
          rainChance: 20,
          careTip: 'Check soil moisture before watering your plants.',
        ),

        onScanTap: () {
          setState(() => _index = 1);
        },
        onAddPlant: () {
          setState(() => _index = 3);
        },
        onViewAllPlants: () {
          setState(() => _index = 3);
        },
        onViewAllScans: () {
          setState(() => _index = 2);
        },
        onWeatherTap: () {
          setState(() => _index = 4);
        },
      ),

      const ScanPage(),

      HistoryPage(
        scans: sampleScans,
        onScanTap: (scan) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanResultPage(
                scan: scan,

                onReportOnMap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlantMapPage()),
                  );
                },

                onRescan: () {
                  Navigator.pop(context);
                  setState(() => _index = 1);
                },
              ),
            ),
          );
        },
      ),

      const PlantMapPage(),

      const WeatherPage(),

      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 18,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        shadowColor: forestGreen.withValues(alpha: 0.08),

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.eco, color: forestGreen),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              kAppName,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: forestGreen,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco, size: 15, color: leafGreen),
                SizedBox(width: 5),
                Text(
                  'Green Life',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Keep pages alive while navigating.
      body: IndexedStack(index: _index, children: pages),

      bottomNavigationBar: CurvedBottomBar(
        selectedIndex: _index,
        onItemSelected: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}

class CurvedBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CurvedBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const Color forestGreen = Color(0xFF245C3A);
  static const Color leafGreen = Color(0xFF4F8A50);
  static const Color lightGreen = Color(0xFFE8F1E5);

  static const List<_NavItem> items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.qr_code_scanner, Icons.qr_code_scanner, 'Scan'),
    _NavItem(Icons.history_outlined, Icons.history_rounded, 'History'),
    _NavItem(Icons.map_outlined, Icons.map_rounded, 'Map'),
    _NavItem(Icons.cloud_outlined, Icons.cloud_rounded, 'Weather'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = selectedIndex == index;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onItemSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? lightGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: selected ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected
                              ? forestGreen
                              : theme.colorScheme.onSurfaceVariant,
                          size: 23,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: selected
                              ? forestGreen
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}
