import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class Navbar extends StatelessWidget {
  final String lang;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onToggleLang;
  final Function(String) onNavigate;

  const Navbar({
    super.key,
    required this.lang,
    required this.isDark,
    required this.onToggleTheme,
    required this.onToggleLang,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkBg : AppTheme.lightBg).withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onNavigate('hero'),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accentIndigo],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.visibility_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          AppConstants.appVersion,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Desktop Nav Links
              if (!isMobile)
                Row(
                  children: [
                    _navItem('nav_features', 'features'),
                    _navItem('nav_formats', 'formats'),
                    _navItem('nav_plugins', 'plugins'),
                    _navItem('nav_demo', 'demo'),
                    _navItem('nav_compare', 'compare'),
                    _navItem('nav_faq', 'faq'),
                  ],
                ),

              // Actions (Theme, Lang, GitHub)
              Row(
                children: [
                  // Language Toggle (RU / EN)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onToggleLang(lang == 'ru' ? 'en' : 'ru'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                          ),
                          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.language,
                              size: 14,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lang.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Theme Toggle (Dark / Light)
                  IconButton(
                    onPressed: onToggleTheme,
                    icon: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      size: 20,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                    tooltip: isDark ? 'Light theme' : 'Dark theme',
                  ),
                  const SizedBox(width: 8),

                  // GitHub Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(AppConstants.githubUrl)),
                      icon: const Icon(Icons.code, size: 16),
                      label: const Text('GitHub'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                        foregroundColor: isDark ? AppTheme.darkText : AppTheme.lightText,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                          ),
                        ),
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

  Widget _navItem(String labelKey, String sectionId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onNavigate(sectionId),
          child: Text(
            WebsiteI18n.t(labelKey, lang),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}
