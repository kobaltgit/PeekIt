import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class SupportedFormats extends StatelessWidget {
  final String lang;
  final bool isDark;

  const SupportedFormats({
    super.key,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    final categories = [
      {
        'title': 'fmt_images',
        'desc': 'fmt_images_desc',
        'exts': ['PNG', 'JPG', 'WebP', 'GIF', 'SVG', 'BMP', 'ICO'],
        'icon': Icons.image_rounded,
        'color': AppTheme.primary,
      },
      {
        'title': 'fmt_media',
        'desc': 'fmt_media_desc',
        'exts': ['MP4', 'WebM', 'MKV', 'MP3', 'WAV', 'FLAC', 'AAC'],
        'icon': Icons.play_circle_fill_rounded,
        'color': AppTheme.accentPurple,
      },
      {
        'title': 'fmt_code',
        'desc': 'fmt_code_desc',
        'exts': ['Rust', 'Python', 'JS/TS', 'JSON', 'YAML', 'C++', 'SQL'],
        'icon': Icons.code_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'fmt_docs',
        'desc': 'fmt_docs_desc',
        'exts': ['PDF', 'Markdown', 'TXT', 'LOG', 'INI'],
        'icon': Icons.description_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'fmt_archives',
        'desc': 'fmt_archives_desc',
        'exts': ['ZIP (Tree, Sizes, Extraction-free)'],
        'icon': Icons.folder_zip_rounded,
        'color': AppTheme.accentIndigo,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                WebsiteI18n.t('formats_title', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                WebsiteI18n.t('formats_subtitle', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 48),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: categories.map((c) {
                  final color = c['color'] as Color;
                  final exts = c['exts'] as List<String>;

                  return Container(
                    width: isMobile ? size.width : 530,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(c['icon'] as IconData, color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              WebsiteI18n.t(c['title'] as String, lang),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          WebsiteI18n.t(c['desc'] as String, lang),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: exts.map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                e,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
