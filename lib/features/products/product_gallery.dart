import 'package:flutter/material.dart';

import '../../core/utils/product_images.dart';
import '../../core/widgets/product_image.dart';

/// Carousel ảnh sản phẩm (main + gallery), chấm chỉ báo, chạm để xem toàn màn hình.
class ProductGallery extends StatefulWidget {
  final String productId;
  final String? fallbackUrl;
  final double height;
  final ProductImages? images;

  const ProductGallery({
    super.key,
    required this.productId,
    this.fallbackUrl,
    this.height = 260,
    this.images,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final _controller = PageController();
  int _page = 0;

  ProductImages get _lookup => widget.images ?? ProductImages.instance;

  @override
  void initState() {
    super.initState();
    _lookup.ensureLoaded();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen(List<String?> pages, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullscreenGallery(
          productId: widget.productId,
          fallbackUrl: widget.fallbackUrl,
          assets: pages,
          initial: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lookup,
      builder: (context, _) {
        final assets = _lookup.all(widget.productId);
        final List<String?> pages = assets.isEmpty ? [null] : assets;
        return SizedBox(
          height: widget.height,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _openFullscreen(pages, i),
                    child: RepaintBoundary(
                      child: ProductImage(
                        productId: widget.productId,
                        assetPath: pages[i],
                        fallbackUrl: widget.fallbackUrl,
                        aspectRatio: null,
                        padding: const EdgeInsets.all(12),
                        images: _lookup,
                        heroTag: i == 0
                            ? ProductImage.heroTagFor(widget.productId)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              if (pages.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? const Color(0xFF1D1D1F)
                                : const Color(0xFFD2D2D7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FullscreenGallery extends StatelessWidget {
  final String productId;
  final String? fallbackUrl;
  final List<String?> assets;
  final int initial;

  const _FullscreenGallery({
    required this.productId,
    required this.fallbackUrl,
    required this.assets,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1D1F),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initial),
        itemCount: assets.length,
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: ProductImage(
            productId: productId,
            assetPath: assets[i],
            fallbackUrl: fallbackUrl,
            aspectRatio: null,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}
