import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../utils/motion.dart';

enum _IosButtonStyle { filled, tinted, plain }

class IosButton extends StatelessWidget {
  const IosButton.filled({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.iconAlignment = IconAlignment.start,
  }) : _style = _IosButtonStyle.filled,
       assert(child != null || label != null);
  const IosButton.tinted({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.iconAlignment = IconAlignment.start,
  }) : _style = _IosButtonStyle.tinted,
       assert(child != null || label != null);
  const IosButton.plain({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.iconAlignment = IconAlignment.start,
  }) : _style = _IosButtonStyle.plain,
       assert(child != null || label != null);
  final VoidCallback? onPressed;
  final Widget? child, label, icon;
  final IconAlignment iconAlignment;
  final _IosButtonStyle _style;

  @override
  Widget build(BuildContext context) {
    final content = DefaultTextStyle.merge(
      style: TextStyle(
        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
        fontSize: _style == _IosButtonStyle.plain ? 15 : 16,
        fontWeight: _style == _IosButtonStyle.plain
            ? FontWeight.w500
            : FontWeight.w600,
        letterSpacing: -.3,
      ),
      child: icon == null
          ? child ?? label!
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconAlignment == IconAlignment.start) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(child: child ?? label!),
                if (iconAlignment == IconAlignment.end) ...[
                  const SizedBox(width: 8),
                  icon!,
                ],
              ],
            ),
    );
    const shape = BorderRadius.all(Radius.circular(14));
    return switch (_style) {
      _IosButtonStyle.filled => CupertinoButton.filled(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(48, 50),
        borderRadius: shape,
        child: content,
      ),
      _IosButtonStyle.tinted => CupertinoButton.tinted(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(48, 50),
        borderRadius: shape,
        child: content,
      ),
      _IosButtonStyle.plain => CupertinoButton(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(48, 48),
        child: content,
      ),
    };
  }
}

class IosIconButton extends StatelessWidget {
  const IosIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.liquidGlass = false,
    this.circular = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool liquidGlass;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, size: 28);
    if (liquidGlass) {
      iconWidget = LiquidGlassContainer(
        padding: const EdgeInsets.all(8),
        borderRadius: circular ? 999.0 : 12.0,
        child: Icon(icon, size: 25),
      );
    }
    return Semantics(
      label: label,
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: onPressed,
        child: iconWidget,
      ),
    );
  }
}

class IosSelectableText extends StatelessWidget {
  const IosSelectableText(this.data, {super.key, this.style});
  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => SelectableText(
    data,
    style: style,
    selectionControls: cupertinoTextSelectionHandleControls,
    contextMenuBuilder: (context, state) =>
        CupertinoAdaptiveTextSelectionToolbar.editableText(
          editableTextState: state,
        ),
  );
}

class Reveal extends ConsumerWidget {
  const Reveal({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      motionEnabled(context, ref)
      ? child
            .animate()
            .fadeIn(duration: 280.ms, curve: Curves.easeOut)
            .slideY(begin: .015, end: 0, duration: 280.ms)
      : child;
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class IosSelectionControl<T extends Object> extends StatelessWidget {
  const IosSelectionControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });
  final Map<T, String> items;
  final T value;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
            constraints.maxWidth < 300) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items.entries)
                Semantics(
                  selected: value == item.key,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    color: value == item.key
                        ? scheme.primary.withValues(alpha: .12)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: onChanged == null
                        ? null
                        : () => onChanged!(item.key),
                    child: Text(
                      item.value,
                      style: style?.copyWith(
                        color: value == item.key
                            ? scheme.primary
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<T>(
            groupValue: value,
            backgroundColor: scheme.surfaceContainerHighest,
            thumbColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF636366)
                : Colors.white,
            padding: const EdgeInsets.all(4),
            children: {
              for (final item in items.entries)
                item.key: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 6,
                  ),
                  child: Text(
                    item.value,
                    textAlign: TextAlign.center,
                    style: style,
                  ),
                ),
            },
            onValueChanged: (selection) {
              if (selection != null) onChanged?.call(selection);
            },
            disabledChildren: onChanged == null ? items.keys.toSet() : const {},
          ),
        );
      },
    );
  }
}

