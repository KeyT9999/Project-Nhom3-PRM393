import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/routes/app_router.dart';
import 'core/config/env_config.dart';
import 'core/services/local_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await LocalNotificationService.initialize(
      onNotificationTap: (orderId) {
        if (orderId != null && orderId.isNotEmpty) {
          AppRouter.router.push('/orders/${Uri.encodeComponent(orderId)}');
        }
      },
    );
  } catch (e) {
    debugPrint('Firebase/Notification init notice: $e');
  }

  runApp(const SmartStoreApp());
}
