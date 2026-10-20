import 'package:flutter/widgets.dart';
import 'khmer_translations.dart';

/// The English copy is the lookup key, keeping shared CV data independent of UI locale.
/// Product names, personal details, URLs and original license text stay unchanged.
abstract final class AppTranslations {
  static const languageNames = {'en': 'English', 'km': 'ភាសាខ្មែរ'};
  static String translate(String source, String languageCode) {
    if (languageCode != 'km') return source;
    final exact = khmerTranslations[source];
    if (exact != null) return exact;
    final count = RegExp(r'^(\d+) projects?$').firstMatch(source);
    if (count != null) return '${count[1]} គម្រោង';
    final caseStudy = RegExp(r'^Case study (\d+) / (.+)$').firstMatch(source);
    if (caseStudy != null) {
      return 'ព័ត៌មានគម្រោង ${caseStudy[1]} / ${translate(caseStudy[2]!, languageCode)}';
    }
    const copiedPrefix = 'Message copied. Paste it into an email to ';
    if (source.startsWith(copiedPrefix)) {
      return 'បានចម្លងសារ។ សូមបិទភ្ជាប់ក្នុងអ៊ីមែលទៅ ${source.substring(copiedPrefix.length)}';
    }
    for (final entry in const {
      ' screenshot': ' រូបថតអេក្រង់',
      ' portrait': ' រូបថត',
      ' initials': ' អក្សរកាត់ឈ្មោះ',
    }.entries) {
      if (source.endsWith(entry.key)) {
        return '${source.substring(0, source.length - entry.key.length)}${entry.value}';
      }
    }
    // Resume entries combine independently translated facts with this separator.
    if (source.contains(' · ')) {
      return source
          .split(' · ')
          .map((part) => translate(part, languageCode))
          .join(' · ');
    }
    return source;
  }
}

extension PortfolioLocalization on BuildContext {
  String tr(String source) => AppTranslations.translate(
    source,
    Localizations.maybeLocaleOf(this)?.languageCode ?? 'en',
  );
}

/// Translates both static UI copy and presentation of the portfolio's shared data.
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) => Text(
    context.tr(data),
    style: style?.copyWith(
      fontFamilyFallback: const ['NotoSansKhmer'],
      letterSpacing: Localizations.maybeLocaleOf(context)?.languageCode == 'km'
          ? 0
          : style?.letterSpacing,
      height:
          Localizations.maybeLocaleOf(context)?.languageCode == 'km' &&
              style?.height != null &&
              style!.height! < 1.4
          ? 1.4
          : style?.height,
    ),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    textScaler: textScaler,
    softWrap: softWrap,
  );
}
