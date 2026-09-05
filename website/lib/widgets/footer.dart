import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class Footer extends StatelessWidget {
  final String lang;
  final bool isDark;

  const Footer({
    super.key,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                WebsiteI18n.t('footer_ecosystem', lang),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 10,
                children: [
                  _ecoLink(WebsiteI18n.t('footer_minibin', lang), AppConstants.minibinUrl),
                  _ecoLink(WebsiteI18n.t('footer_undoit', lang), AppConstants.undoitUrl),
                  _ecoLink(WebsiteI18n.t('footer_polyshift', lang), AppConstants.polyShiftUrl),
                  _ecoLink(WebsiteI18n.t('footer_peekit', lang), AppConstants.githubUrl),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                WebsiteI18n.t('footer_rights', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ecoLink(String title, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(url)),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
