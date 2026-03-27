import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/crop_lifecycle_card.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/water_management_card.dart';
import 'chat_screen.dart';
import 'mapping_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onAITap;

  const HomeScreen({super.key, this.onAITap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData? _weather;
  bool _loadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await ApiService.getWeather();
      if (mounted) setState(() { _weather = weather; _loadingWeather = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingWeather = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildHeroSection(),
                const SizedBox(height: 20),
                _buildWeatherAndAI(),
                const SizedBox(height: 20),
                _buildInsightsGrid(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.surfaceContainerHighest,
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Precision Earth',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_rounded, color: AppTheme.primary),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppTheme.surfaceContainerLow,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Satellite-style background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2d5a27).withOpacity(0.9),
                  const Color(0xFF154212).withOpacity(0.95),
                  const Color(0xFF0a2e08),
                ],
              ),
            ),
          ),
          // Grid pattern overlay simulating field view
          CustomPaint(
            painter: _FieldPatternPainter(),
          ),
          // Content overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryFixed,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'LIVE SATELLITE ANALYSIS',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'North Field\nHealth Index: 0.84',
                    style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nitrogen indicator top-right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'NITROGEN LEVEL',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryFixed,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Optimal',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.energy_savings_leaf_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // NDVI band simulation
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                _NdviBand(color: const Color(0xFF1a5c1a), label: '0.8+'),
                const SizedBox(width: 4),
                _NdviBand(color: const Color(0xFF3d8b3d), label: '0.6'),
                const SizedBox(width: 4),
                _NdviBand(color: const Color(0xFF7ab07a), label: '0.4'),
                const SizedBox(width: 4),
                _NdviBand(color: const Color(0xFFc8a46e), label: '<0.2'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAndAI() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: WeatherCard(weather: _weather, loading: _loadingWeather),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildAIQuickAsk(),
              const SizedBox(height: 12),
              _buildFieldStatsCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIQuickAsk() {
    return GestureDetector(
      onTap: () {
        widget.onAITap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGRONOMIST AI',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryFixed,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Ask AI',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldStatsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIELD STATS',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _StatRow(label: 'Area', value: '4.2 ha'),
          _StatRow(label: 'pH', value: '6.8'),
          _StatRow(label: 'Moisture', value: '42%'),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Field Insights',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onBackground,
            ),
          ),
        ),
        Row(
          children: const [
            Expanded(child: CropLifecycleCard()),
            SizedBox(width: 12),
            Expanded(child: MarketPulseCard()),
          ],
        ),
        const SizedBox(height: 12),
        const WaterManagementCard(),
      ],
    );
  }
}

class _NdviBand extends StatelessWidget {
  final Color color;
  final String label;
  const _NdviBand({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal field lines
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical field lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw some "field patches" with slightly different opacity
    final patchPaint = Paint()..style = PaintingStyle.fill;

    final patches = [
      (Rect.fromLTWH(40, 30, 120, 80), Colors.green.withOpacity(0.08)),
      (Rect.fromLTWH(180, 20, 80, 100), const Color(0xFF7ab07a).withOpacity(0.06)),
      (Rect.fromLTWH(10, 130, 90, 60), Colors.brown.withOpacity(0.06)),
      (Rect.fromLTWH(260, 80, 60, 70), Colors.green.withOpacity(0.05)),
    ];

    for (final (rect, color) in patches) {
      patchPaint.color = color;
      canvas.drawRect(rect, patchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
