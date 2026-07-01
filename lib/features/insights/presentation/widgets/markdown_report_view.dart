import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MarkdownReportView extends StatelessWidget {
  final String markdown;

  const MarkdownReportView({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseMarkdown(markdown),
    );
  }

  /// Parses markdown headings, lists, and bold text without third-party packages.
  List<Widget> _parseMarkdown(String markdown) {
    final lines = markdown.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('###')) {
        // H3
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
            child: Text(
              trimmed.substring(3).trim(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.cyanAccent,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('##')) {
        // H2
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              trimmed.substring(2).trim(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryAccent,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('#')) {
        // H1
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              trimmed.substring(1).trim(),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('-') || trimmed.startsWith('*')) {
        // Bullet points
        final content = trimmed.substring(1).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
                  child: Icon(Icons.circle, size: 6, color: AppTheme.primaryAccent),
                ),
                Expanded(
                  child: _richTextParser(content),
                ),
              ],
            ),
          ),
        );
      } else {
        // Normal paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: _richTextParser(trimmed),
          ),
        );
      }
    }
    return widgets;
  }

  /// Helper to parse bold markdown (e.g. **bold**) in text.
  Widget _richTextParser(String text) {
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    final List<TextSpan> spans = [];
    int start = 0;

    for (final Match match in regExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13.5,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }
}
