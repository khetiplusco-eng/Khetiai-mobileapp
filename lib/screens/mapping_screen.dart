import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../utils/rich_text_renderer.dart';

class MappingScreen extends StatefulWidget {
  const MappingScreen({super.key});

  @override
  State<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<MappingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Field Intelligence',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.outlineVariant.withOpacity(0.3),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.onSurfaceVariant,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              tabs: const [
                Tab(text: 'Satellite View'),
                Tab(text: 'AI Disease Scan'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SatelliteTab(),
          _DiseaseDetectionTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ── Satellite Tab ──────────────────────────────────────────────────────────────

class _SatelliteTab extends StatefulWidget {
  const _SatelliteTab();

  @override
  State<_SatelliteTab> createState() => _SatelliteTabState();
}

class _SatelliteTabState extends State<_SatelliteTab> {
  String _selectedLayer = 'NDVI';
  final _layers = ['NDVI', 'Moisture', 'Temperature', 'Chlorophyll'];

  final _fields = [
    _FieldInfo('North Field', 0.84, 'Excellent', AppTheme.primary, '4.2 ha'),
    _FieldInfo('South Field', 0.67, 'Good', const Color(0xFF7ab07a), '2.8 ha'),
    _FieldInfo('East Block', 0.42, 'Fair', const Color(0xFFf59e0b), '1.5 ha'),
    _FieldInfo('West Plot', 0.28, 'Poor', AppTheme.error, '0.9 ha'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layer selector pills
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _layers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sel = _layers[i] == _selectedLayer;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedLayer = _layers[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.primary
                          : AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      _layers[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppTheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Satellite map
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF0d1f0d),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                    painter: _SatelliteMapPainter(_selectedLayer)),
                // Layer badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22c55e),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$_selectedLayer · Live',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Legend
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _LegendItem(color: AppTheme.primary, label: '0.8+'),
                      const SizedBox(width: 10),
                      _LegendItem(
                          color: const Color(0xFF7ab07a), label: '0.6'),
                      const SizedBox(width: 10),
                      _LegendItem(
                          color: const Color(0xFFf59e0b), label: '0.4'),
                      const SizedBox(width: 10),
                      _LegendItem(color: AppTheme.error, label: '<0.2'),
                      const Spacer(),
                      Text(
                        'NDVI Scale',
                        style: GoogleFonts.inter(
                            fontSize: 9, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Field Health Status',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          ..._fields.map((f) => _FieldCard(field: f)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 9)),
    ]);
  }
}

class _FieldInfo {
  final String name;
  final double ndvi;
  final String status;
  final Color color;
  final String area;
  _FieldInfo(this.name, this.ndvi, this.status, this.color, this.area);
}

class _FieldCard extends StatelessWidget {
  final _FieldInfo field;
  const _FieldCard({required this.field});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: field.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                field.ndvi.toStringAsFixed(2),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: field.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.name,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  '${field.area} · NDVI: ${field.ndvi}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    value: field.ndvi,
                    backgroundColor:
                        AppTheme.surfaceContainerHigh,
                    valueColor:
                        AlwaysStoppedAnimation(field.color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: field.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              field.status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: field.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SatelliteMapPainter extends CustomPainter {
  final String layer;
  _SatelliteMapPainter(this.layer);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF0d1f0d));

    final patches = [
      (Rect.fromLTWH(20, 20, 140, 100), const Color(0xFF1a5c1a)),
      (Rect.fromLTWH(170, 10, 90, 120), const Color(0xFF3d8b3d)),
      (Rect.fromLTWH(20, 140, 100, 80), const Color(0xFF7ab07a)),
      (Rect.fromLTWH(270, 60, 80, 90), const Color(0xFFc8a46e)),
      (Rect.fromLTWH(140, 160, 120, 70), const Color(0xFFba1a1a)),
      (Rect.fromLTWH(130, 30, 30, 30), const Color(0xFF2d5a27)),
    ];

    for (final (rect, color) in patches) {
      canvas.drawRect(
          rect,
          Paint()
            ..color = layer == 'NDVI'
                ? color
                : _transform(color, layer));
    }

    final grid = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  Color _transform(Color c, String layer) {
    if (layer == 'Moisture')
      return c.withBlue((c.blue + 60).clamp(0, 255));
    if (layer == 'Temperature')
      return c.withRed((c.red + 80).clamp(0, 255));
    return c;
  }

  @override
  bool shouldRepaint(covariant _SatelliteMapPainter old) =>
      old.layer != layer;
}

// ── Disease Detection Tab ──────────────────────────────────────────────────────

class _DiseaseDetectionTab extends StatefulWidget {
  const _DiseaseDetectionTab();

  @override
  State<_DiseaseDetectionTab> createState() =>
      _DiseaseDetectionTabState();
}

class _DiseaseDetectionTabState extends State<_DiseaseDetectionTab> {
  File? _imageFile;
  bool _analyzing = false;
  String? _diagnosisText;
  String? _visualObservation;
  String? _error;
  String? _pipeline;

  // Selected crop for better diagnosis
  String _selectedCrop = 'Cotton';
  final _crops = [
    'Cotton', 'Soybean', 'Wheat', 'Rice', 'Tomato', 'Onion',
    'Sugarcane', 'Maize', 'Tur Dal'
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _diagnosisText = null;
      _visualObservation = null;
      _error = null;
      _pipeline = null;
    });
    await _analyze();
  }

  Future<void> _analyze() async {
    if (_imageFile == null) return;
    setState(() {
      _analyzing = true;
      _error = null;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final b64 = base64Encode(bytes);
      final ext = _imageFile!.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';

      final result = await ApiService.analyzeImage(
        base64Image: b64,
        mimeType: mime,
        crop: _selectedCrop,
        district: 'Akola',
        state: 'Maharashtra',
        country: 'India',
      );

      if (mounted) {
        setState(() {
          _diagnosisText = result['result'] as String? ?? '';
          _visualObservation =
              result['visualObservation'] as String?;
          _pipeline = result['pipeline'] as String?;
          _analyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Analysis failed: ${e.toString().replaceAll('Exception: ', '')}';
          _analyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.08),
                  AppTheme.primaryFixed.withOpacity(0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppTheme.primaryFixed, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.biotech_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Disease Scanner',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        'Powered by Llama Scout Vision + K2 AI',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Crop selector
          Text(
            'Select Crop for Better Accuracy',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _crops.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final sel = _crops[i] == _selectedCrop;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCrop = _crops[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.primary
                          : AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      _crops[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppTheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Pick image buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Take Photo',
                  filled: true,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  filled: false,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Image preview
          if (_imageFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.file(
                    _imageFile!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (_analyzing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                            const SizedBox(height: 14),
                            Text(
                              'Analyzing with AI...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Llama Scout Vision → K2 Diagnostics',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Error state
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppTheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.inter(
                          color: AppTheme.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Diagnosis result
          if (_diagnosisText != null && _diagnosisText!.isNotEmpty) ...[
            _DiagnosisResultCard(
              result: _diagnosisText!,
              pipeline: _pipeline,
              crop: _selectedCrop,
            ),
          ],

          // Placeholder when no image
          if (_imageFile == null)
            Container(
              height: 180,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.outlineVariant, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 44,
                    color: AppTheme.outlineVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Upload a photo of your crop',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Leaves, stems, roots, fruits — all supported',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: AppTheme.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: filled ? Colors.white : AppTheme.primary,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisResultCard extends StatelessWidget {
  final String result;
  final String? pipeline;
  final String crop;

  const _DiagnosisResultCard({
    required this.result,
    required this.crop,
    this.pipeline,
  });

  // Extract severity score from text
  int? _extractSeverity(String text) {
    final match =
        RegExp(r'Severity Score.*?(\d+)', caseSensitive: false)
            .firstMatch(text);
    return match != null ? int.tryParse(match.group(1) ?? '') : null;
  }

  Color _severityColor(int score) {
    if (score <= 3) return const Color(0xFF22c55e);
    if (score <= 7) return const Color(0xFFf59e0b);
    return AppTheme.error;
  }

  String _severityLabel(int score) {
    if (score <= 3) return 'Monitor';
    if (score <= 7) return 'Treat Soon';
    return 'Act Now!';
  }

  @override
  Widget build(BuildContext context) {
    final severity = _extractSeverity(result);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Diagnosis Report',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      '$crop · Akola, Maharashtra',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (severity != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _severityColor(severity).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: _severityColor(severity).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$severity/10',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _severityColor(severity),
                        ),
                      ),
                      Text(
                        _severityLabel(severity),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _severityColor(severity),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Clean rendered markdown
          RichTextRenderer(
            text: result,
            isUser: false,
            baseFontSize: 13.5,
          ),

          if (pipeline != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Pipeline: $pipeline',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}