import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/constants/firestore_collections.dart';
import '../local/local_file_storage_service.dart';
import '../models/banner_model.dart';
import '../models/brand_model.dart';
import '../models/coupon_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/variant_model.dart';

class ProductRepository {
  final LocalFileStorageService _localStorage;

  ProductRepository({LocalFileStorageService? localStorage})
    : _localStorage = localStorage ?? LocalFileStorageService();

  static final List<BrandModel> _brands = [
    const BrandModel(
      id: 'apple',
      name: 'Apple',
      slug: 'apple',
      origin: 'Cupertino, USA',
    ),
    const BrandModel(
      id: 'samsung',
      name: 'Samsung',
      slug: 'samsung',
      origin: 'Seoul, Korea',
    ),
    const BrandModel(
      id: 'xiaomi',
      name: 'Xiaomi',
      slug: 'xiaomi',
      origin: 'Beijing, China',
    ),
    const BrandModel(
      id: 'oppo',
      name: 'OPPO',
      slug: 'oppo',
      origin: 'Shenzhen, China',
    ),
    const BrandModel(
      id: 'accessories',
      name: 'Phụ kiện',
      slug: 'accessories',
      origin: 'Chính hãng',
    ),
  ];

  static final List<BannerModel> _banners = [
    const BannerModel(
      id: 'banner_ip16pro',
      badge: 'FLAGSHIP 2026 • VN/A',
      title: 'iPhone 16 Pro Max Titan Sa Mạc',
      subtitle: 'Chip A18 Pro • Quay 4K 120fps Dolby Vision • Sẵn hàng đủ màu',
      targetProductId: 'iphone_16_pro_max',
      sortOrder: 1,
    ),
    const BannerModel(
      id: 'banner_s25ultra',
      badge: 'GALAXY AI • SNAPDRAGON 8 ELITE',
      title: 'Samsung Galaxy S25 Ultra 5G',
      subtitle: 'Khung viền Titanium • Camera 200MP Zoom Quang 10x',
      targetProductId: 'samsung_s25_ultra',
      sortOrder: 2,
    ),
    const BannerModel(
      id: 'banner_voucher',
      badge: 'ƯU ĐÃI ĐỒ ÁN PRM393',
      title: 'Nhập mã SMART500 Giảm Ngay 500.000₫',
      subtitle: 'Áp dụng cho mọi đơn hàng điện thoại từ 15.000.000₫',
      targetProductId: 'iphone_16',
      sortOrder: 3,
    ),
  ];

  static final List<CouponModel> _coupons = [
    const CouponModel(
      code: 'SMART500',
      description: 'Giảm 500.000₫ cho đơn từ 15.000.000₫',
      discountVnd: 500000,
      minOrderVnd: 15000000,
    ),
    const CouponModel(
      code: 'PRM393',
      description: 'Giảm 200.000₫ kỷ niệm môn PRM393',
      discountVnd: 200000,
      minOrderVnd: 1000000,
    ),
    const CouponModel(
      code: 'FREESHIP',
      description: 'Miễn phí vận chuyển 30.000₫',
      discountVnd: 30000,
      minOrderVnd: 10000,
    ),
  ];

  static final ProductModel _payosTestProduct = ProductModel(
    id: 'payos_test_10k',
    name: 'Miếng Dán Cường Lực SmartStore (Test PayOS 10.000₫)',
    slug: 'mieng-dan-cuong-luc-test-payos-10k',
    brandId: 'Phụ kiện',
    categoryId: 'accessories',
    description:
        'Sản phẩm mệnh giá 10.000₫ (Miễn phí vận chuyển) dùng để kiểm thử thanh toán chuyển khoản thực tế VietQR qua cổng PayOS.',
    priceFromVnd: 10000,
    specs: const {
      'Loại sản phẩm': 'Phụ kiện bảo vệ màn hình • Test PayOS',
      'Mệnh giá': '10.000₫ (Free Ship)',
      'Thanh toán': 'Hỗ trợ VietQR PayOS & COD',
    },
    isFeatured: true,
    soldCount: 250,
    ratingAvg: 5.0,
    reviewCount: 42,
    ramOptions: const [0],
    storageOptions: const [0],
    defaultColorHex: '#10B981',
    createdAt: DateTime(2026, 10, 26),
  );

