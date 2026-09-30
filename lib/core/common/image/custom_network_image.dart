import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Simple cached network image wrapper with sensible placeholder and
/// error fallbacks.
class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
    this.placeholder,
  });

  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _fallback();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, _) =>
          placeholder ??
          const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, _, __) => _fallback(),
    );
  }

  Widget _fallback() {
    return SizedBox(
      width: width,
      height: height,
      child: errorWidget ?? const Icon(Icons.image_not_supported_outlined),
    );
  }
}
