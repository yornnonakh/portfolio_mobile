import 'package:flutter/foundation.dart';
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
  const LinkService({this.launcher, this.preferWebMail = kIsWeb});
  final Future<bool> Function(Uri uri)? launcher;
  final bool preferWebMail;
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

  Future<ActionResult> email(
    String address, {
    String? subject,
    String? body,
  }) async {
    // Browsers cannot reliably report whether a mailto handler exists.
    if (preferWebMail) {
      return gmail(address, subject: subject, body: body);
    }
    final fields = {'subject': ?subject, 'body': ?body};
    final query = fields.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
    final result = await _launch(
      Uri(scheme: 'mailto', path: address, query: query.isEmpty ? null : query),
    );
    if (result.succeeded) {
      return const ActionResult(
        true,
        'Email draft opened. Tap Send in your email app to deliver your message.',
      );
    }
    return gmail(address, subject: subject, body: body);
  }

  Future<ActionResult> gmail(
    String address, {
    String? subject,
    String? body,
  }) async {
    final result = await _launch(
      Uri.https('mail.google.com', '/mail/', {
        'view': 'cm',
        'fs': '1',
        'to': address,
        'su': ?subject,
        'body': ?body,
      }),
      sameTab: true,
    );
    return result.succeeded
        ? const ActionResult(
            true,
            'Gmail opened in your browser. Sign in if needed, then tap Send to deliver your message.',
          )
        : const ActionResult(
            false,
            'Could not open email or Gmail. Your details are still here. Try again or copy your message below.',
          );
  }

  Future<ActionResult> phone(String number) =>
      _launch(Uri(scheme: 'tel', path: number));
  Future<ActionResult> copy(
    String text, {
    String successMessage = 'Email copied to clipboard.',
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return ActionResult(true, successMessage);
    } catch (_) {
      return const ActionResult(
        false,
        'Could not access the clipboard. Please select and copy the email.',
      );
    }
  }

  Future<ActionResult> _launch(Uri uri, {bool sameTab = false}) async {
    try {
      if (await (launcher?.call(uri) ??
          launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: sameTab ? '_self' : null,
          ))) {
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
