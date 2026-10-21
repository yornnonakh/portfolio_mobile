import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/motion.dart';

/// Code-drawn screen illustrations on a transparent, responsive canvas.
class ProjectPhoneShowcase extends ConsumerStatefulWidget {
  const ProjectPhoneShowcase({super.key});

  @override
  ConsumerState<ProjectPhoneShowcase> createState() =>
      _ProjectPhoneShowcaseState();
}

class _ProjectPhoneShowcaseState extends ConsumerState<ProjectPhoneShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _pause;
  bool _motionOn = false;
  bool _entered = false;
  int _activePhone = 0;

  static const _phones = [
    _Phone(index: 0),
    _Phone(index: 1),
    _Phone(index: 2),
    _Phone(index: 3),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_motionOn) return;
    _entered = true;
    _activePhone = (_activePhone + 1) % _phones.length;
    _controller.reset();
    // Give the phones a resting beat between each floating cycle.
    _pause = Timer(const Duration(milliseconds: 1400), () {
      if (mounted && _motionOn) _controller.forward(from: 0);
    });
  }

  void _syncMotion(bool enabled) {
    if (_motionOn == enabled) return;
    _motionOn = enabled;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pause?.cancel();
      if (_motionOn) {
        _controller.forward(from: 0);
      } else {
        _activePhone = 0;
        _controller.stop();
        _controller.value = 0;
      }
    });
  }

  @override
  void dispose() {
    _pause?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncMotion(motionEnabled(context, ref));
    return Semantics(
      image: true,
      label: context.tr('Four illustrative mobile app screens'),
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = math.min(constraints.maxWidth, 900.0);
                return Center(
                  child: SizedBox(
                    key: const ValueKey('project-phone-showcase'),
                    width: width,
                    height: width * 540 / 860,
                    child: FittedBox(
                      child: SizedBox(
                        width: 860,
                        height: 540,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final t = _controller.value;
                            final handoff = _motionOn
                                ? Curves.easeInOutCubic.transform(
                                    ((t - .65) / .35).clamp(0.0, 1.0),
                                  )
                                : 0.0;
                            final focus = List.generate(4, (index) {
                              if (index == _activePhone) return 1 - handoff;
                              if (index == (_activePhone + 1) % 4) {
                                return handoff;
                              }
                              return 0.0;
                            });
                            final order = [0, 1, 2, 3]
                              ..sort((a, b) {
                                final depth = focus[a].compareTo(focus[b]);
                                return depth == 0 ? a.compareTo(b) : depth;
                              });
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Paint the enlarged phone in front as focus moves.
                                for (final index in order)
                                  Positioned(
                                    key: ValueKey('phone-slot-$index'),
                                    left: 36 + index * 185,
                                    top: 54,
                                    child: Builder(
                                      builder: (context) {
                                        final entrance = !_motionOn || _entered
                                            ? 1.0
                                            : Curves.easeOutCubic.transform(
                                                ((t * 5 - index * .16).clamp(
                                                  0.0,
                                                  1.0,
                                                )),
                                              );
                                        final wave = _motionOn
                                            ? math.sin(
                                                    t * math.pi * 2 + index,
                                                  ) *
                                                  math.sin(t * math.pi)
                                            : 0.0;
                                        return Opacity(
                                          opacity: entrance,
                                          child: Transform.translate(
                                            key: ValueKey(
                                              'phone-motion-$index',
                                            ),
                                            offset: Offset(
                                              0,
                                              (1 - entrance) * 36 + wave * 9,
                                            ),
                                            child: Transform.rotate(
                                              angle:
                                                  const [
                                                        -.09,
                                                        -.025,
                                                        .025,
                                                        .09,
                                                      ][index] *
                                                      (1 - focus[index]) +
                                                  wave * .012,
                                              child: Transform.scale(
                                                key: ValueKey(
                                                  'phone-scale-$index',
                                                ),
                                                scale: .88 + focus[index] * .28,
                                                child: _phones[index],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

const _ink = Color(0xFF20232C);
const _purple = Color(0xFF7763D8);

class _Phone extends StatelessWidget {
  const _Phone({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final dark = index == 3;
    final foreground = dark ? Colors.white : _ink;
    return MediaQuery.withNoTextScaling(
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Inter',
          color: foreground,
          fontSize: 10,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
        child: IconTheme(
          data: IconThemeData(color: foreground, size: 15),
          child: Container(
            key: ValueKey('showcase-phone-$index'),
            width: 210,
            height: 426,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF191A20),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0xFF4B4B51), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .15),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: ColoredBox(
                color: const [
                  Color(0xFFF0ECFF),
                  Color(0xFFFFFCF3),
                  Color(0xFFF2FAFA),
                  Color(0xFF15171C),
                ][index],
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('9:41', style: TextStyle(fontSize: 9)),
                          Container(
                            width: 58,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF101114),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(CupertinoIcons.wifi, size: 11),
                              SizedBox(width: 3),
                              Icon(CupertinoIcons.battery_full, size: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 22, 14, 8),
                        child: switch (index) {
                          0 => const _FoldersScreen(),
                          1 => const _NoteScreen(),
                          2 => const _ShopScreen(),
                          _ => const _ProductScreen(),
                        },
                      ),
                    ),
                    Container(
                      width: 65,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 7),
                      decoration: BoxDecoration(
                        color: foreground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoldersScreen extends StatelessWidget {
  const _FoldersScreen();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(CupertinoIcons.square_grid_2x2, color: _purple, size: 22),
      const SizedBox(height: 18),
      const _Title('A little more\norganized.'),
      const SizedBox(height: 8),
      const Text('A home for every idea.', style: TextStyle(color: _purple)),
      const SizedBox(height: 16),
      for (final (icon, label, count) in [
        (CupertinoIcons.folder_fill, 'Personal', '12 notes'),
        (CupertinoIcons.lightbulb_fill, 'Ideas', '8 notes'),
        (CupertinoIcons.briefcase_fill, 'Work', '6 notes'),
      ])
        Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .7),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Icon(icon, color: _purple, size: 21),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(
                    count,
                    style: const TextStyle(fontSize: 8, color: _purple),
                  ),
                ],
              ),
            ],
          ),
        ),
      const Spacer(),
      const Align(
        alignment: Alignment.centerRight,
        child: Icon(CupertinoIcons.plus_circle_fill, color: _purple, size: 29),
      ),
    ],
  );
}

class _NoteScreen extends StatelessWidget {
  const _NoteScreen();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(CupertinoIcons.chevron_left, color: Color(0xFFC18B27)),
          Icon(CupertinoIcons.ellipsis_circle, color: Color(0xFFC18B27)),
        ],
      ),
      const SizedBox(height: 18),
      const Text(
        'MONDAY, OCTOBER 19',
        style: TextStyle(
          fontSize: 7,
          color: Color(0xFF9D9279),
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 10),
      const _Title('Make room\nfor good ideas.'),
      const SizedBox(height: 14),
      const Text(
        'Big things begin with a little note.',
        style: TextStyle(fontSize: 10, color: Color(0xFF8C826E)),
      ),
      const SizedBox(height: 18),
      Container(
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFFF3DEA2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.lightbulb,
            size: 42,
            color: Color(0xFF9A721E),
          ),
        ),
      ),
      const SizedBox(height: 18),
      for (final (label, done) in [
        ('Find inspiration', true),
        ('Sketch something new', true),
        ('Bring it to life', false),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(
                done
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                size: 13,
                color: const Color(0xFFC18B27),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      const Spacer(),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(CupertinoIcons.textformat, size: 17),
          Icon(CupertinoIcons.checkmark_circle),
          Icon(CupertinoIcons.photo),
          Icon(CupertinoIcons.pencil),
        ],
      ),
    ],
  );
}

class _ShopScreen extends StatelessWidget {
  const _ShopScreen();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          Icon(CupertinoIcons.bag),
        ],
      ),
      const SizedBox(height: 22),
      const _Title('Find your\neveryday favorite.'),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Row(
          children: [
            Icon(CupertinoIcons.search, size: 12, color: Color(0xFF7D9191)),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Search the collection',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 8, color: Color(0xFF7D9191)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      Container(
        height: 118,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFB9E4DF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.headphones,
            size: 83,
            color: Color(0xFF266E69),
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Sound, reimagined.',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      const Text(
        'A little escape. Wherever you go.',
        style: TextStyle(fontSize: 8, color: Color(0xFF7D9191)),
      ),
      const Spacer(),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(CupertinoIcons.house_fill, color: Color(0xFF266E69)),
          Icon(CupertinoIcons.square_grid_2x2),
          Icon(CupertinoIcons.heart),
          Icon(CupertinoIcons.person),
        ],
      ),
    ],
  );
}

class _ProductScreen extends StatelessWidget {
  const _ProductScreen();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(CupertinoIcons.chevron_left),
          Icon(CupertinoIcons.heart),
        ],
      ),
      const SizedBox(height: 24),
      const Text(
        'LESS NOISE. MORE YOU.',
        style: TextStyle(
          fontSize: 7,
          letterSpacing: 1.3,
          color: Color(0xFFAAA6D0),
        ),
      ),
      const SizedBox(height: 10),
      const _Title('Your world.\nYour soundtrack.'),
      const Expanded(
        child: Center(
          child: Icon(
            CupertinoIcons.headphones,
            size: 114,
            color: Color(0xFFC0B5F6),
          ),
        ),
      ),
      const Text(
        'Studio wireless',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 7),
      const Row(
        children: [
          Icon(CupertinoIcons.star_fill, size: 10, color: Color(0xFFE5C87D)),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              '4.9  ·  Made for everyday',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 8, color: Color(0xFFA4A4AD)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFC0B5F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Add to bag  +',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: 4),
    ],
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 23,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -.8,
      ),
    ),
  );
}
