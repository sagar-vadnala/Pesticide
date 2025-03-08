import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/dev.log.dart';

const String placeholderImageUrl = 'packages/am_utilities/assets/images/placeholder-image.png';

class ExtendedCachedImage extends StatelessWidget {
  const ExtendedCachedImage({
    super.key,
    required this.imageUrl,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.borderRadius,
    this.fit,
    this.color,
  });

  final String? imageUrl;
  final Color? shimmerBaseColor, shimmerHighlightColor;
  final BorderRadius? borderRadius;
  final BoxFit? fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isBlank(imageUrl)) {
      return LimitedBox(
        // maxHeight: 100,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Image.asset(
            placeholderImageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      final ThemeData theme = Theme.of(context);
      return ClipRRect(
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
        child: CachedNetworkImage(
          color: color,
          imageUrl: imageUrl!,
          fit: fit ?? BoxFit.cover,
          placeholder: (context, s) => LimitedBox(
            maxHeight: 100,
            child: Shimmer.fromColors(
              period: const Duration(milliseconds: 500),
              baseColor: shimmerBaseColor ?? theme.colorScheme.surface,
              highlightColor: shimmerHighlightColor ?? const Color(0xFFE0E0E0),
              child: LimitedBox(
                maxHeight: 100,
                child: Image.asset(
                  placeholderImageUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          errorWidget: (context, s, o) {
            Dev.error('Cannot load image', error: s);
            return LimitedBox(
              // maxHeight: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Image.asset(
                  placeholderImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
