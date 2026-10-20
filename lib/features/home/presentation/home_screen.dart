import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/components.dart';
import '../../../core/utils/motion.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../shared/providers/portfolio_providers.dart';
import '../../projects/presentation/project_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final profile = portfolio.profile;
    final theme = Theme.of(context);
    return PageContent(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final introduction = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Flutter Developer'),
                const SizedBox(height: 10),
                _TypewriterText(
                  text: 'Mobile engineer',
                  style: wide
                      ? theme.textTheme.displayLarge
                      : theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: const MutedText(
                    'I build thoughtful mobile experiences for iOS and Android, from Phnom Penh.',
                    large: true,
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    IosButton.filled(
                      onPressed: () => context.go('/projects'),
                      label: const Text('View projects'),
                      icon: const Icon(CupertinoIcons.arrow_up_right, size: 18),
                      iconAlignment: IconAlignment.end,
                    ),
                    IosButton.tinted(
                      onPressed: () => context.push('/resume'),
                      label: const Text('View resume'),
                      icon: const Icon(CupertinoIcons.doc_text, size: 18),
                    ),
                  ],
                ),
              ],
            );
            final identity = Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                MutedText(profile.location),
              ],
            );
            return Padding(
              padding: EdgeInsets.only(top: wide ? 32 : 8, bottom: 36),
              child: wide
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: introduction),
                        const SizedBox(width: 64),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ProfileAvatar(profile: profile, size: 140),
                              const SizedBox(height: 24),
                              identity,
                              const SizedBox(height: 20),
                              const TechBadge('iOS & Android', accent: true),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileAvatar(profile: profile, size: 90),
                        const SizedBox(height: 16),
                        identity,
                        const SizedBox(height: 32),
                        introduction,
                      ],
                    ),
            );
          },
        ),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Fact(
                value: profile.experience,
                label: 'Flutter experience',
                icon: CupertinoIcons.chevron_left_slash_chevron_right,
              ),
              const Divider(indent: 64, endIndent: 16),
              const _Fact(
                value: 'iOS & Android',
                label: 'Mobile development',
                icon: CupertinoIcons.device_phone_portrait,
              ),
              const Divider(indent: 64, endIndent: 16),
              const _Fact(
                value: 'App Store',
                label: 'Deployment experience',
                icon: CupertinoIcons.app_badge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SectionHeading(
          'Selected work',
          action: 'All projects',
          onAction: () => context.go('/projects'),
        ),
        ResponsiveGrid(
          minimumWidth: 430,
          children: portfolio.projects
              .map((p) => ProjectCard(project: p, heroSource: 'home'))
              .toList(),
        ),
        const SizedBox(height: 32),
        const SectionHeading('About me'),
        SurfaceCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final introduction = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning by building.',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  MutedText(profile.summary),
                  const SizedBox(height: 16),
                  IosButton.plain(
                    onPressed: () => context.go('/about'),
                    label: const Text('More about me'),
                    icon: const Icon(CupertinoIcons.arrow_up_right, size: 17),
                    iconAlignment: IconAlignment.end,
                  ),
                ],
              );
              final toolkit = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('My toolkit'),
                  const SizedBox(height: 16),
                  const BadgeList([
                    'Flutter',
                    'Dart',
                    'Riverpod',
                    'GetX',
                    'Provider',
                    'Dio',
                    'REST APIs',
                  ]),
                  const SizedBox(height: 12),
                  IosButton.plain(
                    onPressed: () => context.push('/skills'),
                    child: const Text('Explore skills'),
                  ),
                ],
              );
              return constraints.maxWidth > 700
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: introduction),
                        const SizedBox(width: 48),
                        Expanded(flex: 2, child: toolkit),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        introduction,
                        const Divider(height: 40),
                        toolkit,
                      ],
                    );
            },
          ),
        ),
        const SizedBox(height: 16),
        DeploymentCard(text: portfolio.deployment),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label, required this.icon});
  final String value, label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconTile(icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 2),
              MutedText(label),
            ],
          ),
        ),
      ],
    ),
  );
}

class DeploymentCard extends StatelessWidget {
  const DeploymentCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IconTile(CupertinoIcons.app_badge),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From development to deployment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              MutedText(text),
            ],
          ),
        ),
      ],
    ),
  );
}
class _TypewriterText extends ConsumerStatefulWidget {
  const _TypewriterText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  ConsumerState<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends ConsumerState<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  // Configurable timings
  static const _typeDuration = Duration(milliseconds: 80);   // per character
  static const _deleteDuration = Duration(milliseconds: 50); // per character
  static const _pauseAfterType = Duration(milliseconds: 1800);
  static const _pauseAfterDelete = Duration(milliseconds: 400);

  bool _isDeleting = false;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(_onTick);

    _controller.addStatusListener(_onStatus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (motionEnabled(context, ref)) {
        _startTyping();
      } else {
        setState(() => _charIndex = widget.text.length);
      }
    });
  }

  void _onTick() {
    if (!mounted) return;

    final progress = _animation.value;
    final target = _isDeleting ? 0 : widget.text.length;
    final start = _isDeleting ? widget.text.length : 0;

    final newIndex = (start + (target - start) * progress)
        .round()
        .clamp(0, widget.text.length);

    if (newIndex != _charIndex) {
      setState(() => _charIndex = newIndex);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;

    if (!_isDeleting) {
      // Finished typing → pause → start deleting
      Future.delayed(_pauseAfterType, () {
        if (!mounted || !motionEnabled(context, ref)) return;
        setState(() => _isDeleting = true);
        _startDeleting();
      });
    } else {
      // Finished deleting → short pause → start typing again
      Future.delayed(_pauseAfterDelete, () {
        if (!mounted || !motionEnabled(context, ref)) return;
        setState(() => _isDeleting = false);
        _startTyping();
      });
    }
  }

  void _startTyping() {
    if (!mounted || widget.text.isEmpty) return;

    final duration = _typeDuration * widget.text.length;
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  void _startDeleting() {
    if (!mounted) return;

    final duration = _deleteDuration * widget.text.length;
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Live-check reduced motion
    final motionOn = motionEnabled(context, ref);
    if (!motionOn && _charIndex != widget.text.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _charIndex = widget.text.length);
      });
    }

    final displayText =
    widget.text.substring(0, _charIndex.clamp(0, widget.text.length));

    return Text(
      displayText,
      style: widget.style,
    );
  }
}
