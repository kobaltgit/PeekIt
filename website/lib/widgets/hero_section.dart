import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class HeroSection extends StatelessWidget {
  final String lang;
  final bool isDark;
  final VoidCallback onTryDemo;

  const HeroSection({
    super.key,
    required this.lang,
    required this.isDark,
    required this.onTryDemo,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 850;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Ecosystem Tag Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.12),
                      AppTheme.accentIndigo.withOpacity(0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      WebsiteI18n.t('hero_tag', lang),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Hero Title with Gradient Accent
              Text(
                WebsiteI18n.t('hero_title', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 32 : 56,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -1.5,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  WebsiteI18n.t('hero_subtitle', lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    height: 1.6,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Metric Badges
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _metricPill(Icons.memory_rounded, 'hero_badge_ram'),
                  _metricPill(Icons.speed_rounded, 'hero_badge_speed'),
                  _metricPill(Icons.bolt_rounded, 'hero_badge_rust'),
                ],
              ),
              const SizedBox(height: 40),

              // Action Buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(AppConstants.downloadExeUrl)),
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      WebsiteI18n.t('hero_btn_download', lang),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppTheme.primary.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onTryDemo,
                    icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                    label: Text(
                      WebsiteI18n.t('nav_demo', lang),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.darkText : AppTheme.lightText,
                      side: BorderSide(
                        color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricPill(IconData icon, String labelKey) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            WebsiteI18n.t(labelKey, lang),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
