import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _landCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _loanAmtCtrl = TextEditingController();

  String _selectedCrop = 'Cotton';
  String _selectedPurpose = 'Crop Production';
  bool _hasKCC = false;
  bool _isStreaming = false;
  String _result = '';
  bool _showForm = true;

  final _crops = ['Cotton', 'Wheat', 'Rice', 'Sugarcane', 'Soybean', 'Vegetable'];
  final _purposes = [
    'Crop Production',
    'Land Development',
    'Irrigation',
    'Farm Equipment',
    'Post Harvest Storage',
    'Animal Husbandry',
  ];

  final _schemes = [
    _LoanScheme(
      'Kisan Credit Card (KCC)',
      'Up to ₹3 lakh at 4% interest',
      Icons.credit_card_rounded,
      const Color(0xFF2d5a27),
    ),
    _LoanScheme(
      'PM-KISAN',
      '₹6,000/year income support',
      Icons.agriculture_rounded,
      AppTheme.tertiary,
    ),
    _LoanScheme(
      'NABARD Farm Loan',
      'Up to ₹20 lakh for farm needs',
      Icons.account_balance_rounded,
      const Color(0xFF7a3d00),
    ),
    _LoanScheme(
      'Agri Gold Loan',
      'Quick sanction against gold',
      Icons.monetization_on_rounded,
      const Color(0xFFb45309),
    ),
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
        setState(() => _result = 'Error checking eligibility. Please try again.');
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
        title: Text(
          'Loan & Schemes',
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
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick schemes overview
            Text(
              'Available Schemes',
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _schemes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _SchemeCard(scheme: _schemes[i]),
              ),
            ),
            const SizedBox(height: 20),

            if (_showForm) ...[
              _buildEligibilityForm(),
            ] else ...[
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_rounded, color: AppTheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Eligibility Check',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _FormLabel('Full Name'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'Enter your name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormLabel('Land Area (acres)'),
                      TextFormField(
                        controller: _landCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 4.5'),
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
                      _FormLabel('Annual Income (₹)'),
                      TextFormField(
                        controller: _incomeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 150000'),
                        validator: (v) {
                          if (v!.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _FormLabel('Main Crop'),
            _DropdownField(
              value: _selectedCrop,
              items: _crops,
              onChanged: (v) => setState(() => _selectedCrop = v!),
            ),
            const SizedBox(height: 14),

            _FormLabel('Loan Purpose'),
            _DropdownField(
              value: _selectedPurpose,
              items: _purposes,
              onChanged: (v) => setState(() => _selectedPurpose = v!),
            ),
            const SizedBox(height: 14),

            _FormLabel('Loan Amount Required (₹)'),
            TextFormField(
              controller: _loanAmtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 300000'),
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (int.tryParse(v) == null) return 'Invalid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Checkbox(
                  value: _hasKCC,
                  onChanged: (v) => setState(() => _hasKCC = v!),
                  activeColor: AppTheme.primary,
                ),
                Text(
                  'I have a Kisan Credit Card (KCC)',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _checkEligibility,
                icon: const Icon(Icons.verified_rounded),
                label: const Text('Check Eligibility'),
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
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Column(
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
                  if (_isStreaming)
                    Text(
                      'Analyzing...',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              if (_isStreaming) ...[
                const Spacer(),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildResultText(_result),
        ],
      ),
    );
  }

  Widget _buildResultText(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('## ') || line.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              line.replaceAll(RegExp(r'^#+\s*'), ''),
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          );
        }
        if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
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
        if (line.isEmpty) return const SizedBox(height: 4);
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            line.replaceAll('**', ''),
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppTheme.onSurface,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
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

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

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
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.onSurface,
          ),
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
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
