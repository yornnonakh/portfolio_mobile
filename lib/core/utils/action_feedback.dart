import 'package:flutter/cupertino.dart';
import '../localization/app_localizations.dart';
import '../services/link_service.dart';

Future<void> performAction(
  BuildContext context,
  Future<ActionResult> Function() action,
) async {
  ActionResult result;
  try {
    result = await action();
  } catch (_) {
    result = const ActionResult(
      false,
      'This action could not be completed. Please try again.',
    );
  }
  if (!context.mounted || result.message == null) return;
  final textTheme = CupertinoTheme.of(context).textTheme;
  await showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: AppText(
        result.succeeded ? 'Done' : 'Unable to complete action',
        style: textTheme.textStyle.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: AppText(
        result.message!,
        style: textTheme.textStyle.copyWith(fontSize: 13, height: 1.4),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: AppText(
            'OK',
            style: textTheme.actionTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
