import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/models/portfolio.dart';

/// Decorative illustration, never presented as an actual project screenshot.
class ProjectArt extends StatelessWidget {
  const ProjectArt({super.key, required this.project, this.height = 270});
  final PortfolioProject project;
  final double height;
  @override
  Widget build(BuildContext context) {
    final notes = project.id == 'notes';
    return Semantics(
      image: true,
      // label: '${project.title}. Illustrative preview.',
      child: ExcludeSemantics(
        child: MediaQuery.withNoTextScaling(
          child: Container(
            height: height,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).brightness == Brightness.dark
                  ? (notes ? const Color(0xFF1D2B43) : const Color(0xFF1B3437))
                  : (notes ? const Color(0xFFECF2FF) : const Color(0xFFE9F3EF)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  if (constraints.maxWidth > 360)
                    Positioned(
                      top: 28,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            project.number,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppText(
                            notes
                                ? 'Capture.\nOrganize.'
                                : 'Browse.\nDiscover.',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    right: constraints.maxWidth > 360
                        ? 36
                        : (constraints.maxWidth - 148) / 2,
                    top: 36,
                    child: Transform.rotate(
                      angle: notes ? -.06 : .06,
                      child: _IllustratedPhone(notes: notes),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustratedPhone extends StatelessWidget {
  const _IllustratedPhone({required this.notes});
  final bool notes;
  @override
  Widget build(BuildContext context) => Container(
    width: 148,
    height: 330,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: const Color(0xFF161925),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .12),
          blurRadius: 36,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: ColoredBox(
        color: notes ? const Color(0xFFFFFCF3) : const Color(0xFFF6F6F2),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161925),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              AppText(
                notes ? 'Notes' : 'Discover',
                style: const TextStyle(
                  color: Color(0xFF20242C),
                  fontSize: 19,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E7E1),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 14),
              if (notes) ...[
                for (var i = 0; i < 3; i++) const _NoteRow(),
              ] else ...[
                Container(
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E9E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Transform.rotate(
                    angle: -.2,
                    child: const Icon(
                       CupertinoIcons.headphones,
                      color: Color(0xFF244E50),
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(width: 80, height: 6, color: const Color(0xFFBBC8C3)),
                const SizedBox(height: 7),
                Container(width: 48, height: 4, color: const Color(0xFFDADFDA)),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _NoteRow extends StatelessWidget {
  const _NoteRow();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 65, height: 5, color: const Color(0xFFB7B6AB)),
        const SizedBox(height: 6),
        Container(height: 3, color: const Color(0xFFE9E6DD)),
        const SizedBox(height: 4),
        Container(width: 44, height: 3, color: const Color(0xFFE9E6DD)),
      ],
    ),
  );
}
