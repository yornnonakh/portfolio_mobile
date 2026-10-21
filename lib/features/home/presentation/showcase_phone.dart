import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Decorative onboarding mockups inspired by the supplied phone reference.
class ShowcasePhone extends StatelessWidget {
  const ShowcasePhone({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final foreground = index == 1 || index == 3 ? Colors.white : Colors.black;
    return MediaQuery.withNoTextScaling(
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Inter', height: 1.2),
        child: SizedBox(
          key: ValueKey('showcase-phone-$index'),
          width: 210,
          height: 426,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final (top, height) in [
                (95.0, 17.0),
                (125.0, 28.0),
                (163.0, 28.0),
              ])
                Positioned(
                  left: -1,
                  top: top,
                  width: 2,
                  height: height,
                  child: const ColoredBox(color: Color(0xFF424242)),
                ),
              const Positioned(
                right: -1,
                top: 140,
                width: 2,
                height: 42,
                child: ColoredBox(color: Color(0xFF424242)),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF202120),
                  borderRadius: BorderRadius.circular(37),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      switch (index) {
                        0 => const _DeliveryScreen(),
                        1 => const _InvestingScreen(),
                        2 => const _NotesScreen(),
                        _ => const _ReflectlyScreen(),
                      },
                      Positioned(
                        top: 7,
                        left: 15,
                        right: 15,
                        height: 18,
                        child: _StatusBar(color: foreground),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 65,
                        right: 65,
                        height: 2.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: foreground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
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

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '9:45',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
      Container(
        width: 60,
        height: 18,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF343434),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: Color(0xFF303030),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFF343434),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(
                    width: 1.7,
                    height: 3 + i * 1.7,
                    margin: const EdgeInsets.only(right: 1),
                    color: color,
                  ),
              ],
            ),
            const SizedBox(width: 3),
            Icon(CupertinoIcons.wifi, size: 10, color: color),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: 6,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: .6),
                borderRadius: BorderRadius.circular(1.5),
              ),
              child: ColoredBox(color: color),
            ),
            Container(
              width: 1,
              height: 3,
              margin: const EdgeInsets.only(left: .7),
              color: color,
            ),
          ],
        ),
      ),
    ],
  );
}

class _DeliveryScreen extends StatelessWidget {
  const _DeliveryScreen();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF00BFDF),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const Positioned(
          top: 225,
          bottom: 0,
          left: 0,
          right: 0,
          child: ColoredBox(color: Colors.white),
        ),
        const Positioned(
          top: 33,
          left: 0,
          right: 0,
          height: 32,
          child: _ScreenText(
            'Wolt',
            size: 29,
            weight: FontWeight.w800,
            italic: true,
            color: Colors.white,
          ),
        ),
        Positioned(
          top: 83,
          left: 2,
          right: 2,
          height: 196,
          child: SvgPicture.asset('assets/projects/showcase_delivery.svg'),
        ),
        const Positioned(
          top: 291,
          left: 10,
          right: 10,
          height: 24,
          child: _ScreenText(
            'Welcome to Wolt',
            size: 17,
            weight: FontWeight.w700,
          ),
        ),
        const Positioned(
          top: 323,
          left: 12,
          right: 12,
          height: 29,
          child: _ScreenText(
            'Enjoy the best restaurants or get what you\nneed from nearby stores, delivered',
            size: 8.5,
          ),
        ),
        Positioned(
          bottom: 54,
          left: 8,
          right: 8,
          height: .5,
          child: ColoredBox(color: Colors.black.withValues(alpha: .07)),
        ),
        const Positioned(
          bottom: 15,
          left: 8,
          right: 8,
          height: 30,
          child: _ScreenButton('Get started', color: Color(0xFF00A4DC)),
        ),
      ],
    ),
  );
}

