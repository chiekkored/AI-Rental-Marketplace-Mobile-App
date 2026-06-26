import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/loading.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewArguments {
  final List<String> images;
  final int intialIndex;
  final bool isDownloadVisible;
  PhotoViewArguments({
    required this.images,
    required this.intialIndex,
    this.isDownloadVisible = true,
  });
}

class PhotoViewPage extends StatefulWidget {
  static const routeName = '/photo-view';
  const PhotoViewPage({super.key});

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  late final PhotoViewArguments args;
  late final PageController pageController;
  late int currentIndex;
  late final Map<int, String?> _resolvedUrls = {};
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  @override
  void initState() {
    super.initState();
    args = Get.arguments as PhotoViewArguments;
    currentIndex = args.intialIndex;
    pageController = PageController(initialPage: args.intialIndex);
    _preloadImages();
  }

  void _preloadImages() {
    for (int i = 0; i < args.images.length; i++) {
      _resolveImageUrl(args.images[i]).then((url) {
        _resolvedUrls[i] = url;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  String _fixEmulatorUrl(String url) {
    if (!url.contains('localhost') &&
        !url.contains('127.0.0.1') &&
        !url.contains('10.0.2.2')) {
      return url;
    }

    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    final uri = Uri.parse(url);
    final newUri = uri.replace(host: host);
    return newUri.toString();
  }

  Future<String?> _resolveImageUrl(String imagePath) async {
    if (imagePath.isEmpty) {
      return null;
    } else if (Uri.tryParse(imagePath)?.hasScheme ?? false) {
      return _fixEmulatorUrl(imagePath);
    } else if (File(imagePath).existsSync()) {
      return imagePath;
    } else if (_env == 'local') {
      try {
        final url =
            await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
        return _fixEmulatorUrl(url);
      } catch (e, st) {
        LNDLogger.e(
          'Failed to resolve Firebase Storage URL: $e',
          error: e,
          stackTrace: st,
        );
        return null;
      }
    }
    return null;
  }

  void _downloadPhoto() async {
    try {
      LNDLoading.show();
      final imagePath = args.images[currentIndex];
      final resolvedUrl = await _resolveImageUrl(imagePath);

      if (resolvedUrl == null) {
        LNDSnackbar.showError('Failed to resolve image');
        LNDLoading.hide();
        return;
      }

      final localPath =
          '${Directory.systemTemp.path}/image_${DateTime.now().toIso8601String()}.jpg';
      await Dio().download(resolvedUrl, localPath);

      await Gal.putImage(localPath, album: 'Lend');
      LNDSnackbar.showInfo('Image downloaded');
      LNDLoading.hide();
    } catch (e, st) {
      LNDLoading.hide();
      LNDSnackbar.showError('Failed to download image');
      LNDLogger.e('Failed to download image: $e', error: e, stackTrace: st);
    }
  }

  ImageProvider _getImageProvider(String imagePath) {
    if (File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    }
    return CachedNetworkImageProvider(imagePath, cacheKey: imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: LNDButton.close(color: Colors.white),
        centerTitle: true,
        title: Visibility(
          visible: args.images.length > 1,
          child: LNDText.regular(
            text: '${currentIndex + 1}/${args.images.length}',
            color: Colors.white,
          ),
        ),
        actions: [
          Visibility(
            visible: args.isDownloadVisible,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: LNDButton.icon(
                icon: Icons.download_rounded,
                color: Colors.white,
                size: 25.0,
                onPressed: _downloadPhoto,
              ),
            ),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final imagePath = args.images[index];
          final resolvedUrl = _resolvedUrls[index];

          if (resolvedUrl != null) {
            return PhotoViewGalleryPageOptions(
              imageProvider: _getImageProvider(resolvedUrl),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              heroAttributes: PhotoViewHeroAttributes(tag: args.images),
              errorBuilder:
                  (context, error, stackTrace) => Center(
                    child: LNDText.regular(text: 'Failed to load image'),
                  ),
            );
          }

          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
              imagePath,
              cacheKey: imagePath,
            ),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: args.images),
          );
        },
        itemCount: args.images.length,
        loadingBuilder:
            (context, event) => Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator.adaptive(
                  value:
                      event == null
                          ? 0
                          : event.cumulativeBytesLoaded /
                              (event.expectedTotalBytes ?? 0),
                ),
              ),
            ),
        pageController: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
