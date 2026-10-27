import 'package:flutter/foundation.dart';

import '../data/models/banner_model.dart';
import '../data/models/brand_model.dart';
import '../data/models/coupon_model.dart';
import '../data/models/product_model.dart';
import '../data/models/review_model.dart';
import '../data/models/variant_model.dart';
import '../data/repositories/product_repository.dart';

enum ProductSortOption { newest, priceAsc, priceDesc, bestSelling }

class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  List<ProductModel> _allProducts = [];
  List<VariantModel> _currentVariants = [];
  VariantModel? _selectedVariant;

  // Trạng thái Tìm kiếm (F06), Bộ lọc (F07), Sắp xếp (F08)
  String _selectedBrand = 'Tất cả';
  String _searchQuery = '';
  int? _maxPriceVnd;
  int? _filterRamGB;
  int? _filterStorageGB;
  bool _onlyInStock = false;
  ProductSortOption _sortOption = ProductSortOption.bestSelling;

  // Danh sách so sánh điện thoại (Stage 3)
  final Set<String> _comparedProductIds = {
    'iphone_16_pro_max',
    'samsung_s25_ultra',
  };

  bool _isLoading = false;

  ProductProvider({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository() {
    loadProducts();
  }

  ProductRepository get repository => _productRepository;
  List<ProductModel> get allProducts => List.unmodifiable(_allProducts);
  List<ProductModel> get products => filteredProducts;
  List<VariantModel> get currentVariants => List.unmodifiable(_currentVariants);
  VariantModel? get selectedVariant => _selectedVariant;

  String get selectedBrand => _selectedBrand;
  String get searchQuery => _searchQuery;
  int? get maxPriceVnd => _maxPriceVnd;
  int? get filterRamGB => _filterRamGB;
  int? get filterStorageGB => _filterStorageGB;
  bool get onlyInStock => _onlyInStock;
  ProductSortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;

  List<BrandModel> get brands => _productRepository.getBrands();
  List<BrandModel> get allBrandsAdmin =>
      _productRepository.getBrands(includeInactive: true);
  List<BannerModel> get banners => _productRepository.getBanners();
  List<BannerModel> get allBannersAdmin =>
      _productRepository.getBanners(includeInactive: true);
  List<CouponModel> get coupons => _productRepository.getCoupons();

  Set<String> get comparedProductIds => Set.unmodifiable(_comparedProductIds);
  List<ProductModel> get comparedProducts =>
      _allProducts.where((p) => _comparedProductIds.contains(p.id)).toList();

  /// Áp dụng đồng thời Tìm kiếm (F06), Bộ lọc (F07) và Sắp xếp (F08)
  List<ProductModel> get filteredProducts {
    Iterable<ProductModel> list = _allProducts.where((p) => p.isActive);

    if (_selectedBrand != 'Tất cả' && _selectedBrand.isNotEmpty) {
      list = list.where(
        (p) => p.brandId.toLowerCase() == _selectedBrand.toLowerCase(),
      );
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where(
        (p) =>
            p.name.toLowerCase().contains(q) ||
            p.brandId.toLowerCase().contains(q) ||
            p.slug.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q),
      );
    }

    if (_maxPriceVnd != null) {
      list = list.where((p) => p.priceFromVnd <= _maxPriceVnd!);
    }

    if (_filterRamGB != null) {
      list = list.where((p) => p.ramOptions.contains(_filterRamGB));
    }

    if (_filterStorageGB != null) {
      list = list.where((p) => p.storageOptions.contains(_filterStorageGB));
    }

    if (_onlyInStock) {
      list = list.where(
        (p) => _productRepository
            .getCachedVariants(p.id)
            .any((variant) => variant.isActive && variant.stock > 0),
      );
    }

    final sorted = list.toList();
    switch (_sortOption) {
      case ProductSortOption.priceAsc:
        sorted.sort((a, b) => a.priceFromVnd.compareTo(b.priceFromVnd));
        break;
      case ProductSortOption.priceDesc:
        sorted.sort((a, b) => b.priceFromVnd.compareTo(a.priceFromVnd));
        break;
      case ProductSortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProductSortOption.bestSelling:
        sorted.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
    }
    return sorted;
  }

  Future<void> loadProducts({
    String? brand,
    bool includeInactive = false,
  }) async {
    _isLoading = true;
    if (brand != null) {
      _selectedBrand = brand;
    }
    notifyListeners();

    _allProducts = await _productRepository.getProducts(includeInactive: true);
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void applyFilters({
    String? brand,
    int? maxPriceVnd,
    int? ramGB,
    int? storageGB,
    bool? onlyInStock,
    bool clearAll = false,
  }) {
    if (clearAll) {
      _selectedBrand = 'Tất cả';
      _maxPriceVnd = null;
      _filterRamGB = null;
      _filterStorageGB = null;
      _onlyInStock = false;
    } else {
      if (brand != null) _selectedBrand = brand;
      _maxPriceVnd = maxPriceVnd;
      _filterRamGB = ramGB;
      _filterStorageGB = storageGB;
      if (onlyInStock != null) _onlyInStock = onlyInStock;
    }
    notifyListeners();
  }

  Future<void> loadVariantsForProduct(String productId) async {
    _currentVariants = await _productRepository.getVariantsByProductId(
      productId,
    );
    _currentVariants.sort((a, b) {
      final byPrice = a.priceVnd.compareTo(b.priceVnd);
      return byPrice != 0 ? byPrice : a.storageGB.compareTo(b.storageGB);
    });
    if (_currentVariants.isNotEmpty) {
      _selectedVariant = _currentVariants.firstWhere(
        (v) => v.isInStock,
        orElse: () => _currentVariants.first,
      );
    } else {
      _selectedVariant = null;
    }
    notifyListeners();
  }

  void selectVariant(VariantModel variant) {
    _selectedVariant = variant;
    notifyListeners();
  }

  void toggleCompareProduct(String productId) {
    if (_comparedProductIds.contains(productId)) {
      _comparedProductIds.remove(productId);
    } else {
      if (_comparedProductIds.length >= 3) {
        _comparedProductIds.remove(_comparedProductIds.first);
      }
      _comparedProductIds.add(productId);
    }
    notifyListeners();
  }

  List<ReviewModel> getReviewsForProduct(String productId) {
    return _productRepository.getReviewsForProduct(productId);
  }

  Future<void> submitReview({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    final review = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    await _productRepository.addReview(review);
    await loadProducts();
  }

  CouponModel? validateCoupon(String code, int subtotalVnd) {
    return _productRepository.validateCoupon(code, subtotalVnd);
  }

  // Các hành động Admin (A03, A04, A05, A08)
  Future<void> upsertProduct(ProductModel product) async {
    await _productRepository.upsertProduct(product);
    await loadProducts();
  }

  Future<void> upsertVariant(String productId, VariantModel variant) async {
    await _productRepository.upsertVariant(productId, variant);
    await loadVariantsForProduct(productId);
    await loadProducts();
  }

  Future<void> upsertBrand(BrandModel brand) async {
    await _productRepository.upsertBrand(brand);
    notifyListeners();
  }

  Future<void> upsertBanner(BannerModel banner) async {
    await _productRepository.upsertBanner(banner);
    notifyListeners();
  }
}
