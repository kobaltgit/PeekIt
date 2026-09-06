import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class PluginItem {
  final String id;
  final String name;
  final String category;
  final String version;
  final String author;
  final List<String> extensions;
  final String descriptionKey;
  final List<String> features;
  final IconData icon;
  final Color color;

  const PluginItem({
    required this.id,
    required this.name,
    required this.category,
    required this.version,
    required this.author,
    required this.extensions,
    required this.descriptionKey,
    required this.features,
    required this.icon,
    required this.color,
  });
}

class PluginsSection extends StatefulWidget {
  final String lang;
  final bool isDark;

  const PluginsSection({
    super.key,
    required this.lang,
    required this.isDark,
  });

  @override
  State<PluginsSection> createState() => _PluginsSectionState();
}

class _PluginsSectionState extends State<PluginsSection> {
  String _selectedCategory = 'all';

  final List<PluginItem> _plugins = const [
    PluginItem(
      id: 'com.peekit.psd-viewer',
      name: 'Adobe Photoshop Viewer',
      category: 'graphics',
      version: '1.0.0',
      author: 'Kobalt',
      extensions: ['.psd'],
      descriptionKey: 'plugin_psd_desc',
      features: [
        'plugin_psd_f1',
        'plugin_psd_f2',
        'plugin_psd_f3',
      ],
      icon: Icons.layers_rounded,
      color: Color(0xFFF97316),
    ),
    PluginItem(
      id: 'com.peekit.ai-viewer',
      name: 'Adobe Illustrator Viewer',
      category: 'graphics',
      version: '1.0.0',
      author: 'Kobalt',
      extensions: ['.ai'],
      descriptionKey: 'plugin_ai_desc',
      features: [
        'plugin_ai_f1',
        'plugin_ai_f2',
        'plugin_ai_f3',
      ],
      icon: Icons.brush_rounded,
      color: Color(0xFFF97316),
    ),
    PluginItem(
      id: 'com.peekit.eps-viewer',
      name: 'Encapsulated PostScript',
      category: 'graphics',
      version: '1.0.0',
      author: 'Kobalt',
      extensions: ['.eps'],
      descriptionKey: 'plugin_eps_desc',
      features: [
        'plugin_eps_f1',
        'plugin_eps_f2',
        'plugin_eps_f3',
      ],
      icon: Icons.gesture_rounded,
      color: Color(0xFFF97316),
    ),
    PluginItem(
      id: 'com.peekit.3d-viewer',
      name: '3D Model Viewer',
      category: '3d',
      version: '1.0.0',
      author: 'Kobalt',
      extensions: ['.stl', '.obj', '.gltf', '.glb', '.ply'],
      descriptionKey: 'plugin_3d_desc',
      features: [
        'plugin_3d_f1',
        'plugin_3d_f2',
        'plugin_3d_f3',
      ],
      icon: Icons.view_in_ar_rounded,
      color: Color(0xFF06B6D4),
    ),
    PluginItem(
      id: 'com.peekit.docx-viewer',
      name: 'Word Document Viewer',
      category: 'document',
      version: '1.0.0',
      author: 'PeekIt Team',
      extensions: ['.docx', '.doc'],
      descriptionKey: 'plugin_docx_desc',
      features: [
        'plugin_docx_f1',
        'plugin_docx_f2',
        'plugin_docx_f3',
      ],
      icon: Icons.article_rounded,
      color: Color(0xFF3B82F6),
    ),
    PluginItem(
      id: 'com.peekit.ebook-viewer',
      name: 'E-Book Reader',
      category: 'document',
      version: '1.0.0',
      author: 'Kobalt',
      extensions: ['.epub', '.fb2'],
      descriptionKey: 'plugin_ebook_desc',
      features: [
        'plugin_ebook_f1',
        'plugin_ebook_f2',
        'plugin_ebook_f3',
      ],
      icon: Icons.menu_book_rounded,
      color: Color(0xFF3B82F6),
    ),
    PluginItem(
      id: 'com.peekit.sheet-viewer',
      name: 'Spreadsheet Viewer',
      category: 'spreadsheet',
      version: '1.0.0',
      author: 'PeekIt Team',
      extensions: ['.xlsx', '.xls', '.csv', '.tsv', '.ods'],
      descriptionKey: 'plugin_sheet_desc',
      features: [
        'plugin_sheet_f1',
        'plugin_sheet_f2',
        'plugin_sheet_f3',
      ],
      icon: Icons.table_chart_rounded,
      color: Color(0xFF10B981),
    ),
    PluginItem(
      id: 'com.peekit.slides-viewer',
      name: 'PowerPoint Viewer',
      category: 'document',
      version: '1.0.0',
      author: 'PeekIt Team',
      extensions: ['.pptx', '.ppt'],
      descriptionKey: 'plugin_slides_desc',
      features: [
        'plugin_slides_f1',
        'plugin_slides_f2',
        'plugin_slides_f3',
      ],
      icon: Icons.slideshow_rounded,
      color: Color(0xFFF59E0B),
    ),
    PluginItem(
      id: 'com.peekit.font-viewer',
      name: 'Font Viewer',
      category: 'font',
      version: '1.0.0',
      author: 'Kobalt',
      extensions: ['.ttf', '.otf', '.woff', '.woff2'],
      descriptionKey: 'plugin_font_desc',
      features: [
        'plugin_font_f1',
        'plugin_font_f2',
        'plugin_font_f3',
      ],
      icon: Icons.font_download_rounded,
      color: Color(0xFFA855F7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    final filtered = _selectedCategory == 'all'
        ? _plugins
        : _plugins.where((p) => p.category == _selectedCategory).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                ),
                child: Text(
                  WebsiteI18n.t('plugins_tag', widget.lang),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                WebsiteI18n.t('plugins_title', widget.lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Text(
                  WebsiteI18n.t('plugins_subtitle', widget.lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filterPill('all', 'cat_all'),
                    _filterPill('graphics', 'cat_graphics'),
                    _filterPill('3d', 'cat_3d'),
                    _filterPill('document', 'cat_docs'),
                    _filterPill('font', 'cat_fonts'),
                    _filterPill('spreadsheet', 'cat_sheets'),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Plugins Cards Grid
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: filtered.map((plugin) => _buildPluginCard(plugin, isMobile, size.width)).toList(),
              ),
              const SizedBox(height: 48),

              // Bottom Callout Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(widget.isDark ? 0.15 : 0.08),
                      AppTheme.accentIndigo.withOpacity(widget.isDark ? 0.12 : 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    if (!isMobile) ...[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 24),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WebsiteI18n.t('plugins_store_title', widget.lang),
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            WebsiteI18n.t('plugins_store_desc', widget.lang),
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(AppConstants.pluginsUrl)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24,
                          vertical: isMobile ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: Text(
                        WebsiteI18n.t('plugins_btn_catalog', widget.lang),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterPill(String catId, String labelKey) {
    final isSelected = _selectedCategory == catId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _selectedCategory = catId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : (widget.isDark ? AppTheme.darkCard : AppTheme.lightCard),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : (widget.isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              WebsiteI18n.t(labelKey, widget.lang),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPluginCard(PluginItem plugin, bool isMobile, double screenWidth) {
    // 3 cards per row on desktop (approx 370px each), 2 on tablet, 1 on mobile
    final cardWidth = isMobile
        ? screenWidth - 48
        : (screenWidth > 1150 ? 373.0 : (screenWidth > 800 ? 470.0 : screenWidth - 48));

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: plugin.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: plugin.color.withOpacity(0.3)),
                ),
                child: Icon(plugin.icon, color: plugin.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '@${plugin.author}',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'v${plugin.version}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            WebsiteI18n.t(plugin.descriptionKey, widget.lang),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Key features bullet points
          Column(
            children: plugin.features.map((featKey) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 14, color: plugin.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        WebsiteI18n.t(featKey, widget.lang),
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.3,
                          color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Extensions list chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: plugin.extensions.map((ext) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                  ),
                ),
                child: Text(
                  ext,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
