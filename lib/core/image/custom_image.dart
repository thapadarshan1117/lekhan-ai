import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lekhan_ai/core/utils/shimmer.dart';


class ErroImage {
  static String errorImageUrl = 'https://placehold.co/600x400/png';
}

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? errorUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.errorUrl,
  });

  @override
  Widget build(BuildContext context) {
    // If no image URL is provided
    if (imageUrl == null || imageUrl!.isEmpty) {
      if (errorWidget != null) {
        return errorWidget!;
      } else if (errorUrl != null) {
        return Image.network(
          errorUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildDefaultError(),
        );
      }
      return _buildDefaultError();
    }

    // Handle SVG images
    if (imageUrl!.endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        allowDrawingOutsideViewBox: true,
        semanticsLabel: 'SVG Image',
        errorBuilder: (context, exception, stackTrace) {
          print("SVG loading error: $exception for URL: $imageUrl");
          return errorWidget ?? _buildDefaultError();
        },
        placeholderBuilder: (context) => placeholder ?? _buildPlaceholder(),
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      );
    }

    // Handle regular images
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ??
          (errorUrl != null
              ? Image.network(errorUrl!, width: width, height: height, fit: fit)
              : _buildDefaultError()),
    );
  }

  Widget _buildPlaceholder() {
    return Shimmer(
      width: width,
      height: height,
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: (width ?? 40) * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}
