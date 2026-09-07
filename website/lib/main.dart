import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets/hero_section.dart';
import 'widgets/features_grid.dart';
import 'widgets/supported_formats.dart';
import 'widgets/plugins_section.dart';
import 'widgets/interactive_demo.dart';
import 'widgets/comparison_table.dart';
import 'widgets/faq_section.dart';
import 'widgets/download_cta.dart';
import 'package:kobalt_ui/kobalt_ui.dart';

void main() {
  runApp(const PeekitApp());
}

class PeekitApp extends StatefulWidget {
  const PeekitApp({super.key});

  @override
  State<PeekitApp> createState() => _PeekitAppState();
}

class _PeekitAppState extends State<PeekitApp> {
  String _lang = 'ru';
  bool _isDark = true;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _formatsKey = GlobalKey();
  final GlobalKey _pluginsKey = GlobalKey();
  final GlobalKey _demoKey = GlobalKey();
  final GlobalKey _compareKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey();

  void _scrollToSection(String sectionId) {
    GlobalKey? targetKey;
    switch (sectionId) {
      case 'features':
        targetKey = _featuresKey;
        break;
      case 'formats':
        targetKey = _formatsKey;
        break;
      case 'plugins':
        targetKey = _pluginsKey;
        break;
      case 'demo':
        targetKey = _demoKey;
        break;
      case 'compare':
        targetKey = _compareKey;
        break;
      case 'faq':
        targetKey = _faqKey;
        break;
      case 'download':
        targetKey = _downloadKey;
        break;
      case 'hero':
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        return;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peekit — Мгновенный просмотр по Пробелу для Windows',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(_isDark),
      home: Scaffold(
        body: Column(
          children: [
            KobaltNavBar(
              project: KobaltProjectId.peekIt,
              version: 'v1.0.0',
              isRussian: _lang == 'ru',
              onLanguageToggle: () => setState(() => _lang = _lang == 'ru' ? 'en' : 'ru'),
              isDark: _isDark,
              onThemeToggle: () => setState(() => _isDark = !_isDark),
              accentColor: AppTheme.primary,
              navLinks: [
                KobaltNavLink(
                  label: _lang == 'ru' ? 'Возможности' : 'Features',
                  onTap: () => _scrollToSection('features'),
                ),
                KobaltNavLink(
                  label: _lang == 'ru' ? 'Форматы' : 'Formats',
                  onTap: () => _scrollToSection('formats'),
                ),
                KobaltNavLink(
                  label: _lang == 'ru' ? 'Плагины' : 'Plugins',
                  onTap: () => _scrollToSection('plugins'),
                ),
                KobaltNavLink(
                  label: _lang == 'ru' ? 'Демо' : 'Demo',
                  onTap: () => _scrollToSection('demo'),
                ),
                KobaltNavLink(
                  label: _lang == 'ru' ? 'Сравнение' : 'Compare',
                  onTap: () => _scrollToSection('compare'),
                ),
                KobaltNavLink(
                  label: _lang == 'ru' ? 'FAQ' : 'FAQ',
                  onTap: () => _scrollToSection('faq'),
                ),
              ],
              onDownloadTap: () => _scrollToSection('download'),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    HeroSection(
                      lang: _lang,
                      isDark: _isDark,
                      onTryDemo: () => _scrollToSection('demo'),
                    ),
                    Container(key: _featuresKey, child: FeaturesGrid(lang: _lang, isDark: _isDark)),
                    Container(key: _formatsKey, child: SupportedFormats(lang: _lang, isDark: _isDark)),
                    Container(key: _pluginsKey, child: PluginsSection(lang: _lang, isDark: _isDark)),
                    Container(key: _demoKey, child: InteractiveDemo(lang: _lang, isDark: _isDark)),
                    Container(key: _compareKey, child: ComparisonTable(lang: _lang, isDark: _isDark)),
                    Container(key: _faqKey, child: FaqSection(lang: _lang, isDark: _isDark)),
                    Container(key: _downloadKey, child: DownloadCta(lang: _lang, isDark: _isDark)),
                    KobaltFooter(
                      project: KobaltProjectId.peekIt,
                      version: 'v1.0.0',
                      isRussian: _lang == 'ru',
                      accentColor: AppTheme.primary,
                      onBackToTop: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
