import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../shared/providers/portfolio_providers.dart';
import 'link_service.dart';

final cvServiceProvider = Provider<CvService>((ref) => CvService(rootBundle));
final cvDocumentProvider = FutureProvider<Uint8List?>(
  (ref) => ref
      .watch(cvServiceProvider)
      .load(ref.watch(portfolioProvider).profile.cvAsset),
);

class CvService {
  CvService(this.bundle);
  final AssetBundle bundle;
  Future<Uint8List?> load(String path) async {
    ByteData data;
    try {
      data = await bundle.load(path);
    } on FlutterError {
      return null;
    }
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException('The supplied CV file is not a valid PDF.');
    }
    return bytes;
  }

  Future<ActionResult> save(Uint8List bytes) async {
    try {
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux) {
        await FileSaver.instance.saveFile(
          name: 'Yorn_Nona_CV',
          bytes: bytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
      } else {
        final path = await FileSaver.instance.saveAs(
          name: 'Yorn_Nona_CV',
          bytes: bytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
        if (path == null) return const ActionResult(false);
      }
      return ActionResult(true, kIsWeb ? 'CV download started.' : 'CV saved.');
    } catch (_) {
      return const ActionResult(
        false,
        'Could not save the CV. Try sharing it to Files instead.',
      );
    }
  }

  Future<ActionResult> share(Uint8List bytes, Rect bounds) async {
    try {
      final shared = await Printing.sharePdf(
        bytes: bytes,
        filename: 'Yorn_Nona_CV.pdf',
        bounds: bounds,
      );
      return shared ? const ActionResult(true) : const ActionResult(false);
    } catch (_) {
      return const ActionResult(
        false,
        'Sharing is unavailable on this device. Try saving the CV instead.',
      );
    }
  }
}