  static const VariantModel _payosTestVariant = VariantModel(
    id: 'payos_10k_std',
    sku: 'PAYOS-TEST-10K',
    color: 'Trong Suốt (Tiêu chuẩn)',
    colorHex: '#10B981',
    ramGB: 0,
    storageGB: 0,
    priceVnd: 10000,
    stock: 99,
  );

  static final List<ProductModel> _products = [
    ProductModel(
      id: 'iphone_16_pro_max',
      name: 'iPhone 16 Pro Max Chính Hãng VN/A',
      slug: 'iphone-16-pro-max',
      brandId: 'Apple',
      categoryId: 'smartphones',
      description: 'Tuyệt tác khung viền Titan cấp độ 5, màn hình 6.9 inch Super Retina XDR lớn nhất lịch sử, chip A18 Pro tiến trình 3nm thế hệ 2 và nút Điều khiển Camera chuyên nghiệp.',
      priceFromVnd: 31990000,
      specs: const {
        'Màn hình': '6.9 inch Super Retina XDR ProMotion 120Hz',
        'Chip xử lý': 'Apple A18 Pro (6 nhân GPU)',
        'Camera': '48MP Fusion + 48MP Ultra Wide + 12MP Tele 5x',
        'Pin & Sạc': '4685 mAh • Sạc nhanh MagSafe 25W',
        'Chất liệu': 'Khung Titan cấp 5 • Ceramic Shield thế hệ mới',
      },
      isFeatured: true,
      soldCount: 128,
      ratingAvg: 4.9,
      reviewCount: 54,
      ramOptions: const [8],
      storageOptions: const [256, 512, 1024],
      defaultColorHex: '#C5B4A5',
      createdAt: DateTime(2026, 10, 20),
    ),
    _payosTestProduct,
    ProductModel(
      id: 'iphone_16',
      name: 'iPhone 16 Chính Hãng VN/A',
      slug: 'iphone-16',
      brandId: 'Apple',
      categoryId: 'smartphones',
      description: 'Điện thoại Apple iPhone 16 với chip A18 mạnh mẽ vượt trội, cụm Camera Fusion 48MP chụp cận cảnh Macro sắc nét, nút Tác Vụ (Action Button) và thời lượng pin ấn tượng.',
      priceFromVnd: 18990000,
      specs: const {
        'Màn hình': '6.1 inch Super Retina XDR OLED',
        'Chip xử lý': 'Apple A18 (3nm)',
        'Camera': '48MP Fusion + 12MP Ultra Wide',
        'Pin & Sạc': '3561 mAh • MagSafe 25W',
        'Kháng nước': 'IP68 (ở độ sâu 6m trong 30 phút)',
      },
      isFeatured: true,
      soldCount: 96,
      ratingAvg: 4.9,
      reviewCount: 38,
      ramOptions: const [8],
      storageOptions: const [128, 256, 512],
      defaultColorHex: '#4F6DF5',
      createdAt: DateTime(2026, 10, 18),
    ),
    ProductModel(
      id: 'samsung_s25_ultra',
      name: 'Samsung Galaxy S25 Ultra 5G',
      slug: 'samsung-galaxy-s25-ultra',
      brandId: 'Samsung',
      categoryId: 'smartphones',
      description: 'Đỉnh cao quyền năng Galaxy AI đi kèm bút S-Pen tích hợp, khung viền Titanium bo cong công thái học và hệ thống Quad Telephoto 200MP.',
      priceFromVnd: 29990000,
      specs: const {
        'Màn hình': '6.8 inch Dynamic AMOLED 2X QHD+ 120Hz',
        'Chip xử lý': 'Snapdragon 8 Elite for Galaxy',
        'Camera': '200MP Chính + 50MP Ultra Wide + 50MP Tele 5x',
        'Pin & Sạc': '5000 mAh • Sạc siêu nhanh 45W',
        'Đặc biệt': 'Tích hợp bút cảm ứng S-Pen & Galaxy AI',
      },
      isFeatured: true,
      soldCount: 84,
      ratingAvg: 4.8,
      reviewCount: 31,
      ramOptions: const [12, 16],
      storageOptions: const [256, 512, 1024],
      defaultColorHex: '#8E8E93',
      createdAt: DateTime(2026, 10, 19),
    ),
    ProductModel(
      id: 'samsung_s25',
      name: 'Samsung Galaxy S25 5G',
      slug: 'samsung-galaxy-s25',
      brandId: 'Samsung',
      categoryId: 'smartphones',
      description: 'Thiết kế nhỏ gọn đẳng cấp, màn hình viền siêu mỏng 120Hz kết hợp vi xử lý Snapdragon 8 Elite mạnh mẽ và bộ công cụ Galaxy AI tiếng Việt.',
      priceFromVnd: 20990000,
      specs: const {
        'Màn hình': '6.2 inch Dynamic AMOLED 2X FHD+ 120Hz',
        'Chip xử lý': 'Snapdragon 8 Elite for Galaxy',
        'Camera': '50MP OIS + 12MP Ultra Wide + 10MP Tele 3x',
        'Pin & Sạc': '4000 mAh • Sạc nhanh 25W',
        'Kháng nước': 'Chuẩn IP68',
      },
      isFeatured: true,
      soldCount: 62,
      ratingAvg: 4.8,
      reviewCount: 22,
      ramOptions: const [12],
      storageOptions: const [256, 512],
      defaultColorHex: '#C0C5CE',
      createdAt: DateTime(2026, 10, 15),
    ),
    ProductModel(
      id: 'xiaomi_15',
      name: 'Xiaomi 15 Leica Summilux 5G',
      slug: 'xiaomi-15',
      brandId: 'Xiaomi',
      categoryId: 'smartphones',
      description: 'Hiệu năng dẫn đầu kết hợp hệ thống ống kính quang học Leica Summilux thế hệ mới, cảm biến Light Fusion 900 và pin Silicon-Carbon 5240mAh.',
      priceFromVnd: 17490000,
      specs: const {
        'Màn hình': '6.36 inch CrystalRes LTPO AMOLED 120Hz',
        'Chip xử lý': 'Snapdragon 8 Elite (3nm)',
        'Camera': 'Bộ 3 camera Leica 50MP (Chính + Tele + Góc rộng)',
        'Pin & Sạc': '5240 mAh • HyperCharge 90W',
        'Hệ điều hành': 'Xiaomi HyperOS 2.0',
      },
      isFeatured: true,
      soldCount: 53,
      ratingAvg: 4.7,
      reviewCount: 19,
      ramOptions: const [12, 16],
      storageOptions: const [256, 512],
      defaultColorHex: '#1F2937',
      createdAt: DateTime(2026, 10, 12),
    ),
    ProductModel(
      id: 'oppo_find_x8',
      name: 'OPPO Find X8 Hasselblad 5G',
      slug: 'oppo-find-x8',
      brandId: 'OPPO',
      categoryId: 'smartphones',
      description: 'Camera tiềm vọng kép Hasselblad chân dung chuyên nghiệp, thiết kế mỏng nhẹ 7.85mm cùng viên pin Silicon-Carbon 5630mAh.',
      priceFromVnd: 19990000,
      specs: const {
        'Màn hình': '6.59 inch AMOLED 1.5K 120Hz 4500 nits',
        'Chip xử lý': 'MediaTek Dimensity 9400 (3nm)',
        'Camera': '3 Camera 50MP Hasselblad + AI Telescope Zoom',
        'Pin & Sạc': '5630 mAh • SuperVOOC 80W + AirVOOC 50W',
        'Kháng nước': 'IP68 & IP69',
      },
      isFeatured: true,
      soldCount: 41,
      ratingAvg: 4.8,
      reviewCount: 15,
      ramOptions: const [12, 16],
      storageOptions: const [256, 512],
      defaultColorHex: '#475569',
      createdAt: DateTime(2026, 10, 10),
    ),
    ProductModel(
      id: 'airpods_pro_2',
      name: 'Tai nghe Apple AirPods Pro 2 USB-C',
      slug: 'airpods-pro-2-usbc',
      brandId: 'Phụ kiện',
      categoryId: 'accessories',
      description: 'Chống ồn chủ động (ANC) gấp 2 lần, âm thanh thích ứng Adaptive Audio, chip Apple H2 và hộp sạc MagSafe cổng USB-C tích hợp loa tìm kiếm.',
      priceFromVnd: 5690000,
      specs: const {
        'Chip âm thanh': 'Apple H2 + Chip U1 trong hộp sạc',
        'Công nghệ': 'Chống ồn ANC • Xuyên âm • Spatial Audio',
        'Thời lượng pin': '6 giờ nghe liên tục • 30 giờ kèm hộp sạc',
        'Cổng sạc': 'USB-C • Sạc không dây MagSafe',
      },
      isFeatured: false,
      soldCount: 110,
      ratingAvg: 4.9,
      reviewCount: 47,
      ramOptions: const [0],
      storageOptions: const [0],
      defaultColorHex: '#F1F5F9',
      createdAt: DateTime(2026, 10, 8),
    ),
    ProductModel(
      id: 'magsafe_charger_25w',
      name: 'Bộ Sạc Không Dây Apple MagSafe 25W',
      slug: 'apple-magsafe-25w',
      brandId: 'Phụ kiện',
      categoryId: 'accessories',
      description: 'Sạc không dây từ tính chuẩn Qi2 công suất 25W thế hệ mới dành cho iPhone 16 Series, nạp 50% pin chỉ trong 30 phút.',
      priceFromVnd: 1190000,
      specs: const {
        'Công suất': 'Sạc nhanh không dây MagSafe 25W (Qi2)',
        'Chiều dài cáp': 'Dây bện dù dài 1 mét (Đầu cắm USB-C)',
        'Tương thích': 'iPhone 12 đến iPhone 16 Series & AirPods',
      },
      isFeatured: false,
      soldCount: 89,
      ratingAvg: 4.8,
      reviewCount: 29,
      ramOptions: const [0],
      storageOptions: const [0],
      defaultColorHex: '#E2E8F0',
      createdAt: DateTime(2026, 10, 5),
    ),
  ];

