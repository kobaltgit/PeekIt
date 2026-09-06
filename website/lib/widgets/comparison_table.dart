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
        'param': 'param_tech',
        'peekit': 'param_tech_peekit',
        'ms': 'param_tech_ql',
        'pt': 'param_tech_pt',
      },
      {
        'param': 'param_ram_idle',
        'peekit': 'param_ram_idle_peekit',
        'ms': 'param_ram_idle_ql',
        'pt': 'param_ram_idle_pt',
      },
      {
        'param': 'param_ram_active',
        'peekit': 'param_ram_active_peekit',
        'ms': 'param_ram_active_ql',
        'pt': 'param_ram_active_pt',
      },
      {
        'param': 'param_speed',
        'peekit': 'param_speed_peekit',
        'ms': 'param_speed_ql',
        'pt': 'param_speed_pt',
      },
      {
        'param': 'param_size',
        'peekit': 'param_size_peekit',
        'ms': 'param_size_ql',
        'pt': 'param_size_pt',
      },
      {
        'param': 'param_plugins',
        'peekit': 'param_plugins_peekit',
        'ms': 'param_plugins_ql',
        'pt': 'param_plugins_pt',
      },
      {
        'param': 'param_admin',
        'peekit': 'param_admin_peekit',
        'ms': 'param_admin_ql',
        'pt': 'param_admin_pt',
      },
    ];

    final c1Width = isMobile ? 140.0 : 180.0;
    final c2Width = isMobile ? 185.0 : 235.0;
    final c3Width = isMobile ? 180.0 : 230.0;
    final c4Width = isMobile ? 165.0 : 205.0;

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
                    constraints: BoxConstraints(minWidth: isMobile ? 670 : 880),
                    child: DataTable(
                      columnSpacing: isMobile ? 12 : 20,
                      horizontalMargin: isMobile ? 12 : 20,
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: double.infinity,
                      headingRowColor: WidgetStateProperty.all(
                        isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                      ),
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: c1Width,
                            child: Text(
                              WebsiteI18n.t('col_param', lang),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: c2Width,
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: AppTheme.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    WebsiteI18n.t('col_peekit', lang),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: c3Width,
                            child: Text(
                              WebsiteI18n.t('col_msstore', lang),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: c4Width,
                            child: Text(
                              WebsiteI18n.t('col_powertoys', lang),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                      rows: rows.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: c1Width,
                                child: Text(
                                  WebsiteI18n.t(r['param']!, lang),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: c2Width,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
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
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: c3Width,
                                child: Text(
                                  WebsiteI18n.t(r['ms']!, lang),
                                  style: TextStyle(
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: c4Width,
                                child: Text(
                                  WebsiteI18n.t(r['pt']!, lang),
                                  style: TextStyle(
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                    fontSize: 13.5,
                                  ),
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
