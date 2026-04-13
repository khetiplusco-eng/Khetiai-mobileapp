import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _crops = [
    'Cotton', 'Soybean', 'Wheat', 'Onion', 'Tomato', 'Tur Dal', 'Rice', 'Maize'
  ];
  String _selectedCrop = 'Cotton';
  MarketData? _marketData;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMarket();
  }

  Future<void> _fetchMarket() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getMarketForecast(
        _selectedCrop,
        district: 'Akola',
        state: 'Maharashtra',
        country: 'India',
      );
      if (mounted) setState(() { _marketData = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Market Intelligence',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 20),
            onPressed: _fetchMarket,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildCropSelector(),
            const SizedBox(height: 16),
            if (_loading) _buildSkeleton(),
            if (_error != null) _buildError(),
            if (_marketData != null && !_loading) ...[
              _buildCurrentPriceCard(),
              const SizedBox(height: 14),
              _buildSellHoldCard(),
              const SizedBox(height: 14),
              _buildForecastChart(),
              const SizedBox(height: 14),
              _buildAnalysisCard(),
              const SizedBox(height: 14),
              _buildMSPTable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCropSelector() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = _crops[i] == _selectedCrop;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCrop = _crops[i]);
              _fetchMarket();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                _crops[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppTheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPriceCard() {
    final d = _marketData!;
    final isUp = d.trend == 'up';
    final isDown = d.trend == 'down';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a4d16), Color(0xFF154212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_selectedCrop — APMC Rate',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryFixed.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  d.currentPrice > 0
                      ? '₹${d.currentPrice.toStringAsFixed(0)}'
                      : '—',
                  style: GoogleFonts.manrope(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  'per quintal',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.primaryFixed.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isUp
                                ? Icons.trending_up_rounded
                                : isDown
                                    ? Icons.trending_down_rounded
                                    : Icons.trending_flat_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            d.trend.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      d.trendStrength,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.primaryFixed.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Opportunity score ring
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: d.opportunityScore / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFFbcf0ae)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${d.opportunityScore}',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'OPP',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryFixed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellHoldCard() {
    final d = _marketData!;
    final isSell = d.sellDecision.toLowerCase() == 'sell';
    final color = isSell ? const Color(0xFF22c55e) : const Color(0xFFf59e0b);
    final icon = isSell ? Icons.sell_rounded : Icons.inventory_2_rounded;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Recommendation: ${d.sellDecision.toUpperCase()}',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (d.bestTimeToSell.isNotEmpty)
                  Text(
                    d.bestTimeToSell,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastChart() {
    final forecast = _marketData!.forecast;
    if (forecast.isEmpty) return const SizedBox();

    final prices = forecast.map((e) => e.price).where((p) => p > 0).toList();
    if (prices.isEmpty) return const SizedBox();

    final maxY = prices.reduce((a, b) => a > b ? a : b) * 1.12;
    final minY = prices.reduce((a, b) => a < b ? a : b) * 0.88;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(children: [
            Text(
              '3-Month Price Forecast',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'AI Forecast',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppTheme.outlineVariant.withOpacity(0.25),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (v, _) => Text(
                        '₹${v.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < forecast.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              forecast[i].month,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: forecast
                        .asMap()
                        .entries
                        .where((e) => e.value.price > 0)
                        .map((e) =>
                            FlSpot(e.key.toDouble(), e.value.price))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: AppTheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primary.withOpacity(0.18),
                          AppTheme.primary.withOpacity(0),
                        ],
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

  Widget _buildAnalysisCard() {
    final analysis = _marketData!.analysis;
    if (analysis.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(children: [
            const Icon(Icons.analytics_rounded,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Market Analysis',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(
            analysis,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppTheme.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMSPTable() {
    final msps = [
      ('Cotton (Medium Staple)', '₹7,020'),
      ('Soybean', '₹4,892'),
      ('Wheat', '₹2,275'),
      ('Paddy (Common)', '₹2,300'),
      ('Tur Dal', '₹7,550'),
      ('Maize', '₹2,090'),
      ('Onion', 'No MSP'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(children: [
            const Icon(Icons.policy_rounded,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'MSP 2024-25 Reference',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...msps.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row.$1,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppTheme.onSurface)),
                    Text(
                      row.$2,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: row.$2 == 'No MSP'
                            ? AppTheme.error
                            : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppTheme.error),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Failed to load market data.',
            style: GoogleFonts.inter(color: AppTheme.error, fontSize: 13),
          ),
        ),
        TextButton(onPressed: _fetchMarket, child: const Text('Retry')),
      ]),
    );
  }
}