  static final Map<String, List<VariantModel>> _variants = {
    'iphone_16_pro_max': [
      const VariantModel(
        id: 'ip16pm_256_desert',
        sku: 'IP16PM-256-DST',
        color: 'Titan Sa Mạc',
        colorHex: '#C5B4A5',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 31990000,
        stock: 15,
      ),
      const VariantModel(
        id: 'ip16pm_256_natural',
        sku: 'IP16PM-256-NAT',
        color: 'Titan Tự Nhiên',
        colorHex: '#9A9A96',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 31990000,
        stock: 9,
      ),
      const VariantModel(
        id: 'ip16pm_512_desert',
        sku: 'IP16PM-512-DST',
        color: 'Titan Sa Mạc',
        colorHex: '#C5B4A5',
        ramGB: 8,
        storageGB: 512,
        priceVnd: 37990000,
        stock: 6,
      ),
      const VariantModel(
        id: 'ip16pm_1024_black',
        sku: 'IP16PM-1TB-BLK',
        color: 'Titan Đen',
        colorHex: '#27272A',
        ramGB: 8,
        storageGB: 1024,
        priceVnd: 42990000,
        stock: 3,
      ),
    ],
    'iphone_16': [
      const VariantModel(
        id: 'iphone16_128_black',
        sku: 'IP16-128-BLK',
        color: 'Đen (Black)',
        colorHex: '#1C1C1E',
        ramGB: 8,
        storageGB: 128,
        priceVnd: 18990000,
        stock: 12,
      ),
      const VariantModel(
        id: 'iphone16_256_black',
        sku: 'IP16-256-BLK',
        color: 'Đen (Black)',
        colorHex: '#1C1C1E',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 21990000,
        stock: 7,
      ),
      const VariantModel(
        id: 'iphone16_128_pink',
        sku: 'IP16-128-PNK',
        color: 'Hồng (Pink)',
        colorHex: '#F4A8B8',
        ramGB: 8,
        storageGB: 128,
        priceVnd: 19290000,
        stock: 5,
      ),
      const VariantModel(
        id: 'iphone16_256_ultramarine',
        sku: 'IP16-256-ULT',
        color: 'Xanh Lưu Ly',
        colorHex: '#4F6DF5',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 22290000,
        stock: 8,
      ),
      const VariantModel(
        id: 'iphone16_512_ultramarine',
        sku: 'IP16-512-ULT',
        color: 'Xanh Lưu Ly',
        colorHex: '#4F6DF5',
        ramGB: 8,
        storageGB: 512,
        priceVnd: 26990000,
        stock: 0,
      ),
    ],
    'samsung_s25_ultra': [
      const VariantModel(
        id: 's25u_256_gray',
        sku: 'S25U-256-GRY',
        color: 'Xám Titan',
        colorHex: '#8E8E93',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 29990000,
        stock: 11,
      ),
      const VariantModel(
        id: 's25u_512_black',
        sku: 'S25U-512-BLK',
        color: 'Đen Titan',
        colorHex: '#1E293B',
        ramGB: 12,
        storageGB: 512,
        priceVnd: 33490000,
        stock: 6,
      ),
      const VariantModel(
        id: 's25u_1024_blue',
        sku: 'S25U-1TB-BLU',
        color: 'Xanh Titan',
        colorHex: '#3B82F6',
        ramGB: 16,
        storageGB: 1024,
        priceVnd: 38990000,
        stock: 4,
      ),
    ],
    'samsung_s25': [
      const VariantModel(
        id: 's25_256_silver',
        sku: 'S25-256-SLV',
        color: 'Bạc Titan',
        colorHex: '#C0C5CE',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 20990000,
        stock: 10,
      ),
      const VariantModel(
        id: 's25_512_navy',
        sku: 'S25-512-NVY',
        color: 'Xanh Navy',
        colorHex: '#1E3A8A',
        ramGB: 12,
        storageGB: 512,
        priceVnd: 23990000,
        stock: 4,
      ),
    ],
    'xiaomi_15': [
      const VariantModel(
        id: 'xm15_256_black',
        sku: 'XM15-256-BLK',
        color: 'Đen Tuyền',
        colorHex: '#1F2937',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 17490000,
        stock: 9,
      ),
      const VariantModel(
        id: 'xm15_512_green',
        sku: 'XM15-512-GRN',
        color: 'Xanh Ngọc Bích',
        colorHex: '#10B981',
        ramGB: 16,
        storageGB: 512,
        priceVnd: 19990000,
        stock: 5,
      ),
    ],
    'oppo_find_x8': [
      const VariantModel(
        id: 'findx8_256_gray',
        sku: 'FX8-256-GRY',
        color: 'Xám Tinh Tú',
        colorHex: '#475569',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 19990000,
        stock: 8,
      ),
      const VariantModel(
        id: 'findx8_512_pink',
        sku: 'FX8-512-PNK',
        color: 'Hồng Vỏ Sò',
        colorHex: '#F9A8D4',
        ramGB: 16,
        storageGB: 512,
        priceVnd: 22490000,
        stock: 6,
      ),
    ],
    'airpods_pro_2': [
      const VariantModel(
        id: 'airpods_pro2_white',
        sku: 'APP2-USBC-WHT',
        color: 'Trắng (USB-C)',
        colorHex: '#F8FAFC',
        ramGB: 0,
        storageGB: 0,
        priceVnd: 5690000,
        stock: 20,
      ),
    ],
    'magsafe_charger_25w': [
      const VariantModel(
        id: 'magsafe_25w_1m',
        sku: 'MGSF-25W-1M',
        color: 'Trắng Bạc (1m)',
        colorHex: '#E2E8F0',
        ramGB: 0,
        storageGB: 0,
        priceVnd: 1190000,
        stock: 25,
      ),
    ],
    'payos_test_10k': [_payosTestVariant],
  };

