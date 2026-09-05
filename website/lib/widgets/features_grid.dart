import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class FeaturesGrid extends StatelessWidget {
  final String lang;
  final bool isDark;

  const FeaturesGrid({
    super.key,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    final features = [
      {'icon': Icons.bolt_rounded, 'title': 'feat_1_title', 'desc': 'feat_1_desc', 'color': AppTheme.primary},
      {'icon': Icons.play_circle_fill_rounded, 'title': 'feat_2_title', 'desc': 'feat_2_desc', 'color': AppTheme.accentPurple},
      {'icon': Icons.edit_off_rounded, 'title': 'feat_3_title', 'desc': 'feat_3_desc', 'color': const Color(0xFF10B981)},
      {'icon': Icons.shield_rounded, 'title': 'feat_4_title', 'desc': 'feat_4_desc', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.tab_rounded, 'title': 'feat_5_title', 'desc': 'feat_5_desc', 'color': AppTheme.accentIndigo},
      {'icon': Icons.lock_outline_rounded, 'title': 'feat_6_title', 'desc': 'feat_6_desc', 'color': const Color(0xFF06B6D4)},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                WebsiteI18n.t('feat_title', lang),
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
                WebsiteI18n.t('feat_subtitle', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 48),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 190,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final f = features[index];
                  final icon = f['icon'] as IconData;
                  final color = f['color'] as Color;

                  return Container(
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          WebsiteI18n.t(f['title'] as String, lang),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          WebsiteI18n.t(f['desc'] as String, lang),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
