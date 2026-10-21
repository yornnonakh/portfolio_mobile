import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/design_system/components.dart';
import '../../../core/services/cv_service.dart';
import '../../../core/utils/action_feedback.dart';
import '../../../shared/providers/portfolio_providers.dart';

class ResumeScreen extends ConsumerWidget {
  const ResumeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(portfolioProvider);
    final document = ref.watch(cvDocumentProvider);
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Resume',
          title: 'Resume',
          description: 'My background, education, and mobile development work.',
        ),
        document.when(
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Semantics(
                label: context.tr('Loading CV'),
                child: const CupertinoActivityIndicator(),
              ),
            ),
          ),
          error: (error, stack) => EmptyState(
            icon: CupertinoIcons.exclamationmark_circle_fill,
            title: 'CV could not be opened',
            message: 'Please try again, or read the resume summary below.',
            action: IosButton.tinted(
              onPressed: () => ref.invalidate(cvDocumentProvider),
              child: const AppText('Try again'),
            ),
          ),
          data: (bytes) {
            if (bytes == null) {
              return const EmptyState(
                icon: CupertinoIcons.doc_text_fill,
                title: 'Resume PDF unavailable',
                message: 'Read the resume below or contact me for a PDF copy.',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    IosButton.filled(
                      onPressed: () => performAction(
                        context,
                        () => ref.read(cvServiceProvider).save(bytes),
                      ),
                      icon: const LiquidGlassIcon(
                        CupertinoIcons.arrow_down_doc_fill,
                        size: 18,
                      ),
                      label: const AppText('Download / save PDF'),
                    ),
                    Builder(
                      builder: (buttonContext) => IosButton.tinted(
                        onPressed: () {
                          final box =
                              buttonContext.findRenderObject() as RenderBox?;
                          final bounds = box == null
                              ? const Rect.fromLTWH(0, 0, 48, 48)
                              : box.localToGlobal(Offset.zero) & box.size;
                          performAction(
                            context,
                            () => ref
                                .read(cvServiceProvider)
                                .share(bytes, bounds),
                          );
                        },
                        icon: const LiquidGlassIcon(
                          CupertinoIcons.square_arrow_up_fill,
                          size: 18,
                        ),
                        label: const AppText('Share CV'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PdfPreview(
                      build: (_) async => bytes,
                      pdfFileName: 'Yorn_Nona_CV.pdf',
                      useActions: false,
                      canDebug: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      onError: (_, error) => const EmptyState(
                        icon: CupertinoIcons.exclamationmark_circle_fill,
                        title: 'Preview unavailable',
                        message:
                            'Download the PDF to open it in your preferred reader.',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                data.profile.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              AppText(
                data.profile.title,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              AppText(data.profile.summary),
              const Divider(height: 36),
              AppText(
                'Experience',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              for (final experience in data.experiences) ...[
                AppText(
                  '${experience.title} · ${experience.period}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                MutedText(experience.organization),
                const SizedBox(height: 12),
                BulletList(experience.responsibilities),
                const SizedBox(height: 12),
              ],
              AppText(
                'Education & Training',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final edu in data.educations) ...[
                AppText(
                  edu.institute,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                MutedText(
                  '${edu.program} · ${edu.period} · ${edu.status}',
                ),
                if (edu != data.educations.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
