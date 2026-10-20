import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionResult {
  const ActionResult(this.succeeded, [this.message]);
  final bool succeeded;
  final String? message;
}

final linkServiceProvider = Provider<LinkService>((ref) => const LinkService());

class LinkService {
  const LinkService({this.launcher});
  final Future<bool> Function(Uri uri)? launcher;
  static bool isWebUrl(String? value) {
    final uri = value == null ? null : Uri.tryParse(value);
    return uri != null &&
        ['https', 'http'].contains(uri.scheme) &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
  }

  Future<ActionResult> website(String? value) async {
    if (!isWebUrl(value)) {
      return const ActionResult(
        false,
        'A verified link has not been supplied yet.',
      );
    }
    return _launch(Uri.parse(value!));
  }

  Future<ActionResult> email(String address) =>
      _launch(Uri(scheme: 'mailto', path: address));
  Future<ActionResult> phone(String number) =>
      _launch(Uri(scheme: 'tel', path: number));
  Future<ActionResult> copy(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return const ActionResult(true, 'Email copied to clipboard.');
    } catch (_) {
      return const ActionResult(
        false,
        'Could not access the clipboard. Please select and copy the email.',
      );
    }
  }

  Future<ActionResult> _launch(Uri uri) async {
    try {
      if (await (launcher?.call(uri) ??
          launchUrl(uri, mode: LaunchMode.externalApplication))) {
        return const ActionResult(true);
      }
    } catch (_) {
      // Devices without a mail/phone app fall through to the actionable message.
    }
    return ActionResult(
      false,
      'Could not open ${uri.scheme == 'mailto'
          ? 'an email app'
          : uri.scheme == 'tel'
          ? 'the phone app'
          : 'this link'}. You can copy the contact details instead.',
    );
  }
}
