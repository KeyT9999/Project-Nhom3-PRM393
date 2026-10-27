import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/product_images.dart';

/// Ảnh sản phẩm: asset theo productId > ảnh mạng > placeholder trung tính.
/// Ảnh nhiều tỉ lệ đều được đặt `contain` và căn giữa trong cùng một khung.
class ProductImage extends StatefulWidget {
  final String productId;
  final String? fallbackUrl;

  /// Ép dùng một asset cụ thể (trang gallery); null thì tra theo [productId].
  final String? assetPath;
  final BoxFit fit;

  /// Tỉ lệ khung; null để lấp đầy khung cha.
  final double? aspectRatio;
  final EdgeInsetsGeometry padding;
  final String? heroTag;
  final ProductImages? images;

  const ProductImage({
    super.key,
    required this.productId,
    this.fallbackUrl,
    this.assetPath,
    this.fit = BoxFit.contain,
    this.aspectRatio = 1,
    this.padding = const EdgeInsets.all(6),
    this.heroTag,
    this.images,
  });

  static String heroTagFor(String productId) => 'product-$productId';

  /// Làm tròn kích thước giải mã lên bội số 256px để cache dùng chung giữa
  /// các màn và precacheImage khớp khóa với ảnh được hiển thị.
  static int cacheBucket(double logicalSide, double devicePixelRatio) {
    final px = (logicalSide * devicePixelRatio).ceil();
    return ((px + 255) ~/ 256) * 256;
  }

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  static const _paper = Color(0xFFFFFFFF);
  static const _placeholderBg = Color(0xFFF2F3F5);

  ProductImages get _lookup => widget.images ?? ProductImages.instance;

  @override
  void initState() {
    super.initState();
    _lookup.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListenableBuilder(
      listenable: _lookup,
      builder: (context, _) => LayoutBuilder(
        builder: (context, c) => _buildImage(context, c),
      ),
    );
    if (widget.aspectRatio != null) {
      content = AspectRatio(aspectRatio: widget.aspectRatio!, child: content);
    }
    if (widget.heroTag != null) {
      content = Hero(tag: widget.heroTag!, child: content);
    }
    return content;
  }

  Widget _buildImage(BuildContext context, BoxConstraints c) {
    final asset = widget.assetPath ?? _lookup.main(widget.productId);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final side = [c.maxWidth, c.maxHeight].where((v) => v.isFinite);
    final px = side.isEmpty
        ? null
        : ProductImage.cacheBucket(
            side.reduce((a, b) => a < b ? a : b), dpr);

    Widget? image;
    if (asset != null) {
      image = Image.asset(
        asset,
        fit: widget.fit,
        alignment: Alignment.center,
        cacheWidth: px,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(px) ?? _placeholder(),
      );
    } else {
      image = _fallback(px);
    }
    if (image == null) return _placeholder();
    return ColoredBox(
      color: _paper,
      child: Padding(padding: widget.padding, child: Center(child: image)),
    );
  }

  Widget? _fallback(int? px) {
    final url = widget.fallbackUrl;
    if (url != null && url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: widget.fit,
        memCacheWidth: px,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => const SizedBox.shrink(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    if (url != null && url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: widget.fit,
        cacheWidth: px,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return null;
  }

  Widget _placeholder() => const ColoredBox(
        key: ValueKey('product-image-placeholder'),
        color: _placeholderBg,
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Icon(
                Icons.smartphone_outlined,
                size: 40,
                color: Color(0xFFB8BDC6),
              ),
            ),
          ),
        ),
      );
}
