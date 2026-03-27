import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData? weather;
  final bool loading;

  const WeatherCard({super.key, this.weather, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            )
          : weather == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text('Weather unavailable', style: TextStyle(color: AppTheme.onSurfaceVariant)),
      ),
    );
  }

  Widget _buildContent() {
    final w = weather!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.conditionText,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  w.location,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Text(
              w.weatherIcon,
              style: const TextStyle(fontSize: 36),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${w.temperature.toStringAsFixed(0)}°',
              style: GoogleFonts.manrope(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                'C',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: AppTheme.outlineVariant.withOpacity(0.3),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _WeatherStat(
              label: 'Humidity',
              value: '${w.humidity}%',
            ),
            _WeatherStat(
              label: 'Wind',
              value: '${w.windSpeed.toStringAsFixed(0)} km/h',
            ),
            _WeatherStat(
              label: 'Rain',
              value: '${w.precipitationProbability}%',
            ),
          ],
        ),
        if (w.daily.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: w.daily.length > 5 ? 5 : w.daily.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final d = w.daily[i];
                return Column(
                  children: [
                    Text(
                      d.dayName,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(d.icon, style: const TextStyle(fontSize: 16)),
                    Text(
                      '${d.maxTemp.toStringAsFixed(0)}°',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final String label;
  final String value;
  const _WeatherStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}
