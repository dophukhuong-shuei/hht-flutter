import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/dashboard/main_menu_screen.dart';
import '../presentation/tenant_selection/tenant_selection_screen.dart';
import '../presentation/warehouse_receipt/wr_list_screen.dart';
import '../presentation/warehouse_receipt/wr_detail_screen.dart';
import '../presentation/warehouse_receipt/wr_filter_screen.dart';
import '../presentation/putaway/putaway_list_screen.dart';
import '../presentation/picking/picking_list_screen.dart';
import '../presentation/picking/picking_items_screen.dart';
import '../presentation/picking/picking_detail_screen.dart';
import '../presentation/bundle/bundle_list_screen.dart';
import '../presentation/bundle/bundle_items_screen.dart';
import '../presentation/bundle/bundle_detail_screen.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/picking/picking_line.dart';
import '../data/models/bundle/bundle_line.dart';
import '../data/models/warehouse_receipt/receipt_order.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final isLoggingIn = state.matchedLocation == RouteNames.login;

    if (!isLoggedIn && !isLoggingIn) {
      return RouteNames.login;
    }
    if (isLoggedIn && isLoggingIn) {
      return RouteNames.mainMenu;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.mainMenu,
      builder: (context, state) => const MainMenuScreen(),
    ),
    // Tenant Selection
    GoRoute(
      path: RouteNames.tenantSelection,
      builder: (context, state) {
        final funcNumber = state.uri.queryParameters['funcNumber'];
        return TenantSelectionScreen(funcNumber: funcNumber);
      },
    ),
    // Warehouse Receipt Routes - Separate routes to avoid redirect issues
    GoRoute(
      path: RouteNames.warehouseReceiptList,
      builder: (context, state) {
        final tenantId =
            int.tryParse(state.uri.queryParameters['tenantId'] ?? '') ?? 0;
        final company = state.uri.queryParameters['company'] ?? '';
        final vendorId = state.uri.queryParameters['vendorId'];
        return WRListScreen(
          tenantId: tenantId,
          company: company,
          vendorId: vendorId,
        );
      },
    ),
    GoRoute(
      path: RouteNames.warehouseReceiptDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final receipt = extra?['receipt'] as ReceiptOrder?;
        final tenantId = extra?['tenantId'] as int? ?? 0;
        if (receipt == null) {
          return const SizedBox.shrink();
        }
        return WRDetailsScreen(
          receipt: receipt,
          tenantId: tenantId,
        );
      },
    ),
    GoRoute(
      path: RouteNames.warehouseReceiptFilter,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final tenantId =
            extra?['tenantId'] as int? ??
            int.tryParse(state.uri.queryParameters['tenantId'] ?? '') ??
            0;
        final company = extra?['company'] as String? ??
            state.uri.queryParameters['company'] ??
            '';
        return WRFilterScreen(tenantId: tenantId, company: company);
      },
    ),
    // Putaway Routes
    GoRoute(
      path: RouteNames.putawayList,
      builder: (context, state) => const PutawayListScreen(),
    ),
    GoRoute(
      path: RouteNames.putawayDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final productCode = extra?['productCode'] as String? ?? '';
        // TODO: Create PutawayDetailsScreen
        return const SizedBox.shrink();
      },
    ),
    // Picking Routes
    GoRoute(
      path: RouteNames.pickingList,
      builder: (context, state) {
        final tenantId =
            int.tryParse(state.uri.queryParameters['tenantId'] ?? '') ?? 0;
        final company = state.uri.queryParameters['company'] ?? '';
        return PickingListScreen(
          tenantId: tenantId,
          company: company,
        );
      },
    ),
    GoRoute(
      path: RouteNames.pickingItems,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final pickNo = extra?['pickNo'] as String? ?? '';
        final tenantId = extra?['tenantId'] as int? ?? 0;
        final company = extra?['company'] as String? ?? '';
        return PickingItemsScreen(
          pickNo: pickNo,
          tenantId: tenantId,
          company: company,
        );
      },
    ),
    GoRoute(
      path: RouteNames.pickingDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final pickNo = extra?['pickNo'] as String? ?? '';
        final pickingLine = extra?['pickingLine'] as PickingLine?;
        final currentIndex = extra?['currentIndex'] as int? ?? 0;
        final tenantId = extra?['tenantId'] as int? ?? 0;
        final company = extra?['company'] as String? ?? '';
        return PickingDetailScreen(
          pickNo: pickNo,
          pickingLine: pickingLine,
          currentIndex: currentIndex,
          tenantId: tenantId,
          company: company,
        );
      },
    ),
    // Bundle Routes
    GoRoute(
      path: RouteNames.bundleList,
      builder: (context, state) => const BundleListScreen(),
    ),
    GoRoute(
      path: RouteNames.bundleItems,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final transNo = extra?['transNo'] as String? ?? '';
        return BundleItemsScreen(transNo: transNo);
      },
    ),
    GoRoute(
      path: RouteNames.bundleDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final transNo = extra?['transNo'] as String? ?? '';
        final bundleLine = extra?['bundleLine'] as BundleLine?;
        final currentIndex = extra?['currentIndex'] as int? ?? 0;
        return BundleDetailScreen(
          transNo: transNo,
          bundleLine: bundleLine,
          currentIndex: currentIndex,
        );
      },
    ),
    // Add other routes as needed...
  ],
);

