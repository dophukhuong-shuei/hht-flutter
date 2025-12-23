import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../routes/route_names.dart';
import '../providers/auth_provider.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  List<MenuItem> get _menuItems => [
    MenuItem(
      id: 1,
      title: '1. 入荷',
      color: AppColors.menuColors[0],
      route: RouteNames.warehouseReceipt,
    ),
    MenuItem(
      id: 2,
      title: '2. 棚上げ',
      color: AppColors.menuColors[1],
      route: '/putaway',
    ),
    MenuItem(
      id: 3,
      title: '3. ピッキング',
      color: AppColors.menuColors[2],
      route: '/picking',
    ),
    MenuItem(
      id: 4,
      title: '4. 事前セット',
      color: AppColors.menuColors[3],
      route: '/bundle',
    ),
    MenuItem(
      id: 5,
      title: '5. 棚移動',
      color: AppColors.menuColors[4],
      route: '/bin-movement',
    ),
    MenuItem(
      id: 6,
      title: '6. 棚卸',
      color: AppColors.menuColors[5],
      route: '/bin-audit',
    ),
    MenuItem(
      id: 7,
      title: '7. ログアウト',
      color: AppColors.menuColors[6],
      route: '/logout',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lighter,
      appBar: AppBar(
        title: const Text('メニュー'),
        backgroundColor: AppColors.headerColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Text(
                      authProvider.userName ?? 'User Name',
                      style: const TextStyle(fontSize: 11),
                    );
                  },
                ),
                Text(
                  '${AppConfig.env} V${AppConfig.version}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: item.color,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: () {
                  if (item.route == '/logout') {
                    _handleLogout(context);
                  } else {
                    context.push(item.route);
                  }
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            child: const Text('はい'),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final int id;
  final String title;
  final Color color;
  final String route;

  const MenuItem({
    required this.id,
    required this.title,
    required this.color,
    required this.route,
  });
}

