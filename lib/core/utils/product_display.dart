/// Chuỗi hiển thị cho sản phẩm. Chỉ đổi cách hiển thị, không đổi dữ liệu gốc.
class ProductDisplay {
  ProductDisplay._();

  static final RegExp _vnaSuffix =
      RegExp(r'\s*Chính Hãng VN/A\s*$', caseSensitive: false);

  /// "iPhone 16 Pro Max Chính Hãng VN/A" -> "iPhone 16 Pro Max".
  static String shortName(String name) =>
      name.replaceFirst(_vnaSuffix, '').trim();
}
