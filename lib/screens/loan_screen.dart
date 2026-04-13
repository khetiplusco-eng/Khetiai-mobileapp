import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../utils/rich_text_renderer.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _landCtrl = TextEditingController(text: '4');
  final _incomeCtrl = TextEditingController(text: '150000');
  final _loanAmtCtrl = TextEditingController(text: '300000');

  String _selectedCrop = 'Cotton';
  String _selectedPurpose = 'Crop Production';
  bool _hasKCC = false;
  bool _isStreaming = false;
  String _result = '';
  bool _showForm = true;

  final _crops = [
    'Cotton', 'Wheat', 'Rice', 'Sugarcane', 'Soybean',
    'Tur Dal', 'Vegetable', 'Onion'
  ];
  final _purposes = [
    'Crop Production',
    'Land Development',
    'Irrigation Setup',
    'Farm Equipment',
    'Post Harvest Storage',
    'Animal Husbandry',
    'Horticulture',
  ];

  final _schemes = [
    _LoanScheme('Kisan Credit Card', 'Up to ₹3 lakh @ 4% p.a.',
        Icons.credit_card_rounded, AppTheme.primary),
    _LoanScheme('PM-KISAN', '₹6,000/year direct benefit',
        Icons.agriculture_rounded, AppTheme.tertiary),
    _LoanScheme('NABARD Farm Loan', 'Up to ₹20 lakh for farm needs',
        Icons.account_balance_rounded, const Color(0xFF7a3d00)),
    _LoanScheme('Crop Insurance (PMFBY)', 'Low premium, full coverage',
        Icons.shield_rounded, const Color(0xFF1d4ed8)),
  ];

  Future<void> _checkEligibility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _result = '';
      _isStreaming = true;
      _showForm = false;
    });

    try {
      await for (final chunk in ApiService.loanEligibilityStream(
        farmerName: _nameCtrl.text,
        landArea: double.parse(_landCtrl.text),
        cropType: _selectedCrop,
        annualIncome: double.parse(_incomeCtrl.text),
        loanPurpose: _selectedPurpose,
        loanAmount: int.parse(_loanAmtCtrl.text),
        hasKCC: _hasKCC,
      )) {
        if (!mounted) break;
        setState(() => _result += chunk);
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _result = 'Unable to check eligibility. Please check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _isStreaming = false);
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
          'Loans & Schemes',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          if (!_showForm)
            TextButton.icon(
              onPressed: () => setState(() {
                _showForm = true;
                _result = '';
              }),
              icon: const Icon(Icons.edit_rounded, size: 16,
                  color: AppTheme.primary),
              label: Text('Edit',
                  style: GoogleFonts.inter(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Schemes overview
            Text(
              'Available Schemes',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _schemes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) =>
                    _SchemeCard(scheme: _schemes[i]),
              ),
            ),
            const SizedBox(height: 20),

            if (_showForm)
              _buildForm()
            else
              _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Eligibility Checker',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            _Label('Full Name'),
            _TextField(
              controller: _nameCtrl,
              hint: 'Enter your full name',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Land Area (acres)'),
                    _TextField(
                      controller: _landCtrl,
                      hint: 'e.g. 4.5',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Annual Income (₹)'),
                    _TextField(
                      controller: _incomeCtrl,
                      hint: 'e.g. 150000',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 14),

            _Label('Main Crop'),
            _DropdownField(
              value: _selectedCrop,
              items: _crops,
              onChanged: (v) => setState(() => _selectedCrop = v!),
            ),
            const SizedBox(height: 14),

            _Label('Loan Purpose'),
            _DropdownField(
              value: _selectedPurpose,
              items: _purposes,
              onChanged: (v) => setState(() => _selectedPurpose = v!),
            ),
            const SizedBox(height: 14),

            _Label('Loan Amount Required (₹)'),
            _TextField(
              controller: _loanAmtCtrl,
              hint: 'e.g. 300000',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (int.tryParse(v) == null) return 'Invalid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            GestureDetector(
              onTap: () => setState(() => _hasKCC = !_hasKCC),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _hasKCC
                      ? AppTheme.primary.withOpacity(0.08)
                      : AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _hasKCC
                        ? AppTheme.primary.withOpacity(0.3)
                        : AppTheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _hasKCC
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _hasKCC
                              ? AppTheme.primary
                              : AppTheme.outline,
                          width: 2,
                        ),
                      ),
                      child: _hasKCC
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'I already have a Kisan Credit Card (KCC)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _checkEligibility,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.verified_rounded, size: 20),
                label: Text(
                  'Check My Eligibility',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2d5a27), Color(0xFF154212)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Loan Assessment',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    _isStreaming ? 'Analyzing eligibility...' : 'Assessment complete',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (_isStreaming)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.primary),
              ),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          if (_result.isNotEmpty)
            RichTextRenderer(
              text: _result,
              isUser: false,
              baseFontSize: 14,
            )
          else if (_isStreaming)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Preparing assessment...',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _landCtrl.dispose();
    _incomeCtrl.dispose();
    _loanAmtCtrl.dispose();
    super.dispose();
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

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

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: AppTheme.onSurfaceVariant, fontSize: 13),
        filled: true,
        fillColor: AppTheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((i) =>
                  DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          style: GoogleFonts.inter(
              fontSize: 14, color: AppTheme.onSurface),
        ),
      ),
    );
  }
}

class _LoanScheme {
  final String name;
  final String desc;
  final IconData icon;
  final Color color;
  const _LoanScheme(this.name, this.desc, this.icon, this.color);
}

class _SchemeCard extends StatelessWidget {
  final _LoanScheme scheme;
  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(scheme.icon, color: scheme.color, size: 22),
          const SizedBox(height: 8),
          Text(
            scheme.name,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            scheme.desc,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}