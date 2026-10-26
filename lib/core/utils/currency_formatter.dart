import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Định dạng số nguyên VND thành chuỗi tiền tệ chuẩn (VD: 18.990.000 ₫)
  static String formatVnd(int amountVnd) {
    return _vndFormat.format(amountVnd);
  }
}
