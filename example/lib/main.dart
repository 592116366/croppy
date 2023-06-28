import 'dart:io';
import 'dart:math';

import 'package:croppy/croppy.dart';
import 'package:example/custom_cropper.dart';
import 'package:example/settings_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  if (!kIsWeb) {
    // For some reason, the C++ implementation of the Cassowary solver is super
    // slow in debug mode. So we force the Dart implementation to be used in
    // debug mode. This only applies to Windows.
    croppyForceUseCassowaryDartImpl = true;
  }

  runApp(const MyApp());
}

class ExampleScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const BouncingScrollPhysics();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ScreenUtilInit screenUtilInit({required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(750, 1136),
      splitScreenMode: true,
      minTextAdapt: true,
      builder: (context, _) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return screenUtilInit(
      child: MaterialApp(
        title: 'Croppy Demo',
        scrollBehavior: ExampleScrollBehavior(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            primary: Colors.orange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PageController _pageController;
  var _cropSettings = CropSettings.initial();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.9,
    );

    final random = Random();
    for (var i = 0; i < 10; i++) {
      final image = NetworkImage(
        'https://test-photos-qklwjen.s3.eu-west-3.amazonaws.com/image${random.nextInt(80) + 1}.jpg',
        headers: const {'accept': '*/*'},
      );

      /// 网络图片 如上 (如有特殊需要 当然也可以保留原项目 先网络下载到本地再使用)
      /// 项目下的 本地资源 可以 FileImage 转为 ImageProvider 获取 _imageProviders todo.
      /// 目标:使用方只需要传 url

      _imageProviders.add(image);
    }
    // String localImageUrl = '/storage/emulated/0/Pictures/1687915733219.jpg';
    //
    // final localImage = (localImageUrl);
    //
    // _imageProviders.add(localImage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final _imageProviders = <ImageProvider>[];
  final _data = <int, CroppableImageData>{};
  final _croppedImage = <int, ui.Image>{};

  //保存一个Image
  Future<File?> saveImage(ui.Image image, String path, {format = ui.ImageByteFormat.png}) async {
    var file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    ByteData? byteData = await image.toByteData(format: format);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes != null ? file.writeAsBytes(pngBytes) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final newSettings = await showCropSettingsModal(
                context: context,
                initialSettings: _cropSettings,
              );

              setState(() {
                _cropSettings = newSettings;
              });
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              final page = _pageController.page?.round() ?? 0;

              showCupertinoImageCropper(
                context,
                imageProvider: _imageProviders[page],
                heroTag: 'image-$page',
                initialData: _data[page],
                cropPathFn: _cropSettings.cropShapeFn,
                enabledTransformations: _cropSettings.enabledTransformations,
                allowedAspectRatios: _cropSettings.forcedAspectRatio != null ? [_cropSettings.forcedAspectRatio!] : null,
                postProcessFn: (result) async {
                  _croppedImage[page]?.dispose();

                  CropImageResult r;
                  // 如何将一个Image对象保存到本地？Image对象可以转化成字节流，再通过文件写入。

                  setState(() {
                    _croppedImage[page] = result.uiImage;
                    _data[page] = result.transformationsData;
                  });

                  return result;
                },
              );
            },
            heroTag: 'fab-cupertino',
            child: const Icon(Icons.apple_rounded),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            onPressed: () {
              final page = _pageController.page?.round() ?? 0;

              showMaterialImageCropper(
                context,
                imageProvider: _imageProviders[page],
                heroTag: 'image-$page',
                initialData: _data[page],
                cropPathFn: _cropSettings.cropShapeFn,
                enabledTransformations: _cropSettings.enabledTransformations,
                allowedAspectRatios: _cropSettings.forcedAspectRatio != null ? [_cropSettings.forcedAspectRatio!] : null,
                postProcessFn: (result) async {
                  _croppedImage[page]?.dispose();

                  setState(() {
                    _croppedImage[page] = result.uiImage;
                    _data[page] = result.transformationsData;
                  });

                  return result;
                },
              );
            },
            heroTag: 'fab-material',
            child: const Icon(Icons.android_rounded),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            onPressed: () {
              final page = _pageController.page?.round() ?? 0;

              showCustomCropper(
                context,
                _imageProviders[page],
                heroTag: 'image-$page',
                initialData: _data[page],
                onCropped: (result) async {
                  _croppedImage[page]?.dispose();

                  setState(() {
                    _croppedImage[page] = result.uiImage;
                    _data[page] = result.transformationsData;
                  });

                  return result;
                },
              );
            },
            heroTag: 'fab-custom',
            child: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: Center(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _imageProviders.length,
          scrollDirection: Axis.horizontal,
          padEnds: true,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Hero(
                  tag: 'image-$i',
                  placeholderBuilder: (context, size, child) => Visibility.maintain(
                    visible: false,
                    child: child,
                  ),
                  child: _croppedImage[i] != null ? RawImage(image: _croppedImage[i]) : Image(image: _imageProviders[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
