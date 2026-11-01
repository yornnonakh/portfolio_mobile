import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/components.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/link_service.dart';
import '../../../core/utils/action_feedback.dart';
import '../../../shared/models/portfolio.dart';

class ProjectAppShowcase extends ConsumerWidget {
  const ProjectAppShowcase({
    super.key,
    required this.project,
    required this.heroTag,
  });

  final PortfolioProject project;
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = project.id == 'notes'
        ? const Color(0xFFD7A33F)
        : const Color(0xFF9564EC);
    final links = ref.read(linkServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: RadialGradient(
              center: const Alignment(0, -.15),
              radius: .85,
              colors: [
                accent.withValues(alpha: dark ? .24 : .17),
                dark ? const Color(0xFF191A21) : const Color(0xFFF4F3F8),
              ],
            ),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: .4),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const AppText(
                  'App preview',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = math.min(260.0, constraints.maxWidth);
                  return SizedBox(
                    key: const ValueKey('project-detail-phone'),
                    width: width,
                    height: width * 530 / 260,
                    child: Hero(
                      tag: heroTag,
                      child: Semantics(
                        image: true,
                        label:
                            '${context.tr(project.title)}. ${context.tr('Illustrative preview')}',
                        child: ExcludeSemantics(
                          child: MediaQuery.withNoTextScaling(
                            child: FittedBox(
                              child: _AppPhone(
                                project: project,
                                accent: accent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AppText(
                'Illustrative preview',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: AppText(
            'Get the app',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide =
                constraints.maxWidth >= 440 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.3;
            final width = sideBySide
                ? math.min(228.0, (constraints.maxWidth - 12) / 2)
                : math.min(340.0, constraints.maxWidth);
            return Wrap(
              key: const ValueKey('project-store-actions'),
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                _StoreCard(
                  key: const ValueKey('project-google-play'),
                  width: width,
                  name: 'Google Play',
                  icon: const _GooglePlayMark(),
                  available: LinkService.isWebUrl(project.playStoreUrl),
                  onPressed: LinkService.isWebUrl(project.playStoreUrl)
                      ? () => performAction(
                          context,
                          () => links.website(project.playStoreUrl),
                        )
                      : null,
                ),
                _StoreCard(
                  key: const ValueKey('project-app-store'),
                  width: width,
                  name: 'App Store',
                  icon: const BrandIcon('ios', size: 28, color: Colors.white),
                  available: LinkService.isWebUrl(project.appStoreUrl),
                  onPressed: LinkService.isWebUrl(project.appStoreUrl)
                      ? () => performAction(
                          context,
                          () => links.website(project.appStoreUrl),
                        )
                      : null,
                ),
              ],
            );
          },
        ),
        if (LinkService.isWebUrl(project.demoUrl)) ...[
          const SizedBox(height: 12),
          Center(
            child: IosButton.plain(
              onPressed: () =>
                  performAction(context, () => links.website(project.demoUrl)),
              icon: const Icon(CupertinoIcons.globe, size: 18),
              label: const AppText('Open app'),
            ),
          ),
        ],
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    super.key,
    required this.width,
    required this.name,
    required this.icon,
    required this.available,
    required this.onPressed,
  });

  final double width;
  final String name;
  final Widget icon;
  final bool available;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF191A20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .14)),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    available ? 'Download on' : 'Coming soon',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFBFC0CD),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AppText(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

/// A code-drawn Google Play mark; no remote assets are loaded.
class _GooglePlayMark extends StatelessWidget {
  const _GooglePlayMark();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(27, 30), painter: _GooglePlayPainter());
}

class _GooglePlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .57, size.height * .5);
    final top = Offset.zero;
    final bottom = Offset(0, size.height);
    final upper = Offset(size.width * .76, size.height * .36);
    final lower = Offset(size.width * .76, size.height * .64);
    void triangle(Offset a, Offset b, Offset c, Color color) => canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..close(),
      Paint()..color = color,
    );
    triangle(top, bottom, center, const Color(0xFF48C5F3));
    triangle(top, center, upper, const Color(0xFF48D293));
    triangle(bottom, lower, center, const Color(0xFFF76A72));
    final tip = Offset(size.width, size.height * .5);
    triangle(center, upper, tip, const Color(0xFFFFD067));
    triangle(center, tip, lower, const Color(0xFFFFD067));
  }

  @override
  bool shouldRepaint(_GooglePlayPainter oldDelegate) => false;
}

class _AppPhone extends StatelessWidget {
  const _AppPhone({required this.project, required this.accent});
  final PortfolioProject project;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final notes = project.id == 'notes';
    return Container(
      width: 260,
      height: 530,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF25262E),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFF61616B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .2),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: ColoredBox(
          color: const Color(0xFFFAF9FD),
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              color: Color(0xFF282632),
              fontSize: 12,
              height: 1.3,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 209,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                '9:41',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Spacer(),
                              Icon(
                                CupertinoIcons.wifi,
                                size: 13,
                                color: Color(0xFF282632),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.battery_full,
                                size: 18,
                                color: Color(0xFF282632),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  notes
                                      ? CupertinoIcons.doc_text
                                      : CupertinoIcons.money_dollar_circle,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppText(
                                  project.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          AppText(
                            notes
                                ? 'Your ideas, organized.'
                                : 'Your money, at a glance.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF83808F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accent,
                                  Color.lerp(
                                    accent,
                                    const Color(0xFF40316D),
                                    .3,
                                  )!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  notes ? 'Notes' : 'Monthly spending',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notes ? '24' : '\$1,240.00',
                                  style: const TextStyle(
                                    fontSize: 29,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    for (final height in [
                                      12.0,
                                      22.0,
                                      16.0,
                                      32.0,
                                      24.0,
                                      40.0,
                                      30.0,
                                    ])
                                      Expanded(
                                        child: Container(
                                          height: height,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: .45,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          AppText(
                            notes ? 'Recent notes' : 'Recent activity',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final (icon, label, value)
                              in notes
                                  ? [
                                      (CupertinoIcons.lightbulb, 'Ideas', '08'),
                                      (CupertinoIcons.briefcase, 'Work', '12'),
                                      (CupertinoIcons.person, 'Personal', '04'),
                                    ]
                                  : [
                                      (CupertinoIcons.bag, 'Shopping', '-\$48'),
                                      (
                                        CupertinoIcons.car,
                                        'Transport',
                                        '-\$12',
                                      ),
                                      (
                                        CupertinoIcons.cart,
                                        'Groceries',
                                        '-\$36',
                                      ),
                                    ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: .1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: accent, size: 17),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppText(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 90,
                  right: 90,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 82,
                  right: 82,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF24232A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
