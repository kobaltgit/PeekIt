import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class FaqSection extends StatelessWidget {
  final String lang;
  final bool isDark;

  const FaqSection({
    super.key,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    final faqs = [
      {'q': 'faq_1_q', 'a': 'faq_1_a'},
      {'q': 'faq_2_q', 'a': 'faq_2_a'},
      {'q': 'faq_3_q', 'a': 'faq_3_a'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 40 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                WebsiteI18n.t('faq_title', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 40),

              Column(
                children: faqs.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: AppTheme.primary,
                        collapsedIconColor: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        title: Text(
                          WebsiteI18n.t(item['q']!, lang),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                            child: Text(
                              WebsiteI18n.t(item['a']!, lang),
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
