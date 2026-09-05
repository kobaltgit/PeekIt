import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class InteractiveDemo extends StatefulWidget {
  final String lang;
  final bool isDark;

  const InteractiveDemo({
    super.key,
    required this.lang,
    required this.isDark,
  });

  @override
  State<InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<InteractiveDemo> {
  int _selectedIndex = 0;
  bool _isPreviewOpen = false;

  final List<Map<String, dynamic>> _files = [
    {
      'name': 'launch_trailer.mp4',
      'size': '24.6 MB',
      'type': 'video',
      'icon': Icons.movie_rounded,
      'color': Colors.purpleAccent,
      'duration': '00:48',
      'resolution': '1920 × 1080',
    },
    {
      'name': 'fluent_wallpaper.png',
      'size': '4.2 MB',
      'type': 'image',
      'icon': Icons.image_rounded,
      'color': Colors.lightBlueAccent,
      'resolution': '3840 × 2160',
    },
    {
      'name': 'synth_loop.wav',
      'size': '6.8 MB',
      'type': 'audio',
      'icon': Icons.audiotrack_rounded,
      'color': Colors.cyanAccent,
      'duration': '02:14',
      'bitrate': '320 kbps',
    },
    {
      'name': 'engine_core.rs',
      'size': '18.4 KB',
      'type': 'code',
      'icon': Icons.code_rounded,
      'color': Colors.greenAccent,
      'lines': '342 lines',
    },
    {
      'name': 'architecture.pdf',
      'size': '1.8 MB',
      'type': 'pdf',
      'icon': Icons.picture_as_pdf_rounded,
      'color': Colors.amberAccent,
      'pages': '12 pages',
    },
    {
      'name': 'release_assets.zip',
      'size': '48.1 MB',
      'type': 'archive',
      'icon': Icons.folder_zip_rounded,
      'color': Colors.indigoAccent,
      'items': '28 items',
    },
  ];

  void _togglePreview() {
    setState(() {
      _isPreviewOpen = !_isPreviewOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final selectedFile = _files[_selectedIndex];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Text(
                WebsiteI18n.t('demo_title', widget.lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                WebsiteI18n.t('demo_subtitle', widget.lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 40),

              // Simulated Explorer Container
              Container(
                height: 480,
                decoration: BoxDecoration(
                  color: widget.isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Explorer Header / Address bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: widget.isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            border: Border(
                              bottom: BorderSide(
                                color: widget.isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.arrow_back, size: 16, color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 16, color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_upward, size: 16, color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: widget.isDark ? AppTheme.darkCard : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: widget.isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.folder_open, size: 14, color: AppTheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        WebsiteI18n.t('demo_explorer_bar', widget.lang),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                          color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _togglePreview,
                                icon: const Icon(Icons.space_bar, size: 16),
                                label: const Text('SPACE (Preview)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // File List View
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: _files.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.transparent),
                            itemBuilder: (context, idx) {
                              final f = _files[idx];
                              final isSelected = idx == _selectedIndex;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = idx;
                                    _isPreviewOpen = true;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary.withOpacity(0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary.withOpacity(0.4)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(f['icon'] as IconData, color: f['color'] as Color, size: 20),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          f['name'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        f['size'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                          color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Floating Peekit Preview Popup
                    if (_isPreviewOpen)
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isMobile ? 320 : 540,
                          height: 340,
                          decoration: BoxDecoration(
                            color: (widget.isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.96),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.25),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Popup Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: widget.isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(selectedFile['icon'] as IconData, size: 16, color: AppTheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedFile['name'] as String,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${selectedFile['size']})',
                                          style: TextStyle(fontSize: 11, color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: _togglePreview,
                                      icon: const Icon(Icons.close, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),

                              // Popup Body
                              Expanded(
                                child: _buildPreviewBody(selectedFile),
                              ),

                              // Popup Footer Tip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: widget.isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      WebsiteI18n.t('demo_close_hint', widget.lang),
                                      style: TextStyle(fontSize: 11, color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                                    ),
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle_outline, size: 12, color: AppTheme.primary),
                                        SizedBox(width: 4),
                                        Text('Zero Latency (<50ms)', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildPreviewBody(Map<String, dynamic> f) {
    final type = f['type'] as String;

    if (type == 'video' || type == 'audio') {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accentPurple]),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              type == 'video' ? 'Fluent Video Player Active' : 'Fluent Audio Player Active',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              type == 'video' ? 'Duration: ${f['duration']} • ${f['resolution']}' : 'Duration: ${f['duration']} • ${f['bitrate']}',
              style: const TextStyle(fontSize: 12, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            // Mock Scrubber
            Row(
              children: [
                const Text('00:12', style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.35,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(f['duration'] as String, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
              ],
            ),
          ],
        ),
      );
    } else if (type == 'image') {
      return Container(
        color: Colors.black26,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.panorama_rounded, size: 64, color: AppTheme.primary),
              const SizedBox(height: 12),
              Text(
                f['resolution'] as String,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
              const Text('Interactive Zoom & Pan (100%)', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
    } else if (type == 'code') {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF07090E),
        child: const SingleChildScrollView(
          child: Text(
            'fn main() {\n    let preview = Peekit::inspect("file.rs");\n    println!("Latency: {} ms", preview.elapsed());\n    // Zero RAM footprint\n}',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF86EFAC)),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(f['icon'] as IconData, size: 48, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(f['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
