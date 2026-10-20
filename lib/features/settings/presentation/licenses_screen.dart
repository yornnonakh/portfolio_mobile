import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/design_system/components.dart';
import '../../../core/widgets/app_frame.dart';
import '../../../core/utils/motion.dart';

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});
  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  late final Future<Map<String, String>> _licenses = _loadLicenses();

  Future<Map<String, String>> _loadLicenses() async {
    final packages = <String, List<String>>{};
    await for (final entry in LicenseRegistry.licenses) {
      final text = entry.paragraphs
          .map((paragraph) => paragraph.text)
          .join('\n\n');
      for (final package in entry.packages) {
        packages.putIfAbsent(package, () => []).add(text);
      }
    }
    final names = packages.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return {
      for (final name in names) name: packages[name]!.join('\n\n────────\n\n'),
    };
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, String>>(
    future: _licenses,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const PageContent(
          children: [
            EmptyState(
              icon: CupertinoIcons.doc_text_fill,
              title: 'Licenses unavailable',
              message: 'Please reopen this page to try again.',
            ),
          ],
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CupertinoActivityIndicator());
      }
      final licenses = snapshot.requireData;
      return PageContent(
        children: [
          const PageHeader(
            eyebrow: 'Licenses',
            title: 'Open source',
            description:
                'The packages and fonts that help power this portfolio.',
          ),
          if (licenses.isEmpty)
            const EmptyState(
              icon: CupertinoIcons.doc_text_fill,
              title: 'No licenses registered',
              message: 'License information will appear here when available.',
            )
          else
            IosGroupedList(
              children: [
                for (final package in licenses.entries)
                  IosActionRow(
                    icon: CupertinoIcons.doc_text_fill,
                    title: package.key,
                    onPressed: () => Navigator.of(context).push(
                      IosPageRoute<void>(
                        builder: (context) => AppFrame(
                          title: package.key,
                          child: PageContent(
                            children: [
                              PageHeader(
                                eyebrow: 'License',
                                title: package.key,
                              ),
                              SurfaceCard(
                                child: IosSelectableText(
                                  package.value,
                                  localize: false,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      );
    },
  );
}
