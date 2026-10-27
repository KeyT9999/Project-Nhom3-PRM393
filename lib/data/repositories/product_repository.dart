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
    description: 'Sản phẩm 10.000₫ dùng để kiểm thử thanh toán VietQR qua PayOS.',
    priceFromVnd: 10000,
    specs: const {
      'Loại sản phẩm': 'Phụ kiện bảo vệ màn hình • Test PayOS',
      'Mệnh giá': '10.000₫ (Free Ship)',
      'Thanh toán': 'Hỗ trợ VietQR PayOS & COD',
    },
    isFeatured: false,
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
      description: 'Màn hình 6.9 inch Super Retina XDR 120Hz, chip A18 Pro, khung Titan, camera 48MP kèm tele 5x.',
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
      description: 'Màn hình 6.1 inch Super Retina XDR OLED, chip A18, camera Fusion 48MP, kháng nước IP68.',
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
      description: 'Màn hình 6.8 inch Dynamic AMOLED 2X 120Hz, chip Snapdragon 8 Elite, camera chính 200MP, pin 5000 mAh, có bút S-Pen.',
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
      description: 'Màn hình 6.2 inch Dynamic AMOLED 2X 120Hz, chip Snapdragon 8 Elite, camera chính 50MP, pin 4000 mAh, kháng nước IP68.',
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
      description: 'Màn hình 6.36 inch AMOLED 120Hz, chip Snapdragon 8 Elite, bộ ba camera Leica 50MP, pin 5240 mAh, sạc 90W.',
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
      description: 'Màn hình 6.59 inch AMOLED 120Hz, chip Dimensity 9400, ba camera 50MP Hasselblad, pin 5630 mAh, kháng nước IP68 và IP69.',
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
      description: 'Tai nghe chống ồn chủ động, chip H2, hộp sạc USB-C hỗ trợ MagSafe, nghe liên tục 6 giờ.',
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
      description: 'Sạc không dây MagSafe 25W (Qi2), cáp dài 1 m đầu USB-C, dùng cho iPhone 12 đến iPhone 16 và AirPods.',
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
    ProductModel(
      id: 'iphone_16_pro',
      name: 'iPhone 16 Pro Chính Hãng VN/A',
      slug: 'iphone-16-pro',
      brandId: 'Apple',
      categoryId: 'smartphones',
      description: 'Màn hình 6.3 inch Super Retina XDR 120Hz, chip A18 Pro, khung Titan, camera 48MP kèm tele 5x.',
      priceFromVnd: 28490000,
      specs: const {
        'Màn hình': '6.3 inch Super Retina XDR ProMotion 120Hz',
        'Chip xử lý': 'Apple A18 Pro (6 nhân GPU)',
        'Camera': '48MP Fusion + 48MP Ultra Wide + 12MP Tele 5x',
        'Pin & Sạc': '3582 mAh • Sạc nhanh MagSafe 25W',
        'Chất liệu': 'Khung Titan cấp 5 • Ceramic Shield thế hệ 2',
      },
      isFeatured: true,
      soldCount: 104,
      ratingAvg: 4.9,
      reviewCount: 46,
      ramOptions: const [8],
      storageOptions: const [128, 256, 512, 1024],
      defaultColorHex: '#C5B4A5',
      createdAt: DateTime(2026, 10, 19),
    ),
    ProductModel(
      id: 'iphone_16_plus',
      name: 'iPhone 16 Plus Chính Hãng VN/A',
      slug: 'iphone-16-plus',
      brandId: 'Apple',
      categoryId: 'smartphones',
      description: 'Màn hình 6.7 inch Super Retina XDR OLED, chip A18, camera Fusion 48MP, có nút Camera Control và Action Button.',
      priceFromVnd: 22990000,
      specs: const {
        'Màn hình': '6.7 inch Super Retina XDR OLED',
        'Chip xử lý': 'Apple A18 (3nm)',
        'Camera': '48MP Fusion + 12MP Ultra Wide',
        'Pin & Sạc': '4674 mAh • Thời lượng pin ấn tượng nhất dòng iPhone 16',
        'Tính năng': 'Nút Điều Khiển Camera • Action Button đa năng',
      },
      isFeatured: true,
      soldCount: 88,
      ratingAvg: 4.8,
      reviewCount: 34,
      ramOptions: const [8],
      storageOptions: const [128, 256, 512],
      defaultColorHex: '#4F6DF5',
      createdAt: DateTime(2026, 10, 17),
    ),
    ProductModel(
      id: 'iphone_15',
      name: 'iPhone 15 Chính Hãng VN/A',
      slug: 'iphone-15',
      brandId: 'Apple',
      categoryId: 'smartphones',
      description: 'Màn hình 6.1 inch OLED có Dynamic Island, chip A16 Bionic, camera chính 48MP, cổng USB-C, kháng nước IP68.',
      priceFromVnd: 16490000,
      specs: const {
        'Màn hình': '6.1 inch Super Retina XDR OLED với Dynamic Island',
        'Chip xử lý': 'Apple A16 Bionic (4nm)',
        'Camera': '48MP Main + 12MP Ultra Wide (Zoom quang 2x)',
        'Cổng kết nối': 'USB-C đa dụng',
        'Chống nước': 'IP68 theo tiêu chuẩn IEC 60529',
      },
      isFeatured: false,
      soldCount: 142,
      ratingAvg: 4.8,
      reviewCount: 58,
      ramOptions: const [6, 8],
      storageOptions: const [128, 256],
      defaultColorHex: '#F4A8B8',
      createdAt: DateTime(2026, 10, 5),
    ),
    ProductModel(
      id: 'samsung_s25_plus',
      name: 'Samsung Galaxy S25+ 5G',
      slug: 'samsung-galaxy-s25-plus',
      brandId: 'Samsung',
      categoryId: 'smartphones',
      description: 'Màn hình 6.7 inch Dynamic AMOLED 2X QHD+ 120Hz, chip Snapdragon 8 Elite, pin 4900 mAh, sạc 45W.',
      priceFromVnd: 25990000,
      specs: const {
        'Màn hình': '6.7 inch Dynamic AMOLED 2X QHD+ 120Hz',
        'Chip xử lý': 'Snapdragon 8 Elite for Galaxy (3nm)',
        'Camera': '50MP OIS + 12MP Ultra Wide + 10MP Tele 3x',
        'Pin & Sạc': '4900 mAh • Sạc siêu nhanh 45W',
        'Tính năng': 'Galaxy AI tiếng Việt • Khung Armor Aluminum',
      },
      isFeatured: true,
      soldCount: 71,
      ratingAvg: 4.8,
      reviewCount: 26,
      ramOptions: const [12],
      storageOptions: const [256, 512],
      defaultColorHex: '#1E3A8A',
      createdAt: DateTime(2026, 10, 16),
    ),
    ProductModel(
      id: 'samsung_z_fold6',
      name: 'Samsung Galaxy Z Fold6 5G',
      slug: 'samsung-galaxy-z-fold6',
      brandId: 'Samsung',
      categoryId: 'smartphones',
      description: 'Điện thoại gập với màn hình trong 7.6 inch và màn hình ngoài 6.3 inch, chip Snapdragon 8 Gen 3, kháng nước IP48.',
      priceFromVnd: 41990000,
      specs: const {
        'Màn hình chính': '7.6 inch Dynamic AMOLED 2X 120Hz gập mở',
        'Màn hình phụ': '6.3 inch Dynamic AMOLED 2X 120Hz',
        'Chip xử lý': 'Snapdragon 8 Gen 3 for Galaxy',
        'Camera': '50MP OIS + 12MP Ultra Wide + 10MP Tele 3x',
        'Độ bền': 'Kháng nước bụi IP48 • Kính Gorilla Glass Victus 2',
      },
      isFeatured: true,
      soldCount: 39,
      ratingAvg: 4.9,
      reviewCount: 18,
      ramOptions: const [12, 16],
      storageOptions: const [256, 512, 1024],
      defaultColorHex: '#64748B',
      createdAt: DateTime(2026, 10, 14),
    ),
    ProductModel(
      id: 'samsung_a55',
      name: 'Samsung Galaxy A55 5G',
      slug: 'samsung-galaxy-a55',
      brandId: 'Samsung',
      categoryId: 'smartphones',
      description: 'Màn hình 6.6 inch Super AMOLED 120Hz, chip Exynos 1480, camera chính 50MP, pin 5000 mAh, khung kim loại.',
      priceFromVnd: 8990000,
      specs: const {
        'Màn hình': '6.6 inch Super AMOLED FHD+ 120Hz Vision Booster',
        'Chip xử lý': 'Exynos 1480 8 nhân (GPU Xclipse 530 AMD)',
        'Camera': '50MP OIS Chống rung quang học + 12MP Góc rộng + 5MP Macro',
        'Pin & Sạc': '5000 mAh • Sạc nhanh 25W',
        'Chất liệu': 'Khung viền kim loại nguyên khối • Mặt lưng kính',
      },
      isFeatured: false,
      soldCount: 165,
      ratingAvg: 4.7,
      reviewCount: 62,
      ramOptions: const [8, 12],
      storageOptions: const [128, 256],
      defaultColorHex: '#93C5FD',
      createdAt: DateTime(2026, 10, 11),
    ),
    ProductModel(
      id: 'xiaomi_15_pro',
      name: 'Xiaomi 15 Pro Leica Summilux 5G',
      slug: 'xiaomi-15-pro',
      brandId: 'Xiaomi',
      categoryId: 'smartphones',
      description: 'Màn hình 6.73 inch 2K AMOLED 120Hz, chip Snapdragon 8 Elite, ba camera Leica 50MP, pin 6100 mAh, sạc 90W có dây.',
      priceFromVnd: 21990000,
      specs: const {
        'Màn hình': '6.73 inch 2K AMOLED LTPO 120Hz 3200 nits',
        'Chip xử lý': 'Snapdragon 8 Elite (3nm thế hệ 2)',
        'Camera': '3 ống kính Leica 50MP (Chính + Siêu rộng + Tiềm vọng 5x)',
        'Pin & Sạc': '6100 mAh Silicon-Carbon • Sạc nhanh 90W có dây, 50W không dây',
        'Hệ điều hành': 'Xiaomi HyperOS 2.0 tối ưu AI',
      },
      isFeatured: true,
      soldCount: 48,
      ratingAvg: 4.8,
      reviewCount: 20,
      ramOptions: const [12, 16],
      storageOptions: const [256, 512, 1024],
      defaultColorHex: '#374151',
      createdAt: DateTime(2026, 10, 13),
    ),
    ProductModel(
      id: 'xiaomi_poco_f6_pro',
      name: 'Xiaomi POCO F6 Pro 5G Flagship Killer',
      slug: 'xiaomi-poco-f6-pro',
      brandId: 'Xiaomi',
      categoryId: 'smartphones',
      description: 'Màn hình 6.67 inch WQHD+ AMOLED 120Hz, chip Snapdragon 8 Gen 2, camera chính 50MP, pin 5000 mAh, sạc 120W.',
      priceFromVnd: 12990000,
      specs: const {
        'Màn hình': '6.67 inch WQHD+ Flow AMOLED 120Hz 4000 nits',
        'Chip xử lý': 'Snapdragon 8 Gen 2 (4nm TSMC)',
        'Camera': '50MP OIS Light Fusion 800 + 8MP Ultra Wide',
        'Tản nhiệt': 'LiquidCool 4.0 buồng hơi IceLoop thế hệ mới',
        'Pin & Sạc': '5000 mAh • Sạc siêu tốc 120W (nạp đầy 19 phút)',
      },
      isFeatured: false,
      soldCount: 92,
      ratingAvg: 4.8,
      reviewCount: 37,
      ramOptions: const [12, 16],
      storageOptions: const [256, 512],
      defaultColorHex: '#18181B',
      createdAt: DateTime(2026, 10, 9),
    ),
    ProductModel(
      id: 'xiaomi_redmi_note_14_pro',
      name: 'Xiaomi Redmi Note 14 Pro+ 5G',
      slug: 'xiaomi-redmi-note-14-pro-plus',
      brandId: 'Xiaomi',
      categoryId: 'smartphones',
      description: 'Màn hình 6.67 inch AMOLED 1.5K 120Hz, chip Snapdragon 7s Gen 3, camera chính 50MP, pin 6200 mAh, kháng nước IP68.',
      priceFromVnd: 8490000,
      specs: const {
        'Màn hình': '6.67 inch AMOLED 1.5K 120Hz cong đối xứng',
        'Chip xử lý': 'Snapdragon 7s Gen 3 (4nm)',
        'Camera': '50MP OIS + 50MP Telephoto 2.5x + 8MP Góc siêu rộng',
        'Pin & Sạc': '6200 mAh Silicon-Carbon • Sạc 90W',
        'Độ bền': 'Kháng nước bụi cao cấp IP68 & IP69K',
      },
      isFeatured: false,
      soldCount: 138,
      ratingAvg: 4.7,
      reviewCount: 51,
      ramOptions: const [8, 12],
      storageOptions: const [128, 256, 512],
      defaultColorHex: '#0284C7',
      createdAt: DateTime(2026, 10, 7),
    ),
    ProductModel(
      id: 'oppo_find_x8_pro',
      name: 'OPPO Find X8 Pro Hasselblad 5G',
      slug: 'oppo-find-x8-pro',
      brandId: 'OPPO',
      categoryId: 'smartphones',
      description: 'Màn hình 6.78 inch AMOLED 120Hz, chip Dimensity 9400, bốn camera 50MP Hasselblad, pin 5910 mAh, kháng nước IP68 và IP69.',
      priceFromVnd: 26990000,
      specs: const {
        'Màn hình': '6.78 inch AMOLED 1.5K Micro-Quad Curved 120Hz',
        'Chip xử lý': 'MediaTek Dimensity 9400 (3nm)',
        'Camera': 'Bộ 4 camera 50MP Hasselblad (2 ống kính tiềm vọng kép 3x & 6x)',
        'Pin & Sạc': '5910 mAh Glacier Battery • Sạc 80W SuperVOOC & 50W AirVOOC',
        'Đặc điểm': 'Phím cảm ứng Quick Button • Kháng nước IP68/IP69',
      },
      isFeatured: true,
      soldCount: 52,
      ratingAvg: 4.9,
      reviewCount: 24,
      ramOptions: const [16],
      storageOptions: const [512, 1024],
      defaultColorHex: '#0F172A',
      createdAt: DateTime(2026, 10, 14),
    ),
    ProductModel(
      id: 'oppo_reno_13_pro',
      name: 'OPPO Reno 13 Pro 5G Chuyên Gia Chân Dung',
      slug: 'oppo-reno-13-pro',
      brandId: 'OPPO',
      categoryId: 'smartphones',
      description: 'Màn hình 6.83 inch AMOLED 120Hz, chip Dimensity 8350, camera chính 50MP, pin 5800 mAh, sạc 80W, kháng nước IP68 và IP69.',
      priceFromVnd: 14490000,
      specs: const {
        'Màn hình': '6.83 inch AMOLED 1.5K 120Hz viền cong siêu mỏng',
        'Chip xử lý': 'MediaTek Dimensity 8350 (4nm)',
        'Camera': '50MP Sony OIS + 50MP Chân dung Tele 3.5x + 8MP Góc rộng',
        'Pin & Sạc': '5800 mAh • SuperVOOC 80W',
        'Tính năng': 'Kháng nước IP68 & IP69 • Chụp ảnh dưới nước Underwater Camera',
      },
      isFeatured: true,
      soldCount: 77,
      ratingAvg: 4.8,
      reviewCount: 29,
      ramOptions: const [12, 16],
      storageOptions: const [256, 512],
      defaultColorHex: '#C084FC',
      createdAt: DateTime(2026, 10, 8),
    ),
    ProductModel(
      id: 'oppo_reno_12_f',
      name: 'OPPO Reno 12 F 5G Đèn Halo Thông Minh',
      slug: 'oppo-reno-12-f',
      brandId: 'OPPO',
      categoryId: 'smartphones',
      description: 'Màn hình 6.67 inch OLED 120Hz, chip Dimensity 6300, camera chính 50MP, pin 5000 mAh, sạc 45W.',
      priceFromVnd: 7990000,
      specs: const {
        'Màn hình': '6.67 inch OLED 120Hz bảo vệ mắt Splash Touch',
        'Chip xử lý': 'MediaTek Dimensity 6300 5G',
        'Camera': '50MP Ultra-Clear + 8MP Góc rộng + 2MP Macro + Đèn Halo Light',
        'Pin & Sạc': '5000 mAh • Sạc nhanh SuperVOOC 45W',
        'Độ bền': 'Cấu trúc chống rơi vỡ chuẩn quân đội All-Round Armour',
      },
      isFeatured: false,
      soldCount: 112,
      ratingAvg: 4.6,
      reviewCount: 38,
      ramOptions: const [8],
      storageOptions: const [128, 256],
      defaultColorHex: '#F59E0B',
      createdAt: DateTime(2026, 10, 6),
    ),
    ProductModel(
      id: 'apple_20w_adapter',
      name: 'Củ Sạc Nhanh Apple 20W Type-C Chính Hãng',
      slug: 'apple-20w-adapter',
      brandId: 'Phụ kiện',
      categoryId: 'accessories',
      description: 'Củ sạc 20W chuẩn Power Delivery, cổng USB-C, dùng cho iPhone 8 đến iPhone 16 và iPad.',
      priceFromVnd: 490000,
      specs: const {
        'Công suất': '20W Chuẩn sạc nhanh Power Delivery (PD)',
        'Cổng kết nối': 'Type-C tiêu chuẩn',
        'Tương thích': 'iPhone 8 đến iPhone 16 Series & iPad',
      },
      isFeatured: false,
      soldCount: 220,
      ratingAvg: 4.9,
      reviewCount: 82,
      ramOptions: const [0],
      storageOptions: const [0],
      defaultColorHex: '#F8FAFC',
      createdAt: DateTime(2026, 10, 4),
    ),
    ProductModel(
      id: 'clear_case_magsafe',
      name: 'Ốp Lưng Trong Suốt Tích Hợp MagSafe Chống Sốc',
      slug: 'clear-case-magsafe',
      brandId: 'Phụ kiện',
      categoryId: 'accessories',
      description: 'Ốp lưng nhựa Polycarbonate trong suốt, hỗ trợ sạc MagSafe, chịu rơi từ độ cao 2 m.',
      priceFromVnd: 350000,
      specs: const {
        'Chất liệu': 'Nhựa Polycarbonate trong suốt chống tia UV',
        'Tính năng': 'Hỗ trợ sạc MagSafe hít chặt 15W-25W',
        'Chống sốc': 'Đạt chuẩn bảo vệ rơi tự do 2 mét',
      },
      isFeatured: false,
      soldCount: 175,
      ratingAvg: 4.8,
      reviewCount: 64,
      ramOptions: const [0],
      storageOptions: const [0],
      defaultColorHex: '#E2E8F0',
      createdAt: DateTime(2026, 10, 3),
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
    'iphone_16_pro': [
      const VariantModel(
        id: 'ip16p_128_natural',
        sku: 'IP16P-128-NAT',
        color: 'Titan Tự Nhiên',
        colorHex: '#9A9A96',
        ramGB: 8,
        storageGB: 128,
        priceVnd: 28490000,
        stock: 8,
      ),
      const VariantModel(
        id: 'ip16p_256_desert',
        sku: 'IP16P-256-DST',
        color: 'Titan Sa Mạc',
        colorHex: '#C5B4A5',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 31490000,
        stock: 12,
      ),
      const VariantModel(
        id: 'ip16p_512_black',
        sku: 'IP16P-512-BLK',
        color: 'Titan Đen',
        colorHex: '#27272A',
        ramGB: 8,
        storageGB: 512,
        priceVnd: 37490000,
        stock: 4,
      ),
      const VariantModel(
        id: 'ip16p_1024_white',
        sku: 'IP16P-1TB-WHT',
        color: 'Titan Trắng',
        colorHex: '#F5F5F7',
        ramGB: 8,
        storageGB: 1024,
        priceVnd: 42490000,
        stock: 0,
      ),
    ],
    'iphone_16_plus': [
      const VariantModel(
        id: 'ip16pls_128_teal',
        sku: 'IP16PLS-128-TEL',
        color: 'Xanh Mòng Két',
        colorHex: '#2DD4BF',
        ramGB: 8,
        storageGB: 128,
        priceVnd: 22990000,
        stock: 10,
      ),
      const VariantModel(
        id: 'ip16pls_256_ultramarine',
        sku: 'IP16PLS-256-ULT',
        color: 'Xanh Lưu Ly',
        colorHex: '#4F6DF5',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 25990000,
        stock: 6,
      ),
      const VariantModel(
        id: 'ip16pls_512_black',
        sku: 'IP16PLS-512-BLK',
        color: 'Đen (Black)',
        colorHex: '#1C1C1E',
        ramGB: 8,
        storageGB: 512,
        priceVnd: 30990000,
        stock: 3,
      ),
    ],
    'iphone_15': [
      const VariantModel(
        id: 'ip15_128_green',
        sku: 'IP15-128-GRN',
        color: 'Xanh Lá Pastel',
        colorHex: '#A7F3D0',
        ramGB: 6,
        storageGB: 128,
        priceVnd: 16490000,
        stock: 15,
      ),
      const VariantModel(
        id: 'ip15_128_pink',
        sku: 'IP15-128-PNK',
        color: 'Hồng Nhạt',
        colorHex: '#F4A8B8',
        ramGB: 6,
        storageGB: 128,
        priceVnd: 16490000,
        stock: 10,
      ),
      const VariantModel(
        id: 'ip15_256_black',
        sku: 'IP15-256-BLK',
        color: 'Đen (Black)',
        colorHex: '#1C1C1E',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 19490000,
        stock: 7,
      ),
    ],
    'samsung_s25_plus': [
      const VariantModel(
        id: 's25p_256_gray',
        sku: 'S25P-256-GRY',
        color: 'Xám Titan',
        colorHex: '#8E8E93',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 25990000,
        stock: 8,
      ),
      const VariantModel(
        id: 's25p_512_navy',
        sku: 'S25P-512-NVY',
        color: 'Xanh Navy',
        colorHex: '#1E3A8A',
        ramGB: 12,
        storageGB: 512,
        priceVnd: 28990000,
        stock: 5,
      ),
    ],
    'samsung_z_fold6': [
      const VariantModel(
        id: 'zfold6_256_silver',
        sku: 'ZF6-256-SLV',
        color: 'Xám Bạc (Silver Shadow)',
        colorHex: '#64748B',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 41990000,
        stock: 6,
      ),
      const VariantModel(
        id: 'zfold6_512_navy',
        sku: 'ZF6-512-NVY',
        color: 'Xanh Navy',
        colorHex: '#1E293B',
        ramGB: 12,
        storageGB: 512,
        priceVnd: 45490000,
        stock: 3,
      ),
      const VariantModel(
        id: 'zfold6_1024_black',
        sku: 'ZF6-1TB-BLK',
        color: 'Đen Crafted',
        colorHex: '#0F172A',
        ramGB: 16,
        storageGB: 1024,
        priceVnd: 51990000,
        stock: 0,
      ),
    ],
    'samsung_a55': [
      const VariantModel(
        id: 'a55_128_iceblue',
        sku: 'A55-128-BLU',
        color: 'Xanh Iceblue',
        colorHex: '#93C5FD',
        ramGB: 8,
        storageGB: 128,
        priceVnd: 8990000,
        stock: 25,
      ),
      const VariantModel(
        id: 'a55_256_navy',
        sku: 'A55-256-NVY',
        color: 'Xanh Đen Navy',
        colorHex: '#0F172A',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 9990000,
        stock: 18,
      ),
      const VariantModel(
        id: 'a55_256_lilac',
        sku: 'A55-256-LIC',
        color: 'Tím Lilac',
        colorHex: '#C084FC',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 10490000,
        stock: 12,
      ),
    ],
    'xiaomi_15_pro': [
      const VariantModel(
        id: 'xm15p_256_gray',
        sku: 'XM15P-256-GRY',
        color: 'Xám Titan',
        colorHex: '#374151',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 21990000,
        stock: 8,
      ),
      const VariantModel(
        id: 'xm15p_512_white',
        sku: 'XM15P-512-WHT',
        color: 'Trắng Sứ',
        colorHex: '#F8FAFC',
        ramGB: 16,
        storageGB: 512,
        priceVnd: 24490000,
        stock: 5,
      ),
      const VariantModel(
        id: 'xm15p_1024_green',
        sku: 'XM15P-1TB-GRN',
        color: 'Xanh Lục Bảo',
        colorHex: '#065F46',
        ramGB: 16,
        storageGB: 1024,
        priceVnd: 27990000,
        stock: 2,
      ),
    ],
    'xiaomi_poco_f6_pro': [
      const VariantModel(
        id: 'poco_256_black',
        sku: 'POCO-256-BLK',
        color: 'Đen Midnight',
        colorHex: '#18181B',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 12990000,
        stock: 14,
      ),
      const VariantModel(
        id: 'poco_512_white',
        sku: 'POCO-512-WHT',
        color: 'Trắng Moonlight',
        colorHex: '#F4F4F5',
        ramGB: 16,
        storageGB: 512,
        priceVnd: 14490000,
        stock: 8,
      ),
    ],
    'xiaomi_redmi_note_14_pro': [
      const VariantModel(
        id: 'rdn14p_128_ocean',
        sku: 'RDN14-128-BLU',
        color: 'Xanh Đại Dương',
        colorHex: '#0284C7',
        ramGB: 8,
        storageGB: 128,
        priceVnd: 8490000,
        stock: 20,
      ),
      const VariantModel(
        id: 'rdn14p_256_purple',
        sku: 'RDN14-256-PUR',
        color: 'Tím Cát Tường',
        colorHex: '#A855F7',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 9290000,
        stock: 15,
      ),
      const VariantModel(
        id: 'rdn14p_512_black',
        sku: 'RDN14-512-BLK',
        color: 'Đen Kim Cương',
        colorHex: '#111827',
        ramGB: 12,
        storageGB: 512,
        priceVnd: 10490000,
        stock: 9,
      ),
    ],
    'oppo_find_x8_pro': [
      const VariantModel(
        id: 'findx8p_512_black',
        sku: 'FX8P-512-BLK',
        color: 'Đen Không Gian',
        colorHex: '#0F172A',
        ramGB: 16,
        storageGB: 512,
        priceVnd: 26990000,
        stock: 6,
      ),
      const VariantModel(
        id: 'findx8p_512_white',
        sku: 'FX8P-512-WHT',
        color: 'Trắng Ngọc Trai',
        colorHex: '#F1F5F9',
        ramGB: 16,
        storageGB: 512,
        priceVnd: 26990000,
        stock: 5,
      ),
      const VariantModel(
        id: 'findx8p_1024_black',
        sku: 'FX8P-1TB-BLK',
        color: 'Đen Không Gian',
        colorHex: '#0F172A',
        ramGB: 16,
        storageGB: 1024,
        priceVnd: 30990000,
        stock: 2,
      ),
    ],
    'oppo_reno_13_pro': [
      const VariantModel(
        id: 'reno13p_256_purple',
        sku: 'R13P-256-PUR',
        color: 'Tím Cánh Bướm',
        colorHex: '#C084FC',
        ramGB: 12,
        storageGB: 256,
        priceVnd: 14490000,
        stock: 11,
      ),
      const VariantModel(
        id: 'reno13p_512_gray',
        sku: 'R13P-512-GRY',
        color: 'Xám Tro Tinh Tế',
        colorHex: '#4B5563',
        ramGB: 16,
        storageGB: 512,
        priceVnd: 16490000,
        stock: 7,
      ),
    ],
    'oppo_reno_12_f': [
      const VariantModel(
        id: 'reno12f_128_orange',
        sku: 'R12F-128-ORG',
        color: 'Cam Hổ Phách',
        colorHex: '#F59E0B',
        ramGB: 8,
        storageGB: 128,
        priceVnd: 7990000,
        stock: 16,
      ),
      const VariantModel(
        id: 'reno12f_256_green',
        sku: 'R12F-256-GRN',
        color: 'Xanh Lá Mạ',
        colorHex: '#10B981',
        ramGB: 8,
        storageGB: 256,
        priceVnd: 8790000,
        stock: 12,
      ),
    ],
    'apple_20w_adapter': [
      const VariantModel(
        id: 'adapter_20w_white',
        sku: 'APL-20W-WHT',
        color: 'Trắng Tiêu Chuẩn',
        colorHex: '#F8FAFC',
        ramGB: 0,
        storageGB: 0,
        priceVnd: 490000,
        stock: 50,
      ),
    ],
    'clear_case_magsafe': [
      const VariantModel(
        id: 'case_magsafe_clear',
        sku: 'CASE-MGSF-CLR',
        color: 'Trong Suốt (Clear)',
        colorHex: '#E2E8F0',
        ramGB: 0,
        storageGB: 0,
        priceVnd: 350000,
        stock: 45,
      ),
    ],
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

  static final List<ProductModel> _initialProducts =
      List<ProductModel>.unmodifiable(_products);
  static final Map<String, List<VariantModel>> _initialVariants =
      Map<String, List<VariantModel>>.unmodifiable(_variants);

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
          // Đảm bảo toàn bộ các sản phẩm và biến thể chuẩn của hệ thống luôn có mặt đầy đủ
          final existingIds = result.map((p) => p.id).toSet();
          for (final initP in _initialProducts) {
            if (!existingIds.contains(initP.id)) {
              result.add(initP);
              try {
                final prodRef = FirebaseFirestore.instance
                    .collection(FirestoreCollections.products)
                    .doc(initP.id);
                prodRef.set({
                  ...initP.toJson(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                final initVars = _initialVariants[initP.id] ?? [];
                for (final v in initVars) {
                  prodRef
                      .collection(FirestoreCollections.variants)
                      .doc(v.id)
                      .set(v.toJson());
                }
              } catch (_) {}
            }
          }
          _products
            ..clear()
            ..addAll(result);
          for (final doc in snapshot.docs) {
            final variants = await doc.reference
                .collection(FirestoreCollections.variants)
                .get();
            if (variants.docs.isNotEmpty) {
              _variants[doc.id] = variants.docs
                  .map(
                    (variant) =>
                        VariantModel.fromJson(variant.id, variant.data()),
                  )
                  .toList();
            }
          }
          for (final entry in _initialVariants.entries) {
            if (!_variants.containsKey(entry.key) ||
                _variants[entry.key]!.isEmpty) {
              _variants[entry.key] = entry.value;
            }
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
