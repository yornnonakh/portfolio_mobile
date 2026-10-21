import 'package:flutter/material.dart';

import '../../../core/design_system/components.dart';
import '../../../core/localization/app_localizations.dart';

class DevelopmentTimeline extends StatelessWidget {
  const DevelopmentTimeline({super.key, required this.experience});

  final String experience;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: AppText(
            'Development journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -.4,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _Milestone(
          value: experience,
          label: 'Flutter experience',
          first: true,
          icon: const BrandIcon('flutter', size: 28),
        ),
        const _Milestone(
          value: 'iOS & Android',
          label: 'Mobile development',
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandIcon('ios', size: 20),
              SizedBox(width: 6),
              BrandIcon('android', size: 22),
            ],
          ),
        ),
        const _Milestone(
          value: 'App Store',
          label: 'Deployment experience',
          last: true,
          icon: BrandIcon('app-store', size: 28),
        ),
      ],
    ),
  );
}

class _Milestone extends StatelessWidget {
  const _Milestone({
    required this.value,
    required this.label,
    required this.icon,
    this.first = false,
    this.last = false,
  });

  final String value, label;
  final Widget icon;
  final bool first, last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      container: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: 16,
                child: Stack(
                  children: [
                    PositionedDirectional(
                      start: 7,
                      top: first ? 14 : 0,
                      bottom: last ? null : 0,
                      height: last ? 14 : null,
                      width: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: .22),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 3,
                      top: 9,
                      width: 10,
                      height: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            value,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          MutedText(label),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 48, height: 32, child: Center(child: icon)),
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
