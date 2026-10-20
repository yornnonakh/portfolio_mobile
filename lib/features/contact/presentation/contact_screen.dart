import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/components.dart';
import '../../../core/services/link_service.dart';
import '../../../core/utils/action_feedback.dart';
import '../../../shared/providers/portfolio_providers.dart';

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(portfolioProvider).profile;
    final service = ref.read(linkServiceProvider);
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Contact',
          title: 'Contact',
          description: 'Let’s talk about your next mobile project.',
        ),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTile(CupertinoIcons.envelope_fill),
              const SizedBox(height: 16),
              Text(
                'Say hello.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              IosSelectableText(
                profile.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: IosButton.filled(
                  onPressed: () => performAction(
                    context,
                    () => service.email(profile.email),
                  ),
                  child: const Text('Send an email'),
                ),
              ),
              Center(
                child: IosButton.plain(
                  onPressed: () =>
                      performAction(context, () => service.copy(profile.email)),
                  icon: const Icon(CupertinoIcons.doc_on_doc, size: 17),
                  label: const Text('Copy email'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Eyebrow('Connect'),
        const SizedBox(height: 10),
        IosGroupedList(
          children: [
            IosActionRow(
              icon: CupertinoIcons.phone_fill,
              title: 'Phone',
              subtitle: profile.phone,
              onPressed: () =>
                  performAction(context, () => service.phone(profile.phoneUri)),
            ),
            IosActionRow(
              icon: CupertinoIcons.chevron_left_slash_chevron_right,
              title: 'GitHub',
              subtitle: profile.github,
              onPressed: () =>
                  performAction(context, () => service.website(profile.github)),
            ),
            IosActionRow(
              icon: CupertinoIcons.briefcase_fill,
              title: 'LinkedIn',
              subtitle: LinkService.isWebUrl(profile.linkedIn)
                  ? profile.name
                  : 'Profile link unavailable',
              onPressed: LinkService.isWebUrl(profile.linkedIn)
                  ? () => performAction(
                      context,
                      () => service.website(profile.linkedIn),
                    )
                  : null,
            ),
            IosActionRow(
              icon: CupertinoIcons.paperplane_fill,
              title: 'Telegram',
              subtitle: profile.telegramNumber,
              onPressed: LinkService.isWebUrl(profile.telegramUrl)
                  ? () => performAction(
                      context,
                      () => service.website(profile.telegramUrl),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location,
              size: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            MutedText(profile.location),
          ],
        ),
      ],
    );
  }
}