  static final Map<String, List<ReviewModel>> _reviews = {
    'iphone_16_pro_max': [
      ReviewModel(
        id: 'rev_1',
        productId: 'iphone_16_pro_max',
        userId: 'cust_01',
        userName: 'Nguyễn Văn A',
        rating: 5,
        comment: 'Màu Titan Sa Mạc ngoài đời cực sang, màn hình 6.9 inch viền siêu mỏng, giao hàng nhanh!',
        createdAt: DateTime(2026, 10, 22),
      ),
      ReviewModel(
        id: 'rev_2',
        productId: 'iphone_16_pro_max',
        userId: 'cust_02',
        userName: 'Trần Thị Bích Ngọc',
        rating: 5,
        comment: 'Máy chính hãng VN/A nguyên seal, nút Camera Control rất tiện khi chụp ảnh.',
        createdAt: DateTime(2026, 10, 24),
      ),
    ],
    'iphone_16': [
      ReviewModel(
        id: 'rev_3',
        productId: 'iphone_16',
        userId: 'cust_01',
        userName: 'Lê Minh Tuấn',
        rating: 5,
        comment: 'Màu Xanh Lưu Ly rất đẹp, pin trâu hơn đời trước nhiều, đóng gói kỹ.',
        createdAt: DateTime(2026, 10, 21),
      ),
    ],
  };

  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  List<BrandModel> getBrands({bool includeInactive = false}) {
    if (includeInactive) return List.unmodifiable(_brands);
    return _brands.where((b) => b.isActive).toList();
  }

