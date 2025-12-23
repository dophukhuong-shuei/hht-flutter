import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/dashboard/main_menu_screen.dart';
import '../presentation/warehouse_receipt/wr_list_screen.dart';
import '../presentation/warehouse_receipt/wr_details_screen.dart';
import '../presentation/warehouse_receipt/wr_filter_screen.dart';
import '../data/models/warehouse_receipt/receipt_order.dart';
import 'route_names.dart';

class AppRouter {
  static GoRouter createRouter(bool isAuthenticated) {
    return GoRouter(
      initialLocation: isAuthenticated ? '/main-menu' : '/login',
      redirect: (context, state) {
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        if (isAuthenticated && isLoggingIn) {
          return '/main-menu';
        }

        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),

        // Dashboard routes
        GoRoute(
          path: '/main-menu',
          name: RouteNames.mainMenu,
          builder: (context, state) => const MainMenuScreen(),
        ),

        // Warehouse Receipt routes
        GoRoute(
          path: '/warehouse-receipt/list',
          name: RouteNames.warehouseReceiptList,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return WRListScreen(
              tenantId: args?['tenantId'] ?? 0,
              vendorId: args?['vendorId'],
            );
          },
        ),
        GoRoute(
          path: '/warehouse-receipt/details',
          name: RouteNames.warehouseReceiptDetails,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            return WRDetailsScreen(
              receipt: args['receipt'] as ReceiptOrder,
              tenantId: args['tenantId'] as int,
            );
          },
        ),
        GoRoute(
          path: '/warehouse-receipt/filter',
          name: RouteNames.warehouseReceiptFilter,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            return WRFilterScreen(
              tenantId: args['tenantId'] as int,
            );
          },
        ),
      ],
    );
  }
}

