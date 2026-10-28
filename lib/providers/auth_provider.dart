import 'package:flutter/foundation.dart';

import '../app/theme/app_colors.dart';
import '../data/models/address_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../core/services/connectivity_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  List<AddressModel> _addresses = [];
  LmThemeType _themeType = LmThemeType.titanium;
  bool _isOfflineSimulated = false;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _initSession();
  }

  Future<void> _initSession() async {
    await _authRepository.restoreSession();
    await loadAddresses();
    notifyListeners();
  }

  UserModel? get currentUser => _authRepository.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => currentUser?.isAdmin ?? false;
  String get activeUserId => currentUser?.uid ?? 'guest';

  LmThemeType get themeType => _themeType;
  LmPalette get palette => AppColors.paletteOf(_themeType);

  bool get isOfflineSimulated => _isOfflineSimulated;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get hasShippingAddress => _addresses.isNotEmpty;

  AddressModel? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  void setThemeType(LmThemeType type) {
    _themeType = type;
    notifyListeners();
  }

  void toggleOfflineSimulation([bool? value]) {
    _isOfflineSimulated = value ?? !_isOfflineSimulated;
    ConnectivityService.offlineSimulationEnabled = _isOfflineSimulated;
    notifyListeners();
  }

  Future<void> loadAddresses() async {
    _addresses = await _authRepository.loadAddresses(activeUserId);
    notifyListeners();
  }

  Future<void> syncAddresses() async {
    if (isAuthenticated) {
      await _authRepository.saveAddresses(activeUserId, _addresses);
    }
  }

  Future<void> addOrUpdateAddress(AddressModel address) async {
    final shouldForceDefault =
        _addresses.isEmpty ||
        (_addresses.length == 1 && _addresses.first.id == address.id);
    final effective = shouldForceDefault && !address.isDefault
        ? AddressModel(
            id: address.id,
            fullName: address.fullName,
            phone: address.phone,
            addressLine: address.addressLine,
            isDefault: true,
          )
        : address;

    if (effective.isDefault) {
      _addresses = _addresses
          .map(
            (a) => AddressModel(
              id: a.id,
              fullName: a.fullName,
              phone: a.phone,
              addressLine: a.addressLine,
              isDefault: false,
            ),
          )
          .toList();
    }

    final idx = _addresses.indexWhere((a) => a.id == effective.id);
    if (idx >= 0) {
      _addresses[idx] = effective;
    } else {
      _addresses.insert(0, effective);
    }
    notifyListeners();
    await _authRepository.saveAddresses(activeUserId, _addresses);
  }

  Future<void> deleteAddress(String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
    if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
      final first = _addresses.first;
      _addresses[0] = AddressModel(
        id: first.id,
        fullName: first.fullName,
        phone: first.phone,
        addressLine: first.addressLine,
        isDefault: true,
      );
    }
    notifyListeners();
    await _authRepository.saveAddresses(activeUserId, _addresses);
  }

  Future<void> setDefaultAddress(String addressId) async {
    _addresses = _addresses
        .map(
          (a) => AddressModel(
            id: a.id,
            fullName: a.fullName,
            phone: a.phone,
            addressLine: a.addressLine,
            isDefault: a.id == addressId,
          ),
        )
        .toList();
    notifyListeners();
    await _authRepository.saveAddresses(activeUserId, _addresses);
  }

  /// F01: Đăng ký tài khoản
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _authRepository.registerWithEmail(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
    await loadAddresses();
    notifyListeners();
  }

  /// F02: Đăng nhập Email/Password
  Future<void> signIn(String email, String password) async {
    await _authRepository.signInWithEmail(email, password);
    await loadAddresses();
    notifyListeners();
  }

  /// F02: Đăng nhập Google
  Future<void> signInWithGoogle() async {
    await _authRepository.signInWithGoogle();
    await loadAddresses();
    notifyListeners();
  }

  /// F03: Gửi email khôi phục mật khẩu
  Future<void> sendPasswordReset(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  /// F17: Cập nhật hồ sơ cá nhân
  Future<void> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
    bool clearPhoto = false,
  }) async {
    await _authRepository.updateProfile(
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      clearPhoto: clearPhoto,
    );
    notifyListeners();
  }

  /// A07: Lấy danh sách khách hàng
  Future<List<UserModel>> getAllCustomers() {
    return _authRepository.getAllCustomers();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    await loadAddresses();
    notifyListeners();
  }
}