class _ReflectlyScreen extends StatelessWidget {
  const _ReflectlyScreen();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF7D74C8),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 55,
          left: 70,
          right: 70,
          height: 52,
          child: SvgPicture.asset('assets/projects/showcase_reflectly.svg'),
        ),
        const Positioned(
          top: 122,
          left: 14,
          right: 14,
          height: 39,
          child: _ScreenText(
            'Hi there,\nI’m Reflectly',
            size: 15,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Positioned(
          top: 181,
          left: 26,
          right: 26,
          height: 30,
          child: _ScreenText(
            'Your new personal\nself-care companion',
            size: 9,
            color: Color(0xFFC6BEEB),
            letterSpacing: .35,
          ),
        ),
        const Positioned(
          bottom: 60,
          left: 25,
          right: 25,
          height: 29,
          child: _ScreenButton(
            'HI, REFLECTLY!',
            color: Colors.white,
            foreground: Color(0xFF7D74C8),
            pill: true,
            fontSize: 6,
          ),
        ),
        const Positioned(
          bottom: 28,
          left: 20,
          right: 20,
          height: 12,
          child: _ScreenText(
            'I ALREADY HAVE AN ACCOUNT',
            size: 5.6,
            color: Color(0xFFC6BEEB),
            letterSpacing: .3,
          ),
        ),
      ],
    ),
  );
}

class _InvestingScreen extends StatelessWidget {
  const _InvestingScreen();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 35,
          left: 9,
          height: 15,
          child: Row(
            children: [
              Container(
                width: 9,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD327),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const _ScreenText(
                'Betterment',
                size: 8.5,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ],
          ),
        ),
        const Positioned(
          top: 35,
          right: 9,
          height: 15,
          child: _ScreenText('Log in', size: 6.8, color: Color(0xFF5197DA)),
        ),
        const Positioned(
          top: 95,
          left: 16,
          right: 16,
          height: 57,
          child: _ScreenText(
            'Investing\nmade better.',
            size: 21,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 76,
          left: 0,
          right: 0,
          height: 133,
          child: SvgPicture.asset(
            'assets/projects/showcase_camping.svg',
            fit: BoxFit.fill,
          ),
        ),
        const Positioned(
          bottom: 40,
          left: 9,
          right: 9,
          height: 24,
          child: _ScreenButton(
            'Get started',
            color: Color(0xFF2168E6),
            fontSize: 7,
          ),
        ),
        const Positioned(
          bottom: 16,
          left: 9,
          right: 9,
          height: 14,
          child: _ScreenText(
            'See how it works',
            size: 6.8,
            color: Color(0xFFD2D2D2),
          ),
        ),
      ],
    ),
  );
}

class _NotesScreen extends StatelessWidget {
  const _NotesScreen();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFFFF8E9),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const Positioned(
          top: 40,
          left: 14,
          right: 14,
          height: 19,
          child: _ScreenText(
            'Notes',
            size: 13,
            weight: FontWeight.w700,
            color: Color(0xFF946919),
          ),
        ),
        const Positioned(
          top: 87,
          left: 12,
          right: 12,
          height: 53,
          child: _ScreenText(
            'A little space\nfor big ideas.',
            size: 21,
            weight: FontWeight.w700,
            color: Color(0xFF353025),
          ),
        ),
        Positioned(
          top: 162,
          left: 43,
          right: 43,
          height: 113,
          child: Transform.rotate(
            angle: -.09,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE49C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AC99B37),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      CupertinoIcons.pencil_outline,
                      size: 25,
                      color: Color(0xFF946919),
                    ),
                    const Spacer(),
                    for (final width in [60.0, 48.0, 34.0])
                      Container(
                        width: width,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDA955),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 299,
          left: 15,
          right: 15,
          height: 31,
          child: _ScreenText(
            'Capture your thoughts.\nMake room for what matters.',
            size: 9,
            color: Color(0xFF8C826E),
          ),
        ),
        const Positioned(
          bottom: 28,
          left: 14,
          right: 14,
          height: 31,
          child: _ScreenButton(
            'Create your first note',
            color: Color(0xFFE4B34D),
            foreground: Color(0xFF493512),
          ),
        ),
      ],
    ),
  );
}

class _ScreenButton extends StatelessWidget {
  const _ScreenButton(
    this.label, {
    required this.color,
    this.foreground = Colors.white,
    this.pill = false,
    this.fontSize = 8,
  });
  final String label;
  final Color color, foreground;
  final bool pill;
  final double fontSize;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(pill ? 40 : 4),
    ),
    child: Center(
      child: _ScreenText(
        label,
        size: fontSize,
        weight: FontWeight.w700,
        color: foreground,
      ),
    ),
  );
}

class _ScreenText extends StatelessWidget {
  const _ScreenText(
    this.text, {
    required this.size,
    this.weight = FontWeight.w400,
    this.color = const Color(0xFF252525),
    this.italic = false,
    this.letterSpacing,
  });
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final bool italic;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        height: 1.2,
        fontWeight: weight,
        color: color,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: letterSpacing,
      ),
    ),
  );
}
