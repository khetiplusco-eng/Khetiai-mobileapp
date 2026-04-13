import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Renders AI markdown cleanly — NO raw symbols like **, ##, - leaking through.
class RichTextRenderer extends StatelessWidget {
  final String text;
  final bool isUser;
  final double baseFontSize;

  const RichTextRenderer({
    super.key,
    required this.text,
    this.isUser = false,
    this.baseFontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // H2
      if (trimmed.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Text(
            trimmed.substring(3).trim(),
            style: GoogleFonts.manrope(
              fontSize: baseFontSize + 2,
              fontWeight: FontWeight.w700,
              color: isUser ? Colors.white : AppTheme.primary,
              height: 1.3,
            ),
          ),
        ));
        continue;
      }

      // H3
      if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Text(
            trimmed.substring(4).trim(),
            style: GoogleFonts.manrope(
              fontSize: baseFontSize,
              fontWeight: FontWeight.w700,
              color: isUser ? Colors.white70 : AppTheme.primaryContainer,
              height: 1.3,
            ),
          ),
        ));
        continue;
      }

      // H1
      if (trimmed.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            trimmed.substring(2).trim(),
            style: GoogleFonts.manrope(
              fontSize: baseFontSize + 4,
              fontWeight: FontWeight.w800,
              color: isUser ? Colors.white : AppTheme.primary,
            ),
          ),
        ));
        continue;
      }

      // Bullet points (- or •)
      if (trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
        final content = trimmed.startsWith('- ')
            ? trimmed.substring(2)
            : trimmed.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.white.withOpacity(0.7)
                        : AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInlineText(content, isUser, baseFontSize),
              ),
            ],
          ),
        ));
        continue;
      }

      // Numbered lists
      final numMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(trimmed);
      if (numMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${numMatch.group(1)}.',
                style: GoogleFonts.inter(
                  fontSize: baseFontSize - 1,
                  fontWeight: FontWeight.w700,
                  color: isUser ? Colors.white70 : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInlineText(
                    numMatch.group(2)!, isUser, baseFontSize),
              ),
            ],
          ),
        ));
        continue;
      }

      // Divider (---)
      if (trimmed == '---' || trimmed == '___') {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(
            color: isUser
                ? Colors.white.withOpacity(0.2)
                : AppTheme.outlineVariant.withOpacity(0.4),
            thickness: 1,
          ),
        ));
        continue;
      }

      // Regular paragraph with inline bold
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: _buildInlineText(trimmed, isUser, baseFontSize),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildInlineText(String text, bool isUser, double fontSize) {
    // Parse inline bold (**text**) and handle clean rendering
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    final baseStyle = GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: isUser ? Colors.white : AppTheme.onSurface,
      height: 1.55,
    );

    final boldStyle = GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: isUser ? Colors.white : AppTheme.onSurface,
      height: 1.55,
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }
      parts.add(TextSpan(text: match.group(1), style: boldStyle));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      parts.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }

    if (parts.isEmpty) {
      return Text(text, style: baseStyle);
    }

    return RichText(text: TextSpan(children: parts));
  }
}