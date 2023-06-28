import 'package:croppy/src/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MaterialImageCropperPage extends StatelessWidget {
  const MaterialImageCropperPage({
    super.key,
    required this.materialCroppableImageController,
    required this.controller,
    required this.shouldPopAfterCrop,
    this.gesturePadding = 16.0,
    this.heroTag,
  });
  final MaterialCroppableImageController materialCroppableImageController;
  final CroppableImageController controller;
  final double gesturePadding;
  final Object? heroTag;
  final bool shouldPopAfterCrop;

  Widget _buildButton({String? btnText, Function? onTap}) {
    ///需要改成防连点 todo
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        height: 40,
        child: Text(btnText ?? ''),
        color: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: generateMaterialImageCropperTheme(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: CroppableImagePageAnimator(
          controller: controller,
          heroTag: heroTag,
          builder: (context, overlayOpacityAnimation) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: AnimatedCroppableImageViewport(
                            controller: controller,
                            gesturePadding: gesturePadding,
                            overlayOpacityAnimation: overlayOpacityAnimation,
                            heroTag: heroTag,
                            cropHandlesBuilder: (context) => MaterialImageCropperHandles(
                              controller: controller,
                              gesturePadding: gesturePadding,
                              cornerColor: Color.fromRGBO(255, 186, 32, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: overlayOpacityAnimation,
                      builder: (context, _) => Opacity(
                        opacity: overlayOpacityAnimation.value,
                        child: MaterialImageCropperBottomAppBar(
                          controller: controller,
                          shouldPopAfterCrop: shouldPopAfterCrop,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 33.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildButton(
                            btnText: "旋转",
                            onTap: () {
                              controller.onRotateCCW();
                            },
                          ),
                          _buildButton(
                            btnText: "原图",
                            onTap: () {
                              final imageSize = controller.data.imageSize;
                              materialCroppableImageController.currentAspectRatio = CropAspectRatio(width: imageSize.width.toInt(), height: imageSize.height.toInt());
                            },
                          ),
                          _buildButton(
                            btnText: "3:4",
                            onTap: () {
                              materialCroppableImageController.currentAspectRatio = CropAspectRatio(width: 3, height: 4);
                            },
                          ),
                          _buildButton(
                            btnText: "1:1",
                            onTap: () {
                              materialCroppableImageController.currentAspectRatio = CropAspectRatio(width: 1, height: 1);
                            },
                          ),
                          _buildButton(
                            btnText: "4:3",
                            onTap: () {
                              materialCroppableImageController.currentAspectRatio = CropAspectRatio(width: 4, height: 3);
                            },
                          ),
                        ],
                      ),
                    ),

                    ///
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: overlayOpacityAnimation,
                        builder: (context, _) => Opacity(
                          opacity: overlayOpacityAnimation.value,
                          child: MaterialImageCropperToolbar(
                            controller: controller,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
