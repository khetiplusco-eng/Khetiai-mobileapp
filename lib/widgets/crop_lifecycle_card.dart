import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── Crop Lifecycle Card ──────────────────────────────────────────────────────

class CropLifecycleCard extends StatelessWidget {
  const CropLifecycleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grass_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Crop Lifecycle',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cotton (Bolling)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    'Harvest: Nov 20',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'HEALTHY',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.68,
              backgroundColor: AppTheme.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Growth: 68%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                '32 days left',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second crop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soybean (Pod Fill)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    'Harvest: Oct 05',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFffd7b0),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'WATCH',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7a3d00),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.82,
              backgroundColor: AppTheme.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFf59e0b)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Market Pulse Card ─────────────────────────────────────────────────────────

class MarketPulseCard extends StatelessWidget {
  const MarketPulseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Market Pulse',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MarketRow(
            crop: 'Cotton',
            price: '₹6,820/q',
            change: '+2.4%',
            up: true,
          ),
          _Divider(),
          _MarketRow(
            crop: 'Soybean',
            price: '₹4,290/q',
            change: '-0.8%',
            up: false,
          ),
          _Divider(),
          _MarketRow(
            crop: 'Wheat',
            price: '₹2,275/q',
            change: '+0.5%',
            up: true,
          ),
          _Divider(),
          _MarketRow(
            crop: 'Onion',
            price: '₹1,450/q',
            change: '+5.2%',
            up: true,
          ),
        ],
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  final String crop;
  final String price;
  final String change;
  final bool up;

  const _MarketRow({
    required this.crop,
    required this.price,
    required this.change,
    required this.up,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            crop,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.onSurface,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              Text(
                change,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: up ? AppTheme.primary : AppTheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppTheme.outlineVariant.withOpacity(0.2),
    );
  }
}

// ── Water Management Card ─────────────────────────────────────────────────────

class WaterManagementCard extends StatelessWidget {
  const WaterManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.water_drop_rounded,
              size: 90,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Management',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Smart Irrigation Schedule',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.tertiaryFixedDim,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _IrrigationStat(label: 'Used', value: '42L'),
                      const SizedBox(width: 16),
                      _IrrigationStat(label: 'Saved', value: '18L'),
                      const SizedBox(width: 16),
                      _IrrigationStat(label: 'Efficiency', value: '87%'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF96ccff),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next cycle: 04:00 AM',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Applying 12mm based on soil moisture sensor data from Field A.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.tertiaryFixedDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'ADJUST',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IrrigationStat extends StatelessWidget {
  final String label;
  final String value;
  const _IrrigationStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: AppTheme.tertiaryFixedDim,
          ),
        ),
      ],
    );
  }
}
