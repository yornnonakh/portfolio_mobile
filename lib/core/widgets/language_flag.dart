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
    child: SvgPicture.asset(
      'assets/icons/flags/${languageCode == 'km' ? 'kh' : 'us'}.svg',
      width: width,
      height: height,
      fit: BoxFit.cover,
    ),
  );
}
