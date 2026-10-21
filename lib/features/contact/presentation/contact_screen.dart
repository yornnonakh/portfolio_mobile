import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/design_system/components.dart';
import '../../../core/services/link_service.dart';
import '../../../core/utils/action_feedback.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../shared/providers/portfolio_providers.dart';
import 'contact_form.dart';

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(portfolioProvider).profile;
    final service = ref.read(linkServiceProvider);
    final profileCard = SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(profile: profile, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      profile.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MutedText(profile.title),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IosSelectableText(
            profile.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            children: [
              IosButton.plain(
                onPressed: () =>
                    performAction(context, () => service.email(profile.email)),
                icon: const Icon(CupertinoIcons.envelope, size: 18),
                label: const AppText('Email me'),
              ),
              IosButton.plain(
                onPressed: () =>
                    performAction(context, () => service.copy(profile.email)),
                icon: const Icon(CupertinoIcons.doc_on_doc, size: 18),
                label: const AppText('Copy email'),
              ),
            ],
          ),
        ],
      ),
    );
    final socialLinks = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Social Media'),
        const SizedBox(height: 10),
        IosGroupedList(
          children: [
            IosActionRow(
              svgAsset: 'assets/icons/tools/phone.svg',
              title: 'Phone',
              onPressed: () =>
                  performAction(context, () => service.phone(profile.phoneUri)),
            ),
            IosActionRow(
              svgAsset: 'assets/icons/tools/github.svg',
              title: 'GitHub',
              onPressed: () =>
                  performAction(context, () => service.website(profile.github)),
            ),
            IosActionRow(
              svgAsset: 'assets/icons/tools/linkedin.svg',
              title: 'LinkedIn',
              onPressed: LinkService.isWebUrl(profile.linkedIn)
                  ? () => performAction(
                      context,
                      () => service.website(profile.linkedIn),
                    )
                  : null,
            ),
            IosActionRow(
              svgAsset: 'assets/icons/tools/telegram.svg',
              title: 'Telegram',
              onPressed: LinkService.isWebUrl(profile.telegramUrl)
                  ? () => performAction(
                      context,
                      () => service.website(profile.telegramUrl),
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Contact',
          title: 'Let’s connect.',
          description: 'A project, an opportunity, or a simple hello.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final form = ContactForm(recipient: profile.email);
            if (constraints.maxWidth >= 980 &&
                MediaQuery.textScalerOf(context).scale(16) <= 22) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        profileCard,
                        const SizedBox(height: 28),
                        socialLinks,
                      ],
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(flex: 7, child: form),
                ],
              );
            }
            return Column(
              children: [
                profileCard,
                const SizedBox(height: 24),
                form,
                const SizedBox(height: 28),
                socialLinks,
              ],
            );
          },
        ),
      ],
    );
  }
}
