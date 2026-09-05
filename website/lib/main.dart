import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets/navbar.dart';
import 'widgets/hero_section.dart';
import 'widgets/features_grid.dart';
import 'widgets/supported_formats.dart';
import 'widgets/interactive_demo.dart';
import 'widgets/comparison_table.dart';
import 'widgets/faq_section.dart';
import 'widgets/download_cta.dart';
import 'widgets/footer.dart';

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
  final GlobalKey _demoKey = GlobalKey();
  final GlobalKey _compareKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  void _scrollToSection(String sectionId) {
    GlobalKey? targetKey;
    switch (sectionId) {
      case 'features':
        targetKey = _featuresKey;
        break;
      case 'formats':
        targetKey = _formatsKey;
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
            Navbar(
              lang: _lang,
              isDark: _isDark,
              onToggleTheme: () => setState(() => _isDark = !_isDark),
              onToggleLang: (newLang) => setState(() => _lang = newLang),
              onNavigate: _scrollToSection,
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
                    Container(key: _demoKey, child: InteractiveDemo(lang: _lang, isDark: _isDark)),
                    Container(key: _compareKey, child: ComparisonTable(lang: _lang, isDark: _isDark)),
                    Container(key: _faqKey, child: FaqSection(lang: _lang, isDark: _isDark)),
                    DownloadCta(lang: _lang, isDark: _isDark),
                    Footer(lang: _lang, isDark: _isDark),
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
