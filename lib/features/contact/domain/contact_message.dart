class ContactMessage {
  ContactMessage({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) : name = name.trim(),
       email = email.trim(),
       phone = phone.trim(),
       message = message.trim();

  final String name;
  final String email;
  final String phone;
  final String message;

  String get subject =>
      'Portfolio contact from ${name.replaceAll(RegExp(r'[\r\n]+'), ' ')}';
  String get body =>
      'New message from your portfolio\n\nName: $name\nEmail: $email\nPhone: $phone\n\nMessage:\n$message';

  static String? validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your name.';
    if (text.length > 80) return 'Please use 80 characters or fewer.';
    return null;
  }

  static String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email.';
    if (text.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your phone number.';
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\+?[0-9() .-]+$').hasMatch(text) ||
        digits.length < 6 ||
        digits.length > 20) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  static String? validateMessage(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter a message.';
    if (text.length > 2000) return 'Please use 2,000 characters or fewer.';
    return null;
  }
}