  List<BannerModel> getBanners({bool includeInactive = false}) {
    final list = includeInactive
        ? List<BannerModel>.from(_banners)
        : _banners.where((b) => b.isActive).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<CouponModel> getCoupons() => List.unmodifiable(_coupons);

  CouponModel? validateCoupon(String code, int subtotalVnd) {
    final cleaned = code.trim().toUpperCase();
    for (final c in _coupons) {
      if (c.code.toUpperCase() == cleaned &&
          c.isActive &&
          subtotalVnd >= c.minOrderVnd) {
        return c;
      }
    }
    return null;
  }

  /// Đẩy toàn bộ dữ liệu mẫu lên Cloud Firestore (project-prm393-dc768)
  Future<void> seedDemoDataToFirestore() async {
    if (!_isFirebaseReady) return;
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    for (final brand in _brands) {
      batch.set(
        db.collection(FirestoreCollections.brands).doc(brand.id),
        brand.toJson(),
      );
    }

    for (final banner in _banners) {
      batch.set(
        db.collection(FirestoreCollections.banners).doc(banner.id),
        banner.toJson(),
      );
    }

    for (final product in _products) {
      final prodRef = db
          .collection(FirestoreCollections.products)
          .doc(product.id);
      batch.set(prodRef, {
        ...product.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      final variants = _variants[product.id] ?? [];
      for (final variant in variants) {
        final varRef = prodRef
            .collection(FirestoreCollections.variants)
            .doc(variant.id);
        batch.set(varRef, variant.toJson());
      }
    }

    await batch.commit();
  }

  Future<List<ProductModel>> getProducts({
    String? brandFilter,
    bool includeInactive = false,
  }) async {
    List<ProductModel> result = List<ProductModel>.from(_products);

    if (_isFirebaseReady) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(FirestoreCollections.products)
            .get();
        if (snapshot.docs.isEmpty) {
          await seedDemoDataToFirestore();
        } else {
          result = snapshot.docs
              .map((doc) => ProductModel.fromJson(doc.id, doc.data()))
              .toList();
          if (!result.any((p) => p.id == _payosTestProduct.id)) {
            result.add(_payosTestProduct);
            _variants[_payosTestProduct.id] = [_payosTestVariant];
            try {
              final prodRef = FirebaseFirestore.instance
                  .collection(FirestoreCollections.products)
                  .doc(_payosTestProduct.id);
              await prodRef.set({
                ..._payosTestProduct.toJson(),
                'createdAt': FieldValue.serverTimestamp(),
              });
              await prodRef
                  .collection(FirestoreCollections.variants)
                  .doc(_payosTestVariant.id)
                  .set(_payosTestVariant.toJson());
            } catch (_) {}
          }
          _products
            ..clear()
            ..addAll(result);
          for (final doc in snapshot.docs) {
            final variants = await doc.reference
                .collection(FirestoreCollections.variants)
                .get();
            _variants[doc.id] = variants.docs
                .map(
                  (variant) =>
                      VariantModel.fromJson(variant.id, variant.data()),
                )
                .toList();
          }
        }
      } catch (_) {}
    } else if (ConnectivityService.offlineSimulationEnabled) {
      final cached = await _localStorage.loadCatalogCache();
      if (cached.isNotEmpty) {
        result = cached
            .map((data) => ProductModel.fromJson(data['id'].toString(), data))
            .toList();
      }
    }

    // Lưu cache danh mục xuống catalog_cache.json phục vụ F23 Offline Mode
    await _localStorage.saveCatalogCache(
      result.map((p) => {'id': p.id, ...p.toJson()}).toList(),
    );

    if (!includeInactive) {
      result = result.where((p) => p.isActive).toList();
    }

    if (brandFilter == null || brandFilter.isEmpty || brandFilter == 'Tất cả') {
      return result;
    }
    return result
        .where((p) => p.brandId.toLowerCase() == brandFilter.toLowerCase())
        .toList();
  }

  Future<ProductModel?> getProductById(String productId) async {
    for (final p in _products) {
      if (p.id == productId) return p;
    }
    return _products.isNotEmpty ? _products.first : null;
  }

  Future<List<VariantModel>> getVariantsByProductId(String productId) async {
    return List<VariantModel>.from(_variants[productId] ?? []);
  }

  List<VariantModel> getCachedVariants(String productId) =>
      List<VariantModel>.unmodifiable(_variants[productId] ?? []);

  /// S02: Lấy trực tiếp biến thể để xác minh giá & tồn kho khi Checkout
  VariantModel? findVariantById(String productId, String variantId) {
    final list = _variants[productId] ?? [];
    for (final v in list) {
      if (v.id == variantId) return v;
    }
    for (final entry in _variants.entries) {
      for (final v in entry.value) {
        if (v.id == variantId) return v;
      }
    }
    return null;
  }

  /// Trừ hoặc hoàn tồn kho nguyên tử (S02 / F16 / A06)
  Future<void> adjustVariantStock(
    String productId,
    String variantId,
    int delta, {
    bool syncCloud = true,
  }) async {
    final list = _variants[productId];
    if (list == null) return;
    final idx = list.indexWhere((v) => v.id == variantId);
    if (idx < 0) return;

    final updatedStock = list[idx].stock + delta;
    if (updatedStock < 0) {
      throw StateError('Không đủ tồn kho cho $variantId');
    }
    list[idx] = list[idx].copyWith(stock: updatedStock);

    if (_isFirebaseReady && syncCloud) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.products)
            .doc(productId)
            .collection(FirestoreCollections.variants)
            .doc(variantId)
            .update({'stock': updatedStock});
      } catch (_) {}
    }
  }

  void recordSale(String productId, int quantity) {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index >= 0) {
      _products[index] = _products[index].copyWith(
        soldCount: _products[index].soldCount + quantity,
      );
    }
  }

  /// F22: Lấy danh sách đánh giá của sản phẩm
  List<ReviewModel> getReviewsForProduct(String productId) {
    return List.unmodifiable(_reviews[productId] ?? []);
  }

  /// F22: Khách hàng gửi đánh giá sao & bình luận
  Future<void> addReview(ReviewModel review) async {
    final list = _reviews.putIfAbsent(review.productId, () => []);
    list.insert(0, review);

    final pIdx = _products.indexWhere((p) => p.id == review.productId);
    if (pIdx >= 0) {
      final totalScore = list.fold<int>(0, (total, r) => total + r.rating);
      final avg = totalScore / list.length;
      _products[pIdx] = _products[pIdx].copyWith(
        ratingAvg: double.parse(avg.toStringAsFixed(1)),
        reviewCount: list.length,
      );
    }

    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.products)
            .doc(review.productId)
            .collection(FirestoreCollections.reviews)
            .doc(review.id)
            .set(review.toJson());
      } catch (_) {}
    }
  }

  /// A03: Admin thêm hoặc cập nhật sản phẩm
  Future<void> upsertProduct(ProductModel product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
    } else {
      _products.insert(0, product);
      _variants.putIfAbsent(product.id, () => []);
    }

    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.products)
            .doc(product.id)
            .set(product.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// A04: Admin thêm hoặc cập nhật biến thể SKU (Màu, RAM, ROM, Giá, Tồn kho)
  Future<void> upsertVariant(String productId, VariantModel variant) async {
    final list = _variants.putIfAbsent(productId, () => []);
    final idx = list.indexWhere((v) => v.id == variant.id);
    if (idx >= 0) {
      list[idx] = variant;
    } else {
      list.add(variant);
    }

    // Cập nhật priceFromVnd nhỏ nhất cho sản phẩm
    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx >= 0 && list.isNotEmpty) {
      final minPrice = list
          .map((v) => v.priceVnd)
          .reduce((a, b) => a < b ? a : b);
      final ramOptions = list.map((v) => v.ramGB).toSet().toList()..sort();
      final storageOptions = list.map((v) => v.storageGB).toSet().toList()
        ..sort();
      _products[pIdx] = _products[pIdx].copyWith(
        priceFromVnd: minPrice,
        ramOptions: ramOptions,
        storageOptions: storageOptions,
      );
    }

    if (_isFirebaseReady) {
      try {
        final prodRef = FirebaseFirestore.instance
            .collection(FirestoreCollections.products)
            .doc(productId);
        await prodRef
            .collection(FirestoreCollections.variants)
            .doc(variant.id)
            .set(variant.toJson(), SetOptions(merge: true));
        if (pIdx >= 0) {
          await prodRef.set({
            'priceFromVnd': _products[pIdx].priceFromVnd,
            'ramOptions': _products[pIdx].ramOptions,
            'storageOptions': _products[pIdx].storageOptions,
          }, SetOptions(merge: true));
        }
      } catch (_) {}
    }
  }

  /// A05: Admin thêm/sửa thương hiệu
  Future<void> upsertBrand(BrandModel brand) async {
    final idx = _brands.indexWhere((b) => b.id == brand.id);
    if (idx >= 0) {
      _brands[idx] = brand;
    } else {
      _brands.add(brand);
    }
    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.brands)
            .doc(brand.id)
            .set(brand.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// A08: Admin thêm/sửa/ẩn hiện Banner trang chủ
  Future<void> upsertBanner(BannerModel banner) async {
    final idx = _banners.indexWhere((b) => b.id == banner.id);
    if (idx >= 0) {
      _banners[idx] = banner;
    } else {
      _banners.add(banner);
    }
    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.banners)
            .doc(banner.id)
            .set(banner.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
  }
}
