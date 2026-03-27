import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

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
        title: Text(
          'Field Intelligence',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceVariant,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'Satellite View'),
            Tab(text: 'Disease Detection'),
          ],
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

// ── Satellite Tab ─────────────────────────────────────────────────────────────

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
    _FieldInfo('East Block', 0.42, 'Average', const Color(0xFFf59e0b), '1.5 ha'),
    _FieldInfo('West Plot', 0.28, 'Poor', AppTheme.error, '0.9 ha'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layer selector
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _layers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sel = _layers[i] == _selectedLayer;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLayer = _layers[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primary : AppTheme.surfaceContainerLow,
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

          // Fake satellite map
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF1a3a1a),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _SatelliteMapPainter(_selectedLayer)),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_selectedLayer Layer • Live',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LegendItem(color: AppTheme.primary, label: '0.8+'),
                      _LegendItem(color: const Color(0xFF7ab07a), label: '0.6'),
                      _LegendItem(color: const Color(0xFFf59e0b), label: '0.4'),
                      _LegendItem(color: AppTheme.error, label: '<0.2'),
                      Text(
                        'NDVI Scale',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Field Health Status',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),

          ..._fields.map((field) => _FieldCard(field: field)),
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
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
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
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: field.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                field.ndvi.toStringAsFixed(2),
                style: GoogleFonts.manrope(
                  fontSize: 13,
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
                  '${field.area} • NDVI: ${field.ndvi}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    value: field.ndvi,
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(field.color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: field.color.withOpacity(0.15),
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
    final bg = Paint()..color = const Color(0xFF0d1f0d);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

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
        Paint()..color = layer == 'NDVI' ? color : _transformColor(color, layer),
      );
    }

    // Grid lines
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

  Color _transformColor(Color c, String layer) {
    if (layer == 'Moisture') return c.withBlue((c.blue + 60).clamp(0, 255));
    if (layer == 'Temperature') return c.withRed((c.red + 80).clamp(0, 255));
    return c;
  }

  @override
  bool shouldRepaint(covariant _SatelliteMapPainter oldDelegate) =>
      oldDelegate.layer != layer;
}

// ── Disease Detection Tab ─────────────────────────────────────────────────────

class _DiseaseDetectionTab extends StatefulWidget {
  const _DiseaseDetectionTab();

  @override
  State<_DiseaseDetectionTab> createState() => _DiseaseDetectionTabState();
}

class _DiseaseDetectionTabState extends State<_DiseaseDetectionTab> {
  File? _imageFile;
  bool _analyzing = false;
  String? _result;
  String? _error;

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
      _result = null;
      _error = null;
    });
    await _analyze();
  }

  Future<void> _analyze() async {
    if (_imageFile == null) return;
    setState(() { _analyzing = true; _error = null; });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64 = base64Encode(bytes);
      final ext = _imageFile!.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';

      final result = await ApiService.analyzeImage(
        base64Image: base64,
        mimeType: mime,
      );
      if (mounted) setState(() { _result = result; _analyzing = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Analysis failed. Please try again.';
        _analyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.primaryFixed.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryFixed, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.biotech_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
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
                        'Upload a crop photo for instant diagnosis',
                        style: GoogleFonts.inter(
                          fontSize: 12,
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

          // Pick buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Take Photo',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'From Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                  outlined: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Image preview
          if (_imageFile != null)
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.surfaceContainerHigh,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_imageFile!, fit: BoxFit.cover),
                  if (_analyzing)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            'Analyzing with AI...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _error!,
                style: GoogleFonts.inter(color: AppTheme.error, fontSize: 14),
              ),
            ),
          ],

          if (_result != null) ...[
            const SizedBox(height: 16),
            _DiseaseResultCard(result: _result!),
          ],

          if (_imageFile == null && _result == null)
            _buildPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.outlineVariant,
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 48,
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
            'Supports leaves, stems, roots, fruits',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.outlineVariant,
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
  final bool outlined;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppTheme.primary,
          borderRadius: BorderRadius.circular(50),
          border: outlined
              ? Border.all(color: AppTheme.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: outlined ? AppTheme.primary : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: outlined ? AppTheme.primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiseaseResultCard extends StatelessWidget {
  final String result;
  const _DiseaseResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final sections = _parseSections(result);

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
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Diagnosis Report',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...sections.map((s) => _SectionBlock(section: s)),
        ],
      ),
    );
  }

  List<_Section> _parseSections(String text) {
    final sections = <_Section>[];
    final lines = text.split('\n');
    _Section? current;

    for (final line in lines) {
      if (line.startsWith('## ')) {
        if (current != null) sections.add(current);
        current = _Section(title: line.substring(3), body: '');
      } else if (line.startsWith('### ')) {
        if (current != null) {
          current.body += '\n**${line.substring(4)}**';
        }
      } else if (current != null) {
        current.body += '\n$line';
      }
    }
    if (current != null) sections.add(current);
    return sections;
  }
}

class _Section {
  final String title;
  String body;
  _Section({required this.title, required this.body});
}

class _SectionBlock extends StatelessWidget {
  final _Section section;
  const _SectionBlock({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          section.body.trim(),
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.onSurface,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
