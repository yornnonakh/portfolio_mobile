import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Decorative flag; the adjacent language label provides the accessible name.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag({
    super.key,
    required this.languageCode,
    this.width = 40,
    this.height = 30,
  });
  final String languageCode;
  final double width, height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width < 30 ? 4 : 7),
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: .2),
        ),
      ),
      child: SvgPicture.asset(
        'assets/icons/flags/${languageCode == 'km' ? 'kh' : 'us'}.svg',
        fit: BoxFit.cover,
      ),
    ),
  );
}
