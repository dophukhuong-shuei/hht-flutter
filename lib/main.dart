import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme_config.dart';
import 'core/storage/local_storage.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/warehouse_receipt_repository.dart';
import 'data/repositories/putaway_repository.dart';
import 'data/repositories/picking_repository.dart';
import 'data/repositories/bundle_repository.dart';
import 'Screens/providers/auth_provider.dart';
import 'Screens/providers/warehouse_receipt_provider.dart';
import 'Screens/providers/putaway_provider.dart';
import 'Screens/providers/picking_provider.dart';
import 'Screens/providers/bundle_provider.dart';
import 'Screens/providers/language_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorage(prefs);
  final apiClient = ApiClient(prefs);
  final authRepo = AuthRepository(apiClient, storage);
  final wrRepo = WarehouseReceiptRepository(apiClient, storage);
  final putawayRepo = PutawayRepository(apiClient, storage);
  final pickingRepo = PickingRepository(apiClient, storage);
  final bundleRepo = BundleRepository(apiClient, storage);

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalStorage>.value(value: storage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<WarehouseReceiptRepository>.value(value: wrRepo),
        Provider<PutawayRepository>.value(value: putawayRepo),
        Provider<PickingRepository>.value(value: pickingRepo),
        Provider<BundleRepository>.value(value: bundleRepo),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepo)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              WarehouseReceiptProvider(wrRepo, storage)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => PutawayProvider(putawayRepo, storage)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => PickingProvider(pickingRepo, storage)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => BundleProvider(bundleRepo, storage)..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;
    return MaterialApp.router(
      title: 'FBTHHT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ja')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
