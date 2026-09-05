import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class ComparisonTable extends StatelessWidget {
  final String lang;
  final bool isDark;

  const ComparisonTable({
    super.key,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    final rows = [
      {
        'param': 'param_ram',
        'peekit': 'param_ram_peekit',
        'ms': 'param_ram_ms',
        'pt': 'param_ram_pt',
      },
      {
        'param': 'param_speed',
        'peekit': 'param_speed_peekit',
        'ms': 'param_speed_ms',
        'pt': 'param_speed_pt',
      },
      {
        'param': 'param_media',
        'peekit': 'param_media_peekit',
        'ms': 'param_media_ms',
        'pt': 'param_media_pt',
      },
      {
        'param': 'param_admin',
        'peekit': 'param_admin_peekit',
        'ms': 'param_admin_ms',
        'pt': 'param_admin_pt',
      },
      {
        'param': 'param_size',
        'peekit': 'param_size_peekit',
        'ms': 'param_size_ms',
        'pt': 'param_size_pt',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Text(
                WebsiteI18n.t('compare_title', lang),
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
                WebsiteI18n.t('compare_subtitle', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 40),

              // Table Box
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: isMobile ? 650 : 900),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            WebsiteI18n.t('col_param', lang),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                WebsiteI18n.t('col_peekit', lang),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            WebsiteI18n.t('col_msstore', lang),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            WebsiteI18n.t('col_powertoys', lang),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                      rows: rows.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                WebsiteI18n.t(r['param']!, lang),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  WebsiteI18n.t(r['peekit']!, lang),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                WebsiteI18n.t(r['ms']!, lang),
                                style: TextStyle(
                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                WebsiteI18n.t(r['pt']!, lang),
                                style: TextStyle(
                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
