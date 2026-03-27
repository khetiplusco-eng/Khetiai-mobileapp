import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class PlantRecommendationScreen extends StatefulWidget {
  const PlantRecommendationScreen({super.key});

  @override
  State<PlantRecommendationScreen> createState() =>
      _PlantRecommendationScreenState();
}

class _PlantRecommendationScreenState
    extends State<PlantRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rainfallCtrl = TextEditingController(text: '800');
  final _regionCtrl = TextEditingController(text: 'Marathwada, Maharashtra');
  final _currentCropsCtrl = TextEditingController(text: 'Cotton, Soybean');

  String _soilType = 'Black Cotton Soil';
  String _season = 'Kharif (Jun-Oct)';
  bool _loading = false;
  String _result = '';
  bool _showResult = false;

  final _soilTypes = [
    'Black Cotton Soil',
    'Red Soil',
    'Alluvial Soil',
    'Sandy Loam',
    'Clay Loam',
    'Laterite Soil',
  ];

  final _seasons = [
    'Kharif (Jun-Oct)',
    'Rabi (Nov-Mar)',
    'Zaid (Mar-Jun)',
    'Year Round',
  ];

  Future<void> _getRecommendations() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _result = '';
      _showResult = true;
    });

    try {
      await for (final chunk in ApiService.plantRecommendationsStream(
        soilType: _soilType,
        season: _season,
        rainfall: double.parse(_rainfallCtrl.text),
        region: _regionCtrl.text,
        currentCrops: _currentCropsCtrl.text,
      )) {
        if (!mounted) break;
        setState(() => _result += chunk);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _result = 'Error getting recommendations. Try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Crop Recommendations',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          if (_showResult)
            TextButton(
              onPressed: () => setState(() {
                _showResult = false;
                _result = '';
              }),
              child: const Text('New Query'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF154212), Color(0xFF2d5a27)],
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
                          'AI Plant Intelligence',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get personalized crop recommendations based on your soil, climate & region.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.primaryFixed,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('🌿', style: TextStyle(fontSize: 48)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (!_showResult) ...[
              _buildForm(),
            ] else ...[
              _buildResultView(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormSection('Soil Information', Icons.terrain_rounded),
            const SizedBox(height: 12),
            _Label('Soil Type'),
            _DropdownWidget(
              value: _soilType,
              items: _soilTypes,
              onChanged: (v) => setState(() => _soilType = v!),
            ),
            const SizedBox(height: 14),

            _FormSection('Climate', Icons.wb_sunny_rounded),
            const SizedBox(height: 12),
            _Label('Growing Season'),
            _DropdownWidget(
              value: _season,
              items: _seasons,
              onChanged: (v) => setState(() => _season = v!),
            ),
            const SizedBox(height: 12),
            _Label('Annual Rainfall (mm)'),
            TextFormField(
              controller: _rainfallCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 800'),
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _FormSection('Location & Context', Icons.location_on_rounded),
            const SizedBox(height: 12),
            _Label('Region / District'),
            TextFormField(
              controller: _regionCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Pune, Maharashtra'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _Label('Currently Growing (optional)'),
            TextFormField(
              controller: _currentCropsCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Cotton, Wheat',
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _getRecommendations,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Get AI Recommendations'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final lines = _result.split('\n');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                )
              else
                const Icon(Icons.eco_rounded, color: AppTheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                _loading ? 'Generating recommendations...' : 'Your Recommendations',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...lines.map((line) {
            if (line.startsWith('## ') || line.startsWith('# ')) {
              return Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        line.replaceAll(RegExp(r'^#+\s*'), ''),
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (line.startsWith('### ')) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  line.substring(4),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
              );
            }
            if (line.startsWith('- ') || line.startsWith('• ')) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line.substring(2),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (line.isEmpty) return const SizedBox(height: 4);
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                line.replaceAll('**', ''),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.onSurface,
                  height: 1.6,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rainfallCtrl.dispose();
    _regionCtrl.dispose();
    _currentCropsCtrl.dispose();
    super.dispose();
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  const _FormSection(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DropdownWidget extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownWidget({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(50),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface),
        ),
      ),
    );
  }
}
