import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../../shared/models/portfolio.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.size = 64});
  final DeveloperProfile profile;
  final double size;
  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: AppText(
        'YN',
        style: TextStyle(
          fontSize: size * .33,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
      ),
    );
    return Semantics(
      label: context.tr(
        profile.portraitAsset == null
            ? '${profile.name} initials'
            : '${profile.name} portrait',
      ),
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: profile.portraitAsset == null
            ? placeholder
            : Image.asset(
                profile.portraitAsset!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, error, stack) => placeholder,
              ),
      ),
    );
  }
}
