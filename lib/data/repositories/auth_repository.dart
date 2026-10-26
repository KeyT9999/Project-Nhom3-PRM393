import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/services/connectivity_service.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/firestore_collections.dart';
import '../local/local_file_storage_service.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final LocalFileStorageService _localStorage;
  UserModel? _currentUser;
  bool _googleInitialized = false;

  static const String _webServerClientId =
      '8251934788-6mo8s6he3pmt9fqsv9vs3fcm73c39fb2.apps.googleusercontent.com';

  final List<UserModel> _knownCustomers = [
    const UserModel(
      uid: 'cust_01',
      name: 'Nguyễn Văn A',
      email: 'customer@smartstore.vn',
      phone: '0901234567',
      role: 'customer',
    ),
    const UserModel(
      uid: 'cust_02',
      name: 'Trần Thị Bích Ngọc',
      email: 'ngoctran@gmail.com',
      phone: '0912345678',
      role: 'customer',
    ),
    const UserModel(
      uid: 'admin_01',
      name: 'Quản trị viên SmartStore',
      email: 'admin@smartstore.vn',
      phone: '0988888888',
      role: 'admin',
    ),
  ];

  AuthRepository({LocalFileStorageService? localStorage})
    : _localStorage = localStorage ?? LocalFileStorageService();

  UserModel? get currentUser => _currentUser;
  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  Future<UserModel> _syncFirebaseUserToFirestore(
    User fbUser, {
    String? customName,
    String? customPhone,
  }) async {
    final email = fbUser.email ?? '';
    final token = await fbUser.getIdTokenResult();
    final role = token.claims?['admin'] == true ? 'admin' : 'customer';

    final userDocRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .doc(fbUser.uid);
    final docSnap = await userDocRef.get();

    if (docSnap.exists && docSnap.data() != null) {
      final stored = UserModel.fromJson(docSnap.data()!);
      _currentUser = UserModel(
        uid: fbUser.uid,
        name: stored.name,
        email: email,
        phone: stored.phone,
        photoUrl: stored.photoUrl,
        role: role,
      );
    } else {
      _currentUser = UserModel(
        uid: fbUser.uid,
        name: customName ?? fbUser.displayName ?? email.split('@').first,
        email: email,
        phone: customPhone ?? '0901234567',
        photoUrl: fbUser.photoURL,
        role: role,
      );
      await userDocRef.set({
        ..._currentUser!.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    _upsertKnownCustomer(_currentUser!);
    return _currentUser!;
  }

  void _upsertKnownCustomer(UserModel user) {
    final idx = _knownCustomers.indexWhere((u) => u.email == user.email);
    if (idx >= 0) {
      _knownCustomers[idx] = user;
    } else {
      _knownCustomers.insert(0, user);
    }
  }

  /// F01: Đăng ký tài khoản Email/Password & gửi email xác thực
  Future<UserModel> registerWithEmail({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    if (_isFirebaseReady) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final fbUser = cred.user;
        if (fbUser != null) {
          await fbUser.updateDisplayName(name);
          try {
            await fbUser.sendEmailVerification();
          } catch (_) {}
          return await _syncFirebaseUserToFirestore(
            fbUser,
            customName: name,
            customPhone: phone,
          );
        }
      } on FirebaseAuthException {
        rethrow;
      }
    }

    throw StateError('Firebase chưa được khởi tạo.');
  }

  /// F02: Đăng nhập Email/Password
  Future<UserModel> signInWithEmail(String email, String password) async {
    if (_isFirebaseReady) {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = cred.user;
      if (fbUser != null) {
        return await _syncFirebaseUserToFirestore(fbUser);
      }
      throw StateError('Firebase không trả về tài khoản.');
    }
    throw StateError('Firebase chưa được khởi tạo.');
  }

  /// F02: Đăng nhập bằng tài khoản Google trên Android
  Future<UserModel> signInWithGoogle() async {
    if (_isFirebaseReady) {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: _webServerClientId,
        );
        _googleInitialized = true;
      }

      final googleAccount = await GoogleSignIn.instance.authenticate();
      final idToken = googleAccount.authentication.idToken;
      final oauthCred = GoogleAuthProvider.credential(idToken: idToken);
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        oauthCred,
      );

      final fbUser = userCred.user;
      if (fbUser != null) {
        return await _syncFirebaseUserToFirestore(fbUser);
      }
    }
    throw Exception('Chưa khởi tạo kết nối Firebase cho Google Sign-In');
  }

  /// F03: Quên mật khẩu - Gửi email khôi phục
  Future<void> sendPasswordResetEmail(String email) async {
    if (_isFirebaseReady) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException {
        rethrow;
      }
    }
  }

  /// F17: Cập nhật hồ sơ cá nhân (Tên, Số điện thoại, Ảnh đại diện)
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    final current = _currentUser;
    if (current == null) {
      throw Exception('Vui lòng đăng nhập trước khi cập nhật hồ sơ');
    }

    _currentUser = UserModel(
      uid: current.uid,
      name: name,
      email: current.email,
      phone: phone,
      photoUrl: photoUrl ?? current.photoUrl,
      role: current.role,
    );
    _upsertKnownCustomer(_currentUser!);

    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(current.uid)
            .set(_currentUser!.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
    return _currentUser!;
  }

  /// F18: Đọc danh sách Sổ địa chỉ (Local JSON + Cloud Firestore)
  Future<List<AddressModel>> loadAddresses(String userId) async {
    final raw = await _localStorage.loadAddresses(userId);
    if (raw.isNotEmpty) {
      return raw.map(AddressModel.fromJson).toList();
    }

    if (_isFirebaseReady && userId != 'guest') {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(FirestoreCollections.addresses)
            .get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs
              .map((d) => AddressModel.fromJson(d.data()))
              .toList();
          await _localStorage.saveAddresses(
            userId,
            list.map((e) => e.toJson()).toList(),
          );
          return list;
        }
      } catch (_) {}
    }

    if (userId != 'guest') return [];
    return const [
      AddressModel(
        id: 'addr_default_1',
        fullName: 'Nguyễn Văn A',
        phone: '0901234567',
        addressLine:
            'Lô E2a-7, Đường D1, Khu Công Nghệ Cao, TP. Thủ Đức, TP.HCM',
        isDefault: true,
      ),
      AddressModel(
        id: 'addr_office_2',
        fullName: 'Nguyễn Văn A (Văn phòng)',
        phone: '0901234567',
        addressLine: 'Tòa nhà Bitexco, Số 2 Hải Triều, Quận 1, TP.HCM',
        isDefault: false,
      ),
    ];
  }

  /// F18: Lưu danh sách Sổ địa chỉ
  Future<void> saveAddresses(
    String userId,
    List<AddressModel> addresses,
  ) async {
    await _localStorage.saveAddresses(
      userId,
      addresses.map((e) => e.toJson()).toList(),
    );

    if (_isFirebaseReady && userId != 'guest') {
      try {
        final col = FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(FirestoreCollections.addresses);
        final batch = FirebaseFirestore.instance.batch();
        final existing = await col.get();
        final retained = addresses.map((a) => a.id).toSet();
        for (final doc in existing.docs) {
          if (!retained.contains(doc.id)) batch.delete(doc.reference);
        }
        for (final addr in addresses) {
          batch.set(col.doc(addr.id), addr.toJson());
        }
        await batch.commit();
      } catch (_) {}
    }
  }

  /// A07: Admin lấy danh sách toàn bộ khách hàng
  Future<List<UserModel>> getAllCustomers() async {
    if (_isFirebaseReady) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => UserModel.fromJson(d.data())).toList();
        }
      } catch (_) {}
    }
    return List.unmodifiable(_knownCustomers);
  }

  Future<void> signOut() async {
    if (_isFirebaseReady) {
      try {
        if (_googleInitialized) {
          await GoogleSignIn.instance.signOut();
        }
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    _currentUser = null;
  }
}
