import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:shimmer/shimmer.dart';

class LNDImage extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  final double borderRadius;
  final double height;
  final double width;
  final ImageType imageType;
  static const String _fallbackUser = 'assets/svg/default_avatar.svg';
  static const String _fallbackAsset = 'assets/svg/image.svg';
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  const LNDImage._({
    required this.imageUrl,
    this.size,
    this.borderRadius = 12.0,
    this.height = 50.0,
    this.width = 50.0,
    this.imageType = ImageType.asset,
  });

  factory LNDImage.circle({
    required String? imageUrl,
    double size = 50.0,
    ImageType imageType = ImageType.asset,
  }) {
    return LNDImage._(
      imageUrl: imageUrl,
      size: size,
      borderRadius: size / 2,
      imageType: imageType,
    );
  }

  factory LNDImage.square({
    required String? imageUrl,
    double size = 50.0,
    double borderRadius = 12.0,
    ImageType imageType = ImageType.asset,
  }) {
    return LNDImage._(
      imageUrl: imageUrl,
      size: size,
      borderRadius: borderRadius,
      imageType: imageType,
    );
  }

  factory LNDImage.custom({
    required String? imageUrl,
    required double height,
    required double width,
    double borderRadius = 12.0,
  }) {
    return LNDImage._(
      imageUrl: imageUrl,
      height: height,
      width: width,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? height,
      width: size ?? width,
      child: _loadImage(context, imageUrl),
    );
  }

  String _fixEmulatorUrl(String url) {
    // Only rewrite emulator URLs
    if (!url.contains('localhost') &&
        !url.contains('127.0.0.1') &&
        !url.contains('10.0.2.2')) {
      return url; // real Firebase URL, do nothing
    }

    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';

    // parse the url and replace the host
    final uri = Uri.parse(url);
    final newUri = uri.replace(host: host);
    return newUri.toString();
  }

  Widget _loadImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // No image source was provided, so render the default asset/user fallback.
      return _buildFallbackImage(context);
    } else if (Uri.tryParse(imageUrl)?.hasScheme ?? false) {
      // Public URLs can be rendered directly after normalizing emulator hosts.
      final fixedUrl = _fixEmulatorUrl(imageUrl);

      return _buildNetworkImage(context, fixedUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return _buildAssetImage(context, imageUrl);
    } else if (File(imageUrl).existsSync()) {
      // Picker previews and other device files should render from the local path.
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File((imageUrl)),
          fit: BoxFit.cover,
          errorBuilder: (_, obj, st) {
            LNDLogger.e(
              obj.toString(),
              error: obj,
              stackTrace: st ?? StackTrace.current,
            );
            return _buildFallbackImage(context);
          },
        ),
      );
    } else if (_env == 'local') {
      // Local uploads are stored as Firebase Storage full paths instead of
      // public download URLs, so resolve them through the emulator at render time.
      return FutureBuilder<String>(
        future: FirebaseStorage.instance.ref(imageUrl).getDownloadURL(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // The emulator can return localhost URLs, which Android emulators
            // cannot reach directly. Normalize the host before rendering.
            final fixedUrl = _fixEmulatorUrl(snapshot.data!);
            return _buildNetworkImage(context, fixedUrl);
          }

          if (snapshot.hasError) {
            LNDLogger.e(
              snapshot.error.toString(),
              error: snapshot.error,
              stackTrace: snapshot.stackTrace ?? StackTrace.current,
            );
            return _buildFallbackImage(context);
          }

          // Keep the image box stable while the local Storage URL is resolving.
          return _buildImagePlaceholder(context);
        },
      );
    } else {
      // In non-local environments, unknown non-URL strings are invalid image sources.
      return _buildFallbackImage(context);
    }
  }

  Widget _buildAssetImage(BuildContext context, String assetName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetName,
        fit: BoxFit.contain,
        errorBuilder: (_, obj, st) {
          LNDLogger.e(
            obj.toString(),
            error: obj,
            stackTrace: st ?? StackTrace.current,
          );
          return _buildFallbackImage(context);
        },
      ),
    );
  }

  Widget _buildNetworkImage(BuildContext context, String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheKey: imageUrl,
      placeholder: (context, s) => _buildImagePlaceholder(context),
      imageBuilder: (_, imageProvider) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image(image: imageProvider, fit: BoxFit.cover),
        );
      },
      errorWidget: (context, __, ___) => _buildFallbackImage(context),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Shimmer.fromColors(
        baseColor: context.lndTheme.surfaceMuted,
        highlightColor: context.lndTheme.surface,
        child: ColoredBox(color: context.lndTheme.surfaceMuted),
      ),
    );
  }

  Widget _buildFallbackImage(BuildContext context) {
    final colors = context.lndTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      // child: Image.asset(_fallbackAsset, fit: BoxFit.cover),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        color: colors.surface,
        child: SvgPicture.asset(
          fit: BoxFit.scaleDown,
          imageType == ImageType.user ? _fallbackUser : _fallbackAsset,
        ),
      ),
    );
  }
}
