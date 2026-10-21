import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/design_system/components.dart';
import '../../../core/services/link_service.dart';
import '../domain/contact_message.dart';

class ContactForm extends ConsumerStatefulWidget {
  const ContactForm({super.key, required this.recipient});
  final String recipient;

  @override
  ConsumerState<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  bool _attempted = false;
  ActionResult? _result;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  ContactMessage get _contactMessage => ContactMessage(
    name: _name.text,
    email: _email.text,
    phone: _phone.text,
    message: _message.text,
  );

  Future<void> _send({bool useGmail = false}) async {
    if (_sending) return;
    setState(() {
      _attempted = true;
      _result = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final message = _contactMessage;
    setState(() => _sending = true);
    final service = ref.read(linkServiceProvider);
    final result = await (useGmail
        ? service.gmail(
            widget.recipient,
            subject: message.subject,
            body: message.body,
          )
        : service.email(
            widget.recipient,
            subject: message.subject,
            body: message.body,
          ));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _result = result;
    });
  }

  Future<void> _copyMessage() async {
    final message = _contactMessage;
    final result = await ref
        .read(linkServiceProvider)
        .copy(
          'To: ${widget.recipient}\nSubject: ${message.subject}\n\n${message.body}',
          successMessage:
              'Message copied. Paste it into an email to ${widget.recipient}.',
        );
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .35)),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600 ? 22 : 32,
        ),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: _attempted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        CupertinoIcons.bubble_left_bubble_right,
                        color: scheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Contact Us',
                            style: theme.textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 6),
                          const MutedText(
                            'Good things start with a conversation.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: .45),
                ),
                const SizedBox(height: 24),
                AppText(
                  'Your details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  'All fields are required.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fields = [
                      _ContactInput(
                        fieldKey: const ValueKey('contact-name'),
                        icon: CupertinoIcons.person,
                        label: 'User name',
                        placeholder: 'Your name',
                        controller: _name,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                        maxLength: 80,
                        validator: ContactMessage.validateName,
                        enabled: !_sending,
                      ),
                      _ContactInput(
                        fieldKey: const ValueKey('contact-email'),
                        icon: CupertinoIcons.at,
                        label: 'Email',
                        placeholder: 'you@example.com',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        maxLength: 254,
                        validator: ContactMessage.validateEmail,
                        enabled: !_sending,
                      ),
                    ];
                    if (constraints.maxWidth >= 560 &&
                        MediaQuery.textScalerOf(context).scale(16) <= 22) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: fields[0]),
                          const SizedBox(width: 16),
                          Expanded(child: fields[1]),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        fields[0],
                        const SizedBox(height: 18),
                        fields[1],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                _ContactInput(
                  fieldKey: const ValueKey('contact-phone'),
                  icon: CupertinoIcons.phone,
                  label: 'Phone',
                  placeholder: '+855 12 345 678',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  maxLength: 40,
                  validator: ContactMessage.validatePhone,
                  enabled: !_sending,
                ),
                const SizedBox(height: 18),
                _ContactInput(
                  fieldKey: const ValueKey('contact-message'),
                  icon: CupertinoIcons.text_bubble,
                  label: 'Message',
                  placeholder: 'Tell me about your project…',
                  controller: _message,
                  keyboardType: TextInputType.multiline,
                  maxLength: 2000,
                  validator: ContactMessage.validateMessage,
                  enabled: !_sending,
                  multiline: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: IosButton.filled(
                    onPressed: _sending ? null : () => _send(),
                    iconAlignment: IconAlignment.end,
                    icon: _sending
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : const Icon(CupertinoIcons.paperplane_fill, size: 18),
                    label: AppText(_sending ? 'Opening email…' : 'Send'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        'Review and send in your email app or Gmail. Gmail may ask you to sign in.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: IosButton.plain(
                    onPressed: _sending ? null : () => _send(useGmail: true),
                    icon: const BrandIcon('gmail', size: 20),
                    label: const AppText('Open in Gmail'),
                  ),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 14),
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            (_result!.succeeded ? scheme.primary : scheme.error)
                                .withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _result!.succeeded
                                ? CupertinoIcons.checkmark_circle
                                : CupertinoIcons.exclamationmark_circle,
                            size: 20,
                            color: _result!.succeeded
                                ? scheme.primary
                                : scheme.error,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppText(
                              _result!.message!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _result!.succeeded
                                        ? scheme.onSurfaceVariant
                                        : scheme.error,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!_result!.succeeded)
                    IosButton.plain(
                      onPressed: _copyMessage,
                      label: const AppText('Copy message'),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactInput extends StatefulWidget {
  const _ContactInput({
    required this.fieldKey,
    required this.icon,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.keyboardType,
    required this.maxLength,
    required this.validator,
    required this.enabled,
    this.autofillHints,
    this.multiline = false,
  });
  final Key fieldKey;
  final IconData icon;
  final String label, placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLength;
  final FormFieldValidator<String> validator;
  final bool enabled, multiline;
  final Iterable<String>? autofillHints;

  @override
  State<_ContactInput> createState() => _ContactInputState();
}

class _ContactInputState extends State<_ContactInput> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          widget.label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          key: widget.fieldKey,
          initialValue: widget.controller.text,
          validator: widget.validator,
          enabled: widget.enabled,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListenableBuilder(
                listenable: _focusNode,
                builder: (context, _) => Container(
                  decoration: BoxDecoration(
                    color: _focusNode.hasFocus
                        ? scheme.primary.withValues(alpha: .04)
                        : scheme.surfaceContainerHighest.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: field.hasError
                          ? scheme.error
                          : _focusNode.hasFocus
                          ? scheme.primary
                          : scheme.outlineVariant.withValues(alpha: .3),
                      width: 1,
                    ),
                  ),
                  child: CupertinoTextField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    placeholder: context.tr(widget.placeholder),
                    placeholderStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: .8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: null,
                    prefix: widget.multiline
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Icon(
                              widget.icon,
                              size: 20,
                              color: _focusNode.hasFocus
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    keyboardType: widget.keyboardType,
                    keyboardAppearance: CupertinoTheme.brightnessOf(context),
                    textInputAction: widget.multiline
                        ? TextInputAction.newline
                        : TextInputAction.next,
                    textCapitalization: widget.multiline
                        ? TextCapitalization.sentences
                        : widget.keyboardType == TextInputType.name
                        ? TextCapitalization.words
                        : TextCapitalization.none,
                    autocorrect: widget.multiline,
                    enableSuggestions:
                        widget.multiline ||
                        widget.keyboardType == TextInputType.name,
                    inputFormatters: widget.multiline
                        ? null
                        : [FilteringTextInputFormatter.singleLineFormatter],
                    autofillHints: widget.autofillHints,
                    maxLength: widget.maxLength,
                    minLines: widget.multiline ? 4 : 1,
                    maxLines: widget.multiline ? 8 : 1,
                    enabled: widget.enabled,
                    onChanged: field.didChange,
                    scrollPadding: const EdgeInsets.fromLTRB(20, 90, 20, 100),
                    onSubmitted: widget.multiline
                        ? null
                        : (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 2),
                  child: Semantics(
                    liveRegion: true,
                    child: AppText(
                      field.errorText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.multiline)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, _) => AppText(
                  '${value.text.characters.length} / ${widget.maxLength}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
