import 'package:croppy/src/src.dart';
import 'package:flutter/widgets.dart';

/// A mixin for the [CroppableImageController] that allows to keep the aspect
/// ratio of the crop rect.
mixin AspectRatioMixin on CroppableImageController {
  /// Allowed aspect ratios for the aspect ratio toolbar.
  ///
  /// A `null` value means that the crop rect can be resized freely.
  List<CropAspectRatio?> get allowedAspectRatios;

  @override
  void onResize({
    required Offset offset,
    required ResizeDirection direction,
  }) {
    super.onResize(offset: offset, direction: direction);
    if (currentAspectRatio == null) return;

    final newRect = data.cropRect;
    final ar = currentAspectRatio!.ratio;

    late final Rect correctedRect;
    switch (direction) {
      case ResizeDirection.toTop:
        final pivot = newRect.bottomCenter;
        final height = newRect.height;
        final width = height * ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx - width / 2,
          pivot.dy - height,
          pivot.dx + width / 2,
          pivot.dy,
        );

        break;
      case ResizeDirection.toBottom:
        final pivot = newRect.topCenter;
        final height = newRect.height;
        final width = height * ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx - width / 2,
          pivot.dy,
          pivot.dx + width / 2,
          pivot.dy + height,
        );

        break;
      case ResizeDirection.toLeft:
        final pivot = newRect.centerRight;
        final width = newRect.width;
        final height = width / ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx - width,
          pivot.dy - height / 2,
          pivot.dx,
          pivot.dy + height / 2,
        );

        break;
      case ResizeDirection.toRight:
        final pivot = newRect.centerLeft;
        final width = newRect.width;
        final height = width / ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx,
          pivot.dy - height / 2,
          pivot.dx + width,
          pivot.dy + height / 2,
        );

        break;
      case ResizeDirection.toTopLeft:
        final pivot = newRect.bottomRight;
        final width = newRect.width;
        final height = width / ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx - width,
          pivot.dy - height,
          pivot.dx,
          pivot.dy,
        );

        break;
      case ResizeDirection.toTopRight:
        final pivot = newRect.bottomLeft;
        final width = newRect.width;
        final height = width / ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx,
          pivot.dy - height,
          pivot.dx + width,
          pivot.dy,
        );

        break;
      case ResizeDirection.toBottomLeft:
        final pivot = newRect.topRight;
        final width = newRect.width;
        final height = width / ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx - width,
          pivot.dy,
          pivot.dx,
          pivot.dy + height,
        );

        break;
      case ResizeDirection.toBottomRight:
        final pivot = newRect.topLeft;
        final width = newRect.width;
        final height = width / ar;

        correctedRect = Rect.fromLTRB(
          pivot.dx,
          pivot.dy,
          pivot.dx + width,
          pivot.dy + height,
        );

        break;
    }

    data = transformationInitialData!.copyWith(
      cropRect: correctedRect,
      currentImageTransform: Matrix4.identity(),
    );

    notifyListeners();
  }

  /// Sets the current aspect ratio.
  @mustCallSuper
  set currentAspectRatio(CropAspectRatio? newAspectRatio) {
    if (aspectRatioNotifier.value == newAspectRatio) return;

    aspectRatioNotifier.value = newAspectRatio;
    final newCropRect = resizeCropRectWithAspectRatio(
      data.cropRect,
      newAspectRatio,
    );

    data = data.copyWith(cropRect: newCropRect);
    normalize();

    notifyListeners();
  }

  CropAspectRatio? get currentAspectRatio => aspectRatioNotifier.value;

  /// The aspect ratio notifier.
  final aspectRatioNotifier = ValueNotifier<CropAspectRatio?>(null);
}