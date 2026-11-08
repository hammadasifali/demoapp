import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  static const Color forestGreen = Color(0xFF245C3A);
  static const Color leafGreen = Color(0xFF4F8A50);
  static const Color lightGreen = Color(0xFFE8F1E5);
  //static const Color cream = Color(0xFFFAFAF4);
  static const Color textDark = Color(0xFF26382A);

  late Future<Map<String, dynamic>> _future = _load();

  Future<Map<String, dynamic>> _load() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '33.68',
      'longitude': '73.05',
      'current':
          'temperature_2m,relative_humidity_2m,wind_speed_10m,'
          'apparent_temperature,precipitation,weather_code,is_day',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,sunrise,sunset',
      'timezone': 'Asia/Karachi',
      'forecast_days': '5',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Weather service unavailable');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['current'] == null || data['daily'] == null) {
      throw Exception('Invalid weather response');
    }

    data['fetchedAt'] = DateTime.now();

    return data;
  }

  Future<void> _refresh() async {
    final newFuture = _load();

    setState(() {
      _future = newFuture;
    });

    try {
      await newFuture;
    } catch (_) {
      // FutureBuilder displays the error.
    }
  }

  // Weather code descriptions from Open-Meteo.
  Map<String, dynamic> _weatherInfo(int code) {
    if (code == 0) {
      return {
        'name': 'Clear Sky',
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.orange,
      };
    }

    if ([1, 2, 3].contains(code)) {
      return {
        'name': 'Partly Cloudy',
        'icon': Icons.cloud_rounded,
        'color': Colors.blueGrey,
      };
    }

    if ([45, 48].contains(code)) {
      return {'name': 'Foggy', 'icon': Icons.foggy, 'color': Colors.blueGrey};
    }

    if ([51, 53, 55, 56, 57].contains(code)) {
      return {
        'name': 'Drizzle',
        'icon': Icons.grain,
        'color': Colors.lightBlue,
      };
    }

    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return {
        'name': 'Rainy',
        'icon': Icons.cloudy_snowing,
        'color': Colors.blue,
      };
    }

    if ([71, 73, 75, 77, 85, 86].contains(code)) {
      return {'name': 'Snow', 'icon': Icons.ac_unit, 'color': Colors.lightBlue};
    }

    if ([95, 96, 99].contains(code)) {
      return {
        'name': 'Thunderstorm',
        'icon': Icons.thunderstorm,
        'color': Colors.deepPurple,
      };
    }

    return {
      'name': 'Unknown',
      'icon': Icons.cloud_outlined,
      'color': leafGreen,
    };
  }

  // Generate recommendations using current weather.
  List<String> _plantTips(
    Map<String, dynamic> current,
    Map<String, dynamic> daily,
  ) {
    final tips = <String>[];

    final temp = (current['temperature_2m'] as num).toDouble();
    final humidity = (current['relative_humidity_2m'] as num).toDouble();
    final wind = (current['wind_speed_10m'] as num).toDouble();

    final rainProbability = (daily['precipitation_probability_max'][0] as num)
        .toDouble();

    if (rainProbability >= 60) {
      tips.add('Rain is likely today. Check soil moisture before watering.');
    } else {
      tips.add('Rain probability is low. Check your soil before watering.');
    }

    if (temp >= 35) {
      tips.add('High temperature! Keep sensitive plants in partial shade.');
    } else if (temp <= 10) {
      tips.add('Cold weather detected. Protect sensitive plants from cold.');
    } else if (temp >= 30) {
      tips.add(
        'Warm weather. Monitor soil moisture and avoid midday watering.',
      );
    }

    if (humidity >= 80) {
      tips.add('High humidity. Improve airflow to reduce fungal disease risk.');
    } else if (humidity <= 30) {
      tips.add('Low humidity. Monitor plants for signs of dryness.');
    }

    if (wind >= 25) {
      tips.add(
        'Strong wind detected. Secure pots and support delicate plants.',
      );
    }

    if (tips.length == 1) {
      tips.add(
        'Weather conditions look moderate. Continue your normal plant-care routine.',
      );
    }

    return tips;
  }

  String _dayName(String date) {
    final parsed = DateTime.parse(date);
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[parsed.weekday - 1];
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: forestGreen, size: 21),
          const SizedBox(width: 9),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherMetric(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: forestGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: forestGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _forecastCard(Map<String, dynamic> daily) {
    final dates = daily['time'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final minTemps = daily['temperature_2m_min'] as List;
    final rain = daily['precipitation_probability_max'] as List;
    final codes = daily['weather_code'] as List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE8D9)),
      ),
      child: Column(
        children: List.generate(dates.length, (i) {
          final info = _weatherInfo((codes[i] as num).toInt());

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    i == 0 ? 'Today' : _dayName(dates[i]),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                ),
                Icon(
                  info['icon'] as IconData,
                  color: info['color'] as Color,
                  size: 23,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${rain[i]}% rain',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Text(
                  '${(minTemps[i] as num).round()}°',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(maxTemps[i] as num).round()}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _plantCareCard(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [forestGreen, leafGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.spa, color: Colors.white, size: 25),
              SizedBox(width: 10),
              Text(
                'Plant Care Advisor',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Recommendations based on current weather',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherDashboard(Map<String, dynamic> data) {
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    final temp = (current['temperature_2m'] as num).round();
    final feels = (current['apparent_temperature'] as num).round();
    final humidity = current['relative_humidity_2m'];
    final wind = current['wind_speed_10m'];
    final rainNow = current['precipitation'];
    final code = (current['weather_code'] as num).toInt();

    final info = _weatherInfo(code);
    final tips = _plantTips(current, daily);
    final fetchedAt = data['fetchedAt'] as DateTime;

    final sunrise = (daily['sunrise'] as List)[0].toString().split('T').last;

    final sunset = (daily['sunset'] as List)[0].toString().split('T').last;

    return RefreshIndicator(
      color: forestGreen,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        children: [
          // Location
          Row(
            children: [
              const Icon(Icons.location_on, color: leafGreen, size: 20),
              const SizedBox(width: 5),
              const Text(
                'Islamabad, Pakistan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh weather',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh, color: forestGreen),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Current weather card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Icon(
                  info['icon'] as IconData,
                  color: info['color'] as Color,
                  size: 65,
                ),
                const SizedBox(height: 12),
                Text(
                  '$temp°C',
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
                  ),
                ),
                Text(
                  info['name'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Feels like $feels°C',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _weatherMetric(
                      Icons.water_drop_outlined,
                      'Humidity',
                      '$humidity%',
                    ),
                    const SizedBox(width: 10),
                    _weatherMetric(Icons.air, 'Wind', '$wind km/h'),
                    const SizedBox(width: 10),
                    _weatherMetric(Icons.grain, 'Rain now', '$rainNow mm'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Plant care recommendations
          _sectionTitle('Plant Care Tips', Icons.eco),
          _plantCareCard(tips),

          const SizedBox(height: 25),

          // Forecast
          _sectionTitle('5-Day Forecast', Icons.calendar_month),
          _forecastCard(daily),

          const SizedBox(height: 25),

          // Sun information
          _sectionTitle('Sun Schedule', Icons.wb_twilight),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDCE8D9)),
            ),
            child: Row(
              children: [
                _weatherMetric(Icons.wb_sunny_outlined, 'Sunrise', sunrise),
                const SizedBox(width: 15),
                _weatherMetric(Icons.nights_stay_outlined, 'Sunset', sunset),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              'Last updated: ${fetchedAt.hour.toString().padLeft(2, '0')}:'
              '${fetchedAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text(
              'Weather data powered by Open-Meteo',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: forestGreen),
                SizedBox(height: 15),
                Text(
                  'Growing your weather dashboard...',
                  style: TextStyle(color: forestGreen),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 55, color: Colors.grey),
                  const SizedBox(height: 15),
                  const Text(
                    'Unable to load weather',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check your internet connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _future = _load());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: FilledButton.styleFrom(backgroundColor: forestGreen),
                  ),
                ],
              ),
            ),
          );
        }

        return _weatherDashboard(snapshot.data!);
      },
    );
  }
}
