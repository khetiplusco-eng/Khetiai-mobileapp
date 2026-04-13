import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/crop_lifecycle_card.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/water_management_card.dart';

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
      // Akola coordinates
      final weather = await ApiService.getWeather(
        lat: 20.7002,
        lon: 77.0082,
        location: 'Akola, MH',
      );
      if (mounted)
        setState(() {
          _weather = weather;
          _loadingWeather = false;
        });
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
                _buildInsightsSection(),
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
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2d5a27), Color(0xFF154212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khetiai',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                'Precision Agriculture',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_rounded,
              color: AppTheme.primary, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 270,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2d5a27),
                  Color(0xFF154212),
                  Color(0xFF0a2e08),
                ],
              ),
            ),
          ),
          // Field grid pattern
          CustomPaint(painter: _FieldPatternPainter()),

          // NDVI legend (top left)
          Positioned(
            top: 16,
            left: 16,
            child: Row(
              children: [
                _NdviBand(color: const Color(0xFF1a5c1a), label: '0.8+'),
                const SizedBox(width: 6),
                _NdviBand(color: const Color(0xFF3d8b3d), label: '0.6'),
                const SizedBox(width: 6),
                _NdviBand(color: const Color(0xFF7ab07a), label: '0.4'),
                const SizedBox(width: 6),
                _NdviBand(color: const Color(0xFFc8a46e), label: '<0.2'),
              ],
            ),
          ),

          // Nitrogen pill (top right)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'NITROGEN',
                        style: GoogleFonts.inter(
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryFixed,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Optimal',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                        Icons.energy_savings_leaf_rounded,
                        color: Colors.white,
                        size: 18),
                  ),
                ],
              ),
            ),
          ),

          // Bottom content
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
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryFixed,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'LIVE SATELLITE ANALYSIS',
                      style: GoogleFonts.inter(
                        fontSize: 8,
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
        ],
      ),
    );
  }

  Widget _buildWeatherAndAI() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: WeatherCard(
              weather: _weather, loading: _loadingWeather),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildAIButton(),
              const SizedBox(height: 12),
              _buildFieldStats(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIButton() {
    return GestureDetector(
      onTap: widget.onAITap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2d5a27), Color(0xFF154212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI ADVISOR',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryFixed,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Ask Now',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldStats() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY FARM',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _StatRow(label: 'Area', value: '4.2 ha'),
          _StatRow(label: 'Soil pH', value: '6.8'),
          _StatRow(label: 'Moisture', value: '42%'),
          _StatRow(label: 'NDVI', value: '0.84'),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Field Insights',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
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
          width: 22,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600)),
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
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppTheme.onSurfaceVariant)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
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

    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final pp = Paint()..style = PaintingStyle.fill;
    final patches = [
      (Rect.fromLTWH(40, 30, 120, 80), Colors.green.withOpacity(0.08)),
      (Rect.fromLTWH(180, 20, 80, 100),
          const Color(0xFF7ab07a).withOpacity(0.06)),
      (Rect.fromLTWH(10, 130, 90, 60), Colors.brown.withOpacity(0.06)),
      (Rect.fromLTWH(260, 80, 60, 70), Colors.green.withOpacity(0.05)),
    ];
    for (final (rect, color) in patches) {
      pp.color = color;
      canvas.drawRect(rect, pp);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}