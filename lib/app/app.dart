import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/offline_mode_banner.dart';
import '../features/cart/cart_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/products/catalog_screen.dart';
import '../features/profile/profile_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class SmartStoreApp extends StatelessWidget {
  const SmartStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: 'SmartStore',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(auth.palette),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

class SmartStoreMainShell extends StatefulWidget {
  const SmartStoreMainShell({super.key});

  @override
  State<SmartStoreMainShell> createState() => _SmartStoreMainShellState();
}

class _SmartStoreMainShellState extends State<SmartStoreMainShell> {
  int _currentIndex = 0;
  bool _wasOffline = false;

  static const List<Widget> _tabs = [
    HomeScreen(),
    CatalogScreen(),
    CartScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalQuantity;
    final unreadAlerts = context.watch<NotificationProvider>().unreadCount;
    final auth = context.watch<AuthProvider>();
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final wishlistProvider = context.read<WishlistProvider>();
    if (_wasOffline && !auth.isOfflineSimulated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await cartProvider.syncToCloud();
        if (!mounted) return;
        await wishlistProvider.syncToCloud();
        if (!mounted) return;
        await authProvider.syncAddresses();
      });
    }
    _wasOffline = auth.isOfflineSimulated;

    return Scaffold(
      body: Column(
        children: [
          OfflineModeBanner(
            isOffline: auth.isOfflineSimulated,
            onToggleSimulate: () => auth.toggleOfflineSimulation(false),
          ),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _tabs),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Catalog',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unreadAlerts > 0,
                label: Text('$unreadAlerts'),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: unreadAlerts > 0,
                label: Text('$unreadAlerts'),
                child: const Icon(Icons.notifications_rounded),
              ),
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
