import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tra cứu ảnh sản phẩm trong `assets/images/products/<productId>/`.
///
/// Quy ước tên file (đuôi bất kỳ jpg/png/webp): `main`, `gallery_1..n`,
/// và tùy chọn `color_<tên>` cho ảnh theo màu. Danh sách được lấy từ
/// AssetManifest nên không hardcode đường dẫn hay đuôi file.
class ProductImages extends ChangeNotifier {
  ProductImages({Iterable<String>? assets}) {
    if (assets != null) setAssets(assets);
  }

  static final ProductImages instance = ProductImages();
  static const String prefix = 'assets/images/products/';

  final Map<String, String> _main = {};
  final Map<String, List<_Numbered>> _gallery = {};
  final Map<String, Map<String, String>> _colors = {};
  bool _loaded = false;
  Future<void>? _loading;

  bool get isLoaded => _loaded;

  /// Nạp manifest một lần. Có thể truyền manifest giả khi test.
  Future<void> ensureLoaded({AssetManifest? manifest}) {
    if (_loaded) return Future.value();
    return _loading ??= _load(manifest);
  }

  Future<void> _load(AssetManifest? manifest) async {
    try {
      final m = manifest ?? await AssetManifest.loadFromAssetBundle(rootBundle);
      setAssets(m.listAssets());
    } catch (_) {
      // Không có manifest: coi như chưa có ảnh nào, UI dùng placeholder.
      _loaded = true;
      notifyListeners();
    }
  }

  /// Thay toàn bộ chỉ mục bằng danh sách asset đã cho.
  void setAssets(Iterable<String> assets) {
    _main.clear();
    _gallery.clear();
    _colors.clear();
    for (final path in assets) {
      if (!path.startsWith(prefix)) continue;
      final rest = path.substring(prefix.length).split('/');
      if (rest.length != 2) continue;
      final id = rest[0];
      final file = rest[1];
      final dot = file.lastIndexOf('.');
      if (dot <= 0) continue;
      final base = file.substring(0, dot).toLowerCase();
      if (base == 'main') {
        _main[id] = path;
      } else if (base.startsWith('gallery_')) {
        final n = int.tryParse(base.substring(8));
        if (n != null) (_gallery[id] ??= []).add(_Numbered(n, path));
      } else if (base.startsWith('color_') && base.length > 6) {
        (_colors[id] ??= {})[base.substring(6)] = path;
      }
    }
    for (final list in _gallery.values) {
      list.sort((a, b) => a.n.compareTo(b.n));
    }
    _loaded = true;
    notifyListeners();
  }

  /// Ảnh chính; nếu truyền [color] và có `color_<color>` thì ưu tiên ảnh đó.
  String? main(String productId, {String? color}) {
    if (color != null) {
      final byColor = _colors[productId]?[color.toLowerCase()];
      if (byColor != null) return byColor;
    }
    return _main[productId];
  }

  /// Ảnh gallery theo thứ tự gallery_1, gallery_2, ...
  List<String> gallery(String productId) =>
      [for (final g in _gallery[productId] ?? const <_Numbered>[]) g.path];

  /// main + gallery, dùng cho carousel trang chi tiết.
  List<String> all(String productId, {String? color}) {
    final m = main(productId, color: color);
    return [?m, ...gallery(productId)];
  }

  bool has(String productId) => _main.containsKey(productId);
}

class _Numbered {
  final int n;
  final String path;
  const _Numbered(this.n, this.path);
}
