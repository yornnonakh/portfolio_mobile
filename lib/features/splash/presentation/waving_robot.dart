import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Bends the raised hand at its wrist while keeping the body and phone rigid.
class WavingRobot extends StatefulWidget {
  const WavingRobot({super.key, required this.asset, required this.handAngle});

  final String asset;
  final double handAngle;

  @override
  State<WavingRobot> createState() => _WavingRobotState();
}

class _WavingRobotState extends State<WavingRobot> {
  ImageStream? _stream;
  _RobotMesh? _mesh;
  bool _failed = false;
  late final _listener = ImageStreamListener(
    _onImage,
    onError: (error, stack) {
      if (mounted) setState(() => _failed = true);
    },
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(WavingRobot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolveImage();
  }

  void _resolveImage() {
    final stream = AssetImage(
      widget.asset,
    ).resolve(createLocalImageConfiguration(context));
    if (_stream?.key == stream.key) return;
    _stream?.removeListener(_listener);
    _stream = stream;
    _failed = false;
    stream.addListener(_listener);
  }

  void _onImage(ImageInfo info, bool synchronousCall) {
    if (!mounted) {
      info.dispose();
      return;
    }
    final previous = _mesh;
    setState(() {
      _mesh = _RobotMesh(info);
      _failed = false;
    });
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _mesh?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Icon(
        CupertinoIcons.device_phone_portrait,
        size: 120,
        color: Theme.of(context).colorScheme.primary,
      );
    }
    final mesh = _mesh;
    return RepaintBoundary(
      child: mesh == null
          ? const SizedBox.expand()
          : CustomPaint(
              painter: _RobotPainter(mesh: mesh, handAngle: widget.handAngle),
              child: const SizedBox.expand(),
            ),
    );
  }
}

class _RobotMesh {
  _RobotMesh(this.info)
    : textureCoordinates = Float32List((_divisions + 1) * (_divisions + 1) * 2),
      weights = Float32List((_divisions + 1) * (_divisions + 1)),
      indices = Uint16List(_divisions * _divisions * 6),
      shader = ui.ImageShader(
        info.image,
        TileMode.clamp,
        TileMode.clamp,
        Matrix4.identity().storage,
        filterQuality: FilterQuality.medium,
      ) {
    for (var row = 0; row <= _divisions; row++) {
      for (var column = 0; column <= _divisions; column++) {
        final index = row * (_divisions + 1) + column;
        final x = column / _divisions;
        final y = row / _divisions;
        textureCoordinates[index * 2] = x * info.image.width;
        textureCoordinates[index * 2 + 1] = y * info.image.height;

        // Follow the transparent gap between the face and raised hand. The
        // influence fades into the wrist to avoid a cut or detached joint.
        final boundary = y < .46
            ? .805 - (y - .32) * .62
            : .7182 + (y - .46) * .3;
        final alongHand = (x - _wrist.dx) * .45 - (y - _wrist.dy) * .89;
        weights[index] =
            _smoothStep(boundary, boundary + .025, x) *
            _smoothStep(-.012, .055, alongHand);
      }
    }
    var offset = 0;
    for (var row = 0; row < _divisions; row++) {
      for (var column = 0; column < _divisions; column++) {
        final topLeft = row * (_divisions + 1) + column;
        final bottomLeft = topLeft + _divisions + 1;
        for (final vertex in [
          topLeft,
          bottomLeft,
          topLeft + 1,
          topLeft + 1,
          bottomLeft,
          bottomLeft + 1,
        ]) {
          indices[offset++] = vertex;
        }
      }
    }
  }

  static const _divisions = 60;
  static const _wrist = Offset(.775, .545);

  final ImageInfo info;
  final Float32List textureCoordinates, weights;
  final Uint16List indices;
  final ui.ImageShader shader;

  static double _smoothStep(double start, double end, double value) {
    final t = ((value - start) / (end - start)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  ui.Vertices pose(double handAngle) {
    final positions = Float32List.fromList(textureCoordinates);
    final pivot = Offset(
      _wrist.dx * info.image.width,
      _wrist.dy * info.image.height,
    );
    for (var index = 0; index < weights.length; index++) {
      final angle = handAngle * weights[index];
      if (angle == 0) continue;
      final x = textureCoordinates[index * 2] - pivot.dx;
      final y = textureCoordinates[index * 2 + 1] - pivot.dy;
      final cosine = math.cos(angle);
      final sine = math.sin(angle);
      positions[index * 2] = pivot.dx + x * cosine - y * sine;
      positions[index * 2 + 1] = pivot.dy + x * sine + y * cosine;
    }
    return ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: textureCoordinates,
      indices: indices,
    );
  }

  void dispose() {
    shader.dispose();
    info.dispose();
  }
}

class _RobotPainter extends CustomPainter {
  const _RobotPainter({required this.mesh, required this.handAngle});

  final _RobotMesh mesh;
  final double handAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final image = mesh.info.image;
    final scale = math.min(
      size.width / image.width,
      size.height / image.height,
    );
    canvas.save();
    canvas.translate(
      (size.width - image.width * scale) / 2,
      (size.height - image.height * scale) / 2,
    );
    canvas.scale(scale);
    final vertices = mesh.pose(handAngle);
    canvas.drawVertices(
      vertices,
      BlendMode.srcOver,
      Paint()
        ..shader = mesh.shader
        ..filterQuality = FilterQuality.medium
        ..isAntiAlias = true,
    );
    vertices.dispose();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RobotPainter oldDelegate) =>
      mesh != oldDelegate.mesh || handAngle != oldDelegate.handAngle;
}
