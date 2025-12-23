import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/dashboard/main_menu_screen.dart';
import '../presentation/warehouse_receipt/wr_list_screen.dart';
import '../presentation/warehouse_receipt/wr_detail_screen.dart';
import '../presentation/providers/auth_provider.dart';
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
    // Warehouse Receipt Routes
    GoRoute(
      path: RouteNames.warehouseReceipt,
      builder: (context, state) => const WRListScreen(),
      routes: [
        GoRoute(
          path: 'list',
          builder: (context, state) => const WRListScreen(),
        ),
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return WRDetailScreen(id: id);
          },
        ),
      ],
    ),
    // Add other routes as needed...
  ],
);