class IosGroupedList extends StatelessWidget {
  const IosGroupedList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(indent: 64, endIndent: 16),
          children[i],
        ],
      ],
    ),
  );
}

class IosActionRow extends StatelessWidget {
  const IosActionRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    onPressed: onPressed,
    child: Row(
      children: [
        IconTile(icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                MutedText(subtitle!),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          CupertinoIcons.chevron_right,
          size: 15,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: .6),
        ),
      ],
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.dot = false});
  final String text;
  final bool dot;
  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    children: [
      if (dot)
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 13,
          height: 1.5,
          letterSpacing: .1,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
  });
  final String eyebrow, title;
  final String? description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 10),
            MutedText(description!),
          ],
        ],
      ),
    ),
  );
}

class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, size: 20, color: Colors.white),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.title, {
    super.key,
    this.eyebrow,
    this.subtitle,
    this.action,
    this.onAction,
  });
  final String title;
  final String? eyebrow, subtitle, action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 10)],
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (action != null)
              IosButton.plain(
                onPressed: onAction,
                label: Text(action!),
                icon: const Icon(CupertinoIcons.chevron_right, size: 18),
                iconAlignment: IconAlignment.end,
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          MutedText(subtitle!),
        ],
      ],
    ),
  );
}

class MutedText extends StatelessWidget {
  const MutedText(this.text, {super.key, this.large = false});
  final String text;
  final bool large;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style:
        (large
                ? Theme.of(context).textTheme.bodyLarge
                : Theme.of(context).textTheme.bodyMedium)
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}

class TechBadge extends StatelessWidget {
  const TechBadge(this.label, {super.key, this.accent = false});
  final String label;
  final bool accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: accent
          ? Theme.of(context).colorScheme.primary.withValues(alpha: .07)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 11,
        height: 1.5,
        color: accent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class BadgeList extends StatelessWidget {
  const BadgeList(this.items, {super.key});
  final List<String> items;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items.map((s) => TechBadge(s)).toList(),
  );
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minimumWidth = 340,
    this.spacing = 20,
  });
  final List<Widget> children;
  final double minimumWidth, spacing;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          ((constraints.maxWidth + spacing) / (minimumWidth + spacing))
              .floor()
              .clamp(1, 3);
      final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: children
            .map((child) => SizedBox(width: width, child: child))
            .toList(),
      );
    },
  );
}

class BulletList extends StatelessWidget {
  const BulletList(this.items, {super.key, this.checks = false});
  final List<String> items;
  final bool checks;
  @override
  Widget build(BuildContext context) => Column(
    children: items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    checks
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.circle_fill,
                    size: checks ? 17 : 5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        )
        .toList(),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        IconTile(icon),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    key: PageStorageKey(
      GoRouter.of(context).routeInformationProvider.value.uri.path,
    ),
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(context).width < 600 ? 20 : 40,
      20 + MediaQuery.paddingOf(context).top,
      MediaQuery.sizeOf(context).width < 600 ? 20 : 40,
      36 + MediaQuery.paddingOf(context).bottom,
    ),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...children, const SizedBox(height: 56), const Footer()],
          ),
        ),
      ),
    ),
  );
}

class Footer extends StatelessWidget {
  const Footer({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Divider(),
      const SizedBox(height: 20),
      const Align(
        alignment: Alignment.center,
        child: MutedText('© ${AppConstants.year} Yorn Nona'),
      ),
      const SizedBox(height: 8),
    ],
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 38});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Yorn Nona monogram',
    image: true,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(size * .22),
      ),
      child: Text(
        'yn',
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: size * .42,
          fontWeight: FontWeight.w600,
          letterSpacing: -size * .035,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    ),
  );
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .6),
          ),
        ),
        child: child,
      ),
    ),
  );
}

class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(6),
    this.borderRadius = 10.0,
    this.blur = 16.0,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: .75),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: .5),
              width: .5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class LiquidGlassIcon extends StatelessWidget {
  const LiquidGlassIcon(
    this.icon, {
    super.key,
    this.size = 16,
    this.color,
    this.padding = const EdgeInsets.all(6),
    this.borderRadius = 8.0,
  });
  final IconData icon;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return LiquidGlassContainer(
      padding: padding,
      borderRadius: borderRadius,
      child: Icon(icon, size: size, color: effectiveColor),
    );
  }
}